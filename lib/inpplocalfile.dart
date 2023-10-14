import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:one_klass/components/database.dart';
import 'package:one_klass/components/databaseCache.dart';

class InAppLocal extends StatefulWidget {
  InAppLocal({super.key});

  @override
  State<InAppLocal> createState() => _InAppLocalState();
}

class _InAppLocalState extends State<InAppLocal> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;

  PullToRefreshController? pullToRefreshController;

  bool pullToRefreshEnabled = true;

  Future<bool> _goBack() async {
    var value = await webViewController.canGoBack();
    if (value) {
      webViewController.goBack();
      return false;
    } else {
      return true;
    }
  }

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

  _loadData() async {
    List<Item> items = await DatabaseHelper().getItems();

    return items;
  }

  _loadCache() async {
    List<Cache> cache = await DatabaseCache().getItems();

    return cache;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestCameraPermission();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _goBack(),
      child: SafeArea(
        child: Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Colors.blueAccent,
          //   title: const Text("Google"),
          //   actions: [NavigationControls(controller:controller),],
          // ),

          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        "http://localhost:8080/assets/static/takeattendance.html")),
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onWebViewCreated: (controller) async {
                  webViewController = controller;
                  controller.addJavaScriptHandler(
                    handlerName: 'writeUploadAbles',
                    callback: (args) async {
                      await DatabaseHelper.insertData(args[0], args[1]);
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'fetchUploadAbles',
                    callback: (args) async {
                      _loadData();
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'writeCache',
                    callback: (args) async {
                      await DatabaseCache.insertData(args[0], args[1]);
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'updateCache',
                    callback: (args) async {
                      await DatabaseCache.updateItem(args[0], args[1]);
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'fetchCache',
                    callback: (args) async {
                      _loadCache();
                    },
                  );
                },
                onLoadStart: (controller, url) {},
                onLoadStop: (controller, url) {},
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      mediaPlaybackRequiresUserGesture: false,
                      javaScriptEnabled: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
