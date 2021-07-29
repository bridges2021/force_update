import 'package:bridges_firebase/FirebaseSetting.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdate extends StatefulWidget {
  const ForceUpdate(
      {Key? key,required this.child, required this.app})
      : super(key: key);
  final Widget child;
  final FirebaseSetting app;

  @override
  _ForceUpdateState createState() => _ForceUpdateState();
}

class _ForceUpdateState extends State<ForceUpdate> {
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
    final _data = (await widget.app.store.collection('Packages').doc(packageName).get()).data() ?? {};
    latestVersion = _data['version'] ?? '';
    url = _data['url'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    getPackageInfo().then((value) =>
        getLatestVersion().then((value) => setState(() => _isLoading = false)));
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
                            await launch(url);
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
