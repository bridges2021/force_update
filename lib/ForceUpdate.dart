import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bridges_firebase/FirebaseSetting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdate extends StatefulWidget {
  const ForceUpdate({Key? key, required this.child, required this.app})
      : super(key: key);
  final Widget child;
  final FirebaseSetting app;

  @override
  _ForceUpdateState createState() => _ForceUpdateState();
}

class _ForceUpdateState extends State<ForceUpdate> {
  ReceivePort _port = ReceivePort();

  bool _isLoading = true;

  late String packageName;
  late String version;
  late String latestVersion;
  late String url;

  Future<void> getPackageInfo() async {
    final _packageInfo = await PackageInfo.fromPlatform();
    packageName = _packageInfo.packageName;
    version = _packageInfo.version;
  }

  Future<void> getLatestVersion() async {
    final _data =
        (await widget.app.store.collection('Packages').doc(packageName).get())
                .data() ??
            {};
    latestVersion = _data['version'] ?? '';
    url = _data['url'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
    getPackageInfo().then((value) =>
        getLatestVersion().then((value) => setState(() => _isLoading = false)));
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          )
        : latestVersion == version
            ? widget.child
            : Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Your version is: $version'),
                      Text('The latest version is: $latestVersion'),
                      Text('New version found'),
                      Text('Please click update'),
                      ElevatedButton(
                          onPressed: () async {
                            final _dir = await getTemporaryDirectory();
                            final taskId = await FlutterDownloader.enqueue(
                              url: url,
                              savedDir: _dir.path,
                              showNotification:
                                  true, // show download progress in status bar (for Android)
                              openFileFromNotification:
                                  true, // click on notification to open downloaded file (for Android)
                            );
                            await OpenFile.open('${_dir.path}/app-release.apk');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Text('Update'),
                          ))
                    ],
                  ),
                ),
              );
  }
}
