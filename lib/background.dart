// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'Screens/Reminder/alarm.dart';
import 'db/models/db_models.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void distanceMeasure() async {
  print('distancemeasure');
  double distance;
  List<NotifyModel> notifyList = [];

  await Hive.initFlutter();

  Future<List<NotifyModel>> getAllNotifybg() async {
    if (!Hive.isAdapterRegistered(NotifyModelAdapter().typeId)) {
      Hive.registerAdapter(NotifyModelAdapter());
    }
    final notifyBox = await Hive.openBox<NotifyModel>('notify_db');
    print(' notify db values ${notifyBox.values}');
    notifyList.clear();
    notifyList.addAll(notifyBox.values);
    return notifyList;
  }

  notifyList = await getAllNotifybg();
  print(notifyList);

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

  for (int i = 0; i < notifyList.length; i++) {
    double latitude = notifyList[i].latitude;
    double longitude = notifyList[i].longitude;
    distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      latitude,
      longitude,
    );
    print(distance);
    if (notifyList[i].distance != null) {
      if (distance < 2000) {
        print('hihihi');
        await _showNotification(
          notifyList[i].location,
          notifyList[i].name,
          i.toString(),
        );
      }
    }
  }
}

Future<void> _showNotification(
  String location,
  String name,
  String notificationId,
) async {
  final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
  final place=location.split(',');
  print(place[0]);

  void _sendsms() async {
    List<String> recipents = ["+917902561866"];

    String direct=await sendSMS(message: "Test Messege", recipients: recipents,sendDirect: true);
    print(direct);

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
   _sendsms();
}
void backgroundTask() async {
  distanceMeasure();
  
}



//------------------------------------------------------------------------------------------------------------
void reminderdistanceMeasure() async {
  print('rem distancemeasure');
  double distance;
  List<TaskModel> taskList = [];

  await Hive.initFlutter();

  Future<List<TaskModel>> getAllTasks() async {
    if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    final taskBox = await Hive.openBox<TaskModel>('task_db');
    print(' task db values ${taskBox.values}');
    taskList.clear();
    taskList.addAll(taskBox.values);
    return taskList;
  }

  taskList = await getAllTasks();
  print(taskList);

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
    print(distance);
    if (distance < 2000) {
      print('hihihi');
       _showAlarmScreen(
        
        taskList[i].location,
        taskList[i].task,
        i.toString(),
      );
    }
  }
}
void _showAlarmScreen(String location,
  String name,
  String notificationId,) async{
  final uniqueId = sha1.convert(utf8.encode(location + name)).toString();
  final place=location.split(',');

  // void _sendsms() async {
  //   List<String> recipents = ["+917902561866"];
  //   await sendSMS(message: "hi morning", recipients: recipents,sendDirect: true);
  // }

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
    name,
    '${place[0]} is less than 1000 meters!',
    platformChannelSpecifics,
    payload: notificationId,
  );
  
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => AlarmScreen(place: location),
  //   ),
  // );
}
 
void reminderbackgroundTask() async {
  
  reminderdistanceMeasure();
}


void backgroundTaskTest() async {
  distanceMeasure();
  reminderdistanceMeasure();
}


