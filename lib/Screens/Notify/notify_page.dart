import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../db/functions/db_functions.dart';
import '../../db/models/db_models.dart';

class Notify extends StatefulWidget {
  const Notify({Key? key}) : super(key: key);

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  StreamSubscription<Position>? positionSubscription;
  Position? previousLocation;
  Position? selectedLocation;
  String distanceText = '';

  @override
  void initState() {
    super.initState();
    getAllNotify();
  }

  void showCardDetails(BuildContext context, NotifyModel data) async {
    final Position currentposition = await Geolocator.getCurrentPosition();
    final loc = data.location.split(',');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double distance = Geolocator.distanceBetween(
          currentposition.latitude,
          currentposition.longitude,
          data.latitude,
          data.longitude,
        );
        distance = distance / 1000;
        distance = double.parse(distance.toStringAsFixed(2));

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
                    data.name,
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
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: ValueListenableBuilder<List<NotifyModel>>(
          valueListenable: notifyListNotifier,
          builder:
              (BuildContext ctx, List<NotifyModel> notifyList, Widget? child) {
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              children: notifyList.map((NotifyModel data) {
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
                      showCardDetails(context, data);
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
                                  padding:
                                      const EdgeInsets.only(left: 19, top: 3),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.greenAccent,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 30),
                                        child: Text(
                                          "${loc[0]},${loc[1]}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: data.isVisible,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: IconButton(
                                            onPressed: () {
                                              deleteNotify(data.id);
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
                              data.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30, left: 40),
                            child: Row(
                              children: [
                                Text(
                                  '${data.distance} km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                Switch(
                                  value: data.isOn,
                                  onChanged: (value) {
                                    setState(() {
                                      data.isOn = value;
                                      data.isVisible = !value;
                                    });
                                    // updateNotify(data.id, data.isOn);
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor:
                                      const Color.fromARGB(255, 30, 232, 8),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add',
        tooltip: 'Add Notification',
        onPressed: () {
          Navigator.of(context).pushNamed('notify-data');
        },
        backgroundColor: const Color.fromARGB(255, 20, 19, 19),
        child: const Icon(
          Icons.add,
          color: Colors.green,
          size: 45,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: const Color.fromARGB(255, 20, 19, 19),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: FloatingActionButton(
                heroTag: 'home',
                tooltip: 'Home',
                onPressed: () {
                  Navigator.of(context).pushNamed('home_screen');
                },
                backgroundColor: const Color.fromARGB(255, 20, 19, 19),
                child: const Icon(
                  Icons.home,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ),
            Expanded(
              child: FloatingActionButton(
                heroTag: 'users',
                tooltip: 'Saved Contacts',
                onPressed: () {
                  Navigator.of(context).pushNamed('user');
                },
                backgroundColor: const Color.fromARGB(255, 20, 19, 19),
                child: const Icon(
                  Icons.person,
                  color: Colors.green,
                  size: 45,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
