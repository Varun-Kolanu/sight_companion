import 'package:flutter/material.dart';
import 'package:sight_companion/utils/text_to_speech.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class Qr {
  String result = '';
  final Tts _tts = Tts();
  static final Qr _instance = Qr._internal();

  factory Qr() => _instance;
  Qr._internal();

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> openScanner(
    BuildContext context,
  ) async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ));
    if (res is String) {
      result = res;
    }
    Uri? uri = Uri.tryParse(res);
    if (uri != null && uri.hasScheme && uri.hasAuthority) {
      await _tts.speak("Opening domain ${uri.host}");
      await _launchInBrowserView(uri);
    }
  }
}
