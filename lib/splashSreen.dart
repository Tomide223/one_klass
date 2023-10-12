import 'package:flutter/material.dart';
import 'package:one_klass/components/web_view_stack.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WebViewController controllerA;

  String? connection;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    controllerA = WebViewController(
        // onPermissionRequest: (controller, request) async {
        //   return PermissionResponse(
        //       resources: request.resources,
        //       action: PermissionResponseAction.GRANT);
        // },
        )
      ..loadFlutterAsset('assets/static/splash.html');

    initConnectivity();
    checkInternet();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    Timer(const Duration(seconds: 7), () {
      setState(() {
        if (connection == 'connected') {
          Navigator.pushNamed(context, 'ar');
          // I am connected to a mobile network.
        } else if (connection == 'not connected') {
          Navigator.pushNamed(context, 'ad');
        }
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connection = 'connected';
        });
      }
    } on SocketException catch (_) {
      setState(() {
        connection = 'not connected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WebViewStack(
      controller: controllerA,
    ));
  }
}
