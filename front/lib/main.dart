import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:front2/views/viewmodels/orders_viewmodel.dart';
import 'package:front2/views/viewmodels/registration_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/service_locator.dart';
import 'core/theme.dart';
import 'services/eventos/eventos_service.dart';
import 'views/viewmodels/events_viewmodel.dart';

import 'package:http/http.dart' as http;

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  
  // Setup dependency injection
  await ServiceLocator.setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      title: 'EventoWeb Inscrições',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
