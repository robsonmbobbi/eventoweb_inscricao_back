import 'package:flutter/material.dart';
import 'package:front2/views/viewmodels/registration_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegulationScreen extends StatelessWidget
{
  const RegulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regulamento'),
        leading: BackButton(
          onPressed: () => context.pop()
        ),
      ),
      body: SafeArea(
        child: Consumer<RegistrationViewModel>(
          builder: (BuildContext context, RegistrationViewModel viewModel, Widget? child)
          {
            return Column(
              children: [
                Expanded(
                  child: Text('texto aqui'),
                ),
                const SizedBox(height: 16),

                // Action buttons
                ElevatedButton(
                  onPressed: () async {
                    viewModel.setRegulamentoAceito();
                    context.go('/search');
                  },
                  child: const Text('Aceito os termos'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('Não aceito'),
                ),
              ],
            );
          },
        )
      ),
    );
  }
}