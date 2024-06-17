import 'package:ai_conversation/view_model/conversations_view_model.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationView extends ConsumerWidget {
  const ConversationView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsViewModelProvider);
    final conversationsNotifer = ref.read(conversationsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('CHAPPIE'),
      ),
      body: Center(
        child: ListView.builder(
        itemCount: conversations[0].messages.length,
        itemBuilder: (context, index) {
          final message = conversations[0].messages[index];
          return Text(message.body);
        },
      )),
      floatingActionButton: FloatingActionButton(
          onPressed: () =>
            conversationsNotifer.addMessage(1, Role.user, "hello"),
          child: const Icon(Icons.add),
      ),
    );
  }
}
