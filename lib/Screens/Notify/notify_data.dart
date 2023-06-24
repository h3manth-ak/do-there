import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location_based_reminder/Screens/Notify/add_user.dart';
import 'package:location_based_reminder/db/functions/db_functions.dart';
import 'package:location_based_reminder/db/models/db_models.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';

class NotifyInput extends StatefulWidget {
  NotifyInput({Key? key}) : super(key: key);

  @override
  State<NotifyInput> createState() => _NotifyInputState();
}

class _NotifyInputState extends State<NotifyInput> {
  final _distField = TextEditingController();
  final _locationField = TextEditingController();
  final _dateField = TextEditingController();
  String? selectedName;
  bool _isVisible = false;
  String address = '';
  PickedData? pickeddata;
  Position? position;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Notification',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: ValueListenableBuilder<List<UserModel>>(
          valueListenable: userListNotifier,
          builder: (BuildContext ctx, List<UserModel> userList, Widget? child) {
            List<String> data = userList.map((user) => user.name).toList();

            List<DropdownMenuItem<String>> dropdownItems = data.map((name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList();

            return ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: DropdownButtonFormField<String>(
                          value: selectedName,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 2),
                            ),
                            labelText: 'Select a name',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey,
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedName = value!;
                            });
                          },
                          items: [
                            ...dropdownItems,
                            DropdownMenuItem<String>(
                              value: 'Add New Name',
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (ctx) {
                                          return AddUser();
                                        }),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: TextFormField(
                          controller: _distField,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Before',
                            labelText: 'Before',
                            border: OutlineInputBorder(),
                            suffixText: 'km',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: _locationField,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Choose Location',
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            Positioned(
                              top: 1,
                              right: 1,
                              bottom: 1,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                },
                                icon: const Icon(Icons.location_on_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: TextFormField(
                          controller: _dateField,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Date',
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () {
                            _selectDate(context);
                          },
                          readOnly: true,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onAddNotify();
                          Navigator.of(context).pushNamed('notify_home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 19),
                        ),
                      ),
                      Visibility(
                        visible: _isVisible,
                        child: SizedBox(
                          height: 450,
                          child: OpenStreetMapSearchAndPick(
                            center: LatLong(9.851372, 76.939540),
                            buttonColor: Colors.blue,
                            buttonText: 'Set Location',
                            onPicked: (pickedData) {
                              setState(() {
                                address = pickedData.address;
                                _locationField.text = address;
                                pickeddata = pickedData;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateField.text = picked.toString();
      });
    }
  }

  Future<void> onAddNotify() async {
    final _namedata = selectedName;
    final _locationdata = _locationField.text.trim();
    final _distdata = _distField.text.trim();
    final _datedata = _dateField.text.trim();

    if (_locationdata.isEmpty || _distdata.isEmpty || pickeddata == null ) {
      return;
    } else {
      if (selectedName == null) {
        final _notifydb = NotifyModel(
          name: 'Self',
          distance: double.parse(_distdata),
          location: _locationdata,
          date: DateTime.parse(_datedata),
          latitude: pickeddata!.latLong.latitude,
          longitude: pickeddata!.latLong.longitude,
          id: Random().nextInt(123456789),
        );
        addNotify(_notifydb);
      } else {
        final _notifydb = NotifyModel(
          name: selectedName!,
          distance: double.parse(_distdata),
          location: _locationdata,
          date: DateTime.parse(_datedata),
          latitude: pickeddata!.latLong.latitude,
          longitude: pickeddata!.latLong.longitude,
          id: Random().nextInt(123456789),
        );
        addNotify(_notifydb);
      }
    }
  }
}
