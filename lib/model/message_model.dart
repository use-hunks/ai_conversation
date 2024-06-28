import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
part 'message_model.freezed.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    //required int id,
    required Role role,
    required String content,
    // @TimestampSerializer() required DateTime createdAt
  }) = _MessageModel;
}
