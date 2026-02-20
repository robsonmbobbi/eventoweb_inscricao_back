import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/input_validators.dart';
import '../../common/widgets.dart';
import '../../core/theme.dart';
import '../../models/dto_evento.dart';
import '../../models/enums/enum_sexo.dart';
import '../../models/enums/enum_situacao_pesquisa_pessoa.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../viewmodels/registration_viewmodel.dart';


class RegistrationScreen extends StatefulWidget {
  final int eventId;
  final DTOEvento evento;

  const RegistrationScreen({
    super.key,
    required this.eventId,
    required this.evento,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late RegistrationViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0: CPF, 1: DOB (for new), 2: Form fields

  @override
  void initState() {
    super.initState();
    _viewModel = context.read();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return WillPopScope(
      onWillPop: () async {
        context.go('/orders');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inscrição'),
          leading: BackButton(
            onPressed: () => context.go('/orders'),
          ),
        ),
        body: SafeArea(
          child: ChangeNotifierProvider.value(
            value: _viewModel,
            child: Consumer<RegistrationViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showErrorDialog(
                      context,
                      message: viewModel.error!,
                      onClose: () {
                        viewModel.clearError();
                      },
                    );
                  });
                }

                return LoadingOverlay(
                  isLoading: viewModel.isLoading,
                  message: 'Processando...',
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 32,
                        vertical: 24,
                      ),
                      child: _buildForm(context, viewModel, isMobile),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    RegistrationViewModel viewModel,
    bool isMobile,
  ) {
    if (_step == 0) {
      return _buildCPFStep(context, viewModel, isMobile);
    } else if (_step == 1 && viewModel.pesquisa?.situacao == EnumSituacaoPesquisaPessoa.inscricaoNaoExiste) {
      return _buildDOBStep(context, viewModel, isMobile);
    } else {
      return _buildFullForm(context, viewModel, isMobile);
    }
  }

  Widget _buildCPFStep(
    BuildContext context,
    RegistrationViewModel viewModel,
    bool isMobile,
  ) => Form(
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
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      await viewModel.pesquisarCPF(viewModel.cpf);
                      if (context.mounted && viewModel.pesquisa != null) {
                        if (viewModel.pesquisa!.situacao ==
                            EnumSituacaoPesquisaPessoa.inscricaoRealizada) {
                          // Show that person is already registered
                          showErrorDialog(
                            context,
                            title: 'Inscrição Existente',
                            message:
                                'A pessoa dona deste CPF já está inscrita no evento e não poderá fazer nova inscrição.',
                            onClose: () {
                              viewModel.reset();
                              _step = 0;
                            },
                          );
                        } else if (viewModel.pesquisa!.situacao ==
                            EnumSituacaoPesquisaPessoa.inscricaoNoLimbo) {
                          // Load form with existing data
                          setState(() {
                            _step = 2;
                          });
                        } else if (viewModel.pesquisa!.situacao ==
                            EnumSituacaoPesquisaPessoa.inscricaoNaoExiste) {
                          // Ask for date of birth
                          setState(() {
                            _step = 1;
                          });
                        }
                      }
                    }
                  },
            child: const Text('Prosseguir'),
          ),
        ],
      ),
    );

  Widget _buildDOBStep(
    BuildContext context,
    RegistrationViewModel viewModel,
    bool isMobile,
  ) => Column(
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
                    setState(() {
                      _step = 2;
                    });
                  }
                },
          child: const Text('Prosseguir'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            context.go('/orders');
          },
          child: const Text('Voltar'),
        ),
      ],
    );

  Widget _buildFullForm(
    BuildContext context,
    RegistrationViewModel viewModel,
    bool isMobile,
  ) => Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Determine type of registration
          if (viewModel.idade != null && viewModel.pesquisa != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Card(
                color: AppColors.secondary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    viewModel.idade! < widget.evento.idadeMinimaAdulto
                        ? 'Inscrição do tipo: INFANTIL'
                        : 'Inscrição do tipo: PARTICIPANTE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

          // CPF (disabled)
          TextFormField(
            initialValue: viewModel.cpf,
            decoration: const InputDecoration(
              labelText: 'CPF',
              prefixIcon: Icon(Icons.person),
            ),
            inputFormatters: [InputFormatters.cpfFormatter],
            enabled: false,
          ),
          const SizedBox(height: 16),

          // Date of Birth (disabled)
          InkWell(
            onTap: null,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                viewModel.dataNascimento != null
                    ? DateFormat('dd/MM/yyyy').format(viewModel.dataNascimento!)
                    : '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          TextFormField(
            initialValue: viewModel.nome,
            decoration: const InputDecoration(
              labelText: 'Nome Completo *',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) =>
                InputValidators.validateRequired(value, 'Nome'),
            onChanged: viewModel.setNome,
            maxLength: 200,
          ),
          const SizedBox(height: 16),

          // Nome do Crachá
          TextFormField(
            initialValue: viewModel.nomeCracha,
            decoration: const InputDecoration(
              labelText: 'Nome do Crachá',
              hintText: 'Nome que aparecerá no seu crachá',
              prefixIcon: Icon(Icons.badge),
            ),
            onChanged: viewModel.setNomeCracha,
            maxLength: 150,
          ),
          const SizedBox(height: 16),

          // Sexo
          DropdownButtonFormField<EnumSexo?>(
            initialValue: viewModel.sexo,
            decoration: const InputDecoration(
              labelText: 'Sexo *',
              prefixIcon: Icon(Icons.wc),
            ),
            items: const [
              DropdownMenuItem(
                value: EnumSexo.masculino,
                child: Text('Masculino'),
              ),
              DropdownMenuItem(
                value: EnumSexo.feminino,
                child: Text('Feminino'),
              ),
            ],
            validator: (value) => value == null ? 'Sexo é obrigatório' : null,
            onChanged: viewModel.setSexo,
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            initialValue: viewModel.email,
            decoration: const InputDecoration(
              labelText: 'Email *',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: InputValidators.validateEmail,
            onChanged: viewModel.setEmail,
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // Celular
          TextFormField(
            initialValue: viewModel.celular,
            decoration: const InputDecoration(
              labelText: 'Celular *',
              prefixIcon: Icon(Icons.phone),
            ),
            inputFormatters: [InputFormatters.celularFormatter],
            validator: InputValidators.validateCelular,
            onChanged: viewModel.setCelular,
          ),
          const SizedBox(height: 16),

          // Alergia a alimentos
          TextFormField(
            initialValue: viewModel.alergiaAlimentos,
            decoration: const InputDecoration(
              labelText: 'Alergia a Alimentos',
              hintText: 'Digite se tiver alguma alergia',
              prefixIcon: Icon(Icons.restaurant),
            ),
            onChanged: viewModel.setAlergiaAlimentos,
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // É Diabético
          CheckboxListTile(
            title: const Text('É diabético?'),
            value: viewModel.ehDiabetico,
            onChanged: (value) => viewModel.setEhDiabetico(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),

          // É Vegetariano
          CheckboxListTile(
            title: const Text('É vegetariano?'),
            value: viewModel.ehVegetariano,
            onChanged: (value) => viewModel.setEhVegetariano(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),

          // Usa Adoçante Diariamente
          CheckboxListTile(
            title: const Text('Usa adoçante diariamente?'),
            value: viewModel.usaAdocanteDiariamente,
            onChanged: (value) =>
                viewModel.setUsaAdocanteDiariamente(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),

          // Dormirá no evento
          CheckboxListTile(
            title: const Text('Dormirá no evento?'),
            value: viewModel.dormeEvento,
            onChanged: (value) => viewModel.setDormeEvento(value ?? true),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),

          // Fields for adulto type
          if (viewModel.idade != null && viewModel.idade! >= widget.evento.idadeMinimaAdulto) ...[
            TextFormField(
              initialValue: viewModel.instituicoesEspiritasFrequenta,
              decoration: const InputDecoration(
                labelText: 'Instituições Espíritas que Frequenta',
                hintText: 'Digite as instituições que você frequenta',
                prefixIcon: Icon(Icons.location_city),
              ),
              onChanged: viewModel.setInstituicoesEspiritasFrequenta,
              maxLength: 300,
            ),
            const SizedBox(height: 16),
          ],

          // Fields for infantil type
          if (viewModel.idade != null && viewModel.idade! < widget.evento.idadeMinimaAdulto) ...[
            Text(
              'Responsáveis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: viewModel.cpfResponsavel1,
              decoration: const InputDecoration(
                labelText: 'CPF Responsável 1 *',
                hintText: 'CPF do responsável 1',
                prefixIcon: Icon(Icons.person),
              ),
              inputFormatters: [InputFormatters.cpfFormatter],
              validator: (value) =>
                  InputValidators.validateRequired(value, 'CPF Responsável 1'),
              onChanged: viewModel.setCpfResponsavel1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: viewModel.nomeResponsavel1,
              decoration: const InputDecoration(
                labelText: 'Nome Responsável 1 *',
                hintText: 'Nome do responsável 1',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => InputValidators.validateRequired(
                  value, 'Nome Responsável 1'),
              onChanged: viewModel.setNomeResponsavel1,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: viewModel.cpfResponsavel2,
              decoration: const InputDecoration(
                labelText: 'CPF Responsável 2',
                hintText: 'CPF do responsável 2 (opcional)',
                prefixIcon: Icon(Icons.person),
              ),
              inputFormatters: [InputFormatters.cpfFormatter],
              onChanged: viewModel.setCpfResponsavel2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: viewModel.nomeResponsavel2,
              decoration: const InputDecoration(
                labelText: 'Nome Responsável 2',
                hintText: 'Nome do responsável 2 (opcional)',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: viewModel.setNomeResponsavel2,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
          ],

          // Observações
          TextFormField(
            initialValue: viewModel.observacoes,
            decoration: const InputDecoration(
              labelText: 'Observações',
              hintText: 'Deixe aqui qualquer observação importante',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 4,
            onChanged: viewModel.setObservacoes,
          ),
          const SizedBox(height: 16),

          // Action buttons
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      final resultado = await viewModel.salvarInscricao();
                      if (context.mounted && resultado != null) {
                        // Add to orders
                        context.read<OrdersViewModel>().adicionarInscricao(resultado);
                        // Show success
                        showSuccessDialog(
                          context,
                          message: 'Inscrição realizada com sucesso!',
                          onClose: () {
                            context.go('/orders');
                          },
                        );
                      }
                    }
                  },
            child: const Text('Salvar Inscrição'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              context.go('/orders');
            },
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
}
