import 'package:data_widgets/data_widgets.dart';
import 'package:flutter/material.dart';

class CollectionAnimatedListView<T> extends StatefulWidget {
  const CollectionAnimatedListView({
    super.key,
    required this.initialItems,
    required this.itemBuilder,
    required this.onChanged,
    this.actions = const [CollectionAction.move, CollectionAction.delete],
    this.itemDecorator,
    this.dismissibleDecorator,
    this.keyBuilder,
    this.padding = const EdgeInsets.all(0),
  });

  final List<T> initialItems;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ValueChanged<List<T>> onChanged;
  final List<CollectionAction> actions;
  final Widget Function(BuildContext, Widget)? itemDecorator;
  final Widget Function(BuildContext, Widget)? dismissibleDecorator;
  final Key Function(T item)? keyBuilder;
  final EdgeInsets padding;

  @override
  State<CollectionAnimatedListView<T>> createState() =>
      _CollectionAnimatedListViewState<T>();
}

class _CollectionAnimatedListViewState<T>
    extends State<CollectionAnimatedListView<T>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List<T>.from(widget.initialItems);
  }

  void _removeItem(int index) {
    final removedItem = _items[index];
    _items.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _buildAnimatedItem(
        context,
        removedItem,
        index,
        animation,
        removed: true,
      ),
    );
    widget.onChanged(List.from(_items));
  }

  void _insertItem(int index, T item) {
    _items.insert(index, item);
    _listKey.currentState!.insertItem(index);
    widget.onChanged(List.from(_items));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      padding: widget.padding,
      itemBuilder: (context, index, animation) {
        return _buildAnimatedItem(context, _items[index], index, animation);
      },
    );
  }

  Widget _buildAnimatedItem(
    BuildContext context,
    T item,
    int index,
    Animation<double> animation, {
    bool removed = false,
  }) {
    final key = widget.keyBuilder?.call(item) ?? ValueKey(item);

    Widget content = widget.itemBuilder(context, item, index);

    if (widget.actions.contains(CollectionAction.move)) {
      content = Row(
        children: [
          Expanded(child: content),
          const SizedBox(width: 8),
          const Icon(Icons.drag_handle),
        ],
      );
    }

    if (widget.itemDecorator != null) {
      content = widget.itemDecorator!(context, content);
    }

    if (widget.actions.contains(CollectionAction.delete)) {
      final dismissible = Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        background: Container(),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          final removedItem = item;
          _removeItem(index);

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Elemento eliminado'),
              action: SnackBarAction(
                label: 'Deshacer',
                onPressed: () {
                  _insertItem(index, removedItem);
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        },
        child: content,
      );

      content =
          widget.dismissibleDecorator != null
              ? widget.dismissibleDecorator!(context, dismissible)
              : dismissible;
    }

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(opacity: animation, child: content),
    );
  }
}
