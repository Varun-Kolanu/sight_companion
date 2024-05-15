import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class Qr {
  String result = '';
  static final Qr _instance = Qr._internal();

  factory Qr() => _instance;
  Qr._internal();

  Future<void> launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<String> openScanner(
    BuildContext context,
  ) async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ));
    return res;
  }
}
