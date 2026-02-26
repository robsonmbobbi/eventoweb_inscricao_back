import 'package:flutter/material.dart';
import 'package:front2/models/dto_forma_pagamento.dart';
import 'package:front2/models/dto_inscricao.dart';
import 'package:front2/models/dto_resultado_pedido.dart';
import 'package:front2/models/enums/enum_tipo_pagamento.dart';
import 'package:front2/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/input_validators.dart';
import '../../common/widgets.dart';
import '../../core/service_locator.dart';
import '../../models/enums/enum_tipo_inscricao.dart';
import '../../models/enums/enum_tipo_pedido.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../viewmodels/payment_viewmodel.dart';

class PaymentScreen extends StatefulWidget {
  final List<DTOInscricao> inscricoes;

  const PaymentScreen({required this.inscricoes, super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _viewModel = PaymentViewModel(precosService: getIt(), pedidosService: getIt(), formasPagamentoService: getIt());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.comandoCarregamentoInscricoes.execute(widget.inscricoes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pagamento'),
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
                if (_viewModel.erro != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showErrorDialog(
                      context,
                      message: _viewModel.erro!.excecao.toString(),
                      onClose: () {
                        //_viewModel.clearError();
                      },
                    );
                  });
                }

                return ListenableBuilder(
                  listenable: _viewModel.comandoFinalizacaoPedido,
                  builder: (ctx2, child) {
                    if (_viewModel.comandoFinalizacaoPedido.error) {
                      Future.microtask(() {
                        var resultadoProcesso = _viewModel.comandoFinalizacaoPedido.result as ErrorCommand<DTOResultadoPedido>;
                        showErrorDialog(
                            context,
                            title: "Ocorre um problema ao finalizar o seu pedido...",
                            message: resultadoProcesso.error.toString()
                        );
                        _viewModel.comandoFinalizacaoPedido.clearResult();
                      });
                    }

                    if (_viewModel.comandoFinalizacaoPedido.completed) {
                      Future.microtask(() {
                        var resultadoProcesso = _viewModel.comandoFinalizacaoPedido.result as OkCommand<DTOResultadoPedido>;
                        Navigator.pop(context, resultadoProcesso.value);

                        _viewModel.comandoFinalizacaoPedido.clearResult();
                      });
                    }

                    return LoadingOverlay(
                      isLoading: _viewModel.comandoFinalizacaoPedido.running,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 32,
                            vertical: 24,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Inscriptions Summary
                                Text(
                                  'Resumo das Inscrições',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        ..._viewModel.inscricoes
                                            .asMap()
                                            .entries
                                            .map((e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.value.inscricao.pessoa.nome,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                    Text(
                                                      e.value.inscricao.tipo == EnumTipoInscricao.infantil
                                                          ? 'Infantil'
                                                          : 'Participante',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                'R\$ ${_viewModel.valorTotal?.toStringAsFixed(2) ?? 'Sem informações de valor'}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Text(
                                              'R\$ ${_viewModel.valorTotal?.toStringAsFixed(2) ?? 'Sem valor informado'}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Payment Type
                                Text(
                                  'Tipo de Pagamento',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 16),
                                ValueListenableBuilder<EnumTipoPedido>(
                                  valueListenable: _viewModel.tipoPedido,
                                  builder: (ctx, value, child){
                                    return SegmentedButton<EnumTipoPedido>(
                                      segments: const [
                                        ButtonSegment(
                                          value: EnumTipoPedido.debito,
                                          label: Text('Débito'),
                                          icon: Icon(Icons.credit_card),
                                        ),
                                        ButtonSegment(
                                          value: EnumTipoPedido.desconto,
                                          label: Text('Desconto'),
                                          icon: Icon(Icons.discount),
                                        ),
                                        ButtonSegment(
                                          value: EnumTipoPedido.isencao,
                                          label: Text('Isenção'),
                                          icon: Icon(Icons.free_cancellation),
                                        ),
                                      ],
                                      selected: {_viewModel.tipoPedido.value},
                                      onSelectionChanged: (selected) {
                                        _viewModel.tipoPedido.value = selected.first;
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),

                                ValueListenableBuilder(
                                  valueListenable: _viewModel.tipoPedido,
                                  builder: (ctx3, value, child) {
                                    if (value == EnumTipoPedido.debito) {

                                      if (_viewModel.formasPagamento.value.isNotEmpty && _viewModel.formaPagamentoEscolhida.value == null) {
                                        _viewModel.formaPagamentoEscolhida.value = null;
                                        _viewModel.formaPagamentoEscolhida.value = _viewModel.formasPagamento.value.first;
                                      }

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          DropdownMenuFormField<DTOFormaPagamento>(
                                            dropdownMenuEntries: _viewModel.formasPagamento.value.map((e) => DropdownMenuEntry(value: e, label: e.nome)).toList(),
                                            initialSelection: _viewModel.formaPagamentoEscolhida.value,
                                            onSelected: (value) => _viewModel.formaPagamentoEscolhida.value = value,
                                            enableFilter: false,
                                            enableSearch: false,
                                            label: const Text("Forma de pagamento1 *"),
                                            validator: (value) {
                                              if (value == null) {
                                                return "Você não escolheu uma forma de pagamento";
                                              }

                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                        ],
                                      );
                                    }

                                    return const SizedBox(height: 0);
                                  },
                                ),

                                // Payer Information
                                Text(
                                  'Dados do Pagador',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Nome *',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) => InputValidators.validateRequired(value, 'Nome'),
                                  onChanged: (value) => _viewModel.nomePagador.value = value,
                                  maxLength: 200,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'CPF *',
                                    prefixIcon: Icon(Icons.badge),
                                  ),
                                  inputFormatters: [
                                    InputFormatters.cpfFormatter
                                  ],
                                  validator: InputValidators.validateCPF,
                                  onChanged: (value) => _viewModel.cpfPagador.value = value,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Celular *',
                                    prefixIcon: Icon(Icons.phone),
                                  ),
                                  inputFormatters: [
                                    InputFormatters.celularFormatter
                                  ],
                                  validator: InputValidators.validateCelular,
                                  onChanged: (value) => _viewModel.celularPagador.value = value,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email *',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: InputValidators.validateEmail,
                                  onChanged:(value) => _viewModel.emailPagador.value = value,
                                  maxLength: 100,
                                ),
                                const SizedBox(height: 24),

                                ValueListenableBuilder(
                                    valueListenable: _viewModel.tipoPedido,
                                    builder: (ctx, value, child) {
                                      if (value == EnumTipoPedido.debito) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            ValueListenableBuilder(
                                                valueListenable: _viewModel.formaPagamentoEscolhida,
                                                builder: (ctx2, value, child) {
                                                  if (value?.tipo == EnumTipoPagamento.credito) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                        Text(
                                                          'Dados de Cartão de Crédito',
                                                          style: Theme.of(context).textTheme.headlineSmall,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Número Cartão *',
                                                            prefixIcon: Icon(Icons.credit_card),
                                                          ),
                                                          inputFormatters: [
                                                            InputFormatters.creditCardFormatter
                                                          ],
                                                          validator: (value) => InputValidators.validateRequired(value, "Número Cartão"),
                                                          onChanged: (value) => _viewModel.numeroCartao.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Nome Impresso Cartão *',
                                                            prefixIcon: Icon(Icons.credit_card),
                                                          ),
                                                          validator: (value) => InputValidators.validateRequired(value, "Nome Impresso Cartão"),
                                                          onChanged: (value) => _viewModel.nomeImpressoCartao.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Mês validade *',
                                                            prefixIcon: Icon(Icons.credit_card),
                                                          ),
                                                          keyboardType: TextInputType.number,
                                                          validator: (value) => InputValidators.validateRequired(value, "Mês validade"),
                                                          onChanged: (value) => _viewModel.mesExpiracao.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Ano Validade *',
                                                            prefixIcon: Icon(Icons.credit_card),
                                                          ),
                                                          keyboardType: TextInputType.number,
                                                          validator: (value) => InputValidators.validateRequired(value, "Ano Validade"),
                                                          onChanged: (value) => _viewModel.anoExpiracao.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Código Segurança *',
                                                            prefixIcon: Icon(Icons.credit_card),
                                                          ),
                                                          keyboardType: TextInputType.number,
                                                          validator: (value) => InputValidators.validateRequired(value, "Código Segurança"),
                                                          onChanged: (value) => _viewModel.codigoSeguranca.value = value,
                                                          maxLength: 3,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Nome Titular *',
                                                            prefixIcon: Icon(Icons.credit_card),
                                                          ),
                                                          validator: (value) => InputValidators.validateRequired(value, "Nome Titular"),
                                                          onChanged: (value) => _viewModel.nomeTitular.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Email titular *',
                                                            prefixIcon: Icon(Icons.email),
                                                          ),
                                                          keyboardType: TextInputType.emailAddress,
                                                          validator: InputValidators.validateEmail,
                                                          onChanged: (value) => _viewModel.emailTitular.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'CPF ou CNPJ Titular *',
                                                            prefixIcon: Icon(Icons.corporate_fare),
                                                          ),
                                                          validator: (value) => InputValidators.validateRequired(value, "CPF ou CNPJ Titular"),
                                                          onChanged: (value) => _viewModel.cpfOuCnpjTitular.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'CEP Titular *',
                                                            prefixIcon: Icon(Icons.signpost),
                                                          ),
                                                          inputFormatters: [
                                                            InputFormatters.cepFormatter
                                                          ],
                                                          validator: (value) => InputValidators.validateRequired(value, "CEP Titular"),
                                                          onChanged: (value) => _viewModel.cepTitular.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Número Logradouro Titular *',
                                                            prefixIcon: Icon(Icons.streetview),
                                                          ),
                                                          validator: (value) => InputValidators.validateRequired(value, "Número Logradouro Titular"),
                                                          onChanged: (value) => _viewModel.numeroEnderecoTitular.value = value,
                                                        ),
                                                        const SizedBox(height: 16),
                                                        TextFormField(
                                                          decoration: const InputDecoration(
                                                            labelText: 'Telefone Titular *',
                                                            prefixIcon: Icon(Icons.phone),
                                                          ),
                                                          inputFormatters: [
                                                            InputFormatters.celularFormatter
                                                          ],
                                                          validator: (value) => InputValidators.validateRequired(value, "Telefone Titular"),
                                                          onChanged: (value) => _viewModel.telefoneTitular.value = value,
                                                        ),
                                                        if (value!.nrParcelasMaxima > 1) ...[
                                                          const SizedBox(height: 16),
                                                          DropdownMenuFormField<int>(
                                                            dropdownMenuEntries: GerarEntradas(value.nrParcelasMinima, value.nrParcelasMaxima),
                                                            label: const Text("Número Parcelas *"),
                                                            leadingIcon: Icon(Icons.shopping_bag),
                                                            validator: (value)  {
                                                              if (value == null) {
                                                                return "Informe o número de parcelas";
                                                              }

                                                              return null;
                                                            },
                                                            onSelected: (value) => _viewModel.numeroParcelas.value = value,
                                                          ),
                                                        ],
                                                      ],
                                                    );
                                                  }

                                                  return const SizedBox(height: 0);
                                                }
                                            )
                                          ],
                                        );
                                      }
                                      else {
                                        return TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Motivo *',
                                            hintText: 'Descreva o motivo para o pedido',
                                            prefixIcon: Icon(Icons.description),
                                          ),
                                          maxLines: 4,
                                          validator: (value) => InputValidators.validateRequired(value, 'Motivo'),
                                          onChanged: (value) => _viewModel.motivo.value = value,
                                        );
                                      }
                                    }
                                ),
                                const SizedBox(height: 24),
                                // Action buttons
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final result = await _viewModel.comandoFinalizacaoPedido.execute();
                                    }
                                  },
                                  child: const Text('Finalizar Pedido'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    );
                  }
                );
              },
            ),
          ),
        ),
      );
  }

  List<DropdownMenuEntry<int>> GerarEntradas(int nrParcelasMinima, int nrParcelasMaxima) {
    List<DropdownMenuEntry<int>> lista = [];
    for(var parcela = nrParcelasMinima; parcela <= nrParcelasMaxima; parcela++) {
      lista.add(DropdownMenuEntry<int>(value: parcela, label: "$parcela X"));
    }

    return lista;
  }
}
