import 'package:flutter/material.dart';
import 'package:front2/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/input_validators.dart';
import '../../common/widgets.dart';
import '../../core/theme.dart';
import '../../models/enums/enum_sexo.dart';
import '../viewmodels/registration_viewmodel.dart';

class FormRegistrationWidget extends StatefulWidget {
  
  final RegistrationViewModel viewModel;

  const FormRegistrationWidget({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => _FormRegistrationWidgetState();
}

class _FormRegistrationWidgetState extends State<FormRegistrationWidget> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _txtCPFResponsavel1 = TextEditingController(text: "");
  final TextEditingController _txtNomeResponsavel1 = TextEditingController(text: "");
  final TextEditingController _txtCPFResponsavel2 = TextEditingController(text: "");
  final TextEditingController _txtNomeResponsavel2 = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Determine type of registration
                if (widget.viewModel.idade != null && widget.viewModel.pesquisa != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Card(
                      color: AppColors.secondary.withAlpha((255.0 * 0.1).round()),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.viewModel.idade! < widget.viewModel.evento!.idadeMinimaAdulto
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
                  initialValue: widget.viewModel.cpf,
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
                      widget.viewModel.dataNascimento != null
                          ? DateFormat('dd/MM/yyyy').format(widget.viewModel.dataNascimento!)
                          : '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  initialValue: widget.viewModel.nome,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      InputValidators.validateRequired(value, 'Nome'),
                  onChanged: widget.viewModel.setNome,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),

                // Nome do Crachá
                TextFormField(
                  initialValue: widget.viewModel.nomeCracha,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Crachá',
                    hintText: 'Nome que aparecerá no seu crachá',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  onChanged: widget.viewModel.setNomeCracha,
                  maxLength: 150,
                ),
                const SizedBox(height: 16),

                // Sexo
                DropdownButtonFormField<EnumSexo?>(
                  initialValue: widget.viewModel.sexo,
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
                  onChanged: widget.viewModel.setSexo,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  initialValue: widget.viewModel.email,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: InputValidators.validateEmail,
                  onChanged: widget.viewModel.setEmail,
                  maxLength: 100,
                ),
                const SizedBox(height: 16),

                // Celular
                TextFormField(
                  initialValue: widget.viewModel.celular,
                  decoration: const InputDecoration(
                    labelText: 'Celular *',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  inputFormatters: [InputFormatters.celularFormatter],
                  validator: InputValidators.validateCelular,
                  onChanged: widget.viewModel.setCelular,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: widget.viewModel.cidade,
                  decoration: const InputDecoration(
                    labelText: 'Cidade *',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) => InputValidators.validateRequired(value, "Cidade"),
                  onChanged: widget.viewModel.setCidade,
                  maxLength: 300,
                ),
                const SizedBox(height: 16),

                DropdownMenuFormField<String>(
                  label: const Text('UF *'),
                  leadingIcon: const Icon(Icons.real_estate_agent),
                  validator: (value) => InputValidators.validateRequired(value, "UF"),
                  initialSelection: widget.viewModel.uf,
                  onSelected: (value) => widget.viewModel.setUF(value ?? ''),
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 'AC', label: 'Acre (AC)'),
                    DropdownMenuEntry(value: 'AL', label: 'Alagoas (AL)'),
                    DropdownMenuEntry(value: 'AP', label: 'Amapá (AP)'),
                    DropdownMenuEntry(value: 'AM', label: 'Amazonas (AM)'),
                    DropdownMenuEntry(value: 'BA', label: 'Bahia (BA)'),
                    DropdownMenuEntry(value: 'CE', label: 'Ceará (CE)'),
                    DropdownMenuEntry(value: 'DF', label: 'Distrito Federal (DF)'),
                    DropdownMenuEntry(value: 'ES', label: 'Espírito Santo (ES)'),
                    DropdownMenuEntry(value: 'GO', label: 'Goiás (GO)'),
                    DropdownMenuEntry(value: 'MA', label: 'Maranhão (MA)'),
                    DropdownMenuEntry(value: 'MT', label: 'Mato Grosso (MT)'),
                    DropdownMenuEntry(value: 'MS', label: 'Mato Grosso do Sul (MS)'),
                    DropdownMenuEntry(value: 'MG', label: 'Minas Gerais (MG)'),
                    DropdownMenuEntry(value: 'PA', label: 'Pará (PA)'),
                    DropdownMenuEntry(value: 'PB', label: 'Paraíba (PB)'),
                    DropdownMenuEntry(value: 'PR', label: 'Paraná (PR)'),
                    DropdownMenuEntry(value: 'PE', label: 'Pernambuco (PE)'),
                    DropdownMenuEntry(value: 'PI', label: 'Piauí (PI)'),
                    DropdownMenuEntry(value: 'RJ', label: 'Rio de Janeiro (RJ)'),
                    DropdownMenuEntry(value: 'RN', label: 'Rio Grande do Norte (RN)'),
                    DropdownMenuEntry(value: 'RS', label: 'Rio Grande do Sul (RS)'),
                    DropdownMenuEntry(value: 'RO', label: 'Rondônia (RO)'),
                    DropdownMenuEntry(value: 'RR', label: 'Roraima (RR)'),
                    DropdownMenuEntry(value: 'SC', label: 'Santa Catarina (SC)'),
                    DropdownMenuEntry(value: 'SP', label: 'São Paulo (SP)'),
                    DropdownMenuEntry(value: 'SE', label: 'Sergipe (SE)'),
                    DropdownMenuEntry(value: 'TO', label: 'Tocantins (TO)'),
                  ],
                ),
                const SizedBox(height: 16),

                // Alergia a alimentos
                TextFormField(
                  initialValue: widget.viewModel.alergiaAlimentos,
                  decoration: const InputDecoration(
                    labelText: 'Alergia a Alimentos',
                    hintText: 'Digite se tiver alguma alergia',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  onChanged: widget.viewModel.setAlergiaAlimentos,
                  maxLength: 100,
                ),
                const SizedBox(height: 16),

                // É Diabético
                CheckboxListTile(
                  title: const Text('É diabético?'),
                  value: widget.viewModel.ehDiabetico,
                  onChanged: (value) => widget.viewModel.setEhDiabetico(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 8),

                // É Vegetariano
                CheckboxListTile(
                  title: const Text('É vegetariano?'),
                  value: widget.viewModel.ehVegetariano,
                  onChanged: (value) => widget.viewModel.setEhVegetariano(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 8),

                // Usa Adoçante Diariamente
                CheckboxListTile(
                  title: const Text('Usa adoçante diariamente?'),
                  value: widget.viewModel.usaAdocanteDiariamente,
                  onChanged: (value) =>
                      widget.viewModel.setUsaAdocanteDiariamente(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),

                // Dormirá no evento
                CheckboxListTile(
                  title: const Text('Dormirá no evento?'),
                  value: widget.viewModel.dormeEvento,
                  onChanged: (value) => widget.viewModel.setDormeEvento(value ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),

                // Fields for adulto type
                if (widget.viewModel.idade != null && widget.viewModel.idade! >= widget.viewModel.evento!.idadeMinimaAdulto) ...[
                  TextFormField(
                    initialValue: widget.viewModel.instituicoesEspiritasFrequenta,
                    decoration: const InputDecoration(
                      labelText: 'Instituições Espíritas que Frequenta',
                      hintText: 'Digite as instituições que você frequenta',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onChanged: widget.viewModel.setInstituicoesEspiritasFrequenta,
                    maxLength: 300,
                  ),
                  const SizedBox(height: 16),
                ],

                // Fields for infantil type
                if (widget.viewModel.idade != null && widget.viewModel.idade! < widget.viewModel.evento!.idadeMinimaAdulto) ...[
                  Text(
                    'Responsáveis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: widget.viewModel.buscarResponsavel1,
                    builder: (ctx, child) {
                      if (widget.viewModel.buscarResponsavel1.error) {
                        var error = widget.viewModel.buscarResponsavel1.result as ErrorCommand;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showErrorDialog(
                            context,
                            message: error.error.toString(),
                            onClose: () {
                              widget.viewModel.buscarResponsavel1.clearResult();
                            },
                          );
                        });
                      }

                      if (widget.viewModel.buscarResponsavel1.completed) {
                        var resposta = widget.viewModel.buscarResponsavel1.result as OkCommand<bool>;
                        if (!resposta.value) {
                          _txtNomeResponsavel1.clear();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showErrorDialog(
                              context,
                              message: "Não encontramos nenhuma inscrição com esse CPF para ser o responsável!",
                              onClose: () {
                                widget.viewModel.buscarResponsavel1.clearResult();
                              },
                            );
                          });
                        }
                      }

                      _txtNomeResponsavel1.text = widget.viewModel.responsavel1?.nome ?? "";
                      _txtCPFResponsavel1.text = widget.viewModel.responsavel1?.cpf ?? "";

                      return LoadingOverlay(
                        isLoading: widget.viewModel.buscarResponsavel1.running,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'CPF Responsável 1 *',
                                      hintText: 'CPF do responsável 1',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    controller: _txtCPFResponsavel1,
                                    inputFormatters: [InputFormatters.cpfFormatter],
                                    validator: (value) =>
                                        InputValidators.validateRequired(value, 'CPF Responsável 1'),
                                    enabled: widget.viewModel.responsavel1 == null,
                                  )
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  onPressed: () {
                                    if (widget.viewModel.responsavel1 != null) {
                                      widget.viewModel.setResponsavel1(null);
                                      _txtCPFResponsavel1.clear();
                                    }
                                    else {
                                      widget.viewModel.buscarResponsavel1.execute(_txtCPFResponsavel1.text);
                                    }
                                  },
                                  icon: Icon(widget.viewModel.responsavel1 != null ? Icons.clear : Icons.arrow_right_alt)
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _txtNomeResponsavel1,
                              decoration: const InputDecoration(
                                labelText: 'Nome Responsável 1 *',
                                hintText: 'Nome do responsável 1',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              enabled: false,
                              maxLength: 200,
                            )
                          ],
                        )
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: widget.viewModel.buscarResponsavel2,
                    builder: (ctx, child) {
                      if (widget.viewModel.buscarResponsavel2.error) {
                        var error = widget.viewModel.buscarResponsavel2.result as ErrorCommand;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showErrorDialog(
                            context,
                            message: error.error.toString(),
                            onClose: () {
                              widget.viewModel.buscarResponsavel2.clearResult();
                            },
                          );
                        });
                      }

                      if (widget.viewModel.buscarResponsavel2.completed) {
                        var resposta = widget.viewModel.buscarResponsavel2.result as OkCommand<bool>;
                        if (!resposta.value) {
                          _txtNomeResponsavel2.clear();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showErrorDialog(
                              context,
                              message: "Não encontramos nenhuma inscrição com esse CPF para ser o responsável!",
                              onClose: () {
                                widget.viewModel.buscarResponsavel2.clearResult();
                              },
                            );
                          });
                        }
                      }

                      _txtCPFResponsavel2.text = widget.viewModel.responsavel2?.cpf ?? "";
                      _txtNomeResponsavel2.text = widget.viewModel.responsavel2?.nome ?? "";

                      return LoadingOverlay(
                          isLoading: widget.viewModel.buscarResponsavel2.running,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child:  TextFormField(
                                      controller: _txtCPFResponsavel2,
                                      decoration: const InputDecoration(
                                        labelText: 'CPF Responsável 2 *',
                                        hintText: 'CPF do responsável 2',
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      inputFormatters: [InputFormatters.cpfFormatter],
                                      enabled: widget.viewModel.responsavel2 == null,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                      onPressed: () {
                                        if (widget.viewModel.responsavel2 != null) {
                                          widget.viewModel.setResponsavel2(null);
                                          _txtCPFResponsavel2.clear();
                                        }
                                        else {
                                          widget.viewModel.buscarResponsavel2.execute(_txtCPFResponsavel2.text);
                                        }
                                      },
                                      icon: Icon(widget.viewModel.responsavel2 != null ? Icons.clear : Icons.arrow_right_alt)
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _txtNomeResponsavel2,
                                decoration: const InputDecoration(
                                  labelText: 'Nome Responsável 2 *',
                                  hintText: 'Nome do responsável 2',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                enabled: false,
                                maxLength: 200,
                              )
                            ],
                          )
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Observações
                TextFormField(
                  initialValue: widget.viewModel.observacoes,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    hintText: 'Deixe aqui qualquer observação importante',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 4,
                  onChanged: widget.viewModel.setObservacoes,
                ),
                const SizedBox(height: 16),

                // Action buttons
                ElevatedButton(
                  onPressed: widget.viewModel.isLoading
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      final resultado = await widget.viewModel.salvarInscricao();
                      if (context.mounted && resultado != null) {
                        Navigator.pop(context, resultado);
                      }
                    }
                  },
                  child: const Text('Salvar Inscrição'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Voltar'),
                ),
              ],
            ),
          );
        }
    );
  }
}