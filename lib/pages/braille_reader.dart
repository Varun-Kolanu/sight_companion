import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrailleReaderApp extends StatefulWidget {
  const BrailleReaderApp({super.key});

  @override
  State<BrailleReaderApp> createState() => _BrailleReaderAppState();
}

class _BrailleReaderAppState extends State<BrailleReaderApp> {
  // Define Braille characters and their corresponding Unicode values
  final Map<String, String> brailleMap = {
    'a': '⠁',
    'b': '⠃',
    'c': '⠉',
    'd': '⠙',
    'e': '⠑',
    'f': '⠋',
    'g': '⠛',
    'h': '⠓',
    'i': '⠊',
    'j': '⠚',
    'k': '⠅',
    'l': '⠇',
    'm': '⠍',
    'n': '⠝',
    'o': '⠕',
    'p': '⠏',
    'q': '⠟',
    'r': '⠗',
    's': '⠎',
    't': '⠞',
    'u': '⠥',
    'v': '⠧',
    'w': '⠺',
    'x': '⠭',
    'y': '⠽',
    'z': '⠵',
    ' ': ' ',
  };

  // Convert text to Braille
  String textToBraille(String text) {
    return text.toLowerCase().split('').map((char) {
      return brailleMap[char] ?? char;
    }).join('');
  }

  // Build a single Braille character widget
  Widget buildBrailleCharacter(String brailleChar) {
    return GestureDetector(
      onTap: () {
        // Provide haptic feedback when the user taps on a Braille character
        HapticFeedback.selectionClick();
      },
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          brailleChar,
          style: TextStyle(fontSize: 48.0), // Adjust font size as needed
        ),
      ),
    );
  }

  // Build the Braille reader widget
  Widget buildBrailleReader(String text) {
    List<String> brailleText = textToBraille(text).split('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: brailleText.map((char) {
        return buildBrailleCharacter(char);
      }).toList(),
    );
  }

  void _vibrate() {
    print("Hi");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Braille Reader'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Touch the Braille characters to feel them through haptic feedback',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              buildBrailleReader('Hello'), // Display 'Hello' in Braille
              ElevatedButton(
                onPressed: _vibrate,
                child: const Text("hi"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
