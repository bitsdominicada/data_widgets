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
      title: 'Data Widgets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Widgets Demo')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FormFieldsDemo()),
                    ),
                child: const Text('Campos de Formulario'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Tabla Editable'),
                              ),
                              body: const EditableTableSliver(),
                            ),
                      ),
                    ),
                child: const Text('Tabla Editable'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Lista Ordenable'),
                              ),
                              body: const MyReorderableListScreen(),
                            ),
                      ),
                    ),
                child: const Text('Lista Ordenable'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MySliverListScreen(),
                      ),
                    ),
                child: const Text('Lista Sliver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum UserRole { admin, editor, viewer, guest }

class FormFieldsDemo extends StatefulWidget {
  const FormFieldsDemo({super.key});

  @override
  State<FormFieldsDemo> createState() => _FormFieldsDemoState();
}

class _FormFieldsDemoState extends State<FormFieldsDemo> {
  String? _name;
  String? _email;
  String? _password;
  int? _age;
  double? _height;
  UserRole _selectedRole = UserRole.viewer;
  DateTime? _birthDate;

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.editor:
        return 'Editor';
      case UserRole.viewer:
        return 'Visualizador';
      case UserRole.guest:
        return 'Invitado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campos de Formulario')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Texto normal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextInputField(
                initialValue: _name,
                onChanged: (value) => setState(() => _name = value),
                debounceTime: const Duration(milliseconds: 500),
                selectAllOnFocus: true,
                decoration: const InputDecoration(
                  hintText: 'Introduce tu nombre',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Correo electrónico',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              EmailTextFormField(
                initialValue: _email,
                onChanged: (value) => setState(() => _email = value),
                debounceTime: const Duration(milliseconds: 500),
                selectAllOnFocus: true,
              ),
              const SizedBox(height: 16),

              const Text(
                'Contraseña',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              PasswordTextFormField(
                initialValue: _password,
                onChanged: (value) => setState(() => _password = value),
                debounceTime: const Duration(milliseconds: 500),
                minLength: 8,
                requireSpecialChars: true,
              ),
              const SizedBox(height: 16),

              const Text('Edad', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              IntTextFormField(
                initialValue: _age,
                onChange: (value) => setState(() => _age = value),
                debounceTime: const Duration(milliseconds: 300),
                selectAllOnFocus: true,
              ),
              const SizedBox(height: 16),

              const Text(
                'Altura (m)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DoubleTextFormField(
                initialValue: _height,
                onChange: (value) => setState(() => _height = value),
                debounceTime: const Duration(milliseconds: 300),
                selectAllOnFocus: true,
              ),
              const SizedBox(height: 16),

              const Text(
                'Rol de usuario',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              EnumDropdownField<UserRole>(
                values: UserRole.values,
                initialValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value),
                displayNameBuilder: _getRoleName,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Fecha de nacimiento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DatePickerField(
                initialValue: _birthDate,
                onChanged: (value) => setState(() => _birthDate = value),
                decoration: const InputDecoration(
                  hintText: 'Selecciona tu fecha de nacimiento',
                  border: OutlineInputBorder(),
                ),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 24),

              const Text(
                'Valores actuales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Nombre: $_name'),
              Text('Email: $_email'),
              Text('Contraseña: $_password'),
              Text('Edad: $_age'),
              Text('Altura: $_height'),
              Text('Rol: ${_getRoleName(_selectedRole)}'),
              Text(
                'Fecha de nacimiento: ${_birthDate != null ? "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}" : "No seleccionada"}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyReorderableListScreen extends StatefulWidget {
  const MyReorderableListScreen({super.key});

  @override
  State<MyReorderableListScreen> createState() =>
      _MyReorderableListScreenState();
}

class _MyReorderableListScreenState extends State<MyReorderableListScreen> {
  List<String> _items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];

  void _handleReorder(List<String> updatedItems) {
    setState(() {
      _items = updatedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CollectionList<String>(
      mode:
          CollectionListMode.sliver, // 🔁 Puedes cambiar a .sliver o .animated
      items: _items,
      onChange: _handleReorder,
      itemBuilder: (context, item, index) => ListTile(title: Text(item)),
      itemDecorator: (context, child) => Card(child: child),
      dismissibleDecorator:
          (context, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: child,
          ),
      onEndReached: () => print("🧭 Scroll llegó al final"),
      onVisibleChanged: (keys) => print("👁️ Ítems visibles: $keys"),
      actions: const [CollectionAction.move, CollectionAction.delete],
    );
  }
}

class MySliverListScreen extends StatefulWidget {
  const MySliverListScreen({super.key});

  @override
  State<MySliverListScreen> createState() => _MySliverListScreenState();
}

class _MySliverListScreenState extends State<MySliverListScreen> {
  List<String> _items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];

  void _handleChange(List<String> updated) {
    setState(() {
      _items = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Sliver CollectionList')),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Listado dinámico con Sliver',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          CollectionList<String>(
            mode: CollectionListMode.sliver,
            items: _items,
            onChange: _handleChange,
            itemBuilder: (context, item, index) => ListTile(title: Text(item)),
            itemDecorator: (context, child) => Card(child: child),
            dismissibleDecorator:
                (context, child) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: child,
                ),
            onEndReached: () => print("Scroll llegó al final"),
            onVisibleChanged: (keys) => print("Visibles: $keys"),
            actions: const [CollectionAction.delete, CollectionAction.move],
            sliverHeader: const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text("👆 Arrastra o desliza para eliminar"),
            ),
            sliverFooter: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
