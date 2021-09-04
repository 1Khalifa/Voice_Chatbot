import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';

void main() {
  runApp(MyApp());
}

String res = '';

class WatsonAssistant {
  void watson(String speech) async {
    final auth = IbmWatsonAssistantAuth(
      assistantId: 'faccb0fc-44b9-41b0-9fc5-3e760736d38b',
      url:
          'https://api.eu-gb.assistant.watson.cloud.ibm.com/instances/47e2608d-3af4-4977-af92-c37729e13315',
      apikey: '974qP81PdgVb0yEZ8-E4YJ4MeuTbg70PmY8cghdUApGp',
    );

    final bot = IbmWatsonAssistant(auth);
    final sessionId = await bot.createSession();

    final botRes = await bot.sendInput(speech, sessionId: sessionId);
    try {
      res = botRes.responseText!;

      bot.deleteSession(sessionId!);

      final logs = await bot.logs();
      print(logs);
    } catch (e) {
      print('Logging endpoint only available for paid plans.\n$e');
    }
  }
}

String _text = 'Hi I am Watson!';
String _text2 = 'Press the mic button to talk to me';

const bgColor = Color(0xFFf5f0f3);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Methods Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF9e174c),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(centerTitle: true, title: Text('Smart Methods Assistant')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 120.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: onListen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
        reverse: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Image.asset(
                    'lib/assets/robot-head.png',
                    fit: BoxFit.contain,
                    height: 60,
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color(0xff124c58),
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 30,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    child: Text(
                      _text,
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color(0xFF71949b),
                  borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 0,
              ),
              child: Text(
                _text2,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onListen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() async {
                  _text2 = val.recognizedWords;
                  WatsonAssistant watson = new WatsonAssistant();
                  watson.watson(_text2);
                  _text = res;

                  FlutterTts tts = FlutterTts();
                  tts.setVolume(1.0);
                  await tts.awaitSpeakCompletion(true);
                  await tts.awaitSynthCompletion(true);
                  await tts.speak(res);
                }));
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }
}
