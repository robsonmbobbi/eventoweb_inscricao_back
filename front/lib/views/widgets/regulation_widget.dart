import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:front2/views/viewmodels/registration_viewmodel.dart';
import 'package:go_router/go_router.dart';

class RegulationWidget extends StatelessWidget
{
  final RegistrationViewModel viewModel;

  const RegulationWidget({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Regulamento',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),

        Html(data: viewModel.evento?.regulamento ?? ""),

        const SizedBox(height: 24),

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