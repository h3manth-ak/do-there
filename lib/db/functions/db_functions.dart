import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/db_models.dart';
// import 'package:flutter/src/foundation/change_notifier.dart';

ValueNotifier<List<TaskModel>>taskListNotifier=ValueNotifier([]);
ValueNotifier<List<NotifyModel>>notifyListNotifier=ValueNotifier([]);
ValueNotifier<List<UserModel>>userListNotifier=ValueNotifier([]);

Future <void> addTask(TaskModel task) async{
  final taskDB=await Hive.openBox<TaskModel>('task_db');
  final _id=await taskDB.add(task);
  task.id=_id;
  taskListNotifier.value.add(task);
  taskListNotifier.notifyListeners();
  // print(task.toString());

}

Future <void> getAllTask() async{
  final taskDB=await Hive.openBox<TaskModel>('task_db');
  taskListNotifier.value.clear();
  taskListNotifier.value.addAll(taskDB.values);
  taskListNotifier.notifyListeners();
}
Future <void> addNotify(NotifyModel notify) async{
  final notifyDB=await Hive.openBox<NotifyModel>('notify_db');
  final _id= await notifyDB.add(notify);
  notify.id=_id;
  notifyListNotifier.value.add(notify);
  notifyListNotifier.notifyListeners();
  // print(notify.toString());

}
Future <void> deleteTask(int id) async{
  final taskDB=await Hive.openBox<TaskModel>('task_db');
  await taskDB.delete(id);
  getAllTask();
}
Future <void> getAllNotify() async{
  final notifyDB=await Hive.openBox<NotifyModel>('notify_db');
  notifyListNotifier.value.clear();
  notifyListNotifier.value.addAll(notifyDB.values);
  notifyListNotifier.notifyListeners();
}

Future <void> deleteNotify(int id) async{
  final notifyDB=await Hive.openBox<NotifyModel>('notify_db');
  await notifyDB.delete(id);
  getAllNotify();
}
Future <void> userAdd(UserModel user) async{
  final userDB=await Hive.openBox<UserModel>('user_db');
  final _id= await userDB.add(user);
  user.id=_id;
  userListNotifier.value.add(user);
  userListNotifier.notifyListeners();
  // print(user.toString());

}
Future <void> getAllUser() async{
  final userDB=await Hive.openBox<UserModel>('user_db');
  userListNotifier.value.clear();
  userListNotifier.value.addAll(userDB.values);
  userListNotifier.notifyListeners();
}