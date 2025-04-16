import 'package:data_widgets/data_widgets.dart';
import 'package:flutter/material.dart';

enum CollectionListMode { standard, sliver, animated }

class CollectionList<T> extends StatelessWidget {
  const CollectionList({
    super.key,
    required this.mode,
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
    this.sliverHeader,
    this.sliverFooter,
  });

  final CollectionListMode mode;
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final ValueChanged<List<T>> onChange;

  final Key Function(T item)? keyBuilder;
  final List<CollectionAction> actions;
  final Widget Function(BuildContext, Widget)? itemDecorator;
  final Widget Function(BuildContext, Widget)? dismissibleDecorator;
  final void Function(Set<Key>)? onVisibleChanged;
  final VoidCallback? onEndReached;
  final EdgeInsets padding;

  // Solo para modo sliver
  final Widget? sliverHeader;
  final Widget? sliverFooter;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case CollectionListMode.standard:
        return CollectionListView<T>(
          items: items,
          onChange: onChange,
          itemBuilder: itemBuilder,
          keyBuilder: keyBuilder,
          actions: actions,
          itemDecorator: itemDecorator,
          dismissibleDecorator: dismissibleDecorator,
          onVisibleChanged: onVisibleChanged,
          onEndReached: onEndReached,
          padding: padding,
        );

      case CollectionListMode.sliver:
        return CollectionSliverListView<T>(
          items: items,
          onChange: onChange,
          itemBuilder: itemBuilder,
          keyBuilder: keyBuilder,
          actions: actions,
          itemDecorator: itemDecorator,
          dismissibleDecorator: dismissibleDecorator,
          onVisibleChanged: onVisibleChanged,
          onEndReached: onEndReached,
          padding: padding,
          sliverHeader: sliverHeader,
          sliverFooter: sliverFooter,
        );

      case CollectionListMode.animated:
        return CollectionAnimatedListView<T>(
          initialItems: items,
          onChanged: onChange,
          itemBuilder: itemBuilder,
          keyBuilder: keyBuilder,
          actions: actions,
          itemDecorator: itemDecorator,
          dismissibleDecorator: dismissibleDecorator,
          padding: padding,
        );
    }
  }
}
