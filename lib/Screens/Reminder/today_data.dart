import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../db/functions/db_functions.dart';
import '../../db/models/db_models.dart';

class TodayTasksScreen extends StatefulWidget {
  const TodayTasksScreen({super.key});

  @override
  _TodayTasksScreenState createState() => _TodayTasksScreenState();
}

class _TodayTasksScreenState extends State<TodayTasksScreen> {
  List<TaskModel> orderedTaskList = [];
  List<TaskModel> taskList = [];
  List<TaskModel> todayTasks = [];
  @override
  void initState() {
    super.initState();
    // Fetch and update taskListNotifier with tasks data
    getAllTask();
  }

  void showOrderedLocationsDialog(
      List<TaskModel> orderedLocations, double totalDistance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Ordered Locations',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 1000),
                      opacity: 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(orderedLocations.length, (index) {
                          final location = orderedLocations[index];
                          final locationParts = location.location.split(',');
                          final locationName =
                              '${locationParts[0]}, ${locationParts[1]}';
                          final distanceToNext = index <
                                  orderedLocations.length - 1
                              ? (location.distance! / 1000).toStringAsFixed(2)
                              : '';

                          return Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on,color: Colors.green),
                                        Text(
                                          locationName,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              // fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(255, 228, 132, 132)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (index < orderedLocations.length - 1)
                                        Transform.rotate(
                                          angle: 0 * (pi / 180),
                                          child:
                                              const Icon(Icons.arrow_downward,color: Colors.amber),
                                        ),
                                      if (index < orderedLocations.length - 1)
                                        const SizedBox(width: 8),
                                      if (index < orderedLocations.length - 1)
                                        Text(
                                          '$distanceToNext km',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              // fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                    ],
                                  ),
                                  if (index < orderedLocations.length - 1)
                                    const SizedBox(height: 16),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [],
                                  ),
                                  if (index < orderedLocations.length - 1)
                                    const SizedBox(height: 16),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total Distance to Cover today ${totalDistance.round()} km',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    // getAllTask();

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: taskListNotifier,
          builder: (BuildContext ctx, List<TaskModel> taskList, Widget? child) {
            final today = DateTime.now();
            todayTasks = taskList
                .where((task) =>
                    task.date!.year == today.year &&
                    task.date!.month == today.month &&
                    task.date!.day == today.day)
                .toList();
            // print(todayTasks.length);
            todayTasks = todayTasks;

            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              children: List.generate(todayTasks.length, (index) {
                final data = todayTasks[index];
                final loc = data.location.split(',');
                return Card(
                  color: const Color.fromARGB(255, 39, 39, 39),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      debugPrint('Card tapped.');
                      // showCardDetails(context, data);
                    },
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 19, top: 3),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.greenAccent,
                                      ),
                                      Text(
                                        loc[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Visibility(
                                        visible: data.isVisible,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: IconButton(
                                            onPressed: () {
                                              deleteTask(data.id);
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 4),
                            child: Text(
                              data.task,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30, left: 50),
                            child: Switch(
                              value: data.isOn,
                              onChanged: (value) {
                                if (data.isOn == false) {
                                  setState(() {
                                    data.isOn = value;
                                    data.isVisible = false;
                                  });
                                } else {
                                  setState(() {
                                    data.isOn = value;
                                    data.isVisible = true;
                                  });
                                }
                              },
                              activeColor: Colors.white,
                              activeTrackColor:
                                  const Color.fromARGB(255, 30, 232, 8),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> tspSolution = await solveTSP(todayTasks);
          List<TaskModel> orderedTaskList = tspSolution['orderedTasks'];
          double totalDistance = tspSolution['totalDistance'] /
              1000; // Convert total distance to kilometers

          showOrderedLocationsDialog(orderedTaskList, totalDistance);
        },
        backgroundColor: const Color.fromARGB(255, 20, 19, 19),
        heroTag: 'Task',
        tooltip: 'Add Task',
        child: const Icon(
          Icons.route_outlined,
          color: Colors.green,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 20, 19, 19),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to home screen
                  Navigator.of(context).pushNamed('home_screen');
                  
                },
                heroTag: 'home',
                tooltip: 'Home',
                backgroundColor: const Color.fromARGB(255, 20, 19, 19),
                child: const Icon(
                  Icons.home,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
  Future<Map<String, dynamic>> solveTSP(List<TaskModel> tasks) async {
    if (tasks.isEmpty) {
      return {'orderedTasks': [], 'totalDistance': 0.0};
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    double latitude = position.latitude;
    double longitude = position.longitude;

    List<TaskModel> remainingTasks = tasks;
    List<TaskModel> orderedTasks = [];
    double totalDistance = 0.0; // Initialize total distance

    while (remainingTasks.isNotEmpty) {
      TaskModel nearestTask = remainingTasks.first;
      double minDistance = double.infinity;
      for (final task in remainingTasks) {
        final distance = Geolocator.distanceBetween(
            latitude, longitude, task.latitude, task.longitude);
        if (distance < minDistance) {
          minDistance = distance;
          nearestTask = task;
        }
      }
      orderedTasks.add(nearestTask);
      remainingTasks.remove(nearestTask);

      // Update total distance
      totalDistance += minDistance;

      latitude = nearestTask.latitude;
      longitude = nearestTask.longitude;
    }

    for (int i = 0; i < orderedTasks.length - 1; i++) {
      final distance = Geolocator.distanceBetween(
          orderedTasks[i].latitude,
          orderedTasks[i].longitude,
          orderedTasks[i + 1].latitude,
          orderedTasks[i + 1].longitude);
      orderedTasks[i].distance = distance;
    }

    for (int i = 0; i < orderedTasks.length; i++) {
      // print('Place ${i + 1}: ${orderedTasks[i].location}');
      if (i < orderedTasks.length - 1) {
      }
    }


    return {'orderedTasks': orderedTasks, 'totalDistance': totalDistance};
  }
}
