import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/dto_inscricao.dart';
import '../../models/enums/enum_tipo_inscricao.dart';

class InscriptionCard extends StatelessWidget {
  final DTOInscricao inscricao;
  final VoidCallback onRemove;

  const InscriptionCard({
    Key? key,
    required this.inscricao,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tipoLabel = inscricao.tipo == EnumTipoInscricao.infantil
        ? 'Infantil'
        : 'Participante';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          inscricao.pessoa.nome,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          tipoLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
