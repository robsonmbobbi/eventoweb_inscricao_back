import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/dto_resultado_pedido.dart';
import '../../models/enums/enum_tipo_integracao.dart';
import '../../models/enums/enum_tipo_pedido.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final DTOResultadoPedido? resultado;

  const PaymentSuccessScreen({
    Key? key,
    required this.resultado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return WillPopScope(
      onWillPop: () async {
        context.go('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inscrição Concluída'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success icon and message
                  const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Inscrições Realizadas com Sucesso!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Message based on pedido type
                  if (resultado != null) ...[
                    Card(
                      color: AppColors.info.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID do Pedido: ${resultado!.idPedido}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            if (resultado!.tipo == EnumTipoPedido.debito) ...[
                              if (resultado!.debito != null) ...[
                                if (resultado!.debito!.tipoIntegracao ==
                                    EnumTipoIntegracao.pix) ...[
                                  Text(
                                    'Pagamento via PIX',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (resultado!.debito!.imagemQRCodePixBase64 !=
                                      null) ...[
                                    Center(
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.grey300,
                                          ),
                                        ),
                                        child: Image.memory(
                                          base64Decode(resultado!
                                              .debito!
                                              .imagemQRCodePixBase64!),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (resultado!.debito!.pixCopiaECola !=
                                      null) ...[
                                    Text(
                                      'PIX Copia e Cola:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.grey100,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: SelectableText(
                                        resultado!.debito!.pixCopiaECola!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ] else if (resultado!.debito!.tipoIntegracao ==
                                    EnumTipoIntegracao.creditoVista ||
                                    resultado!.debito!.tipoIntegracao ==
                                        EnumTipoIntegracao
                                            .creditoParcelado) ...[
                                  Text(
                                    'Pagamento em Cartão de Crédito',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Text(
                                  'Status: ${resultado!.debito!.status.toString().split('.')[1]}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ] else if (resultado!.tipo ==
                                EnumTipoPedido.desconto ||
                                resultado!.tipo == EnumTipoPedido.isencao) ...[
                              Text(
                                resultado!.tipo == EnumTipoPedido.desconto
                                    ? 'Solicitação de Desconto'
                                    : 'Solicitação de Isenção',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'A sua solicitação será avaliada pela coordenação e será feito contato em breve.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximas Etapas:',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (resultado!.tipo == EnumTipoPedido.debito) ...[
                            Text(
                              '• As informações de pagamento foram enviadas para seu email e WhatsApp',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Após o pagamento ser processado, você receberá um email e mensagem de confirmação',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ] else ...[
                            Text(
                              '• Sua solicitação será avaliada pela coordenação',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Você será contatado em breve com o resultado',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Back button
                  ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home),
                    label: const Text('Voltar para Eventos'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
