import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_klass/components/roundedButton.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:one_klass/components/databaseCache.dart';

class NoNetworkScreen extends StatefulWidget {
  const NoNetworkScreen({super.key});

  @override
  State<NoNetworkScreen> createState() => _NoNetworkScreenState();
}

class _NoNetworkScreenState extends State<NoNetworkScreen> {
  String? connection;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connection = 'connected';
      }
    } on SocketException catch (_) {
      connection = 'not connected';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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
      setState(() {
        _connectionStatus = result;
        if (_connectionStatus == ConnectivityResult.mobile ||
            _connectionStatus == ConnectivityResult.wifi ||
            _connectionStatus == ConnectivityResult.vpn) {
          checkInternet();
        } else {
          connection = 'not connected';
        }
      });
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      connection = 'not connected';
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => exit(0),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You are not connected to internet, click on "Mark Attendance" to mark attendance offline',
                style: TextStyle(
                    fontSize: 23,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(
                height: 30,
              ),
              RoundedButton(
                  title: 'Mark Attendance',
                  colour: Colors.blue,
                  onPressed: () async {
                    List<Cache> result = await DatabaseCache.getTimeCache();
                    print(result);
                    if (result.isNotEmpty) {
                      Navigator.pushNamed(context, 'arn');
                    } else if (result.isEmpty) {
                      Navigator.pushNamed(context, 'qc');
                    }
                  }),
              RoundedButton(
                  title: 'Try connecting again',
                  colour: Colors.indigo,
                  onPressed: () async {
                    List<Cache>? result = await DatabaseCache.getTimeCache();
                    if (connection == 'connected') {
                      Navigator.pushNamed(context, 'ar');
                      // I am connected to a mobile network.
                    } else if (connection == 'not connected' &&
                        result!.isNotEmpty) {
                      Navigator.pushNamed(context, 'arn');
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
