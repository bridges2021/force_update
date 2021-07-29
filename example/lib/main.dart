import 'package:bridges_firebase/bridges_firebase.dart';
import 'package:example/FirebaseSettings.dart';
import 'package:flutter/material.dart';
import 'package:force_update/ForceUpdate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeApps();
  } catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Force update example'),
        ),
        body: ForceUpdate(
          app: App.OpenProjectAndroid.app,
          child: Center(child: Text('Same version')),
        ),
      ),
    );
  }
}
