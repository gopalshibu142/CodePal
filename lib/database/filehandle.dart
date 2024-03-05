import 'package:codepal/database/api.dart';
import 'package:codepal/database/database.dart';
import 'package:codepal/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

Future<XFile?> handleImageSelection() async {
  final result = await ImagePicker().pickImage(
    imageQuality: 70,
    maxWidth: 1440,
    source: ImageSource.gallery,
  );

  if (result != null) {
    final bytes = await result.readAsBytes();
    final image = await decodeImageFromList(bytes);

    final message = types.ImageMessage(
      author: currentUser!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      height: image.height.toDouble(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: result.name,
      size: bytes.length,
      uri: result.path,
      width: image.width.toDouble(),
    );

    messages.insert(0, message);
    if (!isIncognito) setImageMessage(message, currentUser);
  }
  return result;
}
