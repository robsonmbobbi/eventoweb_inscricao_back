import 'package:flutter/material.dart';
import '../core/theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    this.message = 'Carregando...',
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const ErrorDialog({
    Key? key,
    this.title = 'Erro',
    required this.message,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          child: const Text('OK'),
        ),
      ],
    );
}

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Sim',
    this.cancelText = 'Não',
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const SuccessDialog({
    Key? key,
    this.title = 'Sucesso',
    required this.message,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          child: const Text('OK'),
        ),
      ],
    );
}

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const InfoDialog({
    Key? key,
    this.title = 'Informação',
    required this.message,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.info, color: AppColors.info),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          child: const Text('OK'),
        ),
      ],
    );
}

// Helper functions
void showErrorDialog(
  BuildContext context, {
  required String message,
  String title = 'Erro',
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(
      title: title,
      message: message,
      onClose: onClose,
    ),
  );
}

void showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String confirmText = 'Sim',
  String cancelText = 'Não',
}) {
  showDialog(
    context: context,
    builder: (context) => ConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    ),
  );
}

void showSuccessDialog(
  BuildContext context, {
  required String message,
  String title = 'Sucesso',
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    builder: (context) => SuccessDialog(
      title: title,
      message: message,
      onClose: onClose,
    ),
  );
}

void showInfoDialog(
  BuildContext context, {
  required String message,
  String title = 'Informação',
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    builder: (context) => InfoDialog(
      title: title,
      message: message,
      onClose: onClose,
    ),
  );
}
