import 'package:comsmart/Cartpage.dart';
import 'package:comsmart/Categorypage.dart';
import 'package:comsmart/Homepage.dart';
import 'package:comsmart/Navbar.dart';
import 'package:comsmart/Provider.dart';
import 'package:comsmart/Searchpage.dart';
import 'package:comsmart/Whishlist.dart';
import 'package:comsmart/firebase_options.dart';
import 'package:comsmart/homescreen.dart';
import 'package:comsmart/notification.dart';
import 'package:comsmart/orderpage.dart';
import 'package:comsmart/profilepage.dart';
// import 'package:comsmart/provider.dart';
// import 'package:comsmart/homescreen.dart';
// import 'package:comsmart/auth/loginscreen.dart';
import 'package:comsmart/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartCountNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashPage(),
        routes: {
          '/home': (context) => Homescreen(),
          '/cart': (context) => Cartpage(),
          '/homescreen': (context) => MyHomePage(),
          '/orders': (context) => Orders(),
          '/categories': (context) => CategoryPage(category: ''),
          '/Searchpage': (context) => Searchpage(),
          '/ProfilePage': (context) => Profilepage(),
          '/Navbar': (context) => Navbar(),
          '/Whishlist': (context) => Whishlist(),
          '/Notification': (context) => NotificationPage(),
        },
      ),
    );
  }
}
