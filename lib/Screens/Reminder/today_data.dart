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
  @override
  void initState() {
    super.initState();
    // Fetch and update taskListNotifier with tasks data
    getAllTask();
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
            final todayTasks = taskList
                .where((task) =>
                    task.date!.year == today.year &&
                    task.date!.month == today.month &&
                    task.date!.day == today.day)
                .toList();
            // print(todayTasks.length);

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
        onPressed: () {
          Navigator.of(context).pushNamed('reminder_data');
        },
        backgroundColor: const Color.fromARGB(255, 20, 19, 19),
        heroTag: 'Task',
        tooltip: 'Add Task',
        child: const Icon(
          Icons.add,
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
                  Navigator.popUntil(
                    context,
                    (route) => route.settings.name == 'home_screen',
                  );
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
  Future<List<TaskModel>> solveTSP(List<TaskModel> tasks) async{
    if (tasks.isEmpty){
      return [];
    }
    Position position =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    double latitude= position.latitude;
    double longitude= position.longitude;

   List<TaskModel> remainingTasks=tasks;
   List<TaskModel> orderedTasks=[];

   while(remainingTasks.isEmpty){

    TaskModel nearestTask=remainingTasks.first;
    double minDistance=double.infinity;
    for(final task in remainingTasks){
      final distance=Geolocator.distanceBetween(latitude, longitude, task.latitude, task.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearestTask = task;
      }

    }
    orderedTasks.add(nearestTask);
    remainingTasks.remove(nearestTask);

     latitude = nearestTask.latitude;
    longitude = nearestTask.longitude;

   }
   for (int i = 0; i < orderedTasks.length; i++) {
    print('Place ${i + 1}: ${orderedTasks[i].location}');
  }
   // now i want to change lattitude after first min distance is calculated and then it works well
    return orderedTasks;
  }
}
