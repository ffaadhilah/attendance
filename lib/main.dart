import 'package:attendance/src/screens/absence/absence.dart';
import 'package:attendance/src/screens/history/history_screen.dart';
import 'package:attendance/src/screens/notification/notificationtimeline_screen.dart';
import 'package:attendance/src/screens/notification/notification_screen.dart';
import 'package:attendance/src/screens/splash/splash_screen.dart';
import 'package:attendance/src/screens/task/report.dart';
import 'package:attendance/src/screens/setting/edit_screen.dart';
import 'package:attendance/src/screens/setting/map_screen.dart';
import 'package:attendance/src/screens/setting/setting_screen.dart';
import 'package:attendance/src/screens/task/task_create.dart';
import 'package:attendance/src/screens/warning/warning.dart';
import 'package:attendance/src/screens/warning/warning_version.dart';
import 'package:attendance/src/utils/const/constant.dart';
import 'src/screens/task/task_list.dart';
import 'package:flutter/material.dart';
import './src/screens/login/login_screen.dart';
import 'src/screens/homepage/homepage.dart';
import 'src/screens/homepage/homepage_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("this is the message notifification title: ${message.notification.title}");
//   print("this is the message data title: ${message.data['title']}");
  // print("this is the message type: ${message.messageType}");
  // print("this is the sender id: ${message.senderId}");
  // print("Handling a background message: ${message.messageId}");
// }

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: kAppBarColor, // status bar color
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MSG Attendance',
      routes: {
        '/': (context) => SplashScreen(),
        '/LoginScreen': (context) => LoginScreen(),
        '/HomePage': (context) => HomePage(),
        '/HomeView': (context) => HomeView(),
        '/WarningVersion': (context) => WarningVersion(),
        '/Warning': (context) => WarningPage(),
        '/AbsenceScreen': (context) => AbsenceScreen(),
        '/CreateTask': (context) => CreateTask(),
        '/ListTask': (context) => ListTaskScreen(),
        '/ReportDetailScreen': (context) => ReportDetailScreen(),
        '/SettingScreen': (context) => SettingScreen(),
        '/EditSettingScreen': (context) => EditSettingScreen(),
        '/HistoryScreen': (context) => HistoryScreen(),
        '/MapsScreen': (context) => MapsScreen(),
        '/NotificationTimelineScreen': (context) => NotificationTimelineScreen(),
        '/NotificationScreen': (context) => NotificationScreen(),
      },
      theme: ThemeData(
        buttonColor: Colors.orange,
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange,
        bottomAppBarColor: Colors.orange[100],
        appBarTheme: AppBarTheme(
          color: Colors.orange,
        ),
      ),
    );
  }
}

