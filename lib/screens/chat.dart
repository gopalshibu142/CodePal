import 'package:codepal/database/api.dart';
import 'package:codepal/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:codepal/database/filehandle.dart';
import 'package:image_picker/image_picker.dart';

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

  // Future<String> getGeminiResponse(String message) async {
  //   // flutter
  //   var gemini = Gemini.instance;
  //   String response = 'Error';
  //   await gemini
  //       .text(message)
  //       .then((value) => response = value?.output ?? 'Error')

  //       /// or value?.content?.parts?.last.text
  //       .catchError((e) =>
  //           response = 'Sorry, I didn\'t get that. Could you try again?\n$e');
  //   return response;
  // }

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
      appBar: AppBar(
          backgroundColor: Color(0xff333333),
          title: Text('Chat ' + (isIncognito ? '(Incognito)' : '')),
          actions: [
            //options for incognito mode
            PopupMenuButton<String>(
              onSelected: (String result) async {
                if (result == 'Incognito') {
                  isIncognito = !isIncognito;

                  if (isIncognito) {
                    messages = incognitoMessages;
                  } else {
                    // incognitoMessages = messages;
                    await getMessages().then((value) {
                      //  print(currentUser!.id);
                      // print(value);
                      messages = value;
                      setState(() {});
                    });
                  }
                  setState(() {});
                } else if (result == 'Logout') {
                  setState(() {
                    isIncognito = false;
                    currentUser = null;
                    messages = [];
                    //show alert
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('You have been logged out.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Incognito',
                  child: Text('Incognito'),
                ),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          ]),
      body: Chat(
          theme: const DarkChatTheme(
            backgroundColor: Color(0xff111111),
            inputTextColor: Color(0xffffffff),
            inputBackgroundColor: Color(0xff333333),
            primaryColor: Color(0xff777777),
            secondaryColor: Color(0xff555555),
          ),
          typingIndicatorOptions: TypingIndicatorOptions(
            typingUsers: typingUsers,
          ),
          onAttachmentPressed: () async {
            typingUsers.add(gemini);
            XFile? resultImage = await handleImageSelection();
            setState(() {
              
            });
            if (resultImage != null) {
              final message = await getGeminiImageResponse(resultImage);
              messages.insert(0, message);
            }
            typingUsers.remove(gemini);
            setState(() {});
          },
          messages: messages,
          onSendPressed: (text) async {
            if (text.text.isNotEmpty && typingUsers.isEmpty) {
              types.TextMessage message = types.TextMessage(
                author: currentUser!,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: DateTime.now().millisecondsSinceEpoch.toString(),
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
              if (!isIncognito) setTextMessage(message, currentUser);
              await getGeminiChatResponse(text.text).then((value) {
                types.TextMessage reply = value;
                messages.insert(
                  0,
                  reply,
                );
                if (!isIncognito) setTextMessage(reply, gemini);
              });

              // var id2 = DateTime.now().millisecondsSinceEpoch + 5;
              // await getGeminiResponse(text.text).then((value) {
              //   types.TextMessage reply = types.TextMessage(
              //     author: gemini,
              //     createdAt: id,
              //     id: 'Gemini${id.toString()}',
              //     text: value,
              //   );
              //   messages.insert(
              //     0,
              //     reply,
              //   );

              // setTextMessage(reply, gemini);
              // });

              typingUsers.remove(gemini);
              setState(() {});
            } else if (typingUsers.isNotEmpty) {
              //show snack bar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please wait for the response.',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.grey,
                ),
              );
            } else if (text.text.isEmpty) {
              //show snack bar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter a message.',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          user: currentUser!),
    );
  }
}
