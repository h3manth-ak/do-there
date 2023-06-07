import 'package:flutter/material.dart';
import 'package:location_based_reminder/db/functions/db_functions.dart';
import 'package:location_based_reminder/db/models/db_models.dart';

class AddUser extends StatelessWidget {
  AddUser({super.key});
  final _name=TextEditingController();
  final _phone=TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black87,
      body:
      
      SafeArea(
        
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  hintText: 'Enter Name',
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
               
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _phone,

                decoration: InputDecoration(
                  hintText: 'Enter Phone',
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                  
              
               
              ),
            ),
            ElevatedButton(onPressed: (){
              onAddUser();
              Navigator.of(context).pushNamed('notify-data');
            }, child: Text('Add User'))
          ],
        ),
      )
    );
  }
  Future<void> onAddUser() async{
    final _namedata=_name.text.trim();
    final _phonedata=_phone.text.trim();
    if(_namedata.isEmpty || _phonedata.isEmpty){
      return;
    }
    print('$_namedata $_phonedata');
    final _userDb=UserModel(name: _namedata, phno: _phonedata);
    // AddUser(_userDb);
    userAdd(_userDb);
  }
}