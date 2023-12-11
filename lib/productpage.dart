import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comsmart/connectivity.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductPage extends StatefulWidget {
  final product;

  ProductPage({required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool showSpinner = false;
  // bool isInCart = false;
  String connectionStatus = 'Unknown';
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
      int totalPrice = userDocSnap['TotalPrice'] + widget.product.price;
      await userDoc.update({
        'Cart': FieldValue.arrayUnion([
          {
            'Price': '${widget.product.price}',
            'Name': '${widget.product.name}',
            'Thumbnail': '${widget.product.thumbnail}',
            'Id': '${widget.product.id}',
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
            item['Id'] == '${widget.product.id}' &&
            item['Name'] == '${widget.product.name}');

        setState(() {
          isInCart = productFoundInCart;
        });
      }
    } catch (e) {
      print('Error checking product in cart: $e');
    }
  }

  final double fixedRating = 2;
  @override
  Widget build(BuildContext context) {
    List<dynamic> images = widget.product.images;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product.name),
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
                          fit: BoxFit.fill,
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
                    SizedBox(
                      width: 350,
                      child: Text(
                        '${widget.product.name}',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Text(
                      '\$${widget.product.price}',
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
                        ' ${widget.product.description}',
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    RatingBar.builder(
                      initialRating: widget.product.rating,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 30,
                      ignoreGestures: true,
                      allowHalfRating: true,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      // ratingWidget: RatingWidget(
                      //   full: Icon(Icons.star, color: Colors.amber),
                      //   half: Icon(Icons.star_half, color: Colors.amber),
                      //   empty: Icon(Icons.star_border, color: Colors.amber),
                      // ),
                      onRatingUpdate: (rating) {
                        // Disable update when user tries to interact
                      },
                    ),
                    Text('${widget.product.rating}')
                  ],
                ),
              ),
            ],
          ),
        ),
        
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            color: Color.fromARGB(255, 255, 255, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Price: \n\$${widget.product.price}',
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
