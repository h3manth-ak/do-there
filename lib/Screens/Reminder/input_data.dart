import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import '../../db/functions/db_functions.dart';
import '../../db/models/db_models.dart';

class IpFormField extends StatefulWidget {
  IpFormField({Key? key}) : super(key: key);

  @override
  State<IpFormField> createState() => _IpFormFieldState();
}

class _IpFormFieldState extends State<IpFormField> {
  final _task = TextEditingController();
  final _location = TextEditingController();
  DateTime? _selectedDate; // Updated date field
  final _dateField = TextEditingController();

  String _selectedCategory = 'Buy'; // Default category value

  bool _isVisible = false;
  String address = '';
  PickedData? pickeddata;
  Position? position;

  List<String> categories = ['Buy', 'Visit', 'Other']; // Dropdown categories

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Reminder',
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
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 15),
                    child: TextFormField(
                      controller: _task,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter Task',
                        labelText: 'Task',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 15),
                    child: Stack(
                      children: [
                        TextFormField(
                          controller: _location,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
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
                            onPressed: () async {
                              setState(() {
                                _isVisible = !_isVisible;
                              });
                            },
                            icon: Icon(Icons.location_on_outlined),
                          ),
                        )
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 15),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onAddTask();
                      Navigator.of(context).pushNamed('reminder_home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    child: Text(
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
                            _location.text = address;
                            pickeddata = pickedData;
                          });
                          print(pickedData.latLong.latitude);
                          print(pickedData.latLong.longitude);
                          print(pickedData.address);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Set the initial date
      firstDate: DateTime.now(), // Set the first selectable date
      lastDate: DateTime(2100), // Set the last selectable date
    );

    if (picked != null ) {
      setState(() {
        _dateField.text = picked.toString();
      });
    }
  }

  Future<void> onAddTask() async {
    final _taskdata = _task.text.trim();
    final _locationdata = _location.text.trim();
    final lat = pickeddata!.latLong.latitude;
    final long = pickeddata!.latLong.longitude;
    final category = _selectedCategory;
    final _datedata = _dateField.text.trim();


    if (_taskdata.isEmpty ||
        _locationdata.isEmpty ||
        pickeddata == null 
        ) {
      return;
    }

    final _taskdb = TaskModel(
      task: _taskdata,
      location: _locationdata,
      latitude: lat,
      longitude: long,
      date:DateTime.parse(_datedata), // Save the selected date
      category: category,
      id: Random().nextInt(123456789)
    );
    addTask(_taskdb);
  }
}
