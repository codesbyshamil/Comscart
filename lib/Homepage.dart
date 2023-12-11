import 'dart:convert';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:comsmart/Categorypage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:comsmart/constrians.dart' as k;
import 'package:permission_handler/permission_handler.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class Category {
  final int id;
  final String title;
  final String thumbnail;

  Category({required this.id, required this.title, required this.thumbnail});
}

class _HomescreenState extends State<Homescreen> {
  bool showSpinner = false;
  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchSmartphoneProducts();
    fetchProductsByCategory('smartphones');
    fetchProductsByCategory('laptops');
    fetchProductsByCategory('fragrances');
    fetchProductsByCategory('skincare');
    // getFCMToken();
    _getStoragePermission();
    _getnotificationPermission();
    initializeFirebaseMessaging();
  }

  List<Category> categories = [];
  List<dynamic> products = [];
  List<dynamic> smartphoneProductsList = [];
  List<dynamic> laptopProductsList = [];
  List<dynamic> fragrancesProductsList = [];
  List<dynamic> skincareProductsList = [];

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print('permission granted');
    }
  }

  Future _getnotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void initializeFirebaseMessaging() {
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
      // Send this token to your server to associate the device with the user
    });

    FirebaseMessaging.instance.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming messages when the app is in the foreground
      print(
          "Received a message in the foreground: ${message.notification?.body}");
      // Handle navigation based on notification data
      handleNotificationNavigation(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification when the app is opened from a terminated state
      print("Opened app from terminated state: ${message.notification?.body}");
      // Handle navigation based on notification data
      handleNotificationNavigation(message);
    });
  }

  void handleNotificationNavigation(RemoteMessage message) {
    // Extract necessary data from the notification payload
    // For example, if your notification contains a 'category' field
    String? category = message.data['category'];

    if (category != null) {
      // Navigate to the corresponding category page based on the received category
      switch (category) {
        case 'smartphones':
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryPage(category: 'smartphones')),
          );
          break;
        case 'laptops':
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryPage(category: 'laptops')),
          );
          break;
        case 'fragrances':
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryPage(category: 'fragrances')),
          );
          break;
        case 'skincare':
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryPage(category: 'skincare')),
          );
          break;
        default:
          break;
      }
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    final url = 'https://dummyjson.com/products?category=$category';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic>? productsData = jsonData['products'];

        List<Product> categoryProducts = [];

        if (productsData != null && productsData.isNotEmpty) {
          for (var product in productsData) {
            if (product['category'] == category) {
              Product newProduct = Product(
                id: product['id'],
                name: product['title'] ?? 'No Title',
                category: product['category'] ?? 'No Category',
                thumbnail: product['thumbnail'],
                images: product['images'],
                price: product['price'],
                description: product['description'],
                rating: product['rating'] ?? 5.00,
                // Add other necessary attributes
              );
              categoryProducts.add(newProduct);
            }
          }
        } else {
          print('No products found for $category category');
        }

        setState(() {
          if (category == 'smartphones') {
            smartphoneProductsList = categoryProducts;
          } else if (category == 'laptops') {
            laptopProductsList = categoryProducts;
          } else if (category == 'fragrances') {
            fragrancesProductsList = categoryProducts;
          } else if (category == 'skincare') {
            fragrancesProductsList = categoryProducts;
          }
        });
      } else {
        print(
            'Failed to fetch products for $category category. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  Future<void> fetchSmartphoneProducts() async {
    final url = 'https://dummyjson.com/products';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic>? productsData = jsonData['products'];

        if (productsData != null && productsData.isNotEmpty) {
          List<Product> categoryProducts = [];

          for (var product in productsData) {
            if (product['category'] == 'smartphones') {
              Product newProduct = Product(
                id: product['id'] ?? 0,
                name: product['title'] ?? 'No Title',
                category: product['category'] ?? 'No Category',
                thumbnail: product['thumbnail'],
                images: product['images'],
                price: product['price'],
                description: product['description'],
                rating: product['rating'] ?? 5.00,
                // Add other necessary attributes
              );
              categoryProducts.add(newProduct);
            }
          }

          setState(() {
            products = categoryProducts;
          });
        } else {
          print('No products found for smartphones category');
          // Handle case where no products are available for smartphones category
          setState(() {
            products = []; // Empty the products list
          });
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
        // Handle other status codes if needed
      }
    } catch (error) {
      print('Error fetching products: $error');
      // Handle fetch error, e.g., display an error message to the user
    }
  }

  Future<void> fetchCategories() async {
    setState(() {
      showSpinner = true;
    });
    // Replace with your API endpoint
    try {
      final response = await http.get(Uri.parse(k.url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic>? products = jsonData['products'];
        if (products != null && products.isNotEmpty) {
          Set<String> uniqueCategories = Set<String>();
          for (var product in products) {
            uniqueCategories.add(product['category']);
          }
          List<Category> tempCategories = [];
          int id = 1;
          for (var categoryTitle in uniqueCategories) {
            Category newCategory = Category(
              id: id,
              title: categoryTitle,
              thumbnail:
                  '', // You might want to add category-specific images later
            );
            tempCategories.add(newCategory);
            id++;
          }
          setState(() {
            categories = tempCategories;
            showSpinner = false;
          });
        } else {
          print('No categories found');
        }
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  void navigateToCategoryPage(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(category: category),
      ),
    );
  }

  void gotosearchpage() {
    Navigator.pushNamed(context, '/Searchpage');
  }

  final List<String> logoList = [
    'assets/images/phone1.png',
    'assets/images/laptop.png',
    'assets/images/fragrances.png',
    'assets/images/skincare2.png',
    'assets/images/groceries.png',
    'assets/images/home-decoration.png',
  ];

  final List<String> imageList = [
    'assets/images/s1.png',
    'assets/images/s2.png',
    'assets/images/s3.png',
    'assets/images/s4.png',
    'assets/images/s5.png',
    // 'assets/images/s1.jpeg',
    // 'assets/images/s1.jpeg',
    // 'assets/images/s2.jpeg',
    // 'assets/images/s1.jpeg',
    // Add more asset image paths here
  ];
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/comscartblack.png',
                                width: 200,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 70),
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/Notification');
                                    },
                                    icon: Icon(
                                      Icons.notifications,
                                      size: 28,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/Searchpage');
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                                width: 330,
                                height: 50,
                                child: TextField(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/Searchpage');
                                  },
                                  enabled: false,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                    hintText: "Search Products..",
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color.fromARGB(216, 139, 137, 137),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 242, 238, 238),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 2000),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    viewportFraction: 1.0,
                  ),
                  items: imageList.map((String assetName) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
                          child: Image.asset(
                            assetName,
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Row(
                    children: [
                      Text('Shop By Category',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Display three items in each row
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          navigateToCategoryPage(categories[index]);
                        },
                        child: Container(
                          height: 110,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(255, 238, 235, 235),
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(logoList[index],
                                    width: 70, fit: BoxFit.cover),
                                SizedBox(
                                  width: 110,
                                  child: Center(
                                    child: Text(
                                      categories[index].title,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 62, 61, 61),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Row(
                    children: [
                      Text('Smartphones',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150, // Adjust the height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: (smartphoneProductsList.length ~/ 2),
                      itemBuilder: (context, rowIndex) {
                        return Row(
                          children: List.generate(
                            3,
                            (index) {
                              final itemIndex = (rowIndex * 3) + index;
                              if (itemIndex < smartphoneProductsList.length) {
                                return GestureDetector(
                                  onTap: () {
                                    navigateToCategoryPage(
                                        categories[itemIndex]);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8.0),
                                        height: 110,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color.fromARGB(
                                              255, 238, 235, 235),
                                        ),
                                        child: Image.network(
                                            smartphoneProductsList[itemIndex]
                                                .thumbnail,
                                            width: 70,
                                            fit: BoxFit.cover),
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Center(
                                          child: Text(
                                            '\$${smartphoneProductsList[itemIndex].price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 62, 61, 61),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return SizedBox(
                                    width:
                                        100); // Placeholder to maintain spacing
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Row(
                    children: [
                      Text('Laptops',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150, // Adjust the height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: (laptopProductsList.length ~/ 2),
                      itemBuilder: (context, rowIndex) {
                        return Row(
                          children: List.generate(
                            3,
                            (index) {
                              final itemIndex = (rowIndex * 3) + index;
                              if (itemIndex < laptopProductsList.length) {
                                return GestureDetector(
                                  onTap: () {
                                    navigateToCategoryPage(
                                        categories[itemIndex]);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8.0),
                                        height: 110,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color.fromARGB(
                                              255, 238, 235, 235),
                                        ),
                                        child: Image.network(
                                            laptopProductsList[itemIndex]
                                                .thumbnail,
                                            width: 70,
                                            fit: BoxFit.cover),
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Center(
                                          child: Text(
                                            '\$${laptopProductsList[itemIndex].price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 62, 61, 61),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return SizedBox(
                                    width:
                                        100); // Placeholder to maintain spacing
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Row(
                    children: [
                      Text('Fragrances',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150, // Adjust the height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: ((fragrancesProductsList.length + 2) ~/ 3),
                      itemBuilder: (context, rowIndex) {
                        return Row(
                          children: List.generate(
                            3,
                            (index) {
                              final itemIndex = (rowIndex * 3) + index;
                              if (itemIndex < fragrancesProductsList.length) {
                                return GestureDetector(
                                  onTap: () {
                                    navigateToCategoryPage(
                                        categories[itemIndex]);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8.0),
                                        height: 110,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color.fromARGB(
                                              255, 238, 235, 235),
                                        ),
                                        child: Image.network(
                                            fragrancesProductsList[itemIndex]
                                                .thumbnail,
                                            width: 70,
                                            fit: BoxFit.cover),
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Center(
                                          child: Text(
                                            '\$${fragrancesProductsList[itemIndex].price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 62, 61, 61),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return SizedBox(
                                  width:
                                      fragrancesProductsList.isEmpty ? 0 : 100,
                                ); // Placeholder to maintain spacing
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
