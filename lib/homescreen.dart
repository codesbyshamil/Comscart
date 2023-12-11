import 'dart:convert';
import 'package:comsmart/auth/loginscreen.dart';
import 'package:comsmart/connectivity.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

  List<dynamic> filteredProducts = [];
class _MyHomePageState extends State<MyHomePage> {
  final String apiUrl = 'https://dummyjson.com/products';
  List<dynamic> products = [];
  String connectionStatus = 'Unknown';
  bool showSpinner = false;
  bool isliked = false;

  Future<void> fetchProducts() async {
    showSpinner = true;
    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          var parsedResponse = json.decode(response.body);
          products = parsedResponse['products'];
          filteredProducts = List.from(products);
          showSpinner = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
    }
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

  Future<void> checkProductisliked(String userId) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      final userDocSnap = await userDoc.get();

      if (userDocSnap.exists) {
        List<dynamic> cart = userDocSnap['Whishlist'];

        // Replace this condition with your own logic to check if the product is in the cart
        bool productliked = cart.any((item) =>
            item['Id'] == '${products[index]['id']}' &&
            item['Name'] == '${products[index]['title']}');
        setState(() {
          isliked = productliked;
        });
      }
    } catch (e) {
      print('Error checking product in cart: $e');
    }
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

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    fetchProducts();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Addlist(user.uid);
    }
  }


  String errormsg = '';
  Future<void> Addlist(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDocSnap = await userDoc.get();
    if (!userDocSnap.exists) {
      await userDoc.set({
        'Cart': [],
        'Orders': [],
        'Whishlist': [],
        'TotalPrice': 0,
      });
    }
  }

  void filterProducts(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        return product['title'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void navigateToProductpage(int productId) {
    Map<String, dynamic>? product = products.firstWhere(
      (element) => element['id'] == productId,
    );
    if (product != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Productpage(filteredProducts: product),
        ),
      );
    } else {
      print('Product not found!');
    }
  }

  void stopspinner() {
    showSpinner = false;
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    // if (isLiked) {
    //   User? user = FirebaseAuth.instance.currentUser;
    //   if (user != null) {
    //     Addtowhishlist(user.uid);
    //   }
    // }
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Addtowhishlist(user.uid);
    }
    return !isLiked;
  }

  int index = 0;
  Future<void> Addtowhishlist(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDocSnap = await userDoc.get();
    if (!userDocSnap.exists) {
      await userDoc.set({
        'Whishlist': [],
      });
    } else {
      await userDoc.update({
        'Whishlist': FieldValue.arrayUnion([
          {
            'Price': '${products[index]['price']}',
            'Name': '${products[index]['title']}',
            'Thumbnail': '${products[index]['thumbnail']}',
            'Id': '${products[index]['id']}',
            'test': 'test3',
            // 'Thumbnial': '${product['thumbnail']}',
          }
        ]),
      });
      print('add');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to Whishlist'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Colors.blue.shade400,
          title: Image.asset('assets/images/logononbg1.png', scale: 2.0),
          // Text('Products',
          //     style: TextStyle(color: const Color.fromARGB(255, 241, 240, 240))),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => LoginPage()),
                    ModalRoute.withName('/'),
                  );
                  signOut();
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/orders');
                },
                icon: Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                )),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 60,
              color: Colors.blue.shade400,
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                width: 330,
                height: 50,
                child: TextField(
                  onChanged: filterProducts,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    hintText: "Search Products..",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(216, 139, 137, 137),
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.tune,
                            color: Color.fromARGB(216, 139, 137, 137))),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  // ignore: unnecessary_null_comparison
                  return ListTile(
                    title: Text(filteredProducts[index]['title']),
                    subtitle:
                        Text('Price: \$${filteredProducts[index]['price']}'),
                    leading:
                        Image.network(filteredProducts[index]['thumbnail']),
                    onTap: () {
                      navigateToProductpage(filteredProducts[index]['id']);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LikeButton(
                          size: 25,
                          onTap: onLikeButtonTapped,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Productpage extends StatefulWidget {
  final Map<String, dynamic> filteredProducts;

  Productpage({Key? key, required this.filteredProducts}) : super(key: key);

  @override
  State<Productpage> createState() => _ProductpageState();
}

class _ProductpageState extends State<Productpage> {
  // bool isInCart = false;
  String connectionStatus = 'Unknown';
  bool showSpinner = false;
  // bool _isInCart = false;
  bool isInCart = false;
  @override
  void initState() {
    super.initState();
    checkConnectivity();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      checkProductInCart(user.uid);
    }
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

  Future<void> Addtocart(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDocSnap = await userDoc.get();
    setState(() {
      showSpinner = true;
    });
    if (!userDocSnap.exists) {
      await userDoc.set({
        'Cart': [],
        'TotalPrice': 0,
      });
    } else {
      int totalPrice =
          userDocSnap['TotalPrice'] + widget.filteredProducts['price'];
      await userDoc.update({
        'Cart': FieldValue.arrayUnion([
          {
            'Price': '${widget.filteredProducts['price']}',
            'Name': '${widget.filteredProducts['title']}',
            'Thumbnail': '${widget.filteredProducts['thumbnail']}',
            'Id': '${widget.filteredProducts['id']}',
            // 'Thumbnial': '${product['thumbnail']}',
          }
        ]),
        'TotalPrice': totalPrice,
      });
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      checkProductInCart(user.uid);
    }
    setState(() {
      // isInCart = true;
      showSpinner = false;
    });
    // Show a snackbar or message indicating successful addition to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to Cart'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> checkProductInCart(String userId) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      final userDocSnap = await userDoc.get();

      if (userDocSnap.exists) {
        List<dynamic> cart = userDocSnap['Cart'];

        // Replace this condition with your own logic to check if the product is in the cart
        bool productFoundInCart = cart.any((item) =>
            item['Id'] == '${widget.filteredProducts['id']}' &&
            item['Name'] == '${widget.filteredProducts['title']}');

        setState(() {
          isInCart = productFoundInCart;
        });
      }
    } catch (e) {
      print('Error checking product in cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> images = widget.filteredProducts['images'] ?? [];
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.filteredProducts['title']),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 250.0,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlay: false,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  enableInfiniteScroll: true,
                  viewportFraction: 1.0,
                  autoPlayCurve: Curves.linear,
                ),
                items: images.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                        ),
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Text(
                      '${widget.filteredProducts['title']}',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Text(
                      '\$${widget.filteredProducts['price']}',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 350,
                      child: Text(
                        ' ${widget.filteredProducts['description']}',
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            color: Color.fromARGB(255, 255, 255, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Price: \n\$${widget.filteredProducts['price']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isInCart
                    ? ElevatedButton(
                        onPressed: () {
                          // Go to Cart logic here
                          Navigator.pushNamed(context, '/cart');
                        },
                        child: Text('Go to Cart'),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          User? user = FirebaseAuth.instance.currentUser;
                          // Add to Cart logic here
                          if (user != null) {
                            Addtocart(
                              user.uid,
                            );
                          }
                        },
                        child: Text('Add to Cart'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
