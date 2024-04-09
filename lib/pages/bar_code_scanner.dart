import 'package:flutter/material.dart';
import 'package:sight_companion/components/medium_button.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class BarCodeScannerPage extends StatefulWidget {
  final String? url;
  const BarCodeScannerPage({super.key, this.url});

  @override
  State<BarCodeScannerPage> createState() => _BarCodeScannerPageState();
}

class _BarCodeScannerPageState extends State<BarCodeScannerPage> {
  String result = '';
  // bool openScanner = true;

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();
    result = widget.url!;
  }

  void _openScanner() async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ));
    setState(() {
      if (res is String) {
        result = res;
      }
    });
    Uri? uri = Uri.tryParse(res);
    if (uri != null && uri.hasScheme && uri.hasAuthority) {
      await _launchInBrowserView(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MediumButton(
              color: Colors.blue,
              text: "Open Scanner",
              onTap: _openScanner,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                result == "-1" ? "" : result,
                style: const TextStyle(color: Colors.blue, fontSize: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
