import 'package:flutter/material.dart';
import 'package:front2/views/screens/verification_screen.dart';
import 'package:front2/views/viewmodels/registration_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/dto_evento.dart';
import '../models/dto_resultado_pedido.dart';
import '../views/screens/events_screen.dart';
import '../views/screens/orders_screen.dart';
import '../views/screens/payment_screen.dart';
import '../views/screens/payment_success_screen.dart';
import '../views/screens/registration_screen.dart';
import '../views/screens/regulation_screen.dart';
import '../views/screens/search_registration_screen.dart';
import '../views/viewmodels/orders_viewmodel.dart';
import 'service_locator.dart';

// Route names
class Routes {
  static const String events = '/';
  static const String orders = '/orders';
  static const String registration = '/registration';
  static const String regulation = '/regulation';
  static const String search = '/search';
  static const String verification = '/verification';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
}

final appRouter = GoRouter(
  initialLocation: Routes.events,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Routes.events,
      name: 'events',
      builder: (context, state) => const EventsScreen(),
      routes: [
        GoRoute(
          path: '${Routes.orders}',
          name: 'orders',
          builder: (context, state) {
            var evento = state.extra as DTOEvento;

            var orderModel = context.read<OrdersViewModel>();
            var regModel = context.read<RegistrationViewModel>();
            if (orderModel.evento != null && orderModel.evento!.id! != evento.id!) {
              orderModel.reset();
              regModel.reset();
            }

            if (orderModel.evento == null) {
              orderModel.init(evento);
              regModel.init(evento);
            }

            return OrdersScreen();
          },
          routes: [
            ShellRoute(
              builder: (ctxShell, state, child) {
                return child;
              },
              routes: [
                GoRoute(
                  path: Routes.regulation,
                  name: 'regulation',
                  builder: (context, state) {
                    return RegulationScreen();
                  },
                ),
                GoRoute(
                  path: Routes.search,
                  name: 'search',
                  builder: (context, state) {
                    return SearchRegistrationScreen();
                  },
                ),
                GoRoute(
                  path: Routes.verification,
                  name: 'verification',
                  builder: (context, state) {
                    return VerificationScreen();
                  },
                ),
                GoRoute(
                  path: Routes.registration,
                  name: 'registration',
                  builder: (context, state) {
                    var model = context.read<OrdersViewModel>();

                    return RegistrationScreen(
                        eventId: model.evento!.id!,
                        evento: model.evento!
                    );
                  },
                ),
              ],
              redirect: (ctxRedirect, state) {
                var registration = ctxRedirect.read<RegistrationViewModel>();

                if (state.matchedLocation == 'registration') {
                  if (!registration.regulamentoAceito) {
                    return '${Routes.orders}${Routes.regulation}';
                  }

                  if (!registration.cpfBuscado) {
                    return '${Routes.orders}${Routes.search}';
                  }

                  if (!registration.dataNascimentoInformada) {
                    return '${Routes.orders}${Routes.verification}';
                  }
                }  else if (state.matchedLocation == 'search') {
                  if (!registration.regulamentoAceito) {
                    return '${Routes.orders}${Routes.regulation}';
                  }

                  if (registration.dataNascimentoInformada) {
                    return '${Routes.orders}${Routes.registration}';
                  }

                  if (registration.cpfBuscado) {
                    return '${Routes.orders}${Routes.verification}';
                  }
                }
                else  if (state.matchedLocation == 'verification') {
                  if (!registration.regulamentoAceito) {
                    return '${Routes.orders}${Routes.regulation}';
                  }

                  if (!registration.cpfBuscado) {
                    return '${Routes.orders}${Routes.search}';
                  }

                  if (registration.dataNascimentoInformada) {
                    return '${Routes.orders}${Routes.registration}';
                  }
                } else if (state.matchedLocation == 'regulation') {
                  if (registration.dataNascimentoInformada) {
                    return '${Routes.orders}${Routes.registration}';
                  }

                  if (registration.cpfBuscado) {
                    return '${Routes.orders}${Routes.verification}';
                  }

                  if (registration.regulamentoAceito) {
                    return '${Routes.orders}${Routes.search}';
                  }
                }

                return state.path;
              }
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
          ]
        ),
      ]
    ),
  ],
);
