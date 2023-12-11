import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      fetchNotification(user.uid);
    }
  }

  void fetchNotification(String userId) {
    _notificationsStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots() as Stream<DocumentSnapshot<Map<String, dynamic>>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Center(
                  child: Text('No notifications available'),
                );
              }
              final documentData = snapshot.data!.data()!;
              final notifications = documentData.containsKey('notifications')
                  ? List<Map<String, dynamic>>.from(
                      documentData['notifications'])
                  : [];
              if (notifications.isEmpty) {
                return Center(
                  child: Text('No notifications available'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.black,
                    ),
                    title: Text('${notification['title'].toString()}'),
                    subtitle: Text(
                      '${notification['timestamp']}',
                    ),
                    // Customize ListTile as per your UI design
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
