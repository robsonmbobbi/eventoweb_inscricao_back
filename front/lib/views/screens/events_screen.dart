import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/widgets.dart';
import '../../core/theme.dart';
import '../viewmodels/events_viewmodel.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    // Load events when screen initializes
    Future.microtask(() {
      context.read<EventsViewModel>().loadEventos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Disponíveis'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<EventsViewModel>(
          builder: (context, viewModel, _) {
            // Show error dialog if there's an error
            if (viewModel.error != null && viewModel.error!.isNotEmpty) {
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
              message: 'Carregando eventos...',
              child: viewModel.eventos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.event,
                            size: 64,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.isLoading
                                ? 'Carregando eventos...'
                                : 'Nenhum evento disponível',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              viewModel.loadEventos();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 32,
                        vertical: 16,
                      ),
                      itemCount: viewModel.eventos.length,
                      itemBuilder: (context, index) {
                        final evento = viewModel.eventos[index];
                        return EventCard(
                          evento: evento,
                          isMobile: isMobile,
                          onInscribClick: () {
                            // Navigate to orders screen
                            context.pushNamed('orders', extra: evento.id);
                          },
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {

  const EventCard({
    required this.evento, required this.isMobile, required this.onInscribClick, Key? key,
  }) : super(key: key);
  
  final dynamic evento;
  final bool isMobile;
  final VoidCallback onInscribClick;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Logo/Image
          Container(
            width: double.infinity,
            height: isMobile ? 200 : 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: AppColors.grey200,
              image: evento.logotipo != null
                  ? DecorationImage(
                      image: NetworkImage(evento.logotipo!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: evento.logotipo == null
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                  )
                : null,
          ),
          // Event Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nome,
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Inscription Period
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Inscrições:',
                  value:
                      '${dateFormat.format(evento.dataInicialInscricao)} a ${dateFormat.format(evento.dataFinalInscricao)}',
                ),
                const SizedBox(height: 8),
                // Event Period
                _InfoRow(
                  icon: Icons.event,
                  label: 'Realização:',
                  value:
                      '${dateFormat.format(evento.dataInicialRealizacao)} a ${dateFormat.format(evento.dataFinalRealizacao)}',
                ),
                const SizedBox(height: 16),
                // Inscription Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onInscribClick,
                    child: const Text('Inscrever-se'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                TextSpan(
                  text: ' $value',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
}
