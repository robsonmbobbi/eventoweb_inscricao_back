import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/input_validators.dart';
import '../viewmodels/registration_viewmodel.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<StatefulWidget> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação - Inscrição'),
        leading: BackButton(
            onPressed: _voltar
        ),
      ),
      body: SafeArea(
          child: Consumer<RegistrationViewModel>(
            builder: (BuildContext context, RegistrationViewModel viewModel, Widget? child)
            {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                      hintText: 'Digite seu CPF',
                      prefixIcon: Icon(Icons.person),
                    ),
                    inputFormatters: [InputFormatters.cpfFormatter],
                    validator: InputValidators.validateCPF,
                    onChanged: viewModel.setCpf,
                    enabled: false,
                    autofocus: true,
                    initialValue: viewModel.cpf,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Data de Nascimento',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 6570)),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        viewModel.setDataNascimento(date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Nascimento',
                        hintText: 'Selecione sua data de nascimento',
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        viewModel.dataNascimento != null
                            ? DateFormat('dd/MM/yyyy').format(viewModel.dataNascimento!)
                            : '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: viewModel.isLoading || viewModel.dataNascimento == null
                        ? null
                        : () async {
                      await viewModel.calcularIdade(viewModel.dataNascimento!);
                      if (context.mounted && viewModel.idade != null) {
                        context.go('/regitration');
                      }
                    },
                    child: const Text('Prosseguir'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed:_voltar,
                    child: const Text('Voltar'),
                  ),
                ],
              );
            },
          )
      ),
    );
  }

  void _voltar() {
    context.read<RegistrationViewModel>().resetVerification();
    context.pop();
  }
}