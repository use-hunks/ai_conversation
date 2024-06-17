import 'package:ai_conversation/model/message_model.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ai_conversation/model/conversation_model.dart';

part 'conversations_view_model.g.dart';

@riverpod
class ConversationsViewModel extends _$ConversationsViewModel {
  @override
  List<ConversationModel> build() {
    return const [
      ConversationModel(
          id: 1,
          title: 'Conversation 1',
          messages: [MessageModel(id: 1, role:Role.system, body: "You are an AI English teacher. Users will talk about something in English. You should talk about it to get the conversation going. Please keep note that you should reply in a couple of friendly sentences. ")])
    ];
  }

  void addMessage(int conversationId, Role role, String body) {
    final newMessageId = state
            .firstWhere((conversation) => conversation.id == conversationId)
            .messages.length +1;
    final newMessage = MessageModel(id: newMessageId, role: role, body: body);

    state = state.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation
            .copyWith(messages: [...conversation.messages, newMessage]);
      }
      return conversation;
    }).toList();
  }
}
