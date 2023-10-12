import 'dart:io';

// import 'dart:isolate';
// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class MyInApp extends StatefulWidget {
  @override
  _MyInAppState createState() => new _MyInAppState();
}

class _MyInAppState extends State<MyInApp> {
  final GlobalKey webViewKey = GlobalKey();

  // final ReceivePort _port = ReceivePort();
  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  bool pullToRefreshEnabled = true;

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    final foot = await Permission.storage.request();
    if (status == PermissionStatus.granted &&
        foot == PermissionStatus.granted) {
      debugPrint('granted');
      // Permission granted.
    } else if (status == PermissionStatus.denied &&
        foot == PermissionStatus.denied) {
      // Permission denied.
    } else if (status == PermissionStatus.permanentlyDenied &&
        foot == PermissionStatus.permanentlyDenied) {
      // Permission permanently denied.
    }
  }

  Future<bool> _goBack() async {
    var value = await webViewController?.canGoBack();
    if (value != null) {
      webViewController?.goBack();
      return false;
    } else {
      return true;
    }
  }

  // void copy(List<dynamic> params) {
  //   Clipboard.setData(ClipboardData(text: params[0]));
  // }
  void copy() {
    Clipboard.setData(const ClipboardData(text: 'AYOMIDE'));
  }

  // Future<void> downloadFile(String url, [String? filename]) async {
  //   var hasStoragePermission = await Permission.storage.isGranted;
  //   if (!hasStoragePermission) {
  //     final status = await Permission.storage.request();
  //     hasStoragePermission = status.isGranted;
  //   }
  //   if (hasStoragePermission) {
  //      await FlutterDownloader.enqueue(
  //         url: url,
  //         headers: {},
  //         // optional: header send with url (auth token etc)
  //         savedDir: (await getTemporaryDirectory()).path,
  //         saveInPublicStorage: true,
  //         fileName: filename);
  //   }
  // }

  @override
  void initState() {
    copy();
    requestCameraPermission();
    super.initState();
    // IsolateNameServer.registerPortWithName(
    //     _port.sendPort, 'downloader_send_port');
    // _port.listen((dynamic data) {
    //   String id = data[0];
    //   DownloadTaskStatus status = data[1];
    //   int progress = data[2];
    //   if (kDebugMode) {
    //     print("Download progress: $progress%");
    //   }
    //   if (status == DownloadTaskStatus.complete) {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text("Download $id completed!"),
    //     ));
    //   }
    // });
    // FlutterDownloader.registerCallback(downloadCallback);

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  // @override
  // void dispose() {
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  //   super.dispose();
  // }

  // @pragma('vm:entry-point')
  // static void downloadCallback(
  //     String id, int status, int progress) {
  //   final SendPort? send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send?.send([id, status, progress]);
  // }
  void handleClick(int item) async {
    switch (item) {
      case 0:
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: Uri.parse(
                    "https://www.ceenaija.com/wp-content/uploads/music/2021/01/Dunsin_Oyekan_-_YAH_CeeNaija.com_.mp3")));
        break;
      case 1:
        await webViewController?.loadUrl(
            urlRequest: URLRequest(
                url: Uri.parse(
                    "https://files.ceenaija.com/wp-content/uploads/music/2022/07/Christian_Hymn_-_Higher_Ground_CeeNaija.com_.mp3")));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _goBack(),
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("InAppWebView Download"),
              actions: [
                PopupMenuButton<int>(
                  onSelected: (item) => handleClick(item),
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                        value: 0, child: Text('Download file 1')),
                    const PopupMenuItem<int>(
                        value: 1, child: Text('Download file 2')),
                  ],
                ),
              ],
            ),
            body: Stack(children: <Widget>[
              InAppWebView(
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onLoadStop: (controller, url) {
                  pullToRefreshController?.endRefreshing();
                },
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      mediaPlaybackRequiresUserGesture: false,
                      useOnDownloadStart: true,
                      javaScriptEnabled: true,
                      disableVerticalScroll: false,
                      disableHorizontalScroll: false),
                ),
                onDownloadStartRequest: (controller, url) async {
                  Directory? tempDir = await getExternalStorageDirectory();
                  setState(() {});
                  print("onDownloadStart $url");
                  await FlutterDownloader.enqueue(
                    url: url.url.toString(),
                    savedDir: tempDir!.path,
                    showNotification: true,
                    fileName: url.suggestedFilename,
                    saveInPublicStorage: true,
                    // show download progress in status bar (for Android)
                    openFileFromNotification:
                        true, // click on notification to open downloaded file (for Android)
                  );
                },
                onLoadError: (controller, url, i, s) {
                  webViewController!
                      .loadFile(assetFilePath: "assets/static/not_found.html");
                },
                onLoadHttpError: (controller, url, i, s) {
                  webViewController!
                      .loadFile(assetFilePath: "assets/static/not_found.html");
                },
                key: webViewKey,
                initialUrlRequest: URLRequest(
                    url: Uri.parse('https://oneklass.oauife.edu.ng')),
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  //
                  // (controller, navigationAction) async {
                  //   if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
                  //     final shouldPerformDownload =
                  //         navigationAction.shouldPerformDownload ?? false;
                  //     final url = navigationAction.request.url;
                  //     if (shouldPerformDownload && url != null) {
                  //       await downloadFile(url.toString());
                  //       return NavigationActionPolicy.ALLOW;
                  //     }
                  //   }
                  //   return NavigationActionPolicy.ALLOW;
                  // };
                  // onDownloadStartRequest: (controller, downloadStartRequest) async {
                  // await downloadFile(downloadStartRequest.url.toString(),
                  // downloadStartRequest.suggestedFilename);
                  // };
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                },
              ),
            ])),
      ),
    );
  }
}
