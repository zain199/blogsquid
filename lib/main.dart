import 'package:blogsquid/pages/posts/load_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'prepare.dart';
import 'package:blogsquid/utils/globals.dart' as globals;

void main() {
  globals.appNavigator = GlobalKey<NavigatorState>();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    setupNotification() {
      //Remove this method to stop OneSignal Debugging
      //OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

      //OneSignal.shared.setAppId("YOUR_ONESIGNAL_APP_ID");
      OneSignal.shared.setAppId("39e4c6a5-6d6a-4af3-a68c-239d8cba1c7a");

      // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
      OneSignal.shared
          .promptUserForPushNotificationPermission()
          .then((accepted) {
        print("Accepted permission: $accepted");
      });

      OneSignal.shared.setNotificationWillShowInForegroundHandler(
          (OSNotificationReceivedEvent event) {
        // Will be called whenever a notification is received in foreground
        // Display Notification, pass null param for not displaying the notification
        event.complete(event.notification);
      });

      OneSignal.shared
          .setPermissionObserver((OSPermissionStateChanges changes) {
        // Will be called whenever the permission changes
        // (ie. user taps Allow on the permission prompt in iOS)
      });

      OneSignal.shared
          .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
        // Will be called whenever the subscription changes
        // (ie. user gets registered with OneSignal and gets a user ID)
      });

      OneSignal.shared.setEmailSubscriptionObserver(
          (OSEmailSubscriptionStateChanges emailChanges) {
        // Will be called whenever then user's email subscription changes
        // (ie. OneSignal.setEmail(email) is called and the user gets registered
      });
    }

    useEffect(() {
      setupNotification();
    }, const []);
    return MaterialApp(
      title: 'Blog Squid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Circular",
        primarySwatch: Colors.blue,
      ),
      navigatorKey: globals.appNavigator,
      home: Prepare(),
    );
  }
}
