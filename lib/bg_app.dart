import 'dart:async';
import 'dart:convert';
// import 'dart:js';
// import 'dart:math';

import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms/flutter_sms.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:location_based_reminder/Screens/Reminder/alarm.dart';
// import 'package:location_based_reminder/Screens/Reminder/alarm.dart';
// import 'package:location_based_reminder/background.dart';

import 'db/models/db_models.dart';
import 'main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Initialize location tracking
  // final geolocator = Geolocator();
  Position? currentLocation;

  // Request location permission if not granted
  // perm.PermissionStatus status = await perm.Permission.locationAlways.request();
  var serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  var permission = await Geolocator.checkPermission();
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
  Geolocator.getPositionStream().listen((Position newPosition) {
    currentLocation = newPosition;

    // Update foreground notification with location info
    if (service is AndroidServiceInstance && currentLocation != null) {
      // service.setForegroundNotificationInfo(
      //   title: "Test app",
      //   content:
      //       "Latitude: ${currentLocation!.latitude}, Longitude: ${currentLocation!.longitude}",
      // );
    }
  });

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Update foreground notification with location info
        if (currentLocation != null) {
          // service.setForegroundNotificationInfo(
          //   title: "Test app",
          //   content:
          //       "Latitude: ${currentLocation!.latitude}, Longitude: ${currentLocation!.longitude}",
          // );
        }
      }
    }

    // Perform other background operations
    // String pos = currentLocation.toString();
    // String date = DateTime.now().toString();
    // String notId =  Random().nextInt(100000).toString();
    service.invoke('update');
    // backgroundTaskTest();
    // print(DateTime.now());
    // service.invoke('update');

  void initializeNotifications() {
  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Navigate to the AlarmScreen
      Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => AlarmScreen(place: response.payload!)),
      );
    },
  );
}

    Future<void> _showNotification(
      String location,
      String name,
      String notificationId,
      String phone
    ) async {
      final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
      final place = location.split(',');
      final phno=phone;
      Future<void> _sendsms() async {
        List<String> recipients = [phno];
        String direct = await sendSMS(
            message: "Hi $name $location is less than 1000 meters! from my current location ", recipients: recipients, sendDirect: true);
        debugPrint(direct);
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        // icon:
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        uniqueId.hashCode,
        'Alarm',
        '$name  ...\n${place[0]} is less than 1000 meters!',
        platformChannelSpecifics,
        payload: notificationId,
      );

      // Listen to notification click events
      // flutterLocalNotificationsPlugin.initialize(
      //   InitializationSettings(
      //     android: AndroidInitializationSettings(
      //         'app_icon'), // Replace 'app_icon' with your app's launcher icon
      //   ),
      // );

      // Handle notification click
      flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          // Navigate to the AlarmScreen
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => AlarmScreen(place: place[0],)),
          // );
        },
      );

      await _sendsms();
    }

    void distanceMeasure_1() async {
      double distance;
      List<NotifyModel> notifyList = [];
      List<UserModel> userList = [];
      String phone = '';
      await Hive.initFlutter();

      Future<List<NotifyModel>> getAllNotifybg() async {
        if (!Hive.isAdapterRegistered(NotifyModelAdapter().typeId)) {
          Hive.registerAdapter(NotifyModelAdapter());
        }

        final notifyBox = await Hive.openBox<NotifyModel>('notify_db');
        notifyList.clear();
        notifyList.addAll(notifyBox.values);
        return notifyList;
      }
      
      notifyList = await getAllNotifybg();

    Future<List<UserModel>> getAllUserbg() async {
        if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
          Hive.registerAdapter(UserModelAdapter());
        }

        final userBox = await Hive.openBox<UserModel>('user_db');
        userList.clear();
        userList.addAll(userBox.values);
        return userList;
      }
      userList=await getAllUserbg();


      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      for (int i = 0; i < notifyList.length; i++) {
        double latitude = notifyList[i].latitude;
        double longitude = notifyList[i].longitude;
        DateTime? storedDate =
            notifyList[i].date; // Date stored in the NotifyModel object
        DateTime today = DateTime.now(); // Current date

        // Compare the date component only, ignoring the time
        bool isSameDate = DateFormat('yyyy-MM-dd').format(storedDate!) ==
            DateFormat('yyyy-MM-dd').format(today);
        distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          latitude,
          longitude,
        );

        for(int j = 0; j < userList.length; j++){
        if(notifyList[i].name==userList[j].name){
          phone=userList[j].phno;
        }
      }

        if (notifyList[i].distance != null) {
          if (isSameDate || notifyList[i].date == null) {
            if (distance < 2000) {
              await _showNotification(
                notifyList[i].location,
                notifyList[i].name,
                i.toString(),
                phone
              );
            }
          }
        }
      }
    }

    

    void _showAlarmScreen_buy(
  String location,
  String name,
  String notificationId,
) async {
  final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
  final place = location.split(',');

  

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id_1',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    sound: RawResourceAndroidNotificationSound('buy')
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    uniqueId.hashCode,
    name,
    '${place[0]} is less than 1000 meters!',
    platformChannelSpecifics,
    payload: place[0],
  );
  // void initializeNotifications() {
  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Navigate to the AlarmScreen
      Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => AlarmScreen(place: response.payload!)),
      );
    },
  );
// }

  
}



void _showAlarmScreen_visit(
  String location,
  String name,
  String notificationId,
) async {
  final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
  final place = location.split(',');

  // void _sendsms() async {
  //   List<String> recipents = ["+917902561866"];
  //   await sendSMS(message: "hi morning", recipients: recipents,sendDirect: true);
  // }

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id_2',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    sound: RawResourceAndroidNotificationSound('visit')
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    uniqueId.hashCode,
    name,
    '${place[0]} is less than 1000 meters!',
    platformChannelSpecifics,
    payload: place[0],
  );
  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Navigate to the AlarmScreen
      Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => AlarmScreen(place: response.payload!)),
      );
    },
  );
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => AlarmScreen(place: location),
  //   ),
  // );
}
void _showAlarmScreen_other(
  String location,
  String name,
  String notificationId,
) async {
  final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
  final place = location.split(',');

  // void _sendsms() async {
  //   List<String> recipents = ["+917902561866"];
  //   await sendSMS(message: "hi morning", recipients: recipents,sendDirect: true);
  // }

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id_3',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    sound: RawResourceAndroidNotificationSound('other')
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    uniqueId.hashCode,
    name,
    '${place[0]} is less than 1000 meters!',
    platformChannelSpecifics,
    payload: place[0],
  );

  flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Navigate to the AlarmScreen
      Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => AlarmScreen(place: response.payload!)),
      );
    },
  );
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => AlarmScreen(place: location),
  //   ),
  // );
}

    void reminderdistanceMeasure_1() async {
      double distance;
      List<TaskModel> taskList = [];

      await Hive.initFlutter();

      Future<List<TaskModel>> getAllTasks() async {
        if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
          Hive.registerAdapter(TaskModelAdapter());
        }
        final taskBox = await Hive.openBox<TaskModel>('task_db');
        taskList.clear();
        taskList.addAll(taskBox.values);
        return taskList;
      }

      taskList = await getAllTasks();
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      for (int i = 0; i < taskList.length; i++) {
        double latitude = taskList[i].latitude;
        double longitude = taskList[i].longitude;
        distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          latitude,
          longitude,
        );
        if (distance < 2000) {
          if(taskList[i].category=='Buy'){
        _showAlarmScreen_buy(
        taskList[i].location,
        taskList[i].task,
        i.toString(),
      );
    }
    if(taskList[i].category=='Other'){
        _showAlarmScreen_other(
        taskList[i].location,
        taskList[i].task,
        i.toString(),
      );
    }
    if(taskList[i].category=='Visit'){
        _showAlarmScreen_visit(
        taskList[i].location,
        taskList[i].task,
        i.toString(),
      );
    }
        }
      }
    }

    distanceMeasure_1();
    reminderdistanceMeasure_1();
  });
}
