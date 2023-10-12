import 'package:flutter/material.dart';
import 'package:one_klass/components/web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:isolate';
import 'dart:ui';

class WebViewPage extends StatefulWidget {
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
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
          saveInPublicStorage: false,
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
    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();
    requestCameraPermission();
    // requestStoragePermission();

    controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (WebViewPermissionRequest request) {
        request.grant();
      },
    )..loadRequest(Uri.parse('https://oneklass.oauife.edu.ng'));
    // controller = WebViewController()
    //  ..loadRequest(Uri.parse('https://oneklass.oauife.edu.ng'));
    addFileSelectionListener();
    (navigation) async {
      if (navigation.url.startsWith('https://example.com/download')) {
        // Intercept download request
        controller;
        await _handleDownload(navigation.url, controller);

        //   final host = Uri.parse(navigation.url).host;
        //   if(host.contains('youtube.com')){
        //     ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        // content: Text('Blocking navigation to $host'),
        // ),

        return NavigationDecision.navigate;
      }
      return NavigationDecision.navigate;
    };
  }

  Future<bool> _goBack() async {
    var value = await controller.canGoBack();
    if (value) {
      controller.goBack();
      return false;
    } else {
      return true;
    }
  }

  void addFileSelectionListener() async {
    if (Platform.isAndroid) {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  Future<List<String>> _androidFilePicker(
      final FileSelectorParams params) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      return [file.uri.toString()];
    }
    return [];
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

  // Future<void> requestStoragePermission() async {
  //   final status = await Permission.storage.request();
  //
  //   if (status == PermissionStatus.granted) {
  //     debugPrint('granted');
  //     // Permission granted.
  //   } else if (status == PermissionStatus.denied) {
  //     // Permission denied.
  //   } else if (status == PermissionStatus.permanentlyDenied) {
  //     // Permission permanently denied.
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _goBack(),
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
