import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:one_klass/components/databaseCache.dart';

class MyInApp extends StatefulWidget {
  @override
  _MyInAppState createState() => _MyInAppState();
}

class _MyInAppState extends State<MyInApp> {
  final GlobalKey webViewKey = GlobalKey();

  final ReceivePort _port = ReceivePort();
  late InAppWebViewController webViewController;

  PullToRefreshController? pullToRefreshController;

  bool pullToRefreshEnabled = true;
  String? b;

  Cache items = Cache(type: 'person', packet: 'gfgfg', id: 1);
  Cache? item;

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
    var value = await webViewController.canGoBack();
    if (value) {
      webViewController.goBack();
      return false;
    } else {
      exit(0);
    }
  }

  bool copy(List<dynamic> params) {
    Clipboard.setData(ClipboardData(text: params[0]));
    return true;
  }

  @override
  void initState() {
    // copy();
    requestCameraPermission();
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      // DownloadTaskStatus status = DownloadTaskStatus();
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController.loadUrl(
              urlRequest:
              URLRequest(url: await webViewController.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void handleClick(int item, String request) async {
    switch (item) {
      case 0:
        List<Map<String, dynamic>>? file =
        await DatabaseCache.getCache('login');
        // await DatabaseCache.updateCache(
        //   items,
        // );
        print(file);
        break;
      case 1:
      // await DatabaseCache.addCache(items);
      //   await DatabaseCache.updateCache(
      //     items,
      //   );
        await DatabaseCache.deleteCache(const Cache(type: 'time', packet: ''));

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _goBack(),
      child: SafeArea(
        child: Scaffold(
          // appBar: AppBar(
          //   title: const Text("InAppWebView Download"),
          //   actions: [
          //     PopupMenuButton<int>(
          //       onSelected: (item) => handleClick(item, 'login'),
          //       itemBuilder: (context) =>
          //       [
          //         const PopupMenuItem<int>(
          //             value: 0, child: Text('Download file 1')),
          //         const PopupMenuItem<int>(
          //             value: 1, child: Text('Download file 2')),
          //       ],
          //     ),
          //   ],
          // ),
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
                      cacheEnabled: false,
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
                    fileName: 'testing',
                    // url.suggestedFilename,
                    saveInPublicStorage: true,
                    // show download progress in status bar (for Android)
                    openFileFromNotification:
                    true, // click on notification to open downloaded file (for Android)
                  );
                },
                onLoadError: (controller, url, i, s) {
                  webViewController.loadFile(
                      assetFilePath: "assets/static/not_found.html");
                },
                onLoadHttpError: (controller, url, i, s) {
                  webViewController.loadFile(
                      assetFilePath: "assets/static/not_found.html");
                },
                key: webViewKey,
                initialUrlRequest:
                // URLRequest(url: Uri.parse('http://192.168.43.172:8000/')),
                URLRequest(url: Uri.parse('https://oneklass.oauife.edu.ng')),
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  controller.addJavaScriptHandler(
                    handlerName: 'clipboardManager',
                    callback: (args) {
                      return copy(args);
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'openExternal',
                    callback: (args) async {
                      print(args);
                      for (String a in args) {
                        if (await canLaunchUrl(Uri.parse(
                            a))) {
                          await launchUrl(Uri.parse(
                              a));
                        } else {
                          const ScaffoldMessenger(
                            child: Text('Unable to complete action, try again'),
                          );
                          throw 'Could not launch $a';
                        }
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'writeCache',
                    callback: (args) async {
                      print(args);
                      int r = 1;
                      for (List a in args) {
                        print(a);
                        item = Cache(type: a[0], packet: a[1], id: r);

                        bool take = await DatabaseCache.updateCache(
                          item!,
                        );
                        if (take == false) {
                          await DatabaseCache.addCache(item!);
                        }
                        r++;
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'fetchCache',
                    callback: (args) async {
                      print(args);
                      List jet = [];
                      for (String a in args) {
                        List<Map<String, dynamic>>? geo =
                        await DatabaseCache.getCache(a);

                        jet.add(geo);
                      }

                      return jet;
                      //  await _loadCache(b!);
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'deleteCache',
                    callback: (args) async {
                      print(args);

                      for (String a in args) {
                        await DatabaseCache.deleteCache(Cache(
                            type: a, packet: a));
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'handlePdf',
                    callback: (args) async {
                      print(args);
                      Directory? tempDir = await getExternalStorageDirectory();

                      for (String a in args) {
                        await FlutterDownloader.enqueue(
                          url: a,
                          savedDir: tempDir!.path,
                          showNotification: true,
                          fileName: 'OneKlass',
                          saveInPublicStorage: true,
                          // show download progress in status bar (for Android)
                          openFileFromNotification:
                          true, // click on notification to open downloaded file (for Android)
                        );
                      }
                    },
                  );
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
