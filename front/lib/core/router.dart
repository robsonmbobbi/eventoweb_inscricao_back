import 'package:go_router/go_router.dart';
import '../views/screens/events_screen.dart';
import '../views/screens/orders_screen.dart';


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
          path: '${Routes.orders}/:idEvento',
          name: 'orders',
          builder: (context, state) {
            var idEvento = int.parse(state.pathParameters['idEvento'] ?? '-100');

            return OrdersScreen(idEvento: idEvento);
          }
        ),
      ]
    ),
  ],
);
