import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class InputFormatters {
  // CPF mask formatter: 000.000.000-00
  static final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  // Celular mask formatter: (00) 00000-0000
  static final celularFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  // Telefone mask formatter: (00) 0000-0000
  static final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) ####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  // CEP mask formatter: 00000-000
  static final cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  // CNPJ mask formatter: 00.000.000/0000-00
  static final cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  // Credit card mask formatter: 0000 0000 0000 0000
  static final creditCardFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  // Expiration date formatter: 00/00
  static final expirationDateFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {'#': RegExp(r'[0-9]')},
  );
}

class InputValidators {
  // Validate CPF
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    // Remove masks
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }

    // Check if all digits are the same
    if (cpf.split('').toSet().length == 1) {
      return 'CPF inválido';
    }

    // Validate with check digits (simplified algorithm)
    if (!_isValidCPF(cpf)) {
      return 'CPF inválido';
    }

    return null;
  }

  // Validate CNPJ
  static String? validateCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNPJ é obrigatório';
    }

    final cnpj = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cnpj.length != 14) {
      return 'CNPJ deve conter 14 dígitos';
    }

    if (!_isValidCNPJ(cnpj)) {
      return 'CNPJ inválido';
    }

    return null;
  }

  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  // Validate Celular
  static String? validateCelular(String? value) {
    if (value == null || value.isEmpty) {
      return 'Celular é obrigatório';
    }

    final celular = value.replaceAll(RegExp(r'[^\d]'), '');

    if (celular.length < 10 || celular.length > 11) {
      return 'Celular inválido';
    }

    return null;
  }

  // Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  // Validate field length
  static String? validateLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName não pode ter mais de $maxLength caracteres';
    }
    return null;
  }

  // Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value != null && value.isNotEmpty && value.length < minLength) {
      return '$fieldName deve ter no mínimo $minLength caracteres';
    }
    return null;
  }

  // Validate date is not null
  static String? validateDateRequired(DateTime? value, String fieldName) {
    if (value == null) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  // Validate CEP
  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'CEP é obrigatório';
    }

    final cep = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cep.length != 8) {
      return 'CEP deve conter 8 dígitos';
    }

    return null;
  }

  // Private helper to validate CPF with check digits
  static bool _isValidCPF(String cpf) {
    if (cpf.length != 11) return false;

    int? first = int.tryParse(cpf[0]);
    int? second = int.tryParse(cpf[1]);
    int? third = int.tryParse(cpf[2]);
    int? fourth = int.tryParse(cpf[3]);
    int? fifth = int.tryParse(cpf[4]);
    int? sixth = int.tryParse(cpf[5]);
    int? seventh = int.tryParse(cpf[6]);
    int? eighth = int.tryParse(cpf[7]);
    int? ninth = int.tryParse(cpf[8]);
    int? checkDigit1 = int.tryParse(cpf[9]);
    int? checkDigit2 = int.tryParse(cpf[10]);

    if (first == null || second == null || third == null || 
        fourth == null || fifth == null || sixth == null ||
        seventh == null || eighth == null || ninth == null ||
        checkDigit1 == null || checkDigit2 == null) {
      return false;
    }

    // Calculate first check digit
    int sum = first * 10 +
        second * 9 +
        third * 8 +
        fourth * 7 +
        fifth * 6 +
        sixth * 5 +
        seventh * 4 +
        eighth * 3 +
        ninth * 2;
    int remainder = sum % 11;
    int calculatedCheckDigit1 = remainder < 2 ? 0 : 11 - remainder;

    if (calculatedCheckDigit1 != checkDigit1) return false;

    // Calculate second check digit
    sum = first * 11 +
        second * 10 +
        third * 9 +
        fourth * 8 +
        fifth * 7 +
        sixth * 6 +
        seventh * 5 +
        eighth * 4 +
        ninth * 3 +
        checkDigit1 * 2;
    remainder = sum % 11;
    int calculatedCheckDigit2 = remainder < 2 ? 0 : 11 - remainder;

    return calculatedCheckDigit2 == checkDigit2;
  }

  // Private helper to validate CNPJ with check digits
  static bool _isValidCNPJ(String cnpj) {
    if (cnpj.length != 14) return false;

    // First check digit
    int multiplier = 5;
    int sum = 0;
    for (int i = 0; i < 4; i++) {
      final digit = int.tryParse(cnpj[i]);
      if (digit == null) return false;
      sum += digit * multiplier;
      multiplier--;
    }
    multiplier = 9;
    for (int i = 4; i < 8; i++) {
      final digit = int.tryParse(cnpj[i]);
      if (digit == null) return false;
      sum += digit * multiplier;
      multiplier--;
    }
    int remainder = sum % 11;
    int checkDigit1 = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cnpj[8]) != checkDigit1) return false;

    // Second check digit
    multiplier = 6;
    sum = 0;
    for (int i = 0; i < 5; i++) {
      final digit = int.tryParse(cnpj[i]);
      if (digit == null) return false;
      sum += digit * multiplier;
      multiplier--;
    }
    multiplier = 9;
    for (int i = 5; i < 9; i++) {
      final digit = int.tryParse(cnpj[i]);
      if (digit == null) return false;
      sum += digit * multiplier;
      multiplier--;
    }
    remainder = sum % 11;
    int checkDigit2 = remainder < 2 ? 0 : 11 - remainder;

    return int.parse(cnpj[9]) == checkDigit2;
  }
}
