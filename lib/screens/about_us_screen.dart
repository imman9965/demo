import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _micEnabled = true; // New: Tracks if mic is enabled
  String _selectedLanguage = 'en-US'; // Default to English

  @override
  void initState() {
    super.initState();
    _requestMicPermission().then((_) => _initSpeech());
  }

  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission denied. Enable it in settings.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      await openAppSettings();
    } else {
      print('Microphone permission granted');
    }
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: _statusListener,
      onError: _errorListener,
      debugLogging: true,
    );
    setState(() {
      _speechAvailable = available;
    });
    if (!available) {
      print("Speech recognition not available.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      print('Speech recognition initialized successfully');
    }
  }

  void _startListening() async {
    if (!_speechAvailable || _isListening || !_micEnabled) {
      if (!_speechAvailable) await _initSpeech();
      return;
    }
    await _speech.listen(
      onResult: _resultListener,
      localeId: _selectedLanguage,
      partialResults: true,
    );
    setState(() {
      _isListening = true;
    });
    print('Started listening in $_selectedLanguage');
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _micEnabled = false;
    });
  }

  void _submitFeedback() {
    if (_feedbackController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback submitted: ${_feedbackController.text}'),
          backgroundColor: Colors.green,
        ),
      );
      _feedbackController.clear();
      setState(() {
        _micEnabled = true; // Re-enable mic after submission
      });
      print('Feedback submitted, mic re-enabled');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Status listener callback
  void _statusListener(String status) {
    print('Speech status: $status');
    setState(() {
      _isListening = status == 'listening';
    });
  }

  /// Error listener callback
  void _errorListener(stt.SpeechRecognitionError error) {
    print('Speech error: ${error.errorMsg}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speech recognition error: ${error.errorMsg}'),
        backgroundColor: Colors.redAccent,
      ),
    );
    setState(() {
      _isListening = false;
    });
  }

  /// Result listener callback
  void _resultListener(stt.SpeechRecognitionResult result) {
    setState(() {
      _feedbackController.text = result.recognizedWords;
      print('Recognized words: ${_feedbackController.text}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provide Feedback',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Feedback (English/Tamil)',
                border: OutlineInputBorder(),
                hintText: 'Type or speak your feedback here...',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'en-US', child: Text('English')),
                    DropdownMenuItem(value: 'ta-IN', child: Text('Tamil')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                      if (_isListening) {
                        _stopListening();
                        _startListening();
                      }
                    }
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_off,
                        color: _isListening ? Colors.red : Colors.blue,
                      ),
                      onPressed:
                          _isListening ? _stopListening : _startListening,
                      tooltip:
                          _isListening ? 'Stop Listening' : 'Start Listening',
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _feedbackController.dispose();
    super.dispose();
  }
}
