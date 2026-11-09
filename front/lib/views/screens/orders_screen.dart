import 'package:flutter/material.dart';
import 'package:front2/models/dto_inscricao.dart';
import 'package:front2/models/dto_resultado_pedido.dart';
import 'package:front2/views/screens/payment_screen.dart';
import 'package:front2/views/screens/payment_success_screen.dart';
import 'package:front2/views/screens/registration_screen.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets.dart';
import '../../core/service_locator.dart';
import '../../core/theme.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../widgets/inscription_card.dart';

class OrdersScreen extends StatefulWidget {
  final int idEvento;

  const OrdersScreen({
    required this.idEvento,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  late OrdersViewModel _viewModel;

  @override
  void initState() {

    _viewModel = OrdersViewModel(getIt());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.idEvento);
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog when trying to go back
        if (context.mounted &&
            _viewModel.inscricoes.isNotEmpty) {
          showConfirmDialog(
            context,
            title: 'Descartar Inscrições?',
            message:
            'Quaisquer inscrições ali feitas serão perdidas. Deseja continuar?',
            confirmText: 'Sim, descartar',
            cancelText: 'Não, continuar',
            onConfirm: () {
              _viewModel.reset();
             context.pop();
            },
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Pedidos'), /*ListenableBuilder(
            listenable: _viewModel,
            builder: (ctx, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Meus Pedidos'),
                  Text(
                      _viewModel.evento?.nome ?? 'Evento não encontrado',
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                ],
              );
            }
          ),*/
          leading: BackButton(
            onPressed: () {
              if (_viewModel.inscricoes.isNotEmpty) {
                showConfirmDialog(
                  context,
                  title: 'Descartar Inscrições?',
                  message:
                  'Quaisquer inscrições ali feitas serão perdidas. Deseja continuar?',
                  confirmText: 'Sim, descartar',
                  cancelText: 'Não, permanecer aqui',
                  onConfirm: () {
                    context.pop();
                  },
                );
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  // Inscriptions list
                  Expanded(
                    child: _viewModel.inscricoes.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.assignment,
                            size: 64,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma inscrição realizada',
                            style:
                            Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _viewModel.evento == null ? null : _navigateRegistration,
                            icon: const Icon(Icons.add),
                            label: const Text('Nova Inscrição'),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 32,
                        vertical: 16,
                      ),
                      itemCount: _viewModel.inscricoes.length,
                      itemBuilder: (context, index) {
                        final inscricao = _viewModel.inscricoes[index];
                        return InscriptionCard(
                          inscricao: inscricao,
                          onRemove: () {
                            _viewModel.removerInscricao(index);
                          },
                        );
                      },
                    ),
                  ),
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.grey300,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _viewModel.evento == null ? null : _navigateRegistration,
                          icon: const Icon(Icons.add),
                          label: const Text('Nova Inscrição'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _viewModel.inscricoes.isEmpty
                              ? null
                              : () async {
                            // Navigate to payment screen
                            var resultado = await Navigator.push<DTOResultadoPedido?>(
                              context,
                              MaterialPageRoute(builder: (ctx) => PaymentScreen(inscricoes: _viewModel.inscricoes))
                            );
                            if (resultado != null) {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (ctx) => PaymentSuccessScreen(resultado: resultado))
                              );

                              context.pop();
                            }
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Realizar Pagamento'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateRegistration() async {
    var novaInscricao = await Navigator.push<DTOInscricao?>(
      context,
      MaterialPageRoute(builder: (ctx) => RegistrationScreen(evento: _viewModel.evento!))
    );

    if (novaInscricao != null) {
      _viewModel.adicionarInscricao(novaInscricao);
    }
  }
}