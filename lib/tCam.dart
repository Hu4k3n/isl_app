import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  var client;

  String text = "Press Start";
  bool inProgress = false;
  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.low,
    );

    client = http.Client();
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<String> uploadFile(XFile image) async {
    var postUri = Uri.parse("http://2.tcp.ngrok.io:18644/getchar");
    var stream = new http.ByteStream(image.openRead());
    var length = await image.length();

    var request = new http.MultipartRequest("POST", postUri);

    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(image.path));

    request.files.add(multipartFile);

    // var response = await request.send();
    // final respStr = await response.stream.bytesToString();

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final data = json.decode(response.body);
    print(data);
    return data['character'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISL')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.maxFinite,
              height: 180,
              color: Colors.blue,
              child: Card(
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      text,
                      style: TextStyle(fontSize: 15),
                    ),
                    Align(
                      alignment: Alignment(0, 0),
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;
                            List<XFile> imageArray = [];
                            XFile image;
                            setState(() {
                              text = "Press stop after some time";
                            });
                            if (!inProgress) {
                              inProgress = true;
                              for (; inProgress;) {
                                image = await _controller.takePicture();
                                imageArray.add(image);
                                print(image.path);
                                var c = await uploadFile(image);
                                print("Got the character" + c);
                                // todo: send emails
                              }
                              //Send the image to backend
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Icon(Icons.play_arrow),
                      ),
                    ),
                    Align(
                      alignment: Alignment(0, 0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            if (inProgress) {
                              text = "Press start";
                              inProgress = false;
                              //recieve text from backend
                              //
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayTranslate()),
                              );
                            }
                          });
                        },
                        child: const Icon(Icons.stop_circle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.5),
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.blue),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
// class DisplayTranslateScreen extends StatelessWidget {
//   const DisplayTranslateScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Display the Picture')),
//       // The image is stored as a file on the device. Use the `Image.file`
//       // constructor with the given path to display the image.
//       body: Center(child: Text("here")),
//     );
//   }
// }

class DisplayTranslate extends StatefulWidget {
  DisplayTranslate({Key? key}) : super(key: key);

  @override
  _DisplayTranslateState createState() => _DisplayTranslateState();
}

class _DisplayTranslateState extends State<DisplayTranslate> {
  String text = "Loading ... ";
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translated')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Center(child: Text(text)),
    );
  }
}
