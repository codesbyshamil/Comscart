import 'package:comsmart/Navbar.dart';
import 'package:comsmart/auth/loginscreen.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool? isNewUser;
  int score = 0;
  @override
  void initState() {
    super.initState();
    checkIfAlreadyLogin();
    // signOut();
  }

  Future<void> signOut() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      //Sign out from Firebase
      await _auth.signOut();

      await googleSignIn.signOut();
    } catch (e) {
      print("Error occurred during sign-out: $e");
    }
  }

  Future<void> checkIfAlreadyLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    await Future.delayed(Duration(seconds: 2));

    if (user != null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Navbar()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/images/comscart.gif'),
      logoWidth: 200,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      showLoader: true,
      loaderColor: Color.fromARGB(255, 13, 13, 13),
      loadingText: Text("Loading...", style: TextStyle(color: Colors.white)),
      durationInSeconds: 3,
    );
  }
}
