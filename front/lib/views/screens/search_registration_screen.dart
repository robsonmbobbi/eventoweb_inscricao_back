import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/input_validators.dart';
import '../../common/widgets.dart';
import '../../models/enums/enum_situacao_pesquisa_pessoa.dart';
import '../viewmodels/registration_viewmodel.dart';

class SearchRegistrationScreen extends StatefulWidget {
  const SearchRegistrationScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SearchRegistrationScreenState();
}

class _SearchRegistrationScreenState extends State<SearchRegistrationScreen> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisa - Inscrição'),
        leading: BackButton(
            onPressed: () => context.pop()
        ),
      ),
      body: SafeArea(
          child: Consumer<RegistrationViewModel>(
            builder: (BuildContext context, RegistrationViewModel viewModel, Widget? child)
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
                      onChanged: viewModel.setCpf,
                      enabled: !viewModel.cpfBuscado,
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await viewModel.pesquisarCPF(viewModel.cpf);
                          if (context.mounted && viewModel.pesquisa != null) {
                            if (viewModel.pesquisa!.situacao == EnumSituacaoPesquisaPessoa.inscricaoRealizada) {
                              showErrorDialog(
                                context,
                                title: 'Inscrição Existente',
                                message: 'A pessoa dona deste CPF já está inscrita no evento e não poderá fazer nova inscrição.',
                                onClose: () {
                                  viewModel.resetSearch();
                                },
                              );
                            } else {
                              context.go('/registration');
                            }
                          }
                        }
                      },
                      child: const Text('Prosseguir'),
                    ),
                  ],
                ),
              );
            },
          )
      ),
    );
  }

}