import 'dart:io';
import 'package:flutter/material.dart';
import 'splashSreen.dart';
import 'webScreen.dart';
import 'localFile.dart';
import 'popUp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'inappwebviewstack.dart';
import 'inpplocalfile.dart';

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
        title: 'One Klass',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: 'a',
        // home: const HomeScreen(),

        routes: {
          'a': (context) => const HomeScreen(),
          'aa': (context) => WebViewPage(),
          'aaa': (context) => LocalViewPage(),
          'ad': (context) => const NoNetworkScreen(),
          'ar': (context) => MyInApp(),
          'arn': (context) => InAppLocal(),
        });
  }
}
