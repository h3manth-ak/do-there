import 'package:flutter/material.dart';

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
  bool _isvisible = false;

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
        _isvisible = false;
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
        _isvisible = true;
      });
      print('Switch Button is OFF');
    }
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
                  color: Color.fromARGB(255, 39, 39, 39),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      debugPrint('Card tapped.');
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
                                  padding: EdgeInsets.only(left: 19, top: 3),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.greenAccent,
                                      ),
                                      Text(
                                        loc[0],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Visibility(
                                        visible: data.isVisible,
                                        child: Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: IconButton(
                                              onPressed: () {
                                                if (data.id != null) {
                                                  deleteTask(data.id!);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Student id is null')));
                                                }
                                              },
                                              icon: Icon(
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
                            padding: EdgeInsets.only(
                              top: 20,
                              bottom: 4,
                            ),
                            child: Text(
                              data.task,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 30, left: 50),
                            child: Switch(
                              value: data.isOn,
                              onChanged: (value){
                                if(data.isOn==false){

                                setState(() {
                                  data.isOn=value;
                                  data.isVisible = false;

                                });
                                }
                                else{
                                  setState(() {
                                    data.isOn=value;
                                    data.isVisible = true;

                                  });
                                }
                              },
                              activeColor: Colors.white,
                              activeTrackColor:
                                  Color.fromARGB(255, 30, 232, 8),
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
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      // print('hello reminder ');
                      Navigator.of(context).pushNamed('reminder_data');
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.green,
                      size: 45,
                    ),
                    splashColor: Colors.green,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
