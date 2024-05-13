import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:io';
import 'next_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Talk with CHUPPY'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const tokenKey = 'OPENAI_API_KEY';
  late final String token;
  late final OpenAI openAI;
  _MyHomePageState() {
    // コンストラクター内でtokenとopenAIを初期化
    token = Platform.environment[tokenKey] ?? '';
    openAI = OpenAI.instance.build(
      token: token,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
    );
  }
  String content = 'What should I do for developing my app using flutter?';
  
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

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            ElevatedButton(
              onPressed: (){
                 // ここにボタンを押した時に呼ばれるコードを書く
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NextPage()),
            );
              }, 
              child: Text('START')),
            const SizedBox(height: 20),
            Text(
              'You have pushed the button this many times:'
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
