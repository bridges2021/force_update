import 'package:flutter_downloader/flutter_downloader.dart';

class Task {
  final String name;
  final String url;

  String? id;
  int? progress;
  DownloadTaskStatus? status;

  Task({required this.name, required this.url});

  String statusName() {
    if (status == DownloadTaskStatus.undefined) {
      return 'Undefined';
    } else if (status == DownloadTaskStatus.running) {
      return 'Downloading';
    } else if (status == DownloadTaskStatus.paused) {
      return 'Paused';
    } else if (status == DownloadTaskStatus.complete) {
      return 'Completed';
    } else if (status == DownloadTaskStatus.canceled) {
      return 'Canceled';
    } else {
      return 'Loading';
    }
  }
}
