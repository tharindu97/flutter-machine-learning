import 'dart:io';
import 'package:facedetection/video_camera_page.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isUserPrediction = false;
  // capture image for camera
  File? imageFile;
  Future<File?> captureImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? photo =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      imageFile = File(photo.path);
    }
    return imageFile;
  }

  // face detection.
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableTracking: false,
      enableContours: false,
      enableClassification: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  InputImage cameraImageToInputImage(File cameraImage) {
    return InputImage.fromFile(cameraImage);
  }

  void processImage(File cameraImage) async {
    final List<Face> faces =
        await faceDetector.processImage(cameraImageToInputImage(cameraImage));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Detection"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoCameraPage(),
                ),
              );
            },
            child: const Text("Open Video Camera"),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 400,
            width: 400,
            child: imageFile != null
                ? Image.file(imageFile!)
                : const Text(
                    "No more data",
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                if (imageFile != null) {
                  processImage(imageFile!);
                } else {
                  debugPrint("image file null");
                }
              } catch (e) {
                throw Exception("error face detection");
              }
            },
            child: const Text("Face Detection"),
          ),
          const SizedBox(height: 20),
          Text(isUserPrediction ? "Face Detected" : " No Face")
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await captureImage().then((value) {
              if (value != null) {
                setState(() {});
              }
            });
          } catch (e) {
            throw Exception("error capture image");
          }
        },
        tooltip: 'Capture Image',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
