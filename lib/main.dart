import 'dart:io';
import 'package:flutter/material.dart';
import 'Screens/splashSreen.dart';
import 'webScreen.dart';
import 'logoScreen.dart';
import 'Screens/popUp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'Screens/inappwebviewstack.dart';
import 'Screens/inpplocalfile.dart';
import 'Screens/queryCache.dart';

final InAppLocalhostServer localhostServer = InAppLocalhostServer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: false,
      // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
      true // option: set to false to disable working with http links (default: false)
  );

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  await localhostServer.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        title: 'OneKlass',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: 'aaa',
        // home: const HomeScreen(),

        routes: {
          'a': (context) => const HomeScreen(),
          'aa': (context) => WebViewPage(),
          'aaa': (context) => const SplashScreen(),
          'ad': (context) => const NoNetworkScreen(),
          'ar': (context) => MyInApp(),
          'arn': (context) => InAppLocal(),
          'qc': (context) => const FirstTimer(),
        });
  }
}
