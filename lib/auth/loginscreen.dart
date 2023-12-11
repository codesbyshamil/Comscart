import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comsmart/Navbar.dart';
import 'package:comsmart/auth/resetpassword.dart';
import 'package:comsmart/auth/signup.dart';
import 'package:comsmart/connectivity.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:github_sign_in/github_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int score = 0;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  late SharedPreferences loginData;
  late bool newUser;
  String errorMessage = ''; // Added for error message
  Map<String, dynamic>? _userData;
  late String email;
  late String password;
  bool showSpinner = false;
  String welcome = "Facebook";
  final _auth = FirebaseAuth.instance;
  String errormsg = '';
  bool _isPasswordHidden = true;
  String connectionStatus = 'Unknown';
  @override
  void initState() {
    super.initState();
    // checkIfAlreadyLoggedIn();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectionStatus = 'No internet connection';
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => InternetCheckWidget(),
        ));
      });
    } else {}
  }

  // void checkIfAlreadyLoggedIn() async {
  //   loginData = await SharedPreferences.getInstance();
  //   newUser = (loginData.getBool('login') ?? true);

  //   if (!newUser) {
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => MyHomePage()));
  //   }
  // }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Lottie.asset('assets/lottie/animation_log0v1qi (1).json',
                          width: 230, height: 220, fit: BoxFit.cover),
                      SizedBox(height: 10),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 23, 22, 22),
                        ),
                      ),
                      Text(
                        errormsg,
                        style: TextStyle(
                          color: Color.fromARGB(255, 183, 29, 18),
                          fontSize: 15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.start,
                          onChanged: (value) {
                            email = value;
                            //Do something with the user input.
                          },
                          cursorColor: Color.fromARGB(255, 31, 30, 30),
                          controller: usernameController,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: passwordController,
                              keyboardType: TextInputType.text,
                              obscureText: _isPasswordHidden,
                              textAlign: TextAlign.start,
                              onChanged: (value) {
                                password = value;
                                //Do something with the user input.
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                                suffixIcon: IconButton(
                                  icon: _isPasswordHidden
                                      ? Icon(Icons.visibility)
                                      : Icon(Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 18),
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PasswordResetPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Reset Password?',
                                        style: TextStyle(color: Colors.blue),
                                      )),
                                )
                              ],
                            ),
                            Text(
                              errormsg,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 227, 79, 69)),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                    child: Container(
                                      width: 320,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Color.fromARGB(255, 5, 5, 5)),
                                      child: Center(
                                        child: Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 244, 244, 244),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        showSpinner = true;
                                      });
                                      try {
                                        final user = await _auth
                                            .signInWithEmailAndPassword(
                                                email: email,
                                                password: password);
                                        //ignore: msp
                                        // ignore: unnecessary_null_comparison
                                        if (user != null) {
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
                                          errormsg =
                                              'Username/Password is incorrect';
                                        });
                                      }
                                      setState(() {
                                        showSpinner = false;
                                      });
                                    }),
                                // SizedBox(height: 10),
                                // InkWell(
                                //   child: Container(
                                //     width: 320,
                                //     height: 40,
                                //     decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(15),
                                //         color: Color.fromARGB(255, 11, 11, 11)),
                                //     child: Center(
                                //       child: Text(
                                //         "Login with Mobile OTP",
                                //         style: TextStyle(
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.bold,
                                //           color: Color.fromARGB(
                                //               255, 236, 233, 233),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                //   onTap: () {
                                //     // Navigator.pushReplacement(
                                //     //   context,
                                //     //   MaterialPageRoute(
                                //     //     builder: (context) => OTPScreen(),
                                //     //   ),
                                //     // );
                                //   },
                                //   // child: Text(
                                //   //   "Login",
                                //   //   style: TextStyle(
                                //   //     color: Color.fromARGB(255, 7, 89, 231),
                                //   //   ),
                                //   // ),
                                // ),

                                // child: Text(
                                //   "Login",
                                //   style: TextStyle(
                                //     color: Color.fromARGB(255, 7, 89, 231),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '____Signup with____',
                        style: TextStyle(
                          color: Color.fromARGB(255, 16, 16, 16),
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255)),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      height: 40.0,
                                      width: 40.0,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/google.png'),
                                            fit: BoxFit.cover),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ))),
                            onTap: () async {
                              UserCredential? userCredential =
                                  await signInWithGoogle();
                              if (userCredential != true) {
                                // Successful sign-in
                                User? user = FirebaseAuth.instance.currentUser;
                                final userDoc = FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(user!.uid); // Get the user's document

                                final userDocSnap = await userDoc.get();

                                if (!userDocSnap.exists) {
                                  await userDoc.set({
                                    'User details': FieldValue.arrayUnion([
                                      {
                                        'Login by': 'Google',
                                      }
                                    ]),
                                    'Cart': [],
                                    'Whishlist': [],
                                    'Orders': [],
                                    'TotalPrice': 0,
                                  });
                                } else {
                                  print('user is already exists');
                                }
                                print(
                                    "User signed in: ${userCredential.user!.displayName}");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Navbar(),
                                  ),
                                );
                              } else {
                                // Sign-in failed
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text('Failed to sign in with Google'),
                                ));
                                print("Failed to sign in with Google");
                              }
                            },
                          ),
                          // SizedBox(width: 10),
                          // InkWell(
                          //   child: Container(
                          //       width: 50,
                          //       height: 50,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(60),
                          //           color:
                          //               const Color.fromARGB(255, 255, 255, 255)),
                          //       child: Center(
                          //           child: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceEvenly,
                          //         children: <Widget>[
                          //           Container(
                          //             height: 30.0,
                          //             width: 30.0,
                          //             decoration: BoxDecoration(
                          //               image: DecorationImage(
                          //                   image: AssetImage(
                          //                       'assets/images/apple.png'),
                          //                   fit: BoxFit.cover),
                          //               shape: BoxShape.circle,
                          //             ),
                          //           ),
                          //           // Text(
                          //           //   'Sign in with Google',
                          //           //   style: TextStyle(
                          //           //       fontSize: 16.0,
                          //           //       fontWeight: FontWeight.bold,
                          //           //       color: Color.fromARGB(255, 0, 0, 0)),
                          //           // ),
                          //         ],
                          //       ))),
                          //   onTap: () async {
                          //     // UserCredential? userCredential =
                          //     //     await signInWithGoogle();
                          //     // if (userCredential != true) {
                          //     //   // Successful sign-in
                          //     //   print(
                          //     //       "User signed in: ${userCredential.user!.displayName}");
                          //     // } else {
                          //     //   // Sign-in failed
                          //     //   print("Failed to sign in with Google");
                          //     // }
                          //   },
                          // ),
                          SizedBox(width: 10),
                          InkWell(
                            child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255)),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      height: 30.0,
                                      width: 30.0,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/git.png'),
                                            fit: BoxFit.cover),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    // Text(
                                    //   'Sign in with Google',
                                    //   style: TextStyle(
                                    //       fontSize: 16.0,
                                    //       fontWeight: FontWeight.bold,
                                    //       color: Color.fromARGB(255, 0, 0, 0)),
                                    // ),
                                  ],
                                ))),
                            onTap: () async {
                              // UserCredential? userCredential =
                              //     await signInWithGitHub();
                              // if (userCredential != true) {
                              //   // Successful sign-in
                              //   print(
                              //       "User signed in: ${userCredential.user!.displayName}");
                              // } else {
                              //   // Sign-in failed
                              //   print("Failed to sign in with Google");
                              // }
                            },
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255)),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      height: 45.0,
                                      width: 45.0,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/fb.png'),
                                            fit: BoxFit.cover),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ))),
                            onTap: () async {
                              // signInWithFacebook();
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Dont have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegistrationScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Signup',
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in with the obtained credential using Firebase Authentication
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Return the UserCredential
      return userCredential;
    } catch (e) {
      // Handle any potential error here
      print('Error signing in with Google: $e');
      rethrow; // Re-throw the error for the caller to handle
    }
  }

  // Future<UserCredential> signInWithGitHub() async {
  //   // Create a GitHubSignIn instance
  //   final GitHubSignIn gitHubSignIn = GitHubSignIn(
  //       clientId: 'ede3e911adc22407f26a',
  //       clientSecret: 'e43b47a6556d632a66f78b5d7474ae70e57652cb',
  //       redirectUrl: 'https://my-project.firebaseapp.com/__/auth/handler');

  //   // Trigger the sign-in flow
  //   final result = await gitHubSignIn.signIn(context);

  //   // Create a credential from the access token
  //   final githubAuthCredential =
  //       GithubAuthProvider.credential(result.token as String);

  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance
  //       .signInWithCredential(githubAuthCredential);
  // }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result =
        await FacebookAuth.instance.login(permissions: ['email']);

    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();

      _userData = userData;
    } else {
      print(result.message);
    }

    setState(() {
      welcome = _userData?['email'];
    });

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);

    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
}
