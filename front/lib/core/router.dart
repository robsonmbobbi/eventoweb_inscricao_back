import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/dto_evento.dart';
import '../models/dto_resultado_pedido.dart';
import '../views/screens/events_screen.dart';
import '../views/screens/orders_screen.dart';
import '../views/screens/payment_screen.dart';
import '../views/screens/payment_success_screen.dart';
import '../views/screens/registration_screen.dart';
import '../views/viewmodels/orders_viewmodel.dart';
import 'service_locator.dart';

// Route names
class Routes {
  static const String events = '/';
  static const String orders = '/orders';
  static const String registration = '/registration';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
}

final appRouter = GoRouter(
  initialLocation: Routes.events,
  routes: [
    GoRoute(
      path: Routes.events,
      name: 'events',
      builder: (context, state) => const EventsScreen(),
    ),
    GoRoute(
      path: Routes.orders,
      name: 'orders',
      builder: (context, state) {
        final eventId = state.extra as int?;
        return ChangeNotifierProvider(
          create: (_) => OrdersViewModel(
            apiService: getIt.get(),
            idEvento: eventId ?? 0,
          ),
          child: OrdersScreen(eventId: eventId ?? 0),
        );
      },
    ),
    GoRoute(
      path: Routes.registration,
      name: 'registration',
      builder: (context, state) {
        final eventId = state.extra as int?;
        // Get evento from context or use a placeholder
        // This would typically come from the previous screen's context
        final evento = DTOEvento(
          id: eventId,
          nome: 'Evento',
          dataInicialInscricao: DateTime.now(),
          dataFinalInscricao: DateTime.now(),
          dataInicialRealizacao: DateTime.now(),
          dataFinalRealizacao: DateTime.now(),
          idadeMinimaAdulto: 18,
        );
        return RegistrationScreen(
          eventId: eventId ?? 0,
          evento: evento,
        );
      },
    ),
    GoRoute(
      path: Routes.payment,
      name: 'payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: Routes.paymentSuccess,
      name: 'paymentSuccess',
      builder: (context, state) {
        final result = state.extra as DTOResultadoPedido?;
        return PaymentSuccessScreen(resultado: result);
      },
    ),
  ],
);
