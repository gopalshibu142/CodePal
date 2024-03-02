import 'package:codepal/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/chat.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import './api.dart';
import 'screens/splash.dart';
void main() async {
  Gemini.init(apiKey:api );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CodePal());
}
class CodePal extends StatelessWidget {
  const CodePal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodePal',
      theme: ThemeData.dark(),
      home: const Splash(),
    );
  }
}