import 'package:flutter/material.dart';
import 'package:ai_conversation/view/conversation_view.dart';

class StartPageView extends StatelessWidget {
  const StartPageView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          color: const Color.fromRGBO(31, 28, 57, 1.0),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                const Text(
                  'Welcome to AI Conversation',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('START'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConversationView()),
                    );
                  },
                ),
              ])),
        ));
  }
}
