import 'package:data_widgets/data_widgets.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'typed_text_form_field.dart';

class EditableItem {
  EditableItem({required this.name, required this.quantity});
  String name;
  int quantity;
}

class CollectionSliverListView<T> extends StatelessWidget {
  const CollectionSliverListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onChange,
    this.onAdd,
    this.keyBuilder,
    this.actions = const [CollectionAction.move, CollectionAction.delete],
    this.itemDecorator,
    this.dismissibleDecorator,
    this.onVisibleChanged,
    this.onEndReached,
    this.padding = const EdgeInsets.all(0),
    this.sliverHeader,
    this.sliverFooter,
  });

  final List<T> items;
  final VoidCallback? onAdd;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ValueChanged<List<T>> onChange;
  final Key Function(T item)? keyBuilder;
  final List<CollectionAction> actions;
  final Widget Function(BuildContext, Widget)? itemDecorator;
  final Widget Function(BuildContext, Widget)? dismissibleDecorator;
  final void Function(Set<Key> visibleKeys)? onVisibleChanged;
  final VoidCallback? onEndReached;
  final EdgeInsets padding;

  final Widget? sliverHeader;
  final Widget? sliverFooter;

  @override
  Widget build(BuildContext context) {
    final visibleKeys = <Key>{};

    return SliverPadding(
      padding: padding,
      sliver: SliverMainAxisGroup(
        slivers: [
          if (sliverHeader != null) SliverToBoxAdapter(child: sliverHeader!),
          _buildSliverList(context, visibleKeys),
          if (sliverFooter != null) SliverToBoxAdapter(child: sliverFooter!),
          if (onAdd != null)
            SliverToBoxAdapter(
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Agregar elemento'),
                onTap: onAdd,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverList(BuildContext context, Set<Key> visibleKeys) {
    final useReorderable = actions.contains(CollectionAction.move);

    if (useReorderable) {
      return SliverReorderableList(
        itemCount: items.length,
        onReorder: (oldIndex, newIndex) {
          final updated = List<T>.from(items);
          if (newIndex > oldIndex) newIndex--;
          final item = updated.removeAt(oldIndex);
          updated.insert(newIndex, item);
          onChange(updated);
        },
        itemBuilder: (context, index) {
          final item = items[index];
          final key = keyBuilder?.call(item) ?? ValueKey(item);
          return _buildItem(context, item, index, key, visibleKeys);
        },
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          final key = keyBuilder?.call(item) ?? ValueKey(item);
          return _buildItem(context, item, index, key, visibleKeys);
        }, childCount: items.length),
      );
    }
  }

  Widget _buildItem(
    BuildContext context,
    T item,
    int index,
    Key key,
    Set<Key> visibleKeys,
  ) {
    Widget child = itemBuilder(context, item, index);

    // Mostrar ícono de handle si se permite mover
    if (actions.contains(CollectionAction.move)) {
      // Determinar tipo de listener según plataforma
      final handleIcon = const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(Icons.drag_handle),
      );
      final platform = Theme.of(context).platform;
      Widget handle;
      if (platform == TargetPlatform.iOS ||
          platform == TargetPlatform.android) {
        handle = ReorderableDelayedDragStartListener(
          key: ValueKey('handle-$index'),
          index: index,
          child: handleIcon,
        );
      } else {
        handle = ReorderableDragStartListener(
          key: ValueKey('handle-$index'),
          index: index,
          child: handleIcon,
        );
      }
      child = Row(children: [handle, Expanded(child: child)]);
    }

    if (itemDecorator != null) {
      child = itemDecorator!(context, child);
    }

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
                  final restored = List<T>.from(newList)..insert(index, item);
                  onChange(restored);
                },
              ),
            ),
          );
        },
        child: child,
      );

      child =
          dismissibleDecorator != null
              ? dismissibleDecorator!(context, dismissible)
              : dismissible;
    }

    if (onVisibleChanged != null) {
      child = VisibilityDetector(
        key: key,
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0) {
            visibleKeys.add(key);
          } else {
            visibleKeys.remove(key);
          }
          onVisibleChanged!(Set.from(visibleKeys));
        },
        child: child,
      );
    }

    if (onEndReached != null && index == items.length - 1) {
      onEndReached!();
    }

    return child;
  }
}

/// Ejemplo de uso como tabla editable
class EditableTableSliver extends StatefulWidget {
  const EditableTableSliver({super.key});

  @override
  State<EditableTableSliver> createState() => _EditableTableSliverState();
}

class _EditableTableSliverState extends State<EditableTableSliver> {
  List<EditableItem> items = [
    EditableItem(name: 'Producto A', quantity: 10),
    EditableItem(name: 'Producto B', quantity: 5),
    EditableItem(name: 'Producto C', quantity: 3),
  ];

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  // Forzar actualización programática para probar ConcurrentChangePolicy
  void _forceUpdate() {
    // Creamos nuevos objetos con los mismos valores pero diferentes instancias
    // para asegurar que Flutter detecte el cambio
    setState(() {
      items = [
        EditableItem(name: 'Producto A (Modificado)', quantity: 12),
        EditableItem(name: 'Producto B (Modificado)', quantity: 8),
        EditableItem(name: 'Producto C (Modificado)', quantity: 5),
        EditableItem(name: 'Producto D (Nuevo)', quantity: 7),
      ];
    });

    // Segundo setState para asegurar la actualización completa
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CollectionList<EditableItem>(
                mode: CollectionListMode.sliver,
                items: items,
                onChange: (newItems) => setState(() => items = newItems),
                onAdd:
                    () => setState(
                      () => items.add(EditableItem(name: '', quantity: 0)),
                    ),
                actions: const [CollectionAction.move, CollectionAction.delete],
                sliverHeader: Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Nombre',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Cantidad',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                sliverFooter: Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$totalQuantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context, item, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextInputField(
                            initialValue: item.name,
                            onChanged:
                                (v) => setState(() {
                                  item.name = v ?? '';
                                }),
                            debounceTime: const Duration(milliseconds: 500),
                            selectAllOnFocus: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IntTextFormField(
                            initialValue: item.quantity,
                            onChange:
                                (v) => setState(() {
                                  item.quantity = v ?? 0;
                                }),
                            debounceTime: const Duration(milliseconds: 500),
                            selectAllOnFocus: true,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _forceUpdate,
              heroTag: 'refresh_fab',
              child: const Icon(Icons.refresh),
              tooltip:
                  'Forzar actualización para probar ConcurrentChangePolicy',
            ),
          ),
          // Botón para agregar nueva fila
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  items.add(EditableItem(name: '', quantity: 0));
                });
              },
              heroTag: 'add_fab',
              child: const Icon(Icons.add),
              tooltip: 'Agregar nueva fila',
            ),
          ),
        ],
      ),
    );
  }
}
