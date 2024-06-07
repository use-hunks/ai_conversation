import 'package:freezed_annotation/freezed_annotation.dart';

// 生成されるdartファイルを記述
part 'message_model.freezed.dart';

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required int id,
    required String body,
    // @TimestampSerializer() required DateTime createdAt
  }) = _MessageModel;
}
