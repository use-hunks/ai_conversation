import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart';

class NextPage extends StatefulWidget {
  //initializer
  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  //stt
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  //gpt
  late final String token;
  late final OpenAI openAI;
  late String content;
  String _response = "";
  String userInput = "";

  _NextPageState() {
    // コンストラクター内でtokenとopenAIを初期化
    token = dotenv.get('OPENAI_API_KEY');
    openAI = OpenAI.instance.build(
      token: token,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
    );
  }

  late Future<String> responseText;
  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize(debugLogging: true);
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
  }
  //gpt
  void _getChatGPTResponse(String input) async{
    final response = await openAI.onChatCompletion(
      request: ChatCompleteText(
        model: GptTurboChatModel(),
        messages: [
          Messages(
            role: Role.user,
            content: input,
          ).toJson(),
        ],
        maxToken: 100,
      ),
    );
    setState(() {
      _response = response?.choices.last.message?.content ?? "";
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text('CHAPPIE'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        border: InputBorder.none, 
                        hintText: 'Enter a sentence'
                        ),
                    onChanged: (text) {
                      userInput = text;
                    },
                    onSubmitted: (text){
                      _getChatGPTResponse(text);
                    },
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(_response ?? ''),
                      ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening
                      ? "Listening..."
                      : _speechEnabled
                          ? "Tap the microphone to start listening..."
                          : "Speech not available",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              )),
              if (_speechToText.isNotListening && _confidenceLevel > 0)
                Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Text(
                      "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                      ),
                    )),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              _speechToText.isListening ? _stopListening : _startListening,
          tooltip: 'Listen',
          child: Icon(
            _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
          ),
          backgroundColor: Colors.black,
        ));
  }
}
