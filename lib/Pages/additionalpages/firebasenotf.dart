// import 'package:coachyp/Pages/Notifications.dart';
// import 'package:coachyp/main.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter/material.dart';


// class NotificationScreen extends StatelessWidget {
//   static const routeName = '/notification';

//   @override
//   Widget build(BuildContext context) {
//     final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Notification")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("📨 Title: ${message.notification?.title ?? 'No Title'}"),
//             Text("📝 Body: ${message.notification?.body ?? 'No Body'}"),
//           ],
//         ),
//       ),
//     );
//   }
// }



// class FirebaseNotifications {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fcmToken = await _firebaseMessaging.getToken();
//     print('FCM Token: $fcmToken');

//     FirebaseMessaging.onMessage.listen((message) {
//        print('📩 Foreground message: ${message.notification?.title}');
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       navigatorKey.currentState!.pushNamed(
//         NotificationScreen.routeName,
//     arguments: message,
//   );
//       print('🚀 App opened from notification: ${message.data}');
//       // Navigate to screen
//     });
    
//   }
// }