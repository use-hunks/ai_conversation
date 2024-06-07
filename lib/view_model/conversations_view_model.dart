import 'package:ai_conversation/model/message_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ai_conversation/model/conversation_model.dart';

part 'conversations_view_model.g.dart';

@riverpod
class ConversationsViewModel extends _$ConversationsViewModel {
  @override
  List<ConversationModel> build() {
    return const [
      ConversationModel(
          title: 'sample',
          messages: [MessageModel(id: 1, body: 'sample message')])
    ];
  }
}
