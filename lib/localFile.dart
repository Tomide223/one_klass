import 'package:flutter/material.dart';
import 'package:one_klass/components/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:permission_handler/permission_handler.dart';

class LocalViewPage extends StatefulWidget {
  @override
  State<LocalViewPage> createState() => _LocalViewPageState();
}

class _LocalViewPageState extends State<LocalViewPage> {
  late final WebViewController controller;
  PlatformWebViewControllerCreationParams params =
  const PlatformWebViewControllerCreationParams();
  String statusText = "Start Server";
  String serverIp = 'http://oneklass.oauife.edu.ng';

  // startServer()async{
  //
  //   setState(() {
  //     statusText = "Starting server on Port : 8080";
  //   });
  //   var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  //
  //   debugPrint("Server running on IP : "+server.address.toString()+" On Port : "+server.port.toString());
  //   await for (var request in server) {
  //     request.response
  //       ..headers.contentType =  ContentType("text", "plain", charset: "utf-8")
  //       ..write('Hello, world');
  //       // ..close();
  //   }
  //   setState(() {
  //     serverIp =server.address.toString() ;
  //     statusText = "Server running on IP : "+server.address.toString()+" On Port : "+server.port.toString();
  //   });
  // }
  Future<bool> _goBack() async {
    var value = await controller.canGoBack();
    if (value) {
      controller.goBack();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestCameraPermission();


    // startServer();
    // Future<WebViewController> _getController() async {
    //   // late final PlatformWebViewControllerCreationParams params;
    //   // params = WebViewPlatform.instance is WebKitWebViewPlatform
    //   //     ? WebKitWebViewControllerCreationParams(
    //   //     allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{})
    //   //     : const PlatformWebViewControllerCreationParams();

    controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        request.grant();
      },
    );
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    // controller.loadRequest(
    //     // Uri.parse('https://192.168.43.172:8000/ltakeattendance'));
    // Uri.parse('https://192.168.43.172:8000/ltakeattendance.html'));
    controller.loadFlutterAsset('assets/static/takeattendance.html');

    // return controller;
  }

  // controller = WebViewController().

  // }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _goBack(),
      //     child: Scaffold(
      // body: Center(
      // child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      // children: <Widget>[
      // MaterialButton(
      //     onPressed: (){
      //
      // },
      // child: Text(statusText),
      // )
      // ],
      // ),
      // )
      // ),);
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.blueAccent,
        //   title: const Text("Google"),
        //   actions: [NavigationControls(controller:controller),],
        // ),

          body: RefreshIndicator(
              onRefresh: () {
                return controller.reload();
              },
              child: WebViewStack(
                controller: controller,
              ))),
    );
  }
}

// InAppWebViewController webViewController;
// bool showErrorPage = false;
// @override
// Widget build(BuildContext context) {
//   return Container(
//     child: Stack(
//       children: <Widget>[
//         InAppWebView(
//           initialUrl: 'https://fail.page.asd',
//           onWebViewCreated: (InAppWebViewController controller) {
//             webViewController = controller;
//           },
//           onLoadError: (
//               InAppWebViewController controller,
//               String url,
//               int i,
//               String s
//               ) async {
//             print('CUSTOM_HANDLER: $i, $s');
//             /** instead of printing the console message i want to render a static page or display static message **/
//             showError();
//           },
//           onLoadHttpError: (InAppWebViewController controller, String url,
//               int i, String s) async {
//             print('CUSTOM_HANDLER: $i, $s');
//             /** instead of printing the console message i want to render a static page or display static message **/
//             showError();
//           },
//         ),
//         showErrorPage ? Center(
//           child: Container(
//             color: Colors.white,
//             alignment: Alignment.center,
//             height: double.infinity,
//             width: double.infinity,
//             child: Text('Page failed to open (WIDGET)'),
//           ),
//         ) : SizedBox(height: 0, width: 0),
//       ],
//     ),
//   );
// }
//
// void showError(){
//   setState(() {
//     showErrorPage = true;
//   });
// }
//
// void hideError(){
//   setState(() {
//     showErrorPage = false;
//   });
// }

// InAppWebViewController webViewController;
// bool showErrorPage = false;
// @override
// Widget build(BuildContext context) {
//   return Container(
//     child: InAppWebView(
//       initialUrl: 'https://fail.page.asd',
//       onWebViewCreated: (InAppWebViewController controller) {
//         webViewController = controller;
//       },
//       onLoadError: (
//           InAppWebViewController controller,
//           String url,
//           int i,
//           String s
//           ) async {
//         print('CUSTOM_HANDLER: $i, $s');
//         /** instead of printing the console message i want to render a static page or display static message **/
//         webViewController.loadFile(assetFilePath: "assets/error.html");
//       },
//       onLoadHttpError: (InAppWebViewController controller, String url,
//           int i, String s) async {
//         print('CUSTOM_HANDLER: $i, $s');
//         /** instead of printing the console message i want to render a static page or display static message **/
//         webViewController.loadFile(assetFilePath: "assets/error.html");
//       },
//     ),
//   );
// }
