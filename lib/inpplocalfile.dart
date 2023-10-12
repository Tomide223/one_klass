import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class InAppLocal extends StatefulWidget {
  InAppLocal({super.key});

  @override
  State<InAppLocal> createState() => _InAppLocalState();
}

class _InAppLocalState extends State<InAppLocal> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  bool pullToRefreshEnabled = true;

  Future<bool> _goBack() async {
    var value = await webViewController?.canGoBack();
    if (value != null) {
      webViewController?.goBack();
      return false;
    } else {
      return true;
    }
  }

//   onLoadStop: (controller, url) {
//   controller.evaluateJavascript(
//   source:
//   'javascript:navigator.clipboard.writeText = (msg) => { return window.flutter_inappwebview?.callHandler("axs-wallet-copy-clipboard", msg); }');
//   controller.addJavaScriptHandler(
//   handlerName: 'axs-wallet-copy-clipboard',
//   callback: (args) {
//   copy(args);
//   },
//   );
// },
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
