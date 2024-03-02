import 'package:codepal/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../database/database.dart';
import 'login.dart';

class ChatUI extends StatefulWidget {
  const ChatUI({super.key});

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  // void testGemini() {
  //   final gemini = Gemini.instance;
  //   gemini
  //       .streamGenerateContent('Utilizing Google Ads in Flutter')
  //       .then((value) => print(value));
  // }

  Future<String> getGeminiResponse(String message) async {
    // flutter
    var gemini = Gemini.instance;
    String response = 'Error';
    await gemini
        .text(message)
        .then((value) => response = value?.output ?? 'Error')

        /// or value?.content?.parts?.last.text
        .catchError((e) =>
            response = 'Sorry, I didn\'t get that. Could you try again?\n$e');
    return response;
  }

  List<types.User> typingUsers = [];
  types.User gemini = types.User(
    id: '1',
    firstName: 'Gemini',
    //lastName: 'Bot',
    //imageUrl: 'https://i.imgur.com/7k12EPD.png',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat'), actions: [
        //logout
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            getMessages();
            //show alert dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        signOut();
                        Navigator.pop(context);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ]),
      body: Chat(
          theme: DarkChatTheme(),
          typingIndicatorOptions: TypingIndicatorOptions(
            typingUsers: typingUsers,
          ),
          messages: messages,
          onSendPressed: (text) async {
            var id = DateTime.now().millisecondsSinceEpoch;
            types.TextMessage message = types.TextMessage(
              author: currentUser!,
              createdAt: id,
              id: id.toString(),
              text: text.text,
            );
            setState(() {
              messages.insert(
                0,
                message,
              );
              //show typing indicator
              typingUsers.add(gemini);
            });
            setTextMessage(message,currentUser);
            var id2 = DateTime.now().millisecondsSinceEpoch + 5;
            await getGeminiResponse(text.text).then((value) {
              types.TextMessage reply = types.TextMessage(
                author: gemini,
                createdAt: id,
                id: 'Gemini${id.toString()}',
                text: value,
              );
              messages.insert(
                0,
                reply,
              );
              setTextMessage(reply,gemini);
            });
            
            typingUsers.remove(gemini);
            setState(() {});
          },
          user: currentUser!),
    );
  }
}
