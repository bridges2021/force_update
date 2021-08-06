import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Task.dart';

class ForceUpdate extends StatelessWidget {
  const ForceUpdate(
      {Key? key, required this.child, required this.getVersionAndUrl})
      : super(key: key);

  final Widget child;
  final Future<Map<String, dynamic>> Function(String packageName)
      getVersionAndUrl;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return child;
    } else if (Platform.isAndroid) {
      return _ForceUpdater(
        child: child,
        getVersionAndUrl: getVersionAndUrl,
      );
    } else {
      return child;
    }
  }
}

class _ForceUpdater extends StatefulWidget {
  const _ForceUpdater(
      {Key? key, required this.child, required this.getVersionAndUrl})
      : super(key: key);
  final Widget child;
  final Future<Map<String, dynamic>> Function(String packageName)
      getVersionAndUrl;

  @override
  __ForceUpdaterState createState() => __ForceUpdaterState();
}

class __ForceUpdaterState extends State<_ForceUpdater> {
  late final Task _task;

  late bool _isLoading;
  late bool _havePermission;
  late String _directory;
  late bool _isUpdateToDate;

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _havePermission = false;
    _isUpdateToDate = false;

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _prepare();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];
      setState(() {
        _task.status = status;
        _task.progress = progress;
      });
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<Null> _prepare() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final Map<String, dynamic> data =
        await widget.getVersionAndUrl(packageInfo.packageName);
    _task = Task(name: 'update', url: data['url']);

    if (data['version'] == packageInfo.version) {
      _isUpdateToDate = true;
    } else {
      await FlutterDownloader.loadTasks();

      _havePermission = await _checkPermission();

      if (_havePermission) {
        await _getDirectory();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _checkPermission() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
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

  Future<void> _getDirectory() async {
    _directory =
        (await _findLocalPath())! + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_directory);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_isUpdateToDate) {
      return widget.child;
    } else if (_havePermission) {
      return _build();
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 30,
              ),
              Container(
                height: 20,
              ),
              Text('Permission denied',
                  style: Theme.of(context).textTheme.headline6),
              Container(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    _havePermission = await _checkPermission();
                    setState(() {});
                  },
                  child: Text('Provide access',
                      style: Theme.of(context).textTheme.headline6))
            ],
          ),
        ),
      );
    }
  }

  Widget _build() => Scaffold(
        appBar: AppBar(
          title: Text('Force update'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your application is not update to date, please download the latest version',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Container(
                  height: 20,
                ),
                _task.status == DownloadTaskStatus.complete
                    ? ElevatedButton(
                        onPressed: () async {
                          final _openResult = await OpenFile.open(
                              '$_directory/app-release.apk');
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_openResult.message)));
                        },
                        child: Text('Install'))
                    : ElevatedButton(
                        onPressed: () async {
                          if (_task.status != DownloadTaskStatus.running) {
                            _task.id = await FlutterDownloader.enqueue(
                                url: _task.url,
                                savedDir: _directory,
                                showNotification: true,
                                openFileFromNotification: true);
                          }
                        },
                        child: Text('Download')),
                Container(
                  height: 20,
                ),
                Text('${_task.progress ?? 0}%',
                    style: Theme.of(context).textTheme.headline6),
                Container(
                  height: 20,
                ),
                Text('${_task.statusName()}',
                    style: Theme.of(context).textTheme.headline6)
              ],
            ),
          ),
        ),
      );
}
