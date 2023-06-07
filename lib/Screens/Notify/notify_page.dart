// import 'dart:ffi';
// import 'dart:math' show cos, sqrt, asin;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location_based_reminder/Screens/Reminder/alarm.dart';
// import 'package:location_based_reminder/db/functions/db_functions.dart';
import '../../db/functions/db_functions.dart';
import '../../db/models/db_models.dart';
// import 'package:hive_flutter/adapters.dart';


class Notify extends StatefulWidget {
  const Notify({Key? key}) : super(key: key);

  @override
  SwitchClass createState() => SwitchClass();
}

class SwitchClass extends State<Notify> {
  bool isSwitched = true;
  String textValue = 'Switch is ON';
  bool _isvisible = false;
  StreamSubscription<Position>? positionSubscription;
  Position? previousLocation;
  Position? selectedLocation;
  String distanceText = '';

  // @override
  // void initState() {
  //   super.initState();
  //   _startTracking();
  // }

  // void _startTracking() {
  //   positionSubscription = Geolocator.getPositionStream(
  //           )
  //       .listen((Position position) {
  //     setState(() {
  //       if (previousLocation == null ||
  //           Geolocator.distanceBetween(
  //                   previousLocation!.latitude,
  //                   previousLocation!.longitude,
  //                   position.latitude,
  //                   position.longitude) >=
  //               200) {
  //         previousLocation = position;
  //         // Perform your distance calculation and updates here
  //         updateDistances(position.latitude, position.longitude);
  //       }
  //     });
  //   });
  // }

  // void updateDistances(double currentLatitude, double currentLongitude) {
  //   // Iterate through notifyList and calculate distance for each entry
  //   for (final notifyModel in notifyListNotifier.value) {
  //     double distance = Geolocator.distanceBetween(
  //         currentLatitude, currentLongitude, notifyModel.latitude, notifyModel.longitude);
  //     final distanceKm = distance / 1000; // Convert to kilometers
  //     notifyModel.bal_distance = distanceKm.roundToDouble(); // Update distance
  //   }
  // }
  


  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
        _isvisible = false;
      });
      // print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
        _isvisible = true;
      });
      // print('Switch Button is OFF');
    }
  }

  @override
  Widget build(BuildContext context)  {
    // print('before');
    getAllNotify();
    // print('after');
    print(notifyListNotifier.value);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: notifyListNotifier,
          builder: (BuildContext ctx, List<NotifyModel> notifyList, Widget? child) {
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              children: List.generate(notifyList.length, (index) {
                
                final data = notifyList[index];
                // final double dist=data.distance as double;
                final loc = data.location.split(',');
                print('data $data');
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
                        print(data);
                      },
                      child: SizedBox(
                        width: 170,
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
                                        Padding(
                                          padding: const EdgeInsets.only(right: 30),
                                          child: Text(
                                            loc[0],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: data.isVisible,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: IconButton(
                                              onPressed: () {
                                                if (data.id != null) {
                                                  deleteNotify(data.id!);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Notify id is null')));
                                                }
                                              },
                                              icon: Icon(
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
                              padding: EdgeInsets.only(
                                top: 20,
                                bottom: 4,
                              ),
                              child: Text(
                                data.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30, left: 40),
                              child: Row(
                                children: [
                                  Text(
                                    '${data.distance} km',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Switch(
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
                                    activeTrackColor: Color.fromARGB(255, 30, 232, 8),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.grey,
                                  ),
                                ],
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
                    Navigator.of(context).pushNamed('notify-data');
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 45,
                  ),
                  splashColor: Colors.green,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
