

import 'package:hive_flutter/adapters.dart';
part 'db_models.g.dart';



@HiveType(typeId:1)
class TaskModel{
  @HiveField(0)
  int? _id;
  @HiveField(1)
  final String task;
  @HiveField(2)
  final String location;
  @HiveField(3)
  final double latitude;
  @HiveField(4)
  final double longitude;
  @HiveField(5)
  final DateTime? date;
  @HiveField(6)
  final String category;
  bool isOn=true;
  bool isVisible=false;
  TaskModel({required this.latitude,required this.longitude, required this.task, required this.location,required this.category,this.date,int? id}): _id = id;
  int get id => _id ?? 0; // Provide a default value if id is null

  set id(int value) {
    _id = value;
  }
  
}

@HiveType(typeId:2)
class NotifyModel {
  @HiveField(0)
  int? _id; // Use a separate field for nullable id
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
  @HiveField(6)
  final DateTime? date;
  bool isOn = true;
  bool isVisible = false;

  NotifyModel({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.distance,
    required this.location,
    this.date,
    int? id, // Accept nullable id value
  }) : _id = id;

  int get id => _id ?? 0; // Provide a default value if id is null

  set id(int value) {
    _id = value;
  }
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