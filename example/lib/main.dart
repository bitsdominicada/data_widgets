import 'package:data_widgets/data_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CollectionColumn Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Demo CollectionColumn Reorderable')),
        body: const MyReorderableListScreen(),
      ),
    );
  }
}

// Widget con Estado para manejar la lista
class MyReorderableListScreen extends StatefulWidget {
  const MyReorderableListScreen({super.key});

  @override
  State<MyReorderableListScreen> createState() =>
      _MyReorderableListScreenState();
}

class _MyReorderableListScreenState extends State<MyReorderableListScreen> {
  // 1. Define tu lista de datos en el estado
  List<String> _items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];

  // 2. Define la función que manejará el cambio (reordenamiento)
  void _handleReorder(List<String> reorderedItems) {
    setState(() {
      _items = reorderedItems; // Actualiza el estado con la nueva lista
    });
  }

  // 3. Define cómo se verá cada elemento (el builder)
  Widget _buildItem(BuildContext context, String item) {
    // IMPORTANTE: Proporciona una Key única para cada elemento.
    // ValueKey es una buena opción si el 'item' es único o tiene un id.
    return Card(
      key: ValueKey(item), // <--- ¡CLAVE ESENCIAL!
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(item),
        leading: const Icon(
          Icons.drag_handle,
        ), // Icono para indicar que se puede arrastrar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Como CollectionFlex usa NeverScrollableScrollPhysics,
    // si la lista puede ser larga, envuélvela en un SingleChildScrollView.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CollectionColumn<String>(
          // Usa CollectionColumn (o CollectionRow)
          source: _items, // Pasa la lista del estado
          builder: _buildItem, // Pasa tu función constructora de widgets
          onChange: _handleReorder, // Pasa tu función manejadora de cambios
          // actions: [CollectionAction.move], // Puedes especificar solo las acciones deseadas (aunque delete no funciona aún)
        ),
      ),
    );
  }
}
