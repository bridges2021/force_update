import 'package:bridges_firebase/bridges_firebase.dart';

final List<FirebaseSetting> apps = [
  FirebaseSetting(
      name: 'OpenProjectIOS',
      appId: '1:650650171321:ios:668ade462e8e07ed536868',
      apiKey: 'AIzaSyBTOuYizVZ-Kolv_lImMDNesl6jFRjbRBk',
      messagingSenderId:
      'com.googleusercontent.apps.650650171321-hapdqgu4kf5cib41f3967v4660tlndc6',
      projectId: 'openproject-6544b'),
  FirebaseSetting(
      name: 'OpenProjectAndroid',
      appId: '1:650650171321:android:3debf870ea15b52f536868',
      apiKey: 'AIzaSyBTOuYizVZ-Kolv_lImMDNesl6jFRjbRBk',
      messagingSenderId:
      'com.googleusercontent.apps.650650171321-hapdqgu4kf5cib41f3967v4660tlndc6',
      projectId: 'openproject-6544b'),
];

enum App { OpenProjectIOS, OpenProjectAndroid }

extension Apps on App {
  FirebaseSetting get app {
    switch (this) {
      case App.OpenProjectIOS:
        return apps[0];
      case App.OpenProjectAndroid:
        return apps[1];
      default:
        return apps.first;
    }
  }
}

Future<void> initializeApps() async {
  for (final app in apps) {
    try {
      await app.initialize();
    } catch (e) {
      print(e);
    }
  }
}