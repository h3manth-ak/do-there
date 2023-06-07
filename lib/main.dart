import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:location_based_reminder/Screens/Notify/notify_data.dart';
import 'package:location_based_reminder/Screens/Notify/notify_page.dart';
// import 'package:location_based_reminder/Screens/Reminder/alarm.dart';
import 'package:location_based_reminder/Screens/Reminder/reminder.dart';
import 'package:location_based_reminder/Screens/home/screen_home.dart';
import 'package:location_based_reminder/db/models/db_models.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math' show cos, sqrt, sin, pi, atan2;

import 'Screens/Reminder/input_data.dart';
import 'background.dart';
// import 'package:location_based_reminder/home/screen_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.initFlutter();
  if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  if (!Hive.isAdapterRegistered(NotifyModelAdapter().typeId)) {
    Hive.registerAdapter(NotifyModelAdapter());
  }
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  bool serviceEnabled;
  LocationPermission permission;

  
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  await AndroidAlarmManager.initialize();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  // runApp(const MyApp());
  
  await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    0,
    backgroundTaskTest,
    // reminderbackgroundTask,
    exact: true,
    wakeup: true,
  );
  // await AndroidAlarmManager.periodic(
  //   const Duration(minutes: 1),
  //   0,
  //   backgroundTask,
  //   // reminderbackgroundTask,
  //   exact: true,
  //   wakeup: true,
  // );
  // await AndroidAlarmManager.periodic(
  //   const Duration(minutes: 1),
  //   0,
  //   reminderbackgroundTask,
  //   exact: true,
  //   wakeup: true,
  // );
  

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState()  {
    super.initState();
    // You can call backgroundTask here if needed when the app is launched.
    backgroundTask();
    reminderbackgroundTask();
  }
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true, //<-- SEE HERE
          fillColor: Colors.grey, //<-- SEE HERE
        ),
      ),

      home: const HomeScreen(),
      // home:  AlarmScreen(),
      routes: {
        'notify_home': (ctx) {
          return const Notify();
        },
        'reminder_home': (ctx) {
          return const Reminder();
        },
        'reminder_data': (ctx) {
          return IpFormField();
        },
        'notify-data': (ctx) {
          return NotifyInput();
        },
        'home_screen':(ctx) {
          return const HomeScreen();
        }
        // 'alarm':(ctx){
        //   return AlarmScreen();
        // }
      },
    );
  }
}
