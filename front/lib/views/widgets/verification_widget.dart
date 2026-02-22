import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/input_validators.dart';
import '../../common/widgets.dart';
import '../viewmodels/registration_viewmodel.dart';

class VerificationWidget extends StatefulWidget {
  final RegistrationViewModel viewModel;

  const VerificationWidget({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => _VerificationWidgetState();
}

class _VerificationWidgetState extends State<VerificationWidget> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child)
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
              onChanged: widget.viewModel.setCpf,
              enabled: false,
              autofocus: true,
              initialValue: widget.viewModel.cpf,
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
                  widget.viewModel.setDataNascimento(date);
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
                  widget.viewModel.dataNascimento != null
                      ? DateFormat('dd/MM/yyyy').format(widget.viewModel.dataNascimento!)
                      : '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.viewModel.isLoading || widget.viewModel.dataNascimento == null
                  ? null
                  : () async {

                try {
                  await widget.viewModel.processarDataNascimento();
                }
                catch (e) {
                  showErrorDialog(
                    context,
                    title: 'Pesquisa por CPF',
                    message: e.toString(),
                    onClose: () {
                      widget.viewModel.resetSearch();
                    },
                  );
                }
              },
              child: const Text('Prosseguir'),
            )
          ],
        );
      },
    );
  }
}