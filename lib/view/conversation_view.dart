import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_conversation/view_model/conversations_view_model.dart';

class ConversationView extends ConsumerWidget {
  const ConversationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsViewModelProvider);
    final conversationsNotifer =
        ref.read(conversationsViewModelProvider.notifier);
    final TextEditingController controller = TextEditingController();
    String userInput = "";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('CHAPPIE'),
      ),
      body: Stack(alignment: Alignment.bottomCenter, children: [
        ListView.builder(
          itemCount: conversations[0].messages.length - 1,
          itemBuilder: (context, index) {
            final message = conversations[0].messages[index + 1];
            return Card(
              margin: index % 2 == 0
                  ? const EdgeInsets.only(
                      top: 5.0, left: 90.0, bottom: 5.0, right: 8.0)
                  : const EdgeInsets.only(
                      top: 5.0, left: 8.0, bottom: 5.0, right: 90.0),
              child: ListTile(
                title: Text(message.content),
              ),
            );
          },
        ),
        //テキスト入力フォーム（下部固定）
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 5),
            color: Colors.black,
          ),
          height: 80,
          alignment: Alignment.bottomCenter,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1),
                  color: Colors.black,
                ),
                height: 80,
                alignment: Alignment.bottomCenter,
                child: TextField(
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.done, //Enterで送信させる
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter a sentence...',
                      hintStyle: TextStyle(color: Colors.white, fontSize: 20)),
                  onChanged: (text) {
                    userInput = text;
                  },
                ),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(50, 50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16), // 必要に応じてパディングを設定
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () => {
                      //送信してgptResponse呼び出す
                      conversationsNotifer.getChatGPTResponse(userInput),
                      //textを消す
                      controller.clear(),
                    },
                child: const Icon(Icons.send)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(50, 50),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // 必要に応じてパディングを設定
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () => {
                //mic関係
              },
              child: const Icon(Icons.mic),
            )
          ]),
        ),
      ]),
    );
  }
}
