import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

List<CameraDescription>? cameras;

class VideoCameraPage extends StatefulWidget {
  const VideoCameraPage({super.key});

  @override
  State<VideoCameraPage> createState() => _VideoCameraPageState();
}

class _VideoCameraPageState extends State<VideoCameraPage> {
  bool isUserPrediction = false;
  late CameraController _cameraController;
  late Future<void> cameraValue;

  // todo: face detection
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableTracking: false,
      enableContours: false,
      enableClassification: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  void startCamera() async {
    XFile xFile = await _cameraController.takePicture();
    InputImage inputImage = InputImage.fromFile(File(xFile.path));
    final List<Face> faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      setState(() {
        isUserPrediction = false;
      });
      debugPrint("<< face detection := // FALSE // >>");
    } else {
      setState(() {
        isUserPrediction = true;
      });
      debugPrint("<< face detection := // TRUE // >>");
    }
  }

  @override
  void initState() {
    _cameraController = CameraController(cameras![1], ResolutionPreset.high);
    cameraValue = _cameraController.initialize().whenComplete(() {
      Future.delayed(const Duration(seconds: 10), () {
        startCamera();
      });
    }).catchError((e) {
      debugPrint('camera controller initialize');
    });
    _cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Detection for Video"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity),
          SizedBox(
            height: 400,
            width: 400,
            child: Stack(
              children: [
                FutureBuilder(
                  future: cameraValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      const deviceRatio = 500 / 400;
                      return Transform.scale(
                        scale: 1.23,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: deviceRatio,
                            child: CameraPreview(_cameraController),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        color: Colors.black,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text("User Detection :- ${isUserPrediction ? " TRUE " : " FALSE "}"),
        ],
      ),
    );
  }
}
