import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  //stt
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";

  //tts
  FlutterTts flutterTts = FlutterTts();

  //gpt
  late final String token;
  late final OpenAI openAI;
  late String content;
  String _response = "";
  String userInput = "";
  final TextEditingController _controller = TextEditingController();

  _ChatViewState() {
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
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      addMessage(Role.user, _wordsSpoken);
    });
  }

  //gpt
  List<Messages> messageHistory = [
    Messages(
        role: Role.system,
        content:
            "You are an AI English teacher. Users will talk about something in English. You should talk about it to get the conversation going. Please keep note that you should reply in a couple of friendly sentences. ")
  ];

  void addMessage(Role role, String content) {
    messageHistory.add(Messages(role: role, content: content));
  }

  void _getChatGPTResponse(String input) async {
    addMessage(Role.user, input);
    final messageJson =
        messageHistory.map((message) => message.toJson()).toList();
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
    await flutterTts.setSpeechRate(0.5); //0~1
    //await flutterTts.setVoice({"name": "en-us-x-sfg#male_1-local", "locale": "en-US"});
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('CHAPPIE'),
      ),
      body: Stack(alignment: Alignment.bottomCenter, children: [
        Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //gptのresponse表示
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        _response,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    //音声入力の表示
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _wordsSpoken,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    //マイク権限の状態の表示
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _speechToText.isListening
                            ? "Listening..."
                            : _speechEnabled
                                ? "Tap the microphone to start listening..."
                                : "Speech not available",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    //音声出力
                    ElevatedButton(
                        onPressed: () => _speak(_response), //ここに話したい言葉を入れる
                        child: const Text(
                          "Tap to say",
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        //テキスト入力 下部に固定
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 5),
            color: Colors.black,
          ),
          height: 80,
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1),
                    color: Colors.black,
                  ),
                  height: 80,
                  alignment: Alignment.bottomCenter,
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textInputAction: TextInputAction.done, //Enterで送信させる
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a sentence...',
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 20)),
                    onChanged: (text) {
                      userInput = text;
                    },
                  ),
                ),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(50, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // 必要に応じてパディングを設定
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () => {
                        //送信
                        //gptResponse呼び出す
                        _getChatGPTResponse(userInput),
                        //textを消す
                        _controller.clear(),
                      },
                  child: const Icon(Icons.send)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(50, 50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16), // 必要に応じてパディングを設定
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _speechToText.isListening
                    ? _stopListening
                    : _startListening,
                child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
