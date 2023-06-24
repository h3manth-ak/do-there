import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:synchronized/synchronized.dart';
import '../models/db_models.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';

// import 'package:flutter/src/foundation/change_notifier.dart';

ValueNotifier<List<TaskModel>> taskListNotifier = ValueNotifier([]);
ValueNotifier<List<NotifyModel>> notifyListNotifier = ValueNotifier([]);
ValueNotifier<List<UserModel>> userListNotifier = ValueNotifier([]);

Future<void> addTask(TaskModel task) async {
  final taskDB = await Hive.openBox<TaskModel>('task_db');
  final _id = await taskDB.add(task);
  task.id = _id;
  taskListNotifier.value.add(task);
  taskListNotifier.notifyListeners();
  // print(task.toString());
}

Future<void> getAllTask() async {
  final taskDB = await Hive.openBox<TaskModel>('task_db');
  taskListNotifier.value.clear();
  taskListNotifier.value.addAll(taskDB.values);
  taskListNotifier.notifyListeners();
}

Future<void> deleteTask(int id) async {
  final taskDB = await Hive.openBox<TaskModel>('task_db');
  await taskDB.delete(id);
  getAllTask();
}

Future<void> addNotify(NotifyModel notify) async {
  final notifyDB = await Hive.openBox<NotifyModel>('notify_db');
  final _id = await notifyDB.add(notify);
  notify.id = _id;

  // Clear the notifier list and add the new item
  notifyListNotifier.value.clear();
  notifyListNotifier.value.addAll(notifyDB.values);
  notifyListNotifier.notifyListeners();

  await notifyDB.close();
}

Future<void> getAllNotify() async {
  final notifyDB = await Hive.openBox<NotifyModel>('notify_db');
  // notifyDB.clear();
  notifyListNotifier.value.clear();
  notifyListNotifier.value.addAll(notifyDB.values);
  notifyListNotifier.notifyListeners();
  // await notifyDB.close();

}

Future<void> deleteNotify(int id) async {
  print('Deleting notification with id $id...');
  final notifyDB = await Hive.openBox<NotifyModel>('notify_db');
  await notifyDB.delete(id);
  // await notifyDB.close(); // Close the box before deleting the file
  print('Notification with id $id deleted successfully.');
  // setState(() {}); // Trigger UI rebuild
  getAllNotify(); // Wait for the data to be updated
}



final _lock = Lock();

void updateNotify(int notifyId, bool isOn) async {
  await _lock.synchronized(() async {
    final notifyDB = await Hive.openBox<NotifyModel>('notify_db');
    final notifyList = notifyDB.values.toList();

    final notifyIndex = notifyList.indexWhere((notify) => notify.id == notifyId);
    print('notifyIndex: $notifyIndex');

    if (notifyIndex != -1) {
      final NotifyModel notify = notifyList[notifyIndex];
      notify.isOn = isOn;

      // Put the updated notify object in the database
      await notifyDB.put(notify.id, notify);

      // Update the value in the list
      notifyList[notifyIndex] = notify;
      notifyListNotifier.value = notifyList;

      for (final notify in notifyList) {
        print('id: ${notify.id}');
        print(notify.isOn);
        print(notify.name);
        print(notify.location);
      }
    } else {
      print('No item found with notifyId: $notifyId');
      // Handle the case when notifyIndex is -1
    }

    // Close the database after the operations are done
    await notifyDB.close();
  });
}






Future<void> userAdd(UserModel user) async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  final _id = await userDB.add(user);
  user.id = _id;
  userListNotifier.value.add(user);
  userListNotifier.notifyListeners();
  // print(user.toString());
}

Future<void> getAllUser() async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  userListNotifier.value.clear();
  userListNotifier.value.addAll(userDB.values);
  userListNotifier.notifyListeners();
}
