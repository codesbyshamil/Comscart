import 'package:comsmart/Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comsmart/Cartpage.dart';
import 'package:comsmart/Homepage.dart';
import 'package:comsmart/profilepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  var _currentindex = 0;

  final List<Widget> _screens = [
    Homescreen(),
    Cartpage(),
    Profilepage(),
  ];

  @override
  Widget build(BuildContext context) {
    // var cartNotifier = Provider.of<CartCountNotifier>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color.fromARGB(255, 203, 205, 200),
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Consumer<CartCountNotifier>(
            builder: (context, notifier, _) => Stack(
              children: [
                Icon(Icons.shopping_cart, size: 30),
                notifier.productCountInCart > 0
                    ? Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            notifier.productCountInCart.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          Icon(Icons.person, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentindex = index;
          });
        },
      ),
      body: _screens[_currentindex],
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProductCount(context);
  }

  void fetchProductCount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          List<dynamic> cart = snapshot['Cart'];
          Provider.of<CartCountNotifier>(context, listen: false)
              .updateProductCount(cart.length);
        }
      });
    }
  }
}
