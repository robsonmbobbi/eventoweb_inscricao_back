import 'package:flutter/material.dart';
import 'package:front2/models/dto_evento.dart';
import 'package:front2/views/widgets/form_registration_widget.dart';
import 'package:front2/views/widgets/regulation_widget.dart';
import 'package:front2/views/widgets/search_registration_widget.dart';
import 'package:front2/views/widgets/verification_widget.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets.dart';
import '../../core/service_locator.dart';
import '../viewmodels/registration_viewmodel.dart';


class RegistrationScreen extends StatefulWidget {
  final DTOEvento evento;

  const RegistrationScreen({
    super.key,
    required this.evento
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  final _formKey = GlobalKey<FormState>();
  late final RegistrationViewModel _viewModel;

  @override
  void initState() {

    _viewModel = RegistrationViewModel(eventoService: getIt(), inscricoesService: getIt());
    Future.microtask(() {
      _viewModel.init(widget.evento);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return WillPopScope(
      onWillPop: () async {
        context.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inscrição'),
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showErrorDialog(
                    context,
                    message: _viewModel.error!,
                    onClose: () {
                      _viewModel.clearError();
                    },
                  );
                });
              }

              return LoadingOverlay(
                isLoading: _viewModel.isLoading,
                message: 'Processando...',
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: 24,
                    ),
                    child: _buildForm(context, _viewModel, isMobile),
                  ),
                ),
              );
            },
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

    if (!viewModel.regulamentoAceito) {
      return RegulationWidget(viewModel: _viewModel);
    } else if (!viewModel.cpfBuscado) {
      return SearchRegistrationWidget(viewModel: _viewModel);
    } else if (!viewModel.dataNascimentoInformada) {
      return VerificationWidget(viewModel: _viewModel);
    } else {
      return FormRegistrationWidget(viewModel: _viewModel);
    }
  }
}
