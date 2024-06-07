import 'package:ai_conversation/view_model/conversations_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ConversationView extends ConsumerWidget{
  const ConversationView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final conversations = ref.watch(conversationsViewModelProvider);
    return Text(conversations[0].messages[0].body);
  }
  
}