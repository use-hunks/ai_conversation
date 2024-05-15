import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NextPage extends StatefulWidget{
  //initializer
  NextPage(this.input);
  String input;
  @override
  _NextPageState createState() => _NextPageState(this.input);
}

class _NextPageState extends State<NextPage>{
  late final String token;
  late final OpenAI openAI;
  late String content;
  _NextPageState(String input) {
    // コンストラクター内でtokenとopenAIを初期化
    this.content = input;
    token = dotenv.get('OPENAI_API_KEY') ?? '';
    openAI = OpenAI.instance.build(
      token: token,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
    );
  }
  
  late Future<String> responseText;
  @override
  void initState(){
    super.initState();
    responseText = Future(
      ()async{
        final response = await openAI.onChatCompletion(
          request: ChatCompleteText(
            model: GptTurboChatModel(),
            messages: [ 
              Messages(
                role: Role.system,
                content : content,
              ).toJson(),
            ],
            maxToken: 100,
          ),
      );
      return response?.choices.last.message?.content ?? ''; 
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<String>(
              future: responseText,
              builder: (context, snapshot){
                if(snapshot.hasData){
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child:Text(snapshot.data ?? ''),
                  );
                }
                if(snapshot.connectionState == ConnectionState.waiting){
                  return CircularProgressIndicator();
                }else if(snapshot.hasError){
                  return Text('Error: ${snapshot.error}');
                }else{
                  return Text(
                    snapshot.data ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  );
                }
              }
            ),
            Container(
              child:Text('next page'),
            )
          ],
          ),)
    );
  } 
}