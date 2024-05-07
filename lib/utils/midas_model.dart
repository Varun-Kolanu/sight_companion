import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MiDASModel {
  final Interpreter interpreter;
  final int inputImageDim = 256;
  final List<double> mean = [123.675, 116.28, 103.53];
  final List<double> std = [58.395, 57.12, 57.375];
  final int NUM_THREADS = 4;

  MiDASModel(this.interpreter);

  Future<img.Image> getDepthMap(Uint8List inputImage) async {
    return await run(inputImage);
  }

  Future<img.Image> run(Uint8List inputImage) async {
    print(inputImage);
    img.Image image = img.decodeImage(inputImage)!;
    img.Image resizedImage =
        img.copyResize(image, width: inputImageDim, height: inputImageDim);
    // Normalize the resized image
    List<double> normalizedImage = _normalizeImage(resizedImage);

    // Prepare the input tensor
    var inputTensor = Float32List.fromList(normalizedImage);

    // Prepare the output tensor
    var outputTensor = Float32List(inputImageDim * inputImageDim * 1);

    // Perform inference on the MiDAS model
    interpreter.run(inputTensor.buffer, outputTensor.buffer);

    return _postprocess(outputTensor);
  }

  List<double> _normalizeImage(img.Image image) {
    List<double> normalizedImage = [];
    for (int y = 0; y < inputImageDim; y++) {
      for (int x = 0; x < inputImageDim; x++) {
        img.Pixel pixel = image.getPixelSafe(x, y);
        num r = pixel.r;
        num g = pixel.g;
        num b = pixel.b;
        normalizedImage.add((r - mean[0]) / std[0]);
        normalizedImage.add((g - mean[1]) / std[1]);
        normalizedImage.add((b - mean[2]) / std[2]);
      }
    }
    return normalizedImage;
  }

  img.Image _postprocess(Float32List outputTensor) {
    double max = outputTensor
        .reduce((value, element) => value > element ? value : element);
    double min = outputTensor
        .reduce((value, element) => value < element ? value : element);

    List<int> processedPixels = [];
    for (var pixelValue in outputTensor) {
      // Normalize the values and scale them by a factor of 255
      var p = (((pixelValue - min) / (max - min)) * 255).toInt();
      if (p < 0) {
        p += 255;
      }
      processedPixels.add(p);
    }

    Uint8List pixelBytes = Uint8List.fromList(processedPixels);

    // Convert processed pixels to an image
    return img.Image.fromBytes(
        width: inputImageDim, height: inputImageDim, bytes: pixelBytes.buffer);
  }
}
