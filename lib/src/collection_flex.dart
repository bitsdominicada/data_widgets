import 'package:flutter/material.dart';

class CollectionRow<T> extends StatelessWidget {
  const CollectionRow({
    super.key,
    required this.source,
    required this.builder,
    required this.onChange,
    this.actions = const [CollectionAction.move, CollectionAction.delete],
    this.itemDecorator,
  });

  final List<T> source;
  final Widget Function(BuildContext, T) builder;
  final ValueChanged<List<T>> onChange;
  final List<CollectionAction> actions;
  final Widget Function(BuildContext context, Widget child)? itemDecorator;

  @override
  Widget build(BuildContext context) {
    return CollectionFlex<T>(
      source: source,
      builder: builder,
      onChange: onChange,
      actions: actions,
      direction: Axis.horizontal,
      itemDecorator: itemDecorator,
    );
  }
}

class CollectionFlex<T> extends StatefulWidget {
  const CollectionFlex({
    super.key,
    required this.source,
    required this.builder,
    required this.onChange,
    required this.direction,
    this.actions = const [CollectionAction.move, CollectionAction.delete],
    this.itemDecorator,
    this.dismissibleDecorator,
    this.showHandle = true,
  });

  final List<T> source;
  final Widget Function(BuildContext, T) builder;
  final ValueChanged<List<T>> onChange;
  final List<CollectionAction> actions;
  final Axis direction;
  final Widget Function(BuildContext context, Widget child)? itemDecorator;
  final Widget Function(BuildContext context, Widget child)?
  dismissibleDecorator;
  final bool showHandle;

  @override
  State<CollectionFlex<T>> createState() => _CollectionFlexState<T>();
}

class _CollectionFlexState<T> extends State<CollectionFlex<T>> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      scrollDirection: widget.direction,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        widget.onChange(_reorder(widget.source, newIndex, oldIndex));
      },
      children: [
        for (int index = 0; index < widget.source.length; index++)
          _buildItem(context, widget.source[index], index),
      ],
    );
  }

  Widget _buildItem(BuildContext context, T item, int index) {
    final innerContent = widget.builder(context, item);

    final Widget withHandle =
        widget.showHandle
            ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(fit: FlexFit.loose, child: innerContent),
                const SizedBox(width: 8),
                _platformHandle(index),
              ],
            )
            : innerContent;

    final Widget reorderable = _reorderableWrapper(withHandle, index);
    final Widget decorated =
        widget.itemDecorator?.call(context, reorderable) ?? reorderable;

    if (!widget.actions.contains(CollectionAction.delete)) {
      return decorated;
    }

    final dismissible = Dismissible(
      key: ValueKey(item),
      direction:
          widget.direction == Axis.vertical
              ? DismissDirection.endToStart
              : DismissDirection.up,
      background: Container(),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final removedItem = item;
        final removedIndex = index;
        final newList = List<T>.from(widget.source)..remove(item);
        widget.onChange(newList);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Elemento eliminado'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () {
                final restoredList = List<T>.from(newList)
                  ..insert(removedIndex, removedItem);
                widget.onChange(restoredList);
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      },
      child: decorated,
    );

    return widget.dismissibleDecorator?.call(context, dismissible) ??
        dismissible;
  }

  Widget _platformHandle(int index) {
    const handle = Icon(Icons.drag_handle);

    if (Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android) {
      return handle; // El ícono es solo decorativo en mobile
    }

    return ReorderableDragStartListener(index: index, child: handle);
  }

  Widget _reorderableWrapper(Widget child, int index) {
    if (Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android) {
      return ReorderableDelayedDragStartListener(index: index, child: child);
    }
    return child;
  }
}

enum CollectionAction {
  move,
  @Deprecated("not yet supported")
  delete,
}

List<T> _reorder<T>(List<T> source, int newIndex, int oldIndex) {
  if (newIndex > oldIndex) newIndex -= 1;
  final items = List<T>.from(source);
  final item = items.removeAt(oldIndex);
  items.insert(newIndex, item);
  return items;
}
