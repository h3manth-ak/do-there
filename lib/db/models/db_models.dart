

import 'package:hive_flutter/adapters.dart';
part 'db_models.g.dart';



@HiveType(typeId:1)
class TaskModel{
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String task;
  @HiveField(2)
  final String location;
  @HiveField(3)
  final double latitude;
  @HiveField(4)
  final double longitude;
  bool isOn=true;
  bool isVisible=false;
  TaskModel({required this.latitude,required this.longitude, required this.task, required this.location,this.id});
}

@HiveType(typeId:2)
class NotifyModel{
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double? distance;
  @HiveField(3)
  final String location;
  @HiveField(4)
  final double latitude;
  @HiveField(5)
  final double longitude;
  bool isOn=true;
  bool isVisible=false;
  NotifyModel({required this.latitude,required this.longitude, required this.name,required this.distance,required this.location,this.id});
}
@HiveType(typeId:3)
class UserModel {
  @HiveField(0)
  int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phno;

  UserModel({required this.name,required this.phno,this.id});
}