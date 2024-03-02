import 'package:codepal/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

Future<String> signIn(email, password) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var msg = "error";
  await _auth
      .signInWithEmailAndPassword(email: email, password: password)
      .then((user) {
    if (user.user!.emailVerified) {
      currentUser =
          types.User(id: user.user!.uid, firstName: user.user!.displayName);
      msg = "success";
    } else {
      msg = "Please verify your email";
    }
  });
  return msg;
}

Future<String> signUp(email, password, name) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.reference();
  var msg = "error";
  await _auth
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((user) {
    user.user!.updateDisplayName(name);
    user.user!.sendEmailVerification();
    msg = 'success';

    //showAlertDialog(context, 'Verification Email Sent', 'Please verify your email');
  });
  return msg;
}

void sentVerification() async {}

Future<String> forgetPassword(email) async {
  String msg = "error";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  await _auth.sendPasswordResetEmail(email: email).then((value) {
    msg = "success";
  });
  return msg;
}

void signOut() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  await _auth.signOut();
  currentUser = null;
}

Future<bool> isSignedIn() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isSignedIn = false;
  await _auth.authStateChanges().listen((User? user) {
    if (user == null) {
      isSignedIn = false;
    } else {
      currentUser = types.User(id: user.uid, firstName: user.displayName);
      isSignedIn = true;
    }
  });
  return isSignedIn;
}

Future<List<types.Message>> getMessages() async {
  types.User gemini = types.User(
    id: '1',
    firstName: 'Gemini',
  );
  final ref = FirebaseDatabase.instance.ref();
  List<types.Message> msg = [];
  await ref
      .child('users')
      .child(currentUser!.id)
      .child('messages')
      .once()
      .then((DatabaseEvent event) {
    DataSnapshot snapshot = event.snapshot;
    snapshot.children.forEach((element) {
      if (element.child('type').value.toString() == 'text') {
        msg.insert(0,types.TextMessage(
          author: element.child('author').value.toString() == currentUser!.id
              ? currentUser!
              : gemini,
          createdAt: int.parse(element.child('createdAt').value.toString()),
          id: element.child('id').value.toString(),
          text: element.child('text').value.toString(),
        ));
      }
      print(msg);
    });
  });
  return msg;
}

void setTextMessage(types.TextMessage message, types.User? user) {
  final ref = FirebaseDatabase.instance.ref();
  ref.child('users').child(currentUser!.id).child('messages').push().set({
    'author': user!.id,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
    'id': message.id,
    'text': message.text,
    'type': 'text'
  });
}
