import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
class ChatUI extends StatefulWidget {
  const ChatUI({super.key});

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  getGeminiResponse(String message) async {
    var gemini = Gemini.instance;
    String response = '';
    await gemini
        .text(message)
        .then((value) => response = value?.output ?? 'Error')

        /// or value?.content?.parts?.last.text
        .catchError((e) =>
            response = 'Sorry, I didn\'t get that. Could you try again?');
    return response;
  }

  List<types.Message> messages = [];
  List<types.User> typingUsers = [];
  types.User gemini = types.User(
    id: '2',
    firstName: 'Gemini',
    //lastName: 'Bot',
    //imageUrl: 'https://i.imgur.com/7k12EPD.png',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        typingIndicatorOptions: TypingIndicatorOptions(
          typingUsers: typingUsers,

        ),
        
        messages: messages,
        onSendPressed: (text)async{
          setState((){
            var id = DateTime.now().millisecondsSinceEpoch;
            messages.insert(0,types.TextMessage(
              author: types.User(
                id: '1',
              ),
              createdAt: id,
              id: id.toString(),
              text: text.text,
            ));
           //show typing indicator
           typingUsers.add(gemini);
            
          });
          var id = DateTime.now().millisecondsSinceEpoch;
           await getGeminiResponse(text.text).then((value) {
              messages.insert(0,types.TextMessage(
                author: gemini,
                createdAt: id,
                id: 'Gemini${id.toString()}',
                text: value,
              ));
            });
            typingUsers.remove(gemini);
          setState(() {
            
          });
        },
        user: types.User(
          id: '1',
        ),
      ),
    );
  }
}

