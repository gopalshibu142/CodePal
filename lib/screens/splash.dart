import 'package:codepal/database/database.dart';
import 'package:codepal/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'chat.dart';
import 'login.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool checkSignedIn = false;
  void init() async {
    checkSignedIn = await isSignedIn();
    Future.delayed(const Duration(seconds: 2), () async{
      if (checkSignedIn) {
        User? user = FirebaseAuth.instance.currentUser;
        getMessages().then((value) async{
          messages = value;
          if (messages.length>30){
            messages = messages.sublist(messages.length-30);
          }
           
          currentUser = types.User(id: user!.uid, firstName: user.displayName);
        print(currentUser!.firstName);
        //Future.delayed(const Duration(seconds: 2),);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) =>const ChatUI()));

        });
        
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) =>const Login()));
      }
    });
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FlutterSplashScreen(
        useImmersiveMode: true,
        duration: const Duration(milliseconds: 2000),
        nextScreen: null,
        backgroundColor: Colors.black,
        splashScreenBody: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/loading.json', height: 400, width: 400),
            const SizedBox(height: 20),
            Text('CodePal',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          ],
        )),
      ),
    ));
  }
}
