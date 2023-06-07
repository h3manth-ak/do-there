import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import '../../db/functions/db_functions.dart';
import '../../db/models/db_models.dart';

class IpFormField extends StatefulWidget {
  IpFormField({super.key});

  @override
  State<IpFormField> createState() => _IpFormFieldState();
}

class _IpFormFieldState extends State<IpFormField> {
  final _task = TextEditingController();

  final _location = TextEditingController();
  bool _isVisible = false;
  String address = '';
  PickedData? pickeddata;
  Position? position;

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
        child:ListView(
          shrinkWrap:true,
          children: [Padding(
            padding:EdgeInsets.only(top: 40,left: 20,right: 20) ,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 15),
                child: TextFormField(
                controller:_task ,
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
              padding: const EdgeInsets.only(top: 10,bottom: 15),
              child: Stack(children: [
                          TextFormField(
                            controller: _location,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              // suffixIcon: Icon(Icons.location_on_outlined),
                              hintText: 'Choose Location',
                              labelText: 'Location',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          Positioned(
                              top: 1,
                              right: 1,
                              bottom: 1,
                              // left: 1,
                              child: IconButton(
                                onPressed: () async {
                                  // position =await getLocation() ;
                                  // print(position);
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                  
                                },
                                icon: Icon(Icons.location_on_outlined),
                              ))
                        ]),
            ),
            ElevatedButton(onPressed: (){
              
              onAddTask();
              Navigator.of(context).pushNamed('reminder_home');
              //onAddTask();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent, // Background color
            ),
             child: Text('Submit',style: TextStyle(fontSize: 19),)),
             Visibility(
                        visible: _isVisible,
                        child: SizedBox(
                          height: 450,
                          child: OpenStreetMapSearchAndPick(
                              center: LatLong(9.851372,76.939540),
                              buttonColor: Colors.blue,
                              buttonText: 'Set Location',
                              onPicked: (pickedData) {
                                setState(() {
                                  address = pickedData.address;
                                  _location.text = address;
                                  pickeddata=pickedData;
                                });
                                print(pickedData.latLong.latitude);
                                print(pickedData.latLong.longitude);
                                print(pickedData.address);
                                // getLocation();
                              }),
                        ),
                      )
            ]),
            ),]
        )
        ),
    );
  }

  Future<void>onAddTask() async{
    final _taskdata=_task.text.trim();
    final _locationdata=_location.text.trim();
    final lat=pickeddata!.latLong.latitude;
    final long=pickeddata!.latLong.longitude;
    if(_taskdata.isEmpty || _locationdata.isEmpty||pickeddata==null){
      return;
    }

    print('$_taskdata $_locationdata');
    print(lat);
    print(long);
    final _taskdb=TaskModel(task: _taskdata, location: _locationdata,latitude: lat,longitude: long);
    addTask(_taskdb);

  //  final _student =StudentModel(name: _task, age: _location);
  //   addStudent(_student);
  }
}
