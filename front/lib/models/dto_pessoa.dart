import 'enums/enums.dart';

/// Representa os dados pessoais de um inscrito
class DTOPessoa {
  final String nome;
  final DateTime? dataNascimento;
  final String cpf;
  final String? alergiaAlimentos;
  final String celular;
  final bool ehDiabetico;
  final bool ehVegetariano;
  final String email;
  final EnumSexo? sexo;
  final bool usaAdocanteDiariamente;

  DTOPessoa({
    required this.nome,
    required this.dataNascimento,
    required this.cpf,
    required this.celular,
    required this.email,
    this.alergiaAlimentos,
    this.ehDiabetico = false,
    this.ehVegetariano = false,
    this.sexo,
    this.usaAdocanteDiariamente = false,
  });

  factory DTOPessoa.fromJson(Map<String, dynamic> json) => DTOPessoa(
      nome: json['nome'],
      dataNascimento: json['dataNascimento'] == null ? null : DateTime.parse(json['dataNascimento']),
      cpf: json['cpf'],
      alergiaAlimentos: json['alergiaAlimentos'],
      celular: json['celular'],
      ehDiabetico: json['ehDiabetico'] ?? false,
      ehVegetariano: json['ehVegetariano'] ?? false,
      email: json['email'],
      sexo: json['sexo'] != null ? EnumSexo.values[json['sexo']] : null,
      usaAdocanteDiariamente: json['usaAdocanteDiariamente'] ?? false,
    );

  Map<String, dynamic> toJson() => {
      'nome': nome,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'cpf': cpf,
      'alergiaAlimentos': alergiaAlimentos,
      'celular': celular,
      'ehDiabetico': ehDiabetico,
      'ehVegetariano': ehVegetariano,
      'email': email,
      'sexo': sexo?.index,
      'usaAdocanteDiariamente': usaAdocanteDiariamente,
    };

  DTOPessoa copyWith({
    String? nome,
    DateTime? dataNascimento,
    String? cpf,
    String? alergiaAlimentos,
    String? celular,
    bool? ehDiabetico,
    bool? ehVegetariano,
    String? email,
    EnumSexo? sexo,
    bool? usaAdocanteDiariamente,
  }) => DTOPessoa(
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      cpf: cpf ?? this.cpf,
      alergiaAlimentos: alergiaAlimentos ?? this.alergiaAlimentos,
      celular: celular ?? this.celular,
      ehDiabetico: ehDiabetico ?? this.ehDiabetico,
      ehVegetariano: ehVegetariano ?? this.ehVegetariano,
      email: email ?? this.email,
      sexo: sexo ?? this.sexo,
      usaAdocanteDiariamente: usaAdocanteDiariamente ?? this.usaAdocanteDiariamente,
    );
}
