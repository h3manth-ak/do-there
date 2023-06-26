// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:location_based_reminder/Screens/Reminder/alarm.dart';
import 'package:location_based_reminder/main.dart';
// import 'package:location_based_reminder/db/functions/db_functions.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import 'db/models/db_models.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

distanceMeasure() async {
  double distance;
  List<NotifyModel> notifyList = [];
  List<UserModel> userList = [];
  String phone='';
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(NotifyModelAdapter().typeId)) {
    Hive.registerAdapter(NotifyModelAdapter());
  }
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  final appDir = await getApplicationDocumentsDirectory();

  // ignore: unnecessary_null_comparison
  if (appDir != null) {
    // final notifyDir = Directory('${appDir.path}/notify_db');
    // await notifyDir.create(recursive: true);
    // final notifyBox =
    //     await Hive.openBox<NotifyModel>(appDir.path + '/notify_db');
    // final lockFile = File('${appDir.path}/notify_db.lock');
    // if (await lockFile.exists()) {
    //   // print('dock file exist');
    //   await lockFile.delete();
    // }

    final notifyBox =
        await Hive.openBox<NotifyModel>('notify_db', path: appDir.path);
    notifyList.clear();
    notifyList.addAll(notifyBox.values);

    final userBox = await Hive.openBox<UserModel>('user_db', path: appDir.path);
    userList.clear();
    userList.addAll(userBox.values);

    final currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    for (int i = 0; i < notifyList.length; i++) {
      double latitude = notifyList[i].latitude;
      double longitude = notifyList[i].longitude;
      DateTime? storedDate =
          notifyList[i].date; // Date stored in the NotifyModel object
      DateTime today = DateTime.now(); // Current date
      bool isSameDate;
      // Compare the date component only, ignoring the time
      isSameDate = DateFormat('yyyy-MM-dd').format(storedDate!) ==
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
        if (notifyList[i].date==null ||isSameDate) {
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

    // Close the Hive box to clean up resources
    await notifyBox.close();
    // ...
    // await notifyBox.close();
  } else {}

  final notifyBox = await Hive.openBox<NotifyModel>('notify_db');

  notifyList.clear();
  notifyList.addAll(notifyBox.values);

  final userBox = await Hive.openBox<UserModel>('user_db', path: appDir.path);
    userList.clear();
    userList.addAll(userBox.values);

  final currentPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );

  for (int i = 0; i < notifyList.length; i++) {
    double latitude = notifyList[i].latitude;
    double longitude = notifyList[i].longitude;
    DateTime? storedDate =
        notifyList[i].date; // Date stored in the NotifyModel object
    DateTime today = DateTime.now(); // Current date
    bool isSameDate;
    // Compare the date component only, ignoring the time
    isSameDate = DateFormat('yyyy-MM-dd').format(storedDate!) ==
        DateFormat('yyyy-MM-dd').format(today);
    for(int j = 0; j < userList.length; j++){
        if(notifyList[i].name==userList[j].name){
          phone=userList[j].phno;
        }
      }

    distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      latitude,
      longitude,
    );
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
      } else {
      }
    }
  }

  // Close the Hive box to clean up resources
  await notifyBox.close();
}

Future<void> _showNotification(
  String location,
  String name,
  String notificationId,
  String phone
) async {
  final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
  final place = location.split(',');

  Future<void> _sendsms() async {
    List<String> recipents = [phone];
    print(recipents);
    await sendSMS(
        message: 'Hi $name ${place[0]} is less than 1000 meters! from my current location ', recipients: recipents, sendDirect: true);
  }

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    uniqueId.hashCode,
    'Alarm',
    '$name  ...\n'
        '${place[0]} is less than 1000 meters!',
    platformChannelSpecifics,
    payload: notificationId,
  );
   await _sendsms();
}

void backgroundTask() async {
  await distanceMeasure();
}

//------------------------------------------------------------------------------------------------------------
void reminderdistanceMeasure() async {
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
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

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

 
}


void reminderbackgroundTask() async {
  reminderdistanceMeasure();
}

backgroundTaskTest() async {
  distanceMeasure();
  reminderdistanceMeasure();
}
