import 'package:flutter/material.dart';
import 'package:front2/views/viewmodels/registration_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/widgets.dart';
import '../../core/theme.dart';
import '../../models/dto_inscricao.dart';
import '../../models/enums/enum_tipo_inscricao.dart';
import '../viewmodels/orders_viewmodel.dart';

class OrdersScreen extends StatelessWidget {

  const OrdersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog when trying to go back
        if (context.mounted &&
            context.read<OrdersViewModel>().inscricoes.isNotEmpty) {
          showConfirmDialog(
            context,
            title: 'Descartar Inscrições?',
            message:
                'Quaisquer inscrições ali feitas serão perdidas. Deseja continuar?',
            confirmText: 'Sim, descartar',
            cancelText: 'Não, continuar',
            onConfirm: () {
              context.read<OrdersViewModel>().reset();
              context.read<RegistrationViewModel>().reset();
              context.go('/');
            },
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Pedidos'),
          leading: BackButton(
            onPressed: () {
              if (context.read<OrdersViewModel>().inscricoes.isNotEmpty) {
                showConfirmDialog(
                  context,
                  title: 'Descartar Inscrições?',
                  message:
                      'Quaisquer inscrições ali feitas serão perdidas. Deseja continuar?',
                  confirmText: 'Sim, descartar',
                  cancelText: 'Não, continuar',
                  onConfirm: () {
                    context.read<OrdersViewModel>().reset();
                    context.go('/');
                  },
                );
              } else {
                context.go('/');
              }
            },
          ),
        ),
        body: SafeArea(
          child: Consumer<OrdersViewModel>(
            builder: (context, viewModel, _) => SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    // Inscriptions list
                    Expanded(
                      child: viewModel.inscricoes.isEmpty
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
                                    onPressed: () {
                                      // Navigate to registration screen
                                      context.pushNamed(
                                        'registration',
                                        extra: 0,
                                      );
                                    },
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
                              itemCount: viewModel.inscricoes.length,
                              itemBuilder: (context, index) {
                                final inscricao = viewModel.inscricoes[index];
                                return InscriptionCard(
                                  inscricao: inscricao,
                                  onRemove: () {
                                    viewModel.removerInscricao(index);
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
                            onPressed: () {
                              // Navigate to registration screen
                              context.push(
                                './registration'
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Nova Inscrição'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: viewModel.inscricoes.isEmpty
                                ? null
                                : () {
                                    // Navigate to payment screen
                                    context.pushNamed('payment');
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
}

class InscriptionCard extends StatelessWidget {
  final DTOInscricao inscricao;
  final VoidCallback onRemove;

  const InscriptionCard({
    Key? key,
    required this.inscricao,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tipoLabel = inscricao.tipo == EnumTipoInscricao.infantil
        ? 'Infantil'
        : 'Participante';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          inscricao.pessoa.nome,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          tipoLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
