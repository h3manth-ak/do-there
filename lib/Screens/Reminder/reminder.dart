import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../db/functions/db_functions.dart';
import '../../db/models/db_models.dart';


class Reminder extends StatefulWidget {
  const Reminder({super.key});

  @override
  // State<Reminder> createState() => _ReminderState();
  SwitchClass createState() => SwitchClass();
}

class SwitchClass extends State<Reminder> {
  List<bool> isSelected = [true];
  bool isSwitched = true;
  var textValue = 'Switch is ON';

  void showCardDetails(BuildContext context, TaskModel data) async {
        final Position currentposition=await  Geolocator.getCurrentPosition();
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double distance=Geolocator.distanceBetween(
          currentposition.latitude,
          currentposition.longitude,
          data.latitude,
          data.longitude,
        );
        distance=distance/1000;
        distance=double.parse(distance.toStringAsFixed(2));
        final loc = data.location.split(',');

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 4,
                  ),
                  child: Text(
                    data.task,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 19, top: 3),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.greenAccent,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(
                                "${loc[0]},${loc[1]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                  padding: const EdgeInsets.only(top: 30, left: 40),
                  child: Row(
                    children: [
                      Text(
                        '$distance km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getAllTask();
    // print(taskListNotifier.value);
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: taskListNotifier,
          builder: (BuildContext ctx, List<TaskModel> taskList, Widget? child) {
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              children: List.generate(taskList.length, (index) {
                final data = taskList[index];
                final loc = data.location.split(',');
                return Card(
                  color: const Color.fromARGB(255, 39, 39, 39),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: ()  {
                      debugPrint('Card tapped.');
                      showCardDetails(context, data);
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
                                  padding: const EdgeInsets.only(left: 19, top: 3),
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
                                            padding: const EdgeInsets.only(left: 5),
                                            child: IconButton(
                                              onPressed: () {
                                                if (data.id != null) {
                                                  deleteTask(data.id!);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Student id is null')));
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                                size: 15,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              bottom: 4,
                            ),
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
                              activeTrackColor: const Color.fromARGB(255, 30, 232, 8),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey,
                            ),
                          )
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
          // print('hello reminder ');
          Navigator.of(context).pushNamed('reminder_data');
        },
        // splashColor: Colors.green,
        backgroundColor: const Color.fromARGB(255, 20, 19, 19),
        heroTag: 'Task',
        tooltip: 'Add Task',
        child: const Icon(
          Icons.add,
          color: Colors.green,
          // size: 45,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        // height: 60,
        color: const Color.fromARGB(255, 20, 19, 19),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: FloatingActionButton(
              onPressed: () {
                // Navigator.popUntil(
                //     context, (route) => route.settings.name == 'home_screen');
                Navigator.of(context).pushNamed('home_screen');
              },
              heroTag: 'home',
              tooltip: 'Home',
              backgroundColor: const Color.fromARGB(255, 20, 19, 19),
              child: const Icon(
                Icons.home,
                color: Colors.green,
              ),
            )),
            Expanded(
                child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('today');
                // Navigator.popUntil(
                //     context, (route) => route.settings.name == 'home_screen');
              },
              heroTag: 'today_tag',
              tooltip: 'Today',
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.green,
              ),
              backgroundColor: const Color.fromARGB(255, 20, 19, 19),
            ))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
