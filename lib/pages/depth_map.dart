import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:sight_companion/utils/midas_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // You may need to add dependency for image processing

class DepthMapPage extends StatefulWidget {
  @override
  _DepthMapPageState createState() => _DepthMapPageState();
}

class _DepthMapPageState extends State<DepthMapPage> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  img.Image? _depthMap;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> captureImage() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (_controller.value.isTakingPicture) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });
      final XFile file = await _controller.takePicture();
      // print("File:");
      // print(file);
      Uint8List imageBytes = await file.readAsBytes();
      img.Image image = img.decodeImage(imageBytes)!;
      var model = await Interpreter.fromAsset('assets/depth_model.tflite');
      // print(model);
      img.Image depthMap = await MiDASModel(model).getDepthMap(image);
      setState(() {
        _depthMap = depthMap;
        _isCapturing = false;
      });
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Depth Map Generator'),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: <Widget>[
                CameraPreview(_controller),
                _depthMap != null
                    ? Center(
                        child: Image.memory(
                          Uint8List.fromList(img.encodePng(_depthMap!)),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          "Hello",
                        )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: _isCapturing ? null : captureImage,
                      child: Icon(Icons.camera),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: _depthMap != null
          ? FloatingActionButton(
              onPressed: () {
                // Do something with the depth map
              },
              child: Icon(Icons.check),
            )
          : null,
    );
  }
}
