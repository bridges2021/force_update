# force_update
 
## Installation
1. Add this lines to pub.yaml
```yaml
force_update:
  git:
    url: https://github.com/bridges2021/force_update.git
    ref: main
```
2. Add this lines to main
```dart
WidgetsFlutterBinding.ensureInitialized();
await FlutterDownloader.initialize(debug: true);
```
3. Add this lines to android/app/src/main/AndroidManifest.xml before ```<application>```
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```
before ```</applcation>```
```xml
<provider
    android:name="vn.hunghd.flutterdownloader.DownloadedFileProvider"
    android:authorities="${applicationId}.flutter_downloader.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths"/>
</provider>

<provider
    android:name="androidx.work.impl.WorkManagerInitializer"
    android:authorities="${applicationId}.workmanager-init"
    android:enabled="false"
    android:exported="false"
    tools:node="remove"/>

<provider
    android:name="vn.hunghd.flutterdownloader.FlutterDownloaderInitializer"
    android:authorities="${applicationId}.flutter-downloader-init"
    android:exported="false">
    <meta-data
        android:name="vn.hunghd.flutterdownloader.MAX_CONCURRENT_TASKS"
        android:value="1" />
    </provider>
```
## How to use
1. Wrap your main page with ForceUpdate, give it the latest version and update url
```dart
ForceUpdate(
        getVersionAndUrl: (String packageName) async {
          final _doc = await FirebaseFirestore.instance
              .collection('Packages')
              .doc(packageName)
              .get();
          return {
            'version': _doc.data()!['version'],
            'url': _doc.data()!['url']
          };
        },
        child: MainView()
      )
```
