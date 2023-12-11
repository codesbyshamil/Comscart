import 'package:comsmart/Homepage.dart';
import 'package:comsmart/splashscreen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// class Connect extends StatelessWidget {
//   const Connect({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Lottie.asset('assets/lottie/Animation - 1699209413203.json'),
//           Text(''),
//         ],
//       ),
//     );
//   }
// }
class InternetCheckWidget extends StatefulWidget {
  @override
  _InternetCheckWidgetState createState() => _InternetCheckWidgetState();
}

class _InternetCheckWidgetState extends State<InternetCheckWidget> {
  String connectionStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    await Future.delayed(Duration(seconds: 2));

    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        // connectionStatus = 'Mobile data';
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SplashPage()));
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        // connectionStatus = 'WiFi';
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Homescreen(),
        ));
      });
    } else {
      setState(() {
        connectionStatus = 'Errorcode: NOEN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/lottie/Animation - 1699209413203.json'),
            ElevatedButton(
                onPressed: () {
                  checkConnectivity();
                },
                child: Text('Refresh')),
            Text(
              connectionStatus,
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
