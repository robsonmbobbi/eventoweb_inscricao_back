import 'package:flutter/material.dart';
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
  routes: [
    GoRoute(
      path: Routes.events,
      name: 'events',
      builder: (context, state) => const EventsScreen(),
      routes: [
        GoRoute(
          path: '${Routes.orders}/:idEvento',
          name: 'orders',
          builder: (context, state) {
            final eventId = int.parse(state.pathParameters['idEvento']!);
            return ChangeNotifierProvider(
              create: (_) => OrdersViewModel(
                apiService: getIt.get(),
                idEvento: eventId ?? 0,
              ),
              child: OrdersScreen(eventId: eventId ?? 0),
            );
          },
          routes: [
            ShellRoute(
              builder: (context, state, child) {
                return ChangeNotifierProvider(
                  create: (_) => RegistrationViewModel(
                    eventoService: getIt(),
                    inscricoesService: getIt(),
                    idEvento: context.read<OrdersViewModel>().idEvento
                  ),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  path: Routes.registration,
                  name: 'registration',
                  builder: (context, state) {
                    var model = context.read<OrdersViewModel>();

                    return RegistrationScreen(
                      eventId: model.idEvento,
                      evento: model.evento!
                    );
                  },
                ),
                GoRoute(
                  path: Routes.regulation,
                  name: 'regulation',
                  builder: (context, state) {
                    return Text('regulation');
                  },
                ),
                GoRoute(
                  path: Routes.search,
                  name: 'search',
                  builder: (context, state) {
                    return Text('search');
                  },
                ),
                GoRoute(
                  path: Routes.verification,
                  name: 'verification',
                  builder: (context, state) {
                    return Text('verification');
                  },
                ),
              ],
              redirect: (context, state) {
                var model = context.read<RegistrationViewModel>();

                if (state.matchedLocation != Routes.regulation && !model.regulamentoAceito) {
                  return Routes.regulation;
                }

                if (state.matchedLocation != Routes.search && !model.cpfBuscado) {
                  return Routes.search;
                }

                if (state.matchedLocation != Routes.verification && !model.dataNascimentoInformada) {
                  return Routes.verification;
                }

                return state.path;
              }
            ),
            GoRoute(
              path: Routes.registration,
              name: 'registration',

              builder: (context, state) {

                return ChangeNotifierProvider(
                    create: (_) => RegistrationViewModel(
                        eventoService: getIt(),
                        inscricoesService: getIt(),
                        idEvento: context.read<OrdersViewModel>().idEvento
                    ),


                )

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
          ]
        ),
      ]
    ),
  ],
);
