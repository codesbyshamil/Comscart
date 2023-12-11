import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comsmart/productpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final String thumbnail;
  final List images;
  final int price;
  final String description;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.thumbnail,
    required this.images,
    required this.price,
    required this.description,
    required this.rating,
  });
}

class CategoryPage extends StatefulWidget {
  final category;

  CategoryPage({required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Product> products = [];
  List<String> wishlistIds = [];
  Future<void> checkWishlist(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDocSnap = await userDoc.get();

    if (userDocSnap.exists) {
      List<dynamic> userWishlist = userDocSnap['Whishlist'];
      setState(() {
        wishlistIds =
            userWishlist.map((item) => item['Id'].toString()).toList();
      });
    }
  }

  Future<void> addToWishlist(
      String userId, int index, BuildContext context, bool isLiked) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDocSnap = await userDoc.get();

    try {
      if (!userDocSnap.exists) {
        await userDoc.set({
          'Whishlist': [],
        });
      } else {
        if (index >= 0 && index < products.length) {
          if (isLiked) {
            await userDoc.update({
              'Whishlist': FieldValue.arrayUnion([
                {
                  'Price': '${products[index].price}',
                  'Name': '${products[index].name}',
                  'Thumbnail': '${products[index].thumbnail}',
                  'Id': '${products[index].id}',
                }
              ]),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed from Wishlist'),
                duration: Duration(seconds: 2),
              ),
            );
            setState(() {
              wishlistIds.remove(products[index].id.toString());
            });
          } else {
            await userDoc.update({
              'Whishlist': FieldValue.arrayUnion([
                {
                  'Price': '${products[index].price}',
                  'Name': '${products[index].name}',
                  'Thumbnail': '${products[index].thumbnail}',
                  'Id': '${products[index].id}',
                }
              ]),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added to Wishlist'),
                duration: Duration(seconds: 2),
              ),
            );
            setState(() {
              wishlistIds.add(products[index].id.toString());
            });
          }
          return; // Exit the function after successful update
        } else {
          print('Invalid index');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update Wishlist'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update Wishlist'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      checkWishlist(user.uid);
    }
  }

  Future<void> fetchProducts() async {
    final url = 'https://dummyjson.com/products';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic>? productsData = jsonData['products'];

        if (productsData != null && productsData.isNotEmpty) {
          List<Product> categoryProducts = [];

          for (var product in productsData) {
            if (product.containsKey('id') &&
                product['category'] == widget.category.title) {
              Product newProduct = Product(
                id: product['id'] ?? 0, // Use 'id' as the productId
                name: product['title'] ?? 'No Title',
                category: product['category'] ?? 'No Category',
                thumbnail: product['thumbnail'] ?? '',
                images: product['images'] ?? [],
                price: product['price'] ?? 0,
                description: product['description'] ?? '',
                rating: product['rating'] ?? 5.00,
              );
              categoryProducts.add(newProduct);
            }
          }

          setState(() {
            products = categoryProducts;
          });
        } else {
          print('No products found for this category');
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  void navigateToProductPage(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(product: product),
      ),
    );
  }

  int productIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: products.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 9 / 11,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  bool isInWishlist =
                      wishlistIds.contains(products[index].id.toString());
                  return GestureDetector(
                    onTap: () {
                      navigateToProductPage(products[index]);
                    },
                    child: Container(
                      height: 200,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(255, 239, 236, 236),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Image.network(
                              products[index].thumbnail,
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: 180,
                              child: Center(
                                child: Text(
                                  products[index].name,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 62, 61, 61),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: Center(
                                child: Text(
                                  '\$${products[index].price.toString()}',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 62, 61, 61),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: Center(
                                child: LikeButton(
                                  size: 25,
                                  isLiked: isInWishlist,
                                  onTap: (isLiked) async {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await addToWishlist(user.uid, index,
                                          context, isInWishlist);
                                    }
                                    return !isInWishlist;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
