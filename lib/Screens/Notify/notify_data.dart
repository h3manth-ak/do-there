import 'package:flutter/material.dart';
import 'package:location_based_reminder/Screens/Notify/add_user.dart';
import 'package:location_based_reminder/db/functions/db_functions.dart';
import 'package:location_based_reminder/db/models/db_models.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:geolocator/geolocator.dart';

class NotifyInput extends StatefulWidget {
  NotifyInput({Key? key}) : super(key: key);
  // Position position;

  @override
  State<NotifyInput> createState() => _NotifyInputState();
}

class _NotifyInputState extends State<NotifyInput> {
  final _distField = TextEditingController();
  final _locationField = TextEditingController();
  String? selectedName;
  bool _isVisible = false;
  String address = '';
  PickedData? pickeddata;
  Position? position;
  // Position position=Position.fromMap({'latitude': 37.4, 'longitude': -122.0});
  // var position ;

  // @override
  // void initState() {
  //   super.initState();
  //   selectedName = 'Self'; // Set default value as 'Self'
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
              shrinkWrap:true,
               children:[Padding(
                padding: EdgeInsets.only(top: 40, left: 20, right: 20),
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
                                  icon: Icon(Icons.add),
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
                        style: TextStyle(
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
                      child: Stack(children: [
                        TextFormField(
                          controller: _locationField,
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
                    ElevatedButton(
                      onPressed: ()  {
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
                            center: LatLong(9.851372,76.939540),
                            buttonColor: Colors.blue,
                            buttonText: 'Set Location',
                            onPicked: (pickedData) {
                              setState(() {
                                address = pickedData.address;
                                _locationField.text = address;
                                pickeddata=pickedData;
                              });
                              print(pickedData.latLong.latitude);
                              print(pickedData.latLong.longitude);
                              print(pickedData.address);
                              // getLocation();
                            }),
                      ),
                    )
                  ],
                ),
              ),]
            );
          },
        ),
      ),
    );
  }

  Future<void> onAddNotify() async {
    final _namedata = selectedName;
    final _locationdata = _locationField.text.trim();
    final _distdata = _distField.text.trim();
    
  print(_distdata);
  print(pickeddata);
  print(_locationdata);
    if (_locationdata.isEmpty || _distdata.isEmpty||pickeddata==null) {
      print('$_namedata $_locationdata $_distField $pickeddata');
      return;
    }

    else{
      print('$_namedata $_locationdata $_distdata $pickeddata');
    if (selectedName == null) {
      final _notifydb = NotifyModel(
        name: 'Self',
        distance: double.parse(_distdata),
        location: _locationdata,
        latitude:pickeddata!.latLong.latitude,
        longitude:pickeddata!.latLong.longitude,
      );
      addNotify(_notifydb);
    } else {
      final _notifydb = NotifyModel(
        name: selectedName!,
        distance: double.parse(_distdata),
        location: _locationdata,
        latitude:pickeddata!.latLong.latitude,
        longitude:pickeddata!.latLong.longitude
      );
      addNotify(_notifydb);
    }
    }
  }
//  Future<Position?> getLocation() async{

//     await Geolocator.checkPermission();
//     await Geolocator.requestPermission();

//     position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     print('position lat = ${position!.latitude}');
//     print('position long = ${position!.longitude}'); 
//     return position;
//   }
}
