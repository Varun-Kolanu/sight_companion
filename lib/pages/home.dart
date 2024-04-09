import 'package:flutter/material.dart';
import 'package:sight_companion/components/listening_floating.dart';
import 'package:sight_companion/components/medium_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              children: [
                MediumButton(
                  color: Colors.red,
                  text: 'QR Scanner',
                  onTap: () {
                    Navigator.pushNamed(context, '/barcode');
                  },
                ),
                MediumButton(
                  color: Colors.green,
                  text: 'Text To Braille',
                  onTap: () {
                    Navigator.pushNamed(context, '/braille');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Object Detection',
                  onTap: () {
                    Navigator.pushNamed(context, '/object_detection');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Document to Text',
                  onTap: () {
                    Navigator.pushNamed(context, '/ocr');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Speech To Text',
                  onTap: () {
                    Navigator.pushNamed(context, '/speech_to_text');
                  },
                ),
                MediumButton(
                  color: Colors.blue,
                  text: 'Text To Speech',
                  onTap: () {
                    Navigator.pushNamed(context, '/text_to_speech');
                  },
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
