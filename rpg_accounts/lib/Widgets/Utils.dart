// import 'package:flutter/services.dart';

import 'package:flutter/services.dart';

class NumberFormatter {
  /// Formatea un número con separadores de miles y decimales
  /// [value] - Valor a formatear (puede ser num, String o null)
  /// [decimalPlaces] - Cantidad de decimales a mostrar (default: 2)
  static String format(dynamic value, {int decimalPlaces = 2}) {
    if (value == null || value == '') return '0.00';
    
    // Convertir a número
    final number = value is num ? value : double.tryParse(value.toString());
    if (number == null) return '0.00';
    
    // Formatear el número
    final formatted = number.toStringAsFixed(decimalPlaces);
    final parts = formatted.split('.');
    var integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Agregar separadores de miles
    final result = StringBuffer();
    var count = 0;
    
    for (var i = integerPart.length - 1; i >= 0; i--) {
      result.write(integerPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        result.write(',');
      }
    }
    
    // Invertir y agregar decimales
    var formattedInteger = result.toString().split('').reversed.join();
    return decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
  }

  /// Convierte un valor formateado de vuelta a número
  /// [formattedValue] - Valor formateado (ej: "1,234.56")
  static num parse(String formattedValue) {
    if (formattedValue.isEmpty) return 0;
    final cleanValue = formattedValue.replaceAll(',', '');
    return num.tryParse(cleanValue) ?? 0;
  }

  /// Formatea un valor monetario
  /// [value] - Valor a formatear
  /// [symbol] - Símbolo monetario (opcional)
  static String formatCurrency(dynamic value, {String symbol = ''}) {
    final formatted = format(value);
    return symbol.isNotEmpty ? '$symbol $formatted' : formatted;
  }
}

class MoneyInputFormatter extends TextInputFormatter {
  final bool allowDecimal;
  final String currencySymbol;
  final int decimalDigits;

  MoneyInputFormatter({
    this.allowDecimal = true,
    this.currencySymbol = '\$',
    this.decimalDigits = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, 
    TextEditingValue newValue,
  ) {
    // 1. Permitir signo negativo al inicio
    bool isNegative = newValue.text.startsWith('-');
    
    // 2. Si solo hay un signo negativo, permitirlo
    if (newValue.text == '-' && oldValue.text.isEmpty) {
      return TextEditingValue(
        text: '-',
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    
    // 3. Determinar si es una operación de borrado (ORIGINAL)
    final isBackspace = oldValue.text.length > newValue.text.length;
    
    // 4. Limpiar el texto (MODIFICADO: mantener signo negativo)
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d.-]'), '');
    
    // 5. Manejar múltiples signos negativos (NUEVO)
    if (cleanText.contains('-')) {
      isNegative = true;
      cleanText = cleanText.replaceAll('-', '');
    }
    
    // 6. Manejar el punto decimal (ORIGINAL)
    if (allowDecimal) {
      final dotIndex = cleanText.indexOf('.');
      if (dotIndex != -1) {
        // Limitar a un punto decimal
        cleanText = cleanText.substring(0, dotIndex + 1) + 
                   cleanText.substring(dotIndex + 1).replaceAll('.', '');
        // Limitar decimales según decimalDigits
        if (cleanText.length > dotIndex + 1 + decimalDigits) {
          cleanText = cleanText.substring(0, dotIndex + 1 + decimalDigits);
        }
      }
    } else {
      // Si no se permiten decimales, quitar cualquier punto
      cleanText = cleanText.replaceAll('.', '');
    }

    // 7. Formatear con separadores de miles (ORIGINAL con modificación para negativos)
    String formattedText = _formatWithCommas(cleanText);
    if (isNegative) {
      formattedText = '-$formattedText';
    }
    formattedText = currencySymbol + formattedText;

    // 8. Calcular posición inteligente del cursor (ORIGINAL con mejora para negativos)
    int cursorPosition = _calculateSmartCursorPosition(
      oldValue: oldValue,
      newValue: newValue,
      formattedText: formattedText,
      cleanText: cleanText,
      isBackspace: isBackspace,
      isNegative: isNegative,
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  String _formatWithCommas(String value) {
    if (value.isEmpty) return '';
    
    List<String> parts = value.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Procesar parte entera con separadores de miles (ORIGINAL)
    String formattedInteger = '';
    int digitCount = 0;
    
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedInteger = integerPart[i] + formattedInteger;
      digitCount++;
      if (digitCount % 3 == 0 && i != 0) {
        formattedInteger = ',$formattedInteger';
      }
    }

    return formattedInteger + decimalPart;
  }

  int _calculateSmartCursorPosition({
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
    required String formattedText,
    required String cleanText,
    required bool isBackspace,
    required bool isNegative,
  }) {
    final oldText = oldValue.text;
    final newText = newValue.text;
    final oldOffset = oldValue.selection.baseOffset;
    final newOffset = newValue.selection.baseOffset;

    // Caso especial: Borrado de un separador de miles (ORIGINAL)
    if (isBackspace && oldOffset > 0 && oldText[oldOffset - 1] == ',') {
      return oldOffset - 1; // Saltar la coma al borrar
    }

    // Caso especial: Insertar antes de una coma (ORIGINAL)
    if (!isBackspace && newOffset < oldText.length && oldText[newOffset] == ',') {
      return newOffset + 1; // Saltar la coma al insertar
    }

    // Caso especial: Borrado en decimales (ORIGINAL)
    if (allowDecimal && oldText.contains('.') && oldOffset > oldText.indexOf('.')) {
      // Mantener posición relativa en decimales
      if (newOffset > 0 && newText.length >= newOffset) {
        return newOffset;
      }
    }

    // Caso general: Calcular posición basada en el texto limpio (ORIGINAL mejorado)
    int cleanOffset = newOffset;
    int formattedOffset = 0;
    int cleanIndex = 0;
    
    for (int i = 0; i < formattedText.length && cleanIndex < cleanOffset; i++) {
      // MODIFICADO: Incluir el símbolo de moneda y signo negativo en los caracteres a saltar
      if (formattedText[i] == ',' || 
          formattedText[i] == currencySymbol || 
          formattedText[i] == '-') {
        continue;
      }
      cleanIndex++;
      formattedOffset = i + 1;
    }

    return formattedOffset.clamp(0, formattedText.length);
  }

  static double parseFormattedMoney(String formattedMoney) {
    if (formattedMoney.isEmpty) return 0.0;
    
    // NUEVO: Verificar si es negativo
    bool isNegative = formattedMoney.startsWith('-');
    
    // MODIFICADO: Mantener signo negativo en la limpieza
    String cleanValue = formattedMoney.replaceAll(RegExp(r'[^\d.-]'), '');
    
    // NUEVO: Manejar múltiples signos negativos
    if (cleanValue.contains('-')) {
      isNegative = true;
      cleanValue = cleanValue.replaceAll('-', '');
    }
    
    // ORIGINAL: Parsear el valor
    double value = double.tryParse(cleanValue) ?? 0.0;
    
    // NUEVO: Aplicar signo negativo
    return isNegative ? -value.abs() : value;
  }
}
// class NumberFormatter {
//   /// Formatea un número con separadores de miles y decimales
//   /// [value] - Valor a formatear (puede ser num, String o null)
//   /// [decimalPlaces] - Cantidad de decimales a mostrar (default: 2)
//   static String format(dynamic value, {int decimalPlaces = 2}) {
//     if (value == null || value == '') return '0.00';
    
//     // Convertir a número
//     final number = value is num ? value : double.tryParse(value.toString());
//     if (number == null) return '0.00';
    
//     // Formatear el número
//     final formatted = number.toStringAsFixed(decimalPlaces);
//     final parts = formatted.split('.');
//     var integerPart = parts[0];
//     final decimalPart = parts.length > 1 ? parts[1] : '';
    
//     // Agregar separadores de miles
//     final result = StringBuffer();
//     var count = 0;
    
//     for (var i = integerPart.length - 1; i >= 0; i--) {
//       result.write(integerPart[i]);
//       count++;
//       if (count % 3 == 0 && i != 0) {
//         result.write(',');
//       }
//     }
    
//     // Invertir y agregar decimales
//     var formattedInteger = result.toString().split('').reversed.join();
//     return decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
//   }

//   /// Convierte un valor formateado de vuelta a número
//   /// [formattedValue] - Valor formateado (ej: "1,234.56")
//   static num parse(String formattedValue) {
//     if (formattedValue.isEmpty) return 0;
//     final cleanValue = formattedValue.replaceAll(',', '');
//     return num.tryParse(cleanValue) ?? 0;
//   }

//   /// Formatea un valor monetario
//   /// [value] - Valor a formatear
//   /// [symbol] - Símbolo monetario (opcional)
//   static String formatCurrency(dynamic value, {String symbol = ''}) {
//     final formatted = format(value);
//     return symbol.isNotEmpty ? '$symbol $formatted' : formatted;
//   }
// }
// class MoneyInputFormatter extends TextInputFormatter {
//   final bool allowDecimal;
//   final String currencySymbol;
//   final int decimalDigits;

//   MoneyInputFormatter({
//     this.allowDecimal = true,
//     this.currencySymbol = '\$',
//     this.decimalDigits = 2,
//   });

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue, 
//     TextEditingValue newValue,
//   ) {
//     // 1. Determinar si es una operación de borrado
//     final isBackspace = oldValue.text.length > newValue.text.length;
    
//     // 2. Limpiar el texto (quitar todo excepto dígitos y punto decimal)
//     String cleanText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    
//     // 3. Manejar el punto decimal
//     if (allowDecimal) {
//       final dotIndex = cleanText.indexOf('.');
//       if (dotIndex != -1) {
//         // Limitar a un punto decimal
//         cleanText = cleanText.substring(0, dotIndex + 1) + 
//                    cleanText.substring(dotIndex + 1).replaceAll('.', '');
//         // Limitar decimales según decimalDigits
//         if (cleanText.length > dotIndex + 1 + decimalDigits) {
//           cleanText = cleanText.substring(0, dotIndex + 1 + decimalDigits);
//         }
//       }
//     } else {
//       // Si no se permiten decimales, quitar cualquier punto
//       cleanText = cleanText.replaceAll('.', '');
//     }

//     // 4. Formatear con separadores de miles
//     String formattedText = _formatWithCommas(cleanText);
//     formattedText = currencySymbol + formattedText;

//     // 5. Calcular posición inteligente del cursor
//     int cursorPosition = _calculateSmartCursorPosition(
//       oldValue: oldValue,
//       newValue: newValue,
//       formattedText: formattedText,
//       cleanText: cleanText,
//       isBackspace: isBackspace,
//     );

//     return TextEditingValue(
//       text: formattedText,
//       selection: TextSelection.collapsed(offset: cursorPosition),
//     );
//   }

//   String _formatWithCommas(String value) {
//     if (value.isEmpty) return '';
    
//     List<String> parts = value.split('.');
//     String integerPart = parts[0];
//     String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

//     // Procesar parte entera con separadores de miles
//     String formattedInteger = '';
//     int digitCount = 0;
    
//     for (int i = integerPart.length - 1; i >= 0; i--) {
//       formattedInteger = integerPart[i] + formattedInteger;
//       digitCount++;
//       if (digitCount % 3 == 0 && i != 0) {
//         formattedInteger = ',$formattedInteger';
//       }
//     }

//     return formattedInteger + decimalPart;
//   }

//   int _calculateSmartCursorPosition({
//     required TextEditingValue oldValue,
//     required TextEditingValue newValue,
//     required String formattedText,
//     required String cleanText,
//     required bool isBackspace,
//   }) {
//     final oldText = oldValue.text;
//     final newText = newValue.text;
//     final oldOffset = oldValue.selection.baseOffset;
//     final newOffset = newValue.selection.baseOffset;

//     // Caso especial: Borrado de un separador de miles
//     if (isBackspace && oldOffset > 0 && oldText[oldOffset - 1] == ',') {
//       return oldOffset - 1; // Saltar la coma al borrar
//     }

//     // Caso especial: Insertar antes de una coma
//     if (!isBackspace && newOffset < oldText.length && oldText[newOffset] == ',') {
//       return newOffset + 1; // Saltar la coma al insertar
//     }

//     // Caso especial: Borrado en decimales
//     if (allowDecimal && oldText.contains('.') && oldOffset > oldText.indexOf('.')) {
//       // Mantener posición relativa en decimales
//       if (newOffset > 0 && newText.length >= newOffset) {
//         return newOffset;
//       }
//     }

//     // Caso general: Calcular posición basada en el texto limpio
//     int cleanOffset = newOffset;
//     int formattedOffset = 0;
//     int cleanIndex = 0;
    
//     for (int i = 0; i < formattedText.length && cleanIndex < cleanOffset; i++) {
//       if (formattedText[i] == ',' || formattedText[i] == currencySymbol) {
//         continue;
//       }
//       cleanIndex++;
//       formattedOffset = i + 1;
//     }

//     return formattedOffset.clamp(0, formattedText.length);
//   }

//   static double parseFormattedMoney(String formattedMoney) {
//     return double.tryParse(
//       formattedMoney.replaceAll(RegExp(r'[^\d.]'), '')
//     ) ?? 0.0;
//   }
// }