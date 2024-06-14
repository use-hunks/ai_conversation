import 'package:freezed_annotation/freezed_annotation.dart';
import './message_model.dart';
// 生成されるdartファイルを記述
part 'conversation_model.freezed.dart';

@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required int id,
    required String title, 
    required List<MessageModel> messages
    // @TimestampSerializer() required DateTime createdAt
  }) = _ConversationModel;

  //jsonに変換
//   factory ConversationModel.fromJson(Map<String, dynamic> json) =>
//     _$ConversationModelFromJson(json);
}
