import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comsmart/connectivity.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:comsmart/constrians.dart' as razorCredentials;
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Cartpage extends StatefulWidget {
  const Cartpage({Key? key}) : super(key: key);

  @override
  State<Cartpage> createState() => _CartpageState();
}

List<String> notifications = [];

class _CartpageState extends State<Cartpage> {
  var _razorpay = Razorpay();
  int totalPrice = 0;
  int Id = 123;
  String name = '';
  String userId = '';
  String connectionStatus = 'Unknown';
  bool showSpinner = false;
  List<dynamic> products = [];
  final String apiUrl = 'https://dummyjson.com/products';
  String ordernumber = '';

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    fetchTotalPrice();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   String orderId = generateOrderId(); // Custom method to generate order ID
    //   addNotificationToFirestore(user.uid, orderId);
    // }
  }

  Future<void> addNotificationToFirestore(String userId, String orderId) async {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd/MM/yyyy hh:mm:ss a').format(now);
    try {
      // Create a reference to the specific user document
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');
      final userDoc = usersCollection.doc(userId);
      final userDocSnap = await userDoc.get();
      if (!userDocSnap.exists) {
        await userDoc.set({
          'notifications': FieldValue.arrayUnion([
            {
              'title': 'Your order #$orderId has been placed successfully',
              'timestamp': formattedDateTime,
            }
          ])
        });
      } else {
        await userDoc.update({
          'notifications': FieldValue.arrayUnion([
            {
              'title': 'Your order #$orderId has been placed successfully',
              'timestamp': formattedDateTime,
            }
          ])
        });
      }

      print('Notification added to Firestore for user: $userId');
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment is successful');
    notifications.add('New notification message');
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<Map<String, dynamic>> cartProducts =
          await fetchCartProducts(user.uid);
      String orderId = generateOrderId(); // Custom method to generate order ID
      await addOrder(user.uid, orderId, cartProducts);
      clearCart(user.uid);
      addNotificationToFirestore(user.uid, orderId);
    }

    Fluttertoast.showToast(
      msg: "Your order has been placed successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  String generateOrderId() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    if (timestamp.length > 6) {
      timestamp = timestamp.substring(0, 6); // Take the first 6 digits
    } else if (timestamp.length < 6) {
      timestamp =
          timestamp.padRight(6, '0'); // Pad with zeros if less than 6 digits
    }

    String random =
        UniqueKey().toString().substring(2, 4); // Random 2 characters

    return '$random$timestamp';
  }

  Future<List<Map<String, dynamic>>> fetchCartProducts(String userId) async {
    List<Map<String, dynamic>> cartProducts = [];
    try {
      DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> cartData = snapshot.data() as Map<String, dynamic>;
        List<dynamic> products = cartData['Cart'] ?? [];

        cartProducts = products.map<Map<String, dynamic>>((product) {
          return {
            'Name': product['Name'],
            'Price': product['Price'],
            'Thumbnail': product['Thumbnail'],
            // Add other necessary fields if available
          };
        }).toList();
      }
    } catch (e) {
      print("Error fetching cart products: $e");
    }
    return cartProducts;
  }

  Future<void> clearCart(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'Cart': [],
        'TotalPrice': 0,
      });

      print('Cart cleared successfully');
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  Future<void> addOrder(String userId, String orderId,
      List<Map<String, dynamic>> products) async {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd/MM/yyyy hh:mm:ss a').format(now);
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');
      final userDoc = usersCollection.doc(userId);
      final userDocSnap = await userDoc.get();

      if (!userDocSnap.exists) {
        await userDoc.set({
          'Orders': [
            {
              'OrderId': orderId,
              'Datetime': formattedDateTime,
              'Products': products,
              'Total': totalPrice,
              'Order Status': 'Processing',
              // Add other order-related information if needed
            }
          ],
        });
      } else {
        await userDoc.update({
          'Orders': FieldValue.arrayUnion([
            {
              'OrderId': orderId,
              'Datetime': formattedDateTime,
              'Products': products,
              'Total': totalPrice,
              'Order Status': 'Processing',
              // Add other order-related information if needed
            }
          ]),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order Placed'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamed(context, '/Navbar');

      print('Order added with ID: $orderId');
    } catch (e) {
      print("Error adding order: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print('payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print('payment failed 1');
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

  void fetchTotalPrice() async {
    try {
      DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> cartData = snapshot.data() as Map<String, dynamic>;
        int fetchedTotalPrice = cartData['TotalPrice'] ?? 0.0;
        setState(() {
          totalPrice = fetchedTotalPrice;
        });
      }
    } catch (e) {
      print("Error fetching total price: $e");
    }
  }

  void removeFromCart(Map<String, dynamic> productToRemove) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> cartData =
            documentSnapshot.data() as Map<String, dynamic>;
        List<dynamic> products = List.from(cartData['Cart'] ?? []);

        // Find the index of the product with the same content as productToRemove
        int indexToRemove = products.indexWhere((product) =>
            product['Name'] == productToRemove['Name'] &&
            product['Price'] == productToRemove['Price'] &&
            product['Thumbnail'] == productToRemove['Thumbnail']);

        if (indexToRemove != -1) {
          int removedProductPrice =
              int.parse('${products[indexToRemove]['Price']}');
          products.removeAt(indexToRemove);

          setState(() {
            totalPrice -= removedProductPrice;
          });

          FirebaseFirestore.instance.collection('Users').doc(userId).update({
            'Cart': products,
            'TotalPrice': totalPrice,
          }).then((_) {
            print('Product removed from cart and total price updated!');
            setState(() {
              showSpinner = false;
            });
          }).catchError((error) {
            print('Failed to remove product: $error');
          });
        } else {}
      }
    });
  }

  void createOrder() async {
    String username = razorCredentials.keyId;
    String password = razorCredentials.keySecret;
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Map<String, dynamic> body = {
      "amount": '${totalPrice}00',
      "currency": "INR",
      "receipt": "rcptid_11"
    };
    var res = await http.post(
      Uri.https(
          "api.razorpay.com", "v1/orders"), //https://api.razorpay.com/v1/orders
      headers: <String, String>{
        "Content-Type": "application/json",
        'authorization': basicAuth,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      openGateway(jsonDecode(res.body)['id']);
    }
    print(res.body);
  }

  openGateway(String orderId) {
    var options = {
      'key': razorCredentials.keyId,
      'amount': '${totalPrice}00', //in the smallest currency sub-unit.
      'name': 'Comsmart',
      'order_id': orderId, // Generate order_id using Orders API
      'description': 'Fine T-Shirt',
      'timeout': 60 * 5, // in seconds // 5 minutes
      'prefill': {
        'contact': '9123456789',
        'email': 'ary@example.com',
      }
    };
    _razorpay.open(options);
  }

  verifySignature({
    String? signature,
    String? paymentId,
    String? orderId,
  }) async {
    Map<String, dynamic> body = {
      'razorpay_signature': signature,
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
    };

    var parts = [];
    body.forEach((key, value) {
      parts.add('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value)}');
    });
    var formData = parts.join('&');
    var res = await http.post(
      Uri.https(
        "10.0.2.2", // my ip address , localhost
        "razorpay_signature_verify.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // urlencoded
      },
      body: formData,
    );

    print(res.body);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.body),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(
                      child: Text('Cart is Empty'),
                    );
                  }
                  Map<String, dynamic> cartData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  List<dynamic> products = cartData['Cart'] ?? [];
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      var product = products[index];
                      // int productId = product['id'];
                      return ListTile(
                        title: Text('${product['Name']}'),
                        subtitle: Text('\$${product['Price']}'),
                        leading: Image.network('${product['Thumbnail']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              showSpinner = true;
                            });
                            removeFromCart(product);
                            // deleteProduct(
                            //     product['Id']); // Assuming 'Id' is the productId
                          },
                        ),
                      );
                    },
                  );
                },
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
                'Total Price: \n\$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    createOrder();
                  },
                  child: Text('Place Order')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }
}
