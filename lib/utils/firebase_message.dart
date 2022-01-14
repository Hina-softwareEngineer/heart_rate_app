import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future initialise() async {
    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await _fcm.getToken();
      print("FirebaseMessaging tokenn: $token");

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        print('getInitialMessage data: ${message} ${message?.data}');
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("On Message data : ${message.data} ${message}");
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("onResume data: ${message}, ${message.data}");
      });
      // TODO: handle the received notifications
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
