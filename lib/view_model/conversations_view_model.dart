import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ai_conversation/model/message_model.dart';
import 'package:ai_conversation/model/conversation_model.dart';

part 'conversations_view_model.g.dart';

@riverpod
class ConversationsViewModel extends _$ConversationsViewModel {
  @override
  List<ConversationModel> build() {
    return const [
      ConversationModel(
          // id: 1,
          // title: 'Conversation 1',
          messages: [
            MessageModel(
                role: Role.system,
                content:
                    "You are an AI English teacher. Users will talk about something in English. You should talk about it to get the conversation going. Please keep note that you should reply in a couple of friendly sentences. ")
          ])
    ];
  }

  void addMessage(Role role, String content) {
    final newMessage = MessageModel(role: role, content: content);
    state = state.map((conversation) {
      return conversation
          .copyWith(messages: [...conversation.messages, newMessage]);
    }).toList();
  }

  final OpenAI openAI = OpenAI.instance.build(
    token: dotenv.get('OPENAI_API_KEY'),
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
  );

  void getChatGPTResponse(String input) async {
    addMessage(Role.user, input);
    // 現在のメッセージ履歴を取得
    final messages = state[0].messages.map((message) {
      return {
        'role': message.role.toString().split('.').last,
        'content': message.content
      };
    }).toList();
    // ChatGPT API リクエストを作成
    final request = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: messages,
      maxToken: 100,
    );
    final response = await openAI.onChatCompletion(request: request);
    // レスポンスからアシスタントのメッセージを追加
    final assistantMessage = response?.choices.last.message?.content ?? "";
    speak(assistantMessage);
    addMessage(Role.assistant, assistantMessage);
  }

  //tts
  FlutterTts flutterTts = FlutterTts();
  Future<void> initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5); //0~1
  }

  Future<void> speak(text) async {
    await flutterTts.speak(text);
  }

//stt
  final SpeechToText _speechToText = SpeechToText();
  bool canSpeech = false;

  Future<void> initStt() async {
    canSpeech = await _speechToText.initialize(debugLogging: true);
  }

  bool isListening() {
    return _speechToText.isListening;
  }

  Future<void> startListening() async {
    await _speechToText.listen(onResult: onSpeechResult);
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      getChatGPTResponse(result.recognizedWords);
    }
  }
}
