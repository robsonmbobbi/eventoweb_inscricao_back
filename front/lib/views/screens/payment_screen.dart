import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/input_validators.dart';
import '../../common/widgets.dart';
import '../../core/service_locator.dart';
import '../../models/enums/enum_tipo_inscricao.dart';
import '../../models/enums/enum_tipo_pedido.dart';
import '../../services/pedidos/pedidos_service.dart';
import '../../services/precos/precos_service.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../viewmodels/payment_viewmodel.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = PaymentViewModel(precosService: getIt<PrecosService>(), pedidosService: getIt<PedidosService>());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final ordersVM = context.watch<OrdersViewModel>();

    return WillPopScope(
      onWillPop: () async {
        context.go('/orders');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pagamento'),
          leading: BackButton(
            onPressed: () => context.go('/orders'),
          ),
        ),
        body: SafeArea(
          child: ChangeNotifierProvider.value(
            value: _viewModel,
            child: Consumer<PaymentViewModel>(
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
                  message: 'Processando pagamento...',
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
                                    ...ordersVM.inscricoes
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
                                                    e.value.pessoa.nome,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                  Text(
                                                    e.value.tipo ==
                                                            EnumTipoInscricao
                                                                .infantil
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
                                              'R\$ 0,00',
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
                                          'R\$ ${viewModel.valorTotal.toStringAsFixed(2)}',
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
                            SegmentedButton<EnumTipoPedido>(
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
                              selected: {viewModel.tipoPedido},
                              onSelectionChanged: (selected) {
                                viewModel.setTipoPedido(selected.first);
                              },
                            ),
                            const SizedBox(height: 24),

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
                              validator: (value) => InputValidators
                                  .validateRequired(value, 'Nome'),
                              onChanged: viewModel.setNomePagador,
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
                              onChanged: viewModel.setCpfPagador,
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
                              onChanged: viewModel.setCelularPagador,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: InputValidators.validateEmail,
                              onChanged: viewModel.setEmailPagador,
                              maxLength: 100,
                            ),
                            const SizedBox(height: 24),

                            // Conditional fields based on payment type
                            if (viewModel.tipoPedido == EnumTipoPedido.debito) ...[
                              Text(
                                'Forma de Pagamento',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              // Payment forms dropdown will be populated here
                              const SizedBox(height: 24),
                              // Credit card fields if needed
                              const SizedBox(height: 24),
                            ] else if (viewModel.tipoPedido ==
                                EnumTipoPedido.desconto ||
                                viewModel.tipoPedido ==
                                    EnumTipoPedido.isencao) ...[
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Descrição do Pedido *',
                                  hintText:
                                      'Digite o motivo do desconto ou isenção',
                                  prefixIcon: Icon(Icons.description),
                                ),
                                maxLines: 4,
                                validator: (value) =>
                                    InputValidators.validateRequired(
                                        value, 'Descrição'),
                                onChanged: viewModel.setDescricaoPedido,
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Action buttons
                            ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        final success =
                                            await viewModel.finalizarPedido(
                                          ordersVM.inscricoes
                                              .map((i) => i.id ?? 0)
                                              .toList(),
                                        );
                                        if (context.mounted && success) {
                                          await context.pushNamed(
                                            'paymentSuccess',
                                            extra: viewModel.resultado,
                                          );
                                        }
                                      }
                                    },
                              child: const Text('Finalizar Pedido'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/orders'),
                              child: const Text('Voltar'),
                            ),
                          ],
                        ),
                      ),
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
}
