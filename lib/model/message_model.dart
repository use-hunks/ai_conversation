import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 生成されるdartファイルを記述
part 'message_model.freezed.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required int id,
    required Role role,
    required String body,
    // @TimestampSerializer() required DateTime createdAt
  }) = _MessageModel;
}
