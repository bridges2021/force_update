import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:force_update/ForceUpdate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ForceUpdate(getVersionAndUrl: (String packageName) async {
        final _doc = await FirebaseFirestore.instance.collection('Packages').doc(packageName).get();
        return {'version': _doc.data()!['version'], 'url': _doc.data()!['url']};
      }, child: Scaffold(
        body: Center(
          child: Text('You are up to date'),
        ),
      ),

      ),
    );
  }
}
