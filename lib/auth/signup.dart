import 'package:comsmart/Navbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: Color.fromARGB(255, 66, 66, 66)),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide:
        BorderSide(color: Color.fromARGB(255, 158, 160, 161), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String email;
  late String password;
  late String username;
  late String Phonenumber;
  bool showSpinner = false;
  String errormsg = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Lottie.asset('assets/lottie/animation_loh2nws6.json'),
                    Center(
                      child: Text(
                        "Register Account",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        username = value;
                        // Do something with the user input.
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your Full Name',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      obscureText: true,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        Phonenumber = value;
                        // Do something with the user input.
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your Phone Number',
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        email = value;
                        // Do something with the user input.
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your Email',
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                      obscureText: true,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        password = value;
                        // Do something with the user input.
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter Password For account',
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(errormsg),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showSpinner =
                              true; // Set a loading spinner while processing
                        });
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          // ignore: unnecessary_null_comparison
                          if (newUser != null) {
                            await _auth.currentUser!
                                .updateDisplayName(username);
                            await _auth.currentUser!.sendEmailVerification();
                            final userDoc = FirebaseFirestore.instance
                                .collection('Users')
                                .doc(newUser
                                    .user!.uid); // Get the user's document

                            final userDocSnap = await userDoc.get();

                            if (!userDocSnap.exists) {
                              await userDoc.set({
                                'User details': FieldValue.arrayUnion([
                                  {
                                    'Name': username,
                                    'Email': email,
                                    'PhoneNumber': '+91${Phonenumber}',
                                    'Login by': 'signup',
                                  }
                                ]),
                                'Cart': [],
                                'Whishlist': [],
                                'Orders': [],
                                'TotalPrice': 0,
                              });
                            } else {
                              errormsg = 'user is already exists';
                            }
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Navbar(),
                              ),
                            );
                          }
                        } catch (e) {
                          print(e);
                          setState(() {
                            errormsg = '$e';
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('$e'),
                            ));
                          });
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      },
                      child: Text('Register'), // Button text
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class Verifyotp extends StatelessWidget {
//   Verifyotp({super.key});
//   final _auth = FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//           child: ElevatedButton(
//               onPressed: () {
//                 _auth.authStateChanges().listen((User? user) {
//                   if (user != null && user.emailVerified) {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Homepage(),
//                       ),
//                     );
//                   }
//                 });
//               },
//               child: Text('Email Verified'))),
//     );
//   }
// }
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final displayName = user!.displayName ?? 'User';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home Screen'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Welcome, $displayName!',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacementNamed(context, 'login_screen');
//               },
//               child: Text('Log Out'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
