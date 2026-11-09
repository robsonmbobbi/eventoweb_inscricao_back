import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/ExceptionCommand.dart';
import '../../common/input_validators.dart';
import '../../common/widgets.dart';
import '../../models/enums/enum_situacao_pesquisa_pessoa.dart';
import '../viewmodels/registration_viewmodel.dart';

class SearchRegistrationWidget extends StatefulWidget {
  final RegistrationViewModel viewModel;
  const SearchRegistrationWidget({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => _SearchRegistrationWidgetState();
}

class _SearchRegistrationWidgetState extends State<SearchRegistrationWidget> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child)
      {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pesquisar CPF',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: 'Digite seu CPF',
                  prefixIcon: Icon(Icons.person),
                ),
                inputFormatters: [InputFormatters.cpfFormatter],
                validator: InputValidators.validateCPF,
                onChanged: widget.viewModel.setCpf,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await widget.viewModel.processarCPF();
                    }
                    catch (e) {
                      var mensagem = e.toString();
                      if (e is ExceptionCommand) {
                        mensagem = (e).message;
                      }

                      showErrorDialog(
                        context,
                        title: 'Pesquisa por CPF',
                        message: mensagem,
                        onClose: () {
                          widget.viewModel.resetSearch();
                        },
                      );
                    }
                  }
                },
                child: const Text('Prosseguir'),
              ),
            ],
          ),
        );
      },
    );
  }

}