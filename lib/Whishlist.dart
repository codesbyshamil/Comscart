import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Whishlist extends StatefulWidget {
  const Whishlist({super.key});

  @override
  State<Whishlist> createState() => _WhishlistState();
}

class _WhishlistState extends State<Whishlist> {
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Whishlist')),
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
                      child: Text('Whishlist is Empty'),
                    );
                  }
                  Map<String, dynamic> cartData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  List<dynamic> products = cartData['Whishlist'] ?? [];
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      var product = products[index];
                      // int productId = product['id'];

                      return ListTile(
                        title: Text('${product['Name']}'),
                        subtitle: Text('\$${product['Price']}'),
                        leading: Image.network('${product['Thumbnail']}'),
                        // trailing: IconButton(
                        //   icon: Icon(Icons.delete),
                        //   onPressed: () {
                        //     // setState(() {
                        //     //   showSpinner = true;
                        //     // });
                        //     // removeFromCart(product);
                        //     // // deleteProduct(
                        //     // //     product['Id']); // Assuming 'Id' is the productId
                        //   },
                        // ),
                      );
                    },
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
