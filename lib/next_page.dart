import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  //tts
  FlutterTts flutterTts = FlutterTts();

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
  //stt
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
  List<Messages> messageHistory = [
    Messages(
      role: Role.system,
      content: "You are an AI English teacher. Users will talk about something in English. You should talk about it to get the conversation going. Please keep note that you should reply in a couple of friendly sentences. "
    )
  ];
  
  void addMessage(Role role, String content){
    messageHistory.add(Messages(role: role, content: content));
  }

  void _getChatGPTResponse(String input) async{
    addMessage(Role.user, input);
    final messageJson = messageHistory.map((message) => message.toJson()).toList();
    final response = await openAI.onChatCompletion(
      request: ChatCompleteText(
        model: GptTurboChatModel(),
        messages: messageJson,
        maxToken: 100,
      ),
    );
    setState(() {
      _response = response?.choices.last.message?.content ?? "";
      addMessage(Role.assistant, _response);
    });
  }

  //tts
  void _speak(text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);//0~1
    //await flutterTts.setVoice({"name": "en-us-x-sfg#male_1-local", "locale": "en-US"});
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('CHAPPIE'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      _response ?? '',
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
                    )
                  ),
                  if(_speechToText.isNotListening && _confidenceLevel > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Text(
                        "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      )
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
                  ElevatedButton(
                    onPressed:() => _speak(_response),//ここに話したい言葉を入れる 
                    child: Text(
                      "Tap to say",
                    )
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 5),
                color: Colors.white,
              ),
              height: 80,
              alignment: Alignment.bottomCenter,
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter a sentence'
                ),
                onChanged: (text) {
                  userInput = text;
                },
                onSubmitted: (text) {
                  _getChatGPTResponse(text);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed:
            _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      )
    );
  }
}
