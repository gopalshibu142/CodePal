import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

types.User? currentUser;
List<types.Message> messages = [];
bool isIncognito = false;
List<types.Message> incognitoMessages = [];