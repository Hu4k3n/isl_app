import 'package:avatar_glow/avatar_glow.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'tCam.dart';
import 'package:flutter/material.dart'
    show
        Align,
        Alignment,
        AppBar,
        BuildContext,
        Card,
        Center,
        Colors,
        Container,
        FloatingActionButton,
        Icons,
        Key,
        MaterialApp,
        MaterialPageRoute,
        Scaffold,
        Stack,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextButton,
        TextStyle,
        ThemeData,
        Widget,
        runApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({
    required this.camera,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ISL', camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;
  MyHomePage({Key? key, required this.title, required this.camera})
      : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            Center(
              child: AvatarGlow(
                endRadius: 150,
                duration: Duration(seconds: 2),
                glowColor: Colors.blue,
                repeat: true,
                repeatPauseDuration: Duration(seconds: 2),
                child: FloatingActionButton(
                  onPressed: () {
                    print("buttonPressed ");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TakePictureScreen(camera: widget.camera)));
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),
            Align(
                alignment: Alignment(0, -0.5),
                child: Text("Read4Me", style: TextStyle(fontSize: 30)))
          ],
        ));
  }
}
