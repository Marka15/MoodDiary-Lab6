import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/dashboard_model.dart';
import 'models/history_model.dart';
import 'models/statistics_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('uk_UA', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ініціалізуємо Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://bdbcc7c5bab8add4fa99b1323bf15f96@o4510347437670400.ingest.de.sentry.io/4510347463950416';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardModel()),
        ChangeNotifierProvider(create: (_) => HistoryModel()),
        ChangeNotifierProvider(create: (_) => StatisticsModel()),
      ],
      child: MaterialApp(
        title: 'MoodDiary',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        
        // 2. Налаштування локалізації (щоб календар працював)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('uk', 'UA'), // Українська
          Locale('en', 'US'), // Англійська
        ],
        locale: const Locale('uk', 'UA'), 
        
        home: const LoginPage(),
      ),
    );
  }
}