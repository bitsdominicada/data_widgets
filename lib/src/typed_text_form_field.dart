// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class IntTextFormField extends StatelessWidget {
  const IntTextFormField({
    super.key,
    this.initialValue,
    this.autofocus = false,
    this.focusNode,
    required this.onChange,
    this.concurrentChangePolicy = ConcurrentChangePolicy.retainCursorPosition,
    this.debounceTime,
    this.selectAllOnFocus = false,
  });

  // TODO: min/max
  final bool autofocus;
  final FocusNode? focusNode;
  final int? initialValue;
  final ValueChanged<int?> onChange;
  final ConcurrentChangePolicy concurrentChangePolicy;
  final Duration? debounceTime;
  final bool selectAllOnFocus;

  @override
  Widget build(BuildContext context) {
    return TypedTextFormField<int>(
      autofocus: autofocus,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChange,
      concurrentChangePolicy: concurrentChangePolicy,
      debounceTime: debounceTime,
      selectAllOnFocus: selectAllOnFocus,
      spec: TypedTextFormFieldSpec(
        serialize: (x) => x?.toString() ?? '',
        deserialize: (x) => int.tryParse(x),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
      ),
    );
  }
}

class DoubleTextFormField extends StatelessWidget {
  const DoubleTextFormField({
    super.key,
    this.initialValue,
    required this.onChange,
    this.autofocus = false,
    this.focusNode,
    this.debounceTime,
    this.selectAllOnFocus = false,
  });

  // TODO: min, max
  final double? initialValue;
  final ValueChanged<double?> onChange;
  final bool autofocus;
  final FocusNode? focusNode;
  final Duration? debounceTime;
  final bool selectAllOnFocus;

  @override
  Widget build(BuildContext context) {
    return TypedTextFormField<double>(
      autofocus: autofocus,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChange,
      debounceTime: debounceTime,
      selectAllOnFocus: selectAllOnFocus,
      spec: TypedTextFormFieldSpec(
        serialize: (x) => x.toString(),
        deserialize: (x) => double.tryParse(x),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}

class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.concurrentChangePolicy = ConcurrentChangePolicy.retainCursorPosition,
    this.debounceTime,
    this.selectAllOnFocus = false,
    this.decoration,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final ConcurrentChangePolicy concurrentChangePolicy;
  final Duration? debounceTime;
  final bool selectAllOnFocus;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return TypedTextFormField<String>(
      autofocus: autofocus,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChanged,
      concurrentChangePolicy: concurrentChangePolicy,
      debounceTime: debounceTime,
      selectAllOnFocus: selectAllOnFocus,
      decoration: decoration,
      spec: TypedTextFormFieldSpec(
        serialize: (x) => x ?? '',
        deserialize: (x) => x,
        inputFormatters: [],
        keyboardType: TextInputType.text,
      ),
    );
  }
}

class EnumDropdownField<T extends Enum> extends StatelessWidget {
  const EnumDropdownField({
    super.key,
    required this.values,
    required this.initialValue,
    required this.onChanged,
    this.displayNameBuilder,
    this.decoration,
    this.isExpanded = true,
  });

  final List<T> values;
  final T initialValue;
  final ValueChanged<T> onChanged;
  final String Function(T value)? displayNameBuilder;
  final InputDecoration? decoration;
  final bool isExpanded;

  String _getDisplayName(T value) {
    if (displayNameBuilder != null) {
      return displayNameBuilder!(value);
    }
    // Por defecto, convertimos el nombre del enum a una forma más legible
    // Por ejemplo: UserRole.admin -> "Admin"
    final name = value.toString().split('.').last;
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: decoration ?? const InputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: isExpanded,
          value: initialValue,
          items:
              values.map((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(_getDisplayName(value)),
                );
              }).toList(),
          onChanged: (T? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.decoration,
    this.dateFormat,
    this.selectableDayPredicate,
    this.locale,
  });

  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final InputDecoration? decoration;
  final String Function(DateTime)? dateFormat;
  final bool Function(DateTime)? selectableDayPredicate;
  final Locale? locale;

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    if (dateFormat != null) {
      return dateFormat!(date);
    }

    // Formato predeterminado: dd/MM/yyyy
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final currentDate = initialValue ?? DateTime.now();

    final firstValidDate = firstDate ?? DateTime(1900);
    final lastValidDate = lastDate ?? DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstValidDate,
      lastDate: lastValidDate,
      selectableDayPredicate: selectableDayPredicate,
      locale: locale,
    );

    if (pickedDate != null) {
      onChanged(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      child: InputDecorator(
        decoration: (decoration ?? const InputDecoration()).copyWith(
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon:
              initialValue != null
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => onChanged(null),
                  )
                  : null,
        ),
        isEmpty: initialValue == null,
        child: Text(
          _formatDate(initialValue),
          style:
              initialValue == null
                  ? Theme.of(context).inputDecorationTheme.hintStyle
                  : null,
        ),
      ),
    );
  }
}

class EmailTextFormField extends StatelessWidget {
  const EmailTextFormField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.concurrentChangePolicy = ConcurrentChangePolicy.retainCursorPosition,
    this.debounceTime,
    this.selectAllOnFocus = false,
    this.decoration,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final ConcurrentChangePolicy concurrentChangePolicy;
  final Duration? debounceTime;
  final bool selectAllOnFocus;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return TypedTextFormField<String>(
      autofocus: autofocus,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChanged,
      concurrentChangePolicy: concurrentChangePolicy,
      debounceTime: debounceTime,
      selectAllOnFocus: selectAllOnFocus,
      decoration:
          decoration ??
          const InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            hintText: 'correo@ejemplo.com',
          ),
      spec: TypedTextFormFieldSpec(
        serialize: (x) => x ?? '',
        deserialize: (x) => x,
        inputFormatters: [
          FilteringTextInputFormatter.deny(
            RegExp(r'\s'),
          ), // No espacios en correos
        ],
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null; // No validamos si está vacío, eso depende de required
          }

          // Expresión regular para validar correos electrónicos básica
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
          if (!emailRegex.hasMatch(value)) {
            return 'Por favor ingresa un correo electrónico válido';
          }
          return null;
        },
      ),
    );
  }
}

class PasswordTextFormField extends StatefulWidget {
  const PasswordTextFormField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.concurrentChangePolicy = ConcurrentChangePolicy.retainCursorPosition,
    this.debounceTime,
    this.selectAllOnFocus = false,
    this.decoration,
    this.minLength = 6,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireDigits = true,
    this.requireSpecialChars = false,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final ConcurrentChangePolicy concurrentChangePolicy;
  final Duration? debounceTime;
  final bool selectAllOnFocus;
  final InputDecoration? decoration;
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireDigits;
  final bool requireSpecialChars;

  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TypedTextFormField<String>(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      concurrentChangePolicy: widget.concurrentChangePolicy,
      debounceTime: widget.debounceTime,
      selectAllOnFocus: widget.selectAllOnFocus,
      obscureText: _obscureText,
      decoration:
          widget.decoration ??
          InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
      spec: TypedTextFormFieldSpec(
        serialize: (x) => x ?? '',
        deserialize: (x) => x,
        inputFormatters: [],
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null; // No validamos si está vacío, eso depende de required
          }

          final List<String> validationErrors = [];

          if (value.length < widget.minLength) {
            validationErrors.add('al menos ${widget.minLength} caracteres');
          }

          if (widget.requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
            validationErrors.add('una letra mayúscula');
          }

          if (widget.requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
            validationErrors.add('una letra minúscula');
          }

          if (widget.requireDigits && !value.contains(RegExp(r'[0-9]'))) {
            validationErrors.add('un número');
          }

          if (widget.requireSpecialChars &&
              !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
            validationErrors.add('un carácter especial');
          }

          if (validationErrors.isNotEmpty) {
            return 'La contraseña debe contener ${validationErrors.join(', ')}';
          }

          return null;
        },
      ),
    );
  }
}

// Nuevo: campo para moneda
class CurrencyTextFormField extends StatelessWidget {
  const CurrencyTextFormField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.debounceTime,
    this.selectAllOnFocus = false,
    this.decoration,
    this.locale,
    this.currencySymbol,
  });

  final double? initialValue;
  final ValueChanged<double?> onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final Duration? debounceTime;
  final bool selectAllOnFocus;
  final InputDecoration? decoration;
  final String? locale;
  final String? currencySymbol;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.simpleCurrency(
      locale: locale ?? Intl.getCurrentLocale(),
      name: currencySymbol,
    );
    return TypedTextFormField<double>(
      autofocus: autofocus,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChanged,
      debounceTime: debounceTime,
      selectAllOnFocus: selectAllOnFocus,
      decoration:
          decoration ??
          InputDecoration(
            prefixIcon: const Icon(Icons.attach_money),
            hintText: fmt.format(0),
          ),
      spec: TypedTextFormFieldSpec(
        serialize: (x) => x != null ? fmt.format(x) : '',
        deserialize: (text) {
          if (text.isEmpty) return null;
          try {
            final num value = fmt.parse(text);
            return value.toDouble();
          } catch (_) {
            return null;
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}

// Nuevo: campo para teléfono
class PhoneTextFormField extends StatelessWidget {
  const PhoneTextFormField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.debounceTime,
    this.selectAllOnFocus = false,
    this.decoration,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final Duration? debounceTime;
  final bool selectAllOnFocus;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return TypedTextFormField<String>(
      autofocus: autofocus,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChanged,
      debounceTime: debounceTime,
      selectAllOnFocus: selectAllOnFocus,
      decoration:
          decoration ??
          const InputDecoration(
            prefixIcon: Icon(Icons.phone),
            hintText: '123-456-7890',
          ),
      spec: TypedTextFormFieldSpec(
        serialize: (x) => x ?? '',
        deserialize: (x) => x,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]+')),
        ],
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          final regex = RegExp(r'^\+?[0-9\s\-()]{6,}$');
          if (!regex.hasMatch(value)) {
            return 'Teléfono inválido';
          }
          return null;
        },
      ),
    );
  }
}

// Para mantener compatibilidad con código existente
@Deprecated('Use TextInputField instead')
class StringFormField extends TextInputField {
  const StringFormField({
    super.key,
    super.initialValue,
    required super.onChanged,
    super.autofocus = false,
    super.focusNode,
    super.concurrentChangePolicy = ConcurrentChangePolicy.retainCursorPosition,
    super.debounceTime,
    super.selectAllOnFocus = false,
  });
}

// Para mantener compatibilidad con código existente
@Deprecated('Use TextInputField instead')
class TextInputFieldmy extends TextInputField {
  const TextInputFieldmy({
    super.key,
    super.initialValue,
    required super.onChanged,
    super.autofocus = false,
    super.focusNode,
    super.concurrentChangePolicy = ConcurrentChangePolicy.retainCursorPosition,
    super.debounceTime,
    super.selectAllOnFocus = false,
  }) : super();
}

enum ConcurrentChangePolicy {
  ignore,
  resetCursorPosition,
  retainCursorPosition,
  showAcceptContextItem,
}

class TypedTextFormField<T> extends StatefulWidget {
  const TypedTextFormField({
    super.key,
    required this.spec,
    required this.autofocus,
    this.focusNode,
    this.initialValue,
    required this.onChanged,
    this.concurrentChangePolicy = ConcurrentChangePolicy.ignore,
    this.debounceTime,
    this.selectAllOnFocus = false,
    this.obscureText = false,
    this.decoration,
  });

  final T? initialValue;
  final TypedTextFormFieldSpec<T> spec;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<T?> onChanged;
  final ConcurrentChangePolicy concurrentChangePolicy;
  final Duration? debounceTime;
  final bool selectAllOnFocus;
  final bool obscureText;
  final InputDecoration? decoration;

  @override
  _TypedTextFormFieldState<T> createState() => _TypedTextFormFieldState<T>();
}

class _TypedTextFormFieldState<T> extends State<TypedTextFormField<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _lastExternalValue;
  bool _userEditing = false;
  Timer? _debounceTimer;
  bool _initialFocusReceived = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.spec.serialize(widget.initialValue),
    );
    _lastExternalValue = _controller.text;
    _focusNode = widget.focusNode ?? FocusNode();

    // Escuchar cambios en el controlador para detectar ediciones del usuario
    _controller.addListener(_onTextChanged);

    // Escuchar cambios en el foco para detectar cuando el usuario comienza/finaliza la edición
    _focusNode.addListener(_onFocusChanged);

    // Validación inicial
    _validateText();
  }

  void _validateText() {
    if (widget.spec.validator != null) {
      setState(() {
        _errorText = widget.spec.validator!(_controller.text);
      });
    }
  }

  void _onTextChanged() {
    // Si el texto cambia mientras el campo tiene el foco, es una edición del usuario
    if (_focusNode.hasFocus && _controller.text != _lastExternalValue) {
      _userEditing = true;

      // Validar el texto
      _validateText();

      // Aplicar debounce si está configurado
      if (widget.debounceTime != null) {
        _debounceOnChanged();
      } else {
        // Llamar directamente a onChanged si no hay debounce
        widget.onChanged(widget.spec.deserialize(_controller.text));
      }
    }
  }

  void _debounceOnChanged() {
    // Cancelar el timer anterior si existe
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Crear un nuevo timer
    _debounceTimer = Timer(
      widget.debounceTime ?? const Duration(milliseconds: 300),
      () {
        if (mounted) {
          widget.onChanged(widget.spec.deserialize(_controller.text));
        }
      },
    );
  }

  void _onFocusChanged() {
    // Cuando el campo gana el foco y queremos seleccionar todo el texto
    if (_focusNode.hasFocus &&
        widget.selectAllOnFocus &&
        !_initialFocusReceived) {
      _initialFocusReceived = true;
      // Usar un microtask para asegurarnos de que la selección se realiza después de que el foco esté completamente aplicado
      Future.microtask(() {
        if (_controller.text.isNotEmpty && mounted) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        }
      });
    }

    // Cuando el campo pierde el foco...
    if (!_focusNode.hasFocus) {
      _initialFocusReceived =
          false; // Reiniciar para la próxima vez que reciba foco

      if (_userEditing) {
        _lastExternalValue = _controller.text;
        _userEditing = false;

        // Validar nuevamente al perder el foco
        _validateText();

        // Si hay un debounce pendiente, ejecutarlo inmediatamente al perder el foco
        if (_debounceTimer?.isActive ?? false) {
          _debounceTimer!.cancel();
          widget.onChanged(widget.spec.deserialize(_controller.text));
        }
      }
    }
  }

  void _handleTextUpdate(String newText) {
    // Solo aplicamos políticas de cambio concurrente si el campo tiene el foco
    // y el usuario ha editado el texto
    if (_focusNode.hasFocus && _userEditing) {
      print('Aplicando política: ${widget.concurrentChangePolicy}');
      print('Texto actual: ${_controller.text}, Nuevo texto: $newText');

      switch (widget.concurrentChangePolicy) {
        case ConcurrentChangePolicy.ignore:
          // No hacemos nada, el usuario mantiene su texto
          print('Política IGNORE: Manteniendo texto del usuario');
          break;

        case ConcurrentChangePolicy.resetCursorPosition:
          print(
            'Política RESET_CURSOR: Actualizando texto y posicionando cursor al inicio',
          );
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: 0),
          );
          _lastExternalValue = newText;
          _userEditing = false;
          break;

        case ConcurrentChangePolicy.retainCursorPosition:
          print(
            'Política RETAIN_CURSOR: Actualizando texto y manteniendo posición del cursor',
          );
          final currentPosition = _controller.selection.baseOffset;
          final adjustedPosition =
              currentPosition > newText.length
                  ? newText.length
                  : currentPosition;

          _controller.value = _controller.value.copyWith(
            text: newText,
            selection: TextSelection.fromPosition(
              TextPosition(offset: adjustedPosition),
            ),
          );
          _lastExternalValue = newText;
          _userEditing = false;
          break;

        case ConcurrentChangePolicy.showAcceptContextItem:
          print(
            'Política SHOW_ACCEPT_DIALOG: Mostrando diálogo de confirmación',
          );
          // Usamos addPostFrameCallback para evitar problemas con el ciclo de vida del widget
          final currentText = _controller.text;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Cambios detectados'),
                  content: Text(
                    'El valor ha cambiado de "$currentText" a "$newText".\n¿Deseas aplicar los cambios?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Mantener mi edición'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (mounted) {
                          _controller.value = TextEditingValue(
                            text: newText,
                            selection: TextSelection.fromPosition(
                              TextPosition(offset: newText.length),
                            ),
                          );
                          _lastExternalValue = newText;
                          _userEditing = false;
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Aceptar cambios'),
                    ),
                  ],
                );
              },
            );
          });
          break;
      }
    } else {
      // Si el campo no tiene el foco o el usuario no ha editado el texto,
      // simplemente actualizamos el valor
      print(
        'Campo sin foco o sin edición del usuario. Actualizando texto directamente.',
      );
      _controller.text = newText;
      _lastExternalValue = newText;

      // Validar después de actualizar el texto
      _validateText();
    }
  }

  @override
  void didUpdateWidget(covariant TypedTextFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el valor inicial cambió, actualizamos el texto
    final newText = widget.spec.serialize(widget.initialValue);

    // Comparación correcta: verificamos si el valor inicial cambió realmente
    if (newText != _lastExternalValue) {
      print(
        'didUpdateWidget: Valor externo cambió de $_lastExternalValue a $newText',
      );
      _handleTextUpdate(newText);
    }

    // Si el FocusNode cambió, actualizamos la referencia
    if (widget.focusNode != null && widget.focusNode != _focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      _focusNode = widget.focusNode!;
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        controller: _controller,
        autofocus: widget.autofocus,
        focusNode: _focusNode,
        autocorrect: false,
        obscureText: widget.obscureText,
        inputFormatters: widget.spec.inputFormatters,
        decoration: (widget.decoration ??
                InputDecoration(hintText: widget.initialValue?.toString()))
            .copyWith(errorText: _errorText),
        onChanged: (_) {
          // La llamada real a onChanged se maneja en _onTextChanged con debounce
        },
        keyboardType: widget.spec.keyboardType,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();

    // Cancelamos cualquier timer pendiente
    _debounceTimer?.cancel();

    // Solo disponemos del FocusNode si lo creamos internamente
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChanged);
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }
}

class TypedTextFormFieldSpec<T> {
  final String Function(T?) serialize;
  final T? Function(String) deserialize;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String? Function(String)? validator;

  TypedTextFormFieldSpec({
    required this.serialize,
    required this.deserialize,
    required this.inputFormatters,
    required this.keyboardType,
    this.validator,
  });
}
