import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sight_companion/components/listening_floating.dart';
import 'package:sight_companion/components/medium_button.dart';
import 'package:sight_companion/components/points.dart';
import 'package:sight_companion/pages/object_detection.dart';
import 'package:sight_companion/utils/colors_detection.dart';
import 'package:sight_companion/utils/text_to_speech.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MyTts tts = MyTts();
  bool loading = false;

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _objectDetectionHandler(BuildContext context) async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ObjectDetectionPage(imageFile: image),
      ));
    }
  }

  void _qrHandler(BuildContext context) async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ));
    Uri? uri = Uri.tryParse(res);
    if (uri != null && uri.hasScheme && uri.hasAuthority) {
      setState(() {
        loading = true;
      });
      await tts.speak("Opening domain ${uri.host}");
      setState(() {
        loading = false;
      });
      await _launchInBrowserView(uri);
    } else {
      setState(() {
        loading = true;
      });
      await tts.speak("The url is not valid. QR returned $res");
      setState(() {
        loading = false;
      });
    }
  }

  void _colorHandler(BuildContext context) async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    String color = await calculateDominantColor(image);
    setState(() {
      loading = true;
    });
    await tts.speak("It is $color color");
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: loading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        children: [
                          MediumButton(
                            color: Colors.green,
                            text: 'QR Scanner',
                            onTap: () => _qrHandler(context),
                          ),
                          MediumButton(
                            color: Colors.orange,
                            text: 'Object Detection',
                            onTap: () => _objectDetectionHandler(context),
                          ),
                          MediumButton(
                            color: Colors.blue,
                            text: 'Document Scanner',
                            onTap: () {
                              Navigator.pushNamed(context, '/ocr');
                            },
                          ),
                          MediumButton(
                            color: Colors.purple,
                            text: 'Color Detection',
                            onTap: () => _colorHandler(context),
                          ),
                        ],
                      ),
                      const Points(
                        points: [
                          '1: Tap on microphone to Start/Stop',
                          '2: You need not navigate by clicking. Just say "Open <page you want to open>"',
                          '3: Eg., "Open QR Scanner" or "Open Barcode Scanner" etc',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: const ListeningFloatingActionButton(),
    );
  }
}
