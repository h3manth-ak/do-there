import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:location_based_reminder/Screens/home/info_screen.dart';

class Settings {
  static String name = ''; // Store the name here
  static String taskNotificationMusic = ''; // Store task notification music here
  static String purchaseNotificationMusic = ''; // Store purchase notification music here
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController nameController = TextEditingController();
  String selectedTaskMusic = '';
  String selectedPurchaseMusic = '';

  bool isEditing = false; // Track whether the name is being edited or not

  Future<void> pickMusic(bool isTaskMusic) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      setState(() {
        if (isTaskMusic) {
          selectedTaskMusic = filePath;
        } else {
          selectedPurchaseMusic = filePath;
        }
      });
    }
  }

  final AudioCache audioCache = AudioCache();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    nameController.text = Settings.name;
    selectedTaskMusic = Settings.taskNotificationMusic;
    selectedPurchaseMusic = Settings.purchaseNotificationMusic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Text(
                    Settings.name.isNotEmpty ? Settings.name[0].toUpperCase() : '',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Visibility(
                  visible: !isEditing,
                  child: Text(
                    Settings.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Visibility(
                  visible: isEditing,
                  child: Expanded(
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.check : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        Settings.name = nameController.text;
                      }
                      isEditing = !isEditing;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Task Notification Music',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTaskMusic.isNotEmpty ? selectedTaskMusic : 'No music selected',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.folder_open,
                    color: Colors.amber,
                  ),
                  onPressed: () => pickMusic(true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Purchase Notification Music',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedPurchaseMusic.isNotEmpty ? selectedPurchaseMusic : 'No music selected',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open, color: Colors.amber),
                  onPressed: () => pickMusic(false),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            if (isEditing) {
              Settings.name = nameController.text;
            }
            isEditing = !isEditing;
          });
        },
        child: Icon(
          isEditing ? Icons.check : Icons.edit,
        ),
      ),
    );
  }
}

// class InfoScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       appBar: AppBar(
//         title: const Text(
//           'App Permissions',
//         ),
//       ),
//       // rest of the code...
//     );
//   }
// }
