import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:flutter/services.dart';
import 'package:fm_photo/fm_photo.dart';
import 'dart:io';
// import 'package:path_provider/path_provider.dart';
import './play.dart';
// import 'package:archive/archive.dart';
// import 'package:archive/archive_io.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: App(),
    );
  }
}
class App extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  String _platformVersion = 'Unknown';
  List _photo = [];
  Map _camera = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: [
                OutlineButton(
                  child: Text("pick"),
                  onPressed: () async {
                    // Directory docDirectory = await getExternalStorageDirectory();
                    _photo = await FmPhoto.pickPhoto( max: 2, type: 0, enableCrop: false, enableCamera: true);
                    print(_photo.toString()+"==-098767890-=-098767890-=");
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                OutlineButton(
                  child: Text("camera"),
                  onPressed: () async {
                    // Directory docDirectory = await getExternalStorageDirectory();
                    Map camera = await FmPhoto.cameraPhoto(type: 2);
                    print(camera["path"]);
//                      _camera = await FmPhoto.getThumbnail(path: "/storage/emulated/0/hhwy/xl_528c1ca6763d497f9b152a6f4a9168cf/GT_873183b2c16b42578fdec3f4a6f085ae/video_fjid/add_1555663067998.mp4");
//                      print(_camera);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                OutlineButton(
                  child: Text("播放"),
                  onPressed: () async {
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => new VideoApp()));
                  },
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _photo.length,
                itemBuilder: (BuildContext context, int index) {
                  return Image.file(File(_photo[index]["path"]),fit:BoxFit.fill);
                },
              ),
            )
          ],
        )
      );
  }
}
