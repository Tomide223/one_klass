import 'package:flutter/material.dart';
import 'package:one_klass/components/roundedButton.dart';
import 'dart:io';

String? connection;

class NoNetworkScreen extends StatelessWidget {
  const NoNetworkScreen({super.key});

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
                  onPressed: () {
                    Navigator.pushNamed(context, 'arn');
                  }),
              RoundedButton(
                  title: 'Try connecting again',
                  colour: Colors.indigo,
                  onPressed: () {
                    checkInternet();
                    if (connection == 'connected') {
                      Navigator.pushNamed(context, 'ar');
                      // I am connected to a mobile network.
                    } else if (connection == 'not connected') {
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
