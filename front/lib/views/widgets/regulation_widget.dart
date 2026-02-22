import 'package:flutter/material.dart';
import 'package:front2/views/viewmodels/registration_viewmodel.dart';
import 'package:go_router/go_router.dart';

class RegulationWidget extends StatelessWidget
{
  final RegistrationViewModel viewModel;

  const RegulationWidget({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Regulamento aqui'),
        const SizedBox(height: 16),

        // Action buttons
        ElevatedButton(
          onPressed: () async {
            viewModel.setRegulamentoAceito();
          },
          child: const Text('Aceito o regulamento'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
           Navigator.pop(context);
          },
          child: const Text('Não aceito'),
        ),
      ],
    );
  }
}