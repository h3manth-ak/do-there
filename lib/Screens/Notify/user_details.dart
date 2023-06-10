import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../../db/functions/db_functions.dart';
import '../../db/models/db_models.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}


class _UserScreenState extends State<UserScreen> {
  // final ValueNotifier<List<UserModel>> userListNotifier =
  //     ValueNotifier<List<UserModel>>([]);

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    await getAllUser();
    userListNotifier.value = userListNotifier.value;
  }

  Future<void> deleteUser(UserModel user) async {
    final userDB = await Hive.openBox<UserModel>('user_db');
    await userDB.delete(user.id);
    userListNotifier.value = userListNotifier.value
        .where((existingUser) => existingUser.id != user.id)
        .toList();
  }

@override
Widget build(BuildContext context) {
  getAllUser();
  // print(userListNotifier.value);
  return Scaffold(
    backgroundColor: Colors.black87,
    appBar: AppBar(
      title: const Text('Guardian Details'),
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        ValueListenableBuilder(
          valueListenable: userListNotifier,
          builder: (BuildContext context, List<UserModel> userList, Widget? child) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return Card(
                  elevation: 2,
                  color: const Color.fromARGB(255, 39, 39, 39),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 15,
                        ),
                        
                        Text(
                          user.phno,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => deleteUser(user),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}


}
