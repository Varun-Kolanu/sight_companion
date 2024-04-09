import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:typed_data';

int _colorDistance(Color a, Color b) {
  return (a.red - b.red) * (a.red - b.red) +
      (a.green - b.green) * (a.green - b.green) +
      (a.blue - b.blue) * (a.blue - b.blue);
}

Future<String> calculateDominantColor(XFile? imageFile) async {
  Uint8List bytes = await File(imageFile!.path).readAsBytes();
  ImageProvider<Object> imageProvider = MemoryImage(Uint8List.fromList(bytes));
  PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
    imageProvider,
  );
  Color? domColor = paletteGenerator.dominantColor?.color;

  Map<String, Color> colorMap = {
    'White': Colors.white,
    'Black': Colors.black,
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Yellow': Colors.yellow,
    'Grey': Colors.grey,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Green': Colors.green,
    'Brown': Colors.brown,
    'Pink': Colors.pink,
    'Cyan': Colors.cyan
  };
  int minDistance = 200000;
  String nearestColor = '';
  for (var entry in colorMap.entries) {
    int colorDist = _colorDistance(domColor!, entry.value);
    if (colorDist < minDistance) {
      minDistance = colorDist;
      nearestColor = entry.key;
    }
  }
  return nearestColor;
}
