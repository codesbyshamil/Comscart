import 'package:comsmart/auth/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  bool showSpinner = false;
  late User? _user;
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    _user = auth.currentUser;
    setState(() {}); // Update the UI after fetching user data
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String? photoUrl = user?.photoURL;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Profile',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: Row(children: [
                    SizedBox(
                      width: 110,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : AssetImage('assets/images/profile.jpeg')
                                as ImageProvider,
                      ),
                    ),
                    SizedBox(width: 5),
                    SizedBox(
                      width: 220,
                      // height: 100,
                      child: Text(
                        photoUrl != null ? '${_user!.displayName}' : 'User',
                        style: TextStyle(
                            fontSize: 25,
                            color: const Color.fromARGB(255, 5, 5, 5),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                  width: double.infinity,
                  height: 130,
                  color: Colors.transparent,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orders');
                  },
                  child: Row(
                    children: [
                      ImageIcon(AssetImage('assets/images/order.png'),
                          size: 60, color: Colors.black),
                      Text(
                        'My Orders',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 5, 5, 5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/Whishlist');
                  },
                  child: Row(
                    children: [
                      ImageIcon(AssetImage('assets/images/whishlist1.png'),
                          size: 50, color: Colors.black),
                      Text(
                        'Whishlists',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 5, 5, 5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _openChat();
                  },
                  child: Row(
                    children: [
                      // ImageIcon(AssetImage('assets/images/order.png'),
                      //     size: 60, color: Colors.black),
                      Icon(Icons.support_agent, size: 40, color: Colors.black),
                      Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 5, 5, 5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      // ImageIcon(AssetImage('assets/images/order.png'),
                      //     size: 60, color: Colors.black),
                      Icon(Icons.privacy_tip, size: 40, color: Colors.black),
                      Text(
                        'Privacy and policy',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 5, 5, 5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil<void>(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) => LoginPage()),
                      ModalRoute.withName('/'),
                    );
                    signOut();
                  },
                  child: Row(
                    children: [
                      // ImageIcon(AssetImage('assets/images/order.png'),
                      //     size: 60, color: Colors.black),
                      Icon(Icons.logout, size: 40, color: Colors.black),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 5, 5, 5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  _openChat() async {
    setState(() {
      showSpinner = true;
    });
    dynamic conversationObject = {
      'appId':
          '10bd87a78feacb15ac6996f2fe08ffed6', // The [APP_ID](https://dashboard.kommunicate.io/settings/install) obtained from kommunicate dashboard.
      'withPreChat': true
    };

    KommunicateFlutterPlugin.buildConversation(conversationObject)
        .then((clientConversationId) {
      print(
          "Conversation builder success : " + clientConversationId.toString());
    }).catchError((error) {
      print("Conversation builder error : " + error.toString());
    });
    setState(() {
      showSpinner = false;
    });
  }
}
