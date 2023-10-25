import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewStack extends StatefulWidget {
  WebViewStack({required this.controller, super.key});

  final WebViewController controller;

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;
  bool spin = false;
  late String localPath;

  Future<void> prepareSaveDir() async {
    localPath = (await findLocalPath())!;
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return;
  }

  Future<String?> findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.documentsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  Future<void> _handleDownload(
      String url, WebViewController webViewController) async {
    //todo download catelog here
    FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
    final platform = Theme.of(context).platform;
    bool value = await _checkPermission(platform);
    if (value) {
      await prepareSaveDir();
      {
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: localPath,
          showNotification: true,
          saveInPublicStorage: true,
          // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)
        );
      }
    }
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<bool> _checkPermission(platform) async {
    if (Platform.isIOS) return true;
    // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      await Permission.manageExternalStorage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        final result2 = await Permission.manageExternalStorage.request();
        if (result == PermissionStatus.granted &&
            result2 == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    prepareSaveDir();
    widget.controller
      ..setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
        setState(() {
          loadingPercentage = 0;
          spin = true;
        });
      }, onProgress: (progress) {
        setState(() {
          loadingPercentage = progress;
        });
      }, onPageFinished: (url) {
        setState(() {
          loadingPercentage = 100;
          spin = false;
        });
      }, onNavigationRequest: (navigation) async {
        if (navigation.url.startsWith('https://example.com/download')) {
          // Intercept download request
          await widget.controller;
          await _handleDownload(navigation.url, widget.controller);

          //   final host = Uri.parse(navigation.url).host;
          //   if(host.contains('youtube.com')){
          //     ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          // content: Text('Blocking navigation to $host'),
          // ),

          return NavigationDecision.navigate;
        }
        return NavigationDecision.navigate;
      }))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: spin,
        opacity: 0.05,
        // progressIndicator: Text('$loadingPercentage%',style: const TextStyle(fontSize: 20, color: Colors.blue), ),
        child: Stack(
          children: [
            WebViewWidget(
              // gestureRecognizers: Set()
              //   ..add(
              //     Factory<VerticalDragGestureRecognizer>(
              //         () => VerticalDragGestureRecognizer()
              //           ..onDown = (DragDownDetails dragDownDetails) {
              //             widget.controller.getScrollPosition().then((value) {
              //               if (value == 0 &&
              //                   dragDownDetails.globalPosition.direction < 1) {
              //                 widget.controller.reload();
              //               }
              //             });
              //           }),
              //   ),
              controller: widget.controller,
            ),
            // if(loadingPercentage < 100)
            //   LinearProgressIndicator(value: loadingPercentage / 100.0,color: Colors.lightBlueAccent,)
          ],
        ),
      ),
    );
  }
}
