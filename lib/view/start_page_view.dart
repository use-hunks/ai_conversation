import 'package:flutter/material.dart';
import 'package:ai_conversation/view/chat_view.dart';

class StartPageView extends StatelessWidget{
  const StartPageView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to AI Conversation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: const Text('START'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatView()),
                );
              },
            ),
          ]
        )
      )
    );
  }
}