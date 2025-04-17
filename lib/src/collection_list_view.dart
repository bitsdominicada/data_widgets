import 'package:data_widgets/data_widgets.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CollectionListView<T> extends StatelessWidget {
  const CollectionListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onChange,
    this.keyBuilder,
    this.actions = const [CollectionAction.move, CollectionAction.delete],
    this.itemDecorator,
    this.dismissibleDecorator,
    this.onVisibleChanged,
    this.onEndReached,
    this.padding = const EdgeInsets.all(0),
    this.onAdd,
  });

  final List<T> items;
  final Widget Function(BuildContext, T item, int index) itemBuilder;
  final ValueChanged<List<T>> onChange;
  final Key Function(T item)? keyBuilder;
  final List<CollectionAction> actions;
  final Widget Function(BuildContext context, Widget child)? itemDecorator;
  final Widget Function(BuildContext context, Widget child)?
  dismissibleDecorator;
  final void Function(Set<Key> visibleKeys)? onVisibleChanged;
  final VoidCallback? onEndReached;
  final EdgeInsets padding;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final visibleKeys = <Key>{};
    final totalItems = items.length + (onAdd != null ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (onEndReached != null &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.95) {
          onEndReached!();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: totalItems,
        padding: padding,
        itemBuilder: (context, index) {
          // Si es la última posición y tenemos onAdd, mostrar botón Agregar
          if (onAdd != null && index == items.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Agregar elemento'),
              onTap: onAdd,
            );
          }
          final item = items[index];
          final key = keyBuilder?.call(item) ?? ValueKey(item);

          Widget content = itemBuilder(context, item, index);

          // Decorar con handle (solo si move está activo)
          if (actions.contains(CollectionAction.move)) {
            content = Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle), // No reordenable, es visual
              ],
            );
          }

          // Decorar ítem
          if (itemDecorator != null) {
            content = itemDecorator!(context, content);
          }

          // Wrap con Dismissible si delete está activo
          if (actions.contains(CollectionAction.delete)) {
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
                final newList = List<T>.from(items)..removeAt(index);
                onChange(newList);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Elemento eliminado'),
                    action: SnackBarAction(
                      label: 'Deshacer',
                      onPressed: () {
                        final restoredList = List<T>.from(newList)
                          ..insert(index, item);
                        onChange(restoredList);
                      },
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              child: content,
            );

            content =
                dismissibleDecorator != null
                    ? dismissibleDecorator!(context, dismissible)
                    : dismissible;
          }

          // Visibilidad
          if (onVisibleChanged != null) {
            content = VisibilityDetector(
              key: key,
              onVisibilityChanged: (info) {
                if (info.visibleFraction > 0) {
                  visibleKeys.add(key);
                } else {
                  visibleKeys.remove(key);
                }
                onVisibleChanged!(Set.from(visibleKeys));
              },
              child: content,
            );
          }

          return content;
        },
      ),
    );
  }
}
