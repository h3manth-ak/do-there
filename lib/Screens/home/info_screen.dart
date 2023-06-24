import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('User Guide'),
        backgroundColor:Colors.black87,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.message, color: Colors.green),
                title: Text('Allow SMS Permission', style: TextStyle(color: Colors.white)),
                subtitle: Text('Step 1: Open Settings', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward, color: Colors.green),
                title: Text('Step 2: Go to App Permissions', style: TextStyle(color: Colors.white)),
                subtitle: Text('Find and tap on "App Permissions"', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.message, color: Colors.green),
                title: Text('Step 3: Enable SMS Permission', style: TextStyle(color: Colors.white)),
                subtitle: Text('Locate "SMS" and enable the permission', style: TextStyle(color: Colors.white)),
              ),
              Divider(color: Colors.white),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.green),
                title: Text('Allow Notification Permission', style: TextStyle(color: Colors.white)),
                subtitle: Text('Step 4: Open Settings', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward, color: Colors.green),
                title: Text('Step 5: Go to App Permissions', style: TextStyle(color: Colors.white)),
                subtitle: Text('Find and tap on "App Permissions"', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.green),
                title: Text('Step 6: Enable Notification Permission', style: TextStyle(color: Colors.white)),
                subtitle: Text('Locate "Notifications" and enable the permission', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward, color: Colors.green),
                title: Text('Step 7: Enable Notification Access', style: TextStyle(color: Colors.white)),
                subtitle: Text('Find and enable your app under "Notification Access"', style: TextStyle(color: Colors.white)),
              ),
              Divider(color: Colors.white),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text('Allow Location Permission', style: TextStyle(color: Colors.white)),
                subtitle: Text('Step 8: Swipe down from the top of the screen', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward, color: Colors.green),
                title: Text('Step 9: Touch and hold Location', style: TextStyle(color: Colors.white)),
                subtitle: Text('If you don\'t find Location, tap Edit or Settings. Then drag Location into your Quick Settings.', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text('Step 10: Tap App Location Permissions', style: TextStyle(color: Colors.white)),
                subtitle: Text('Under "Allowed all the time," "Allowed only while in use," and "Not allowed," find the apps that can use your phone\'s location.', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward, color: Colors.green),
                title: Text('Step 11: Change Location Access', style: TextStyle(color: Colors.white)),
                subtitle: Text('To change the app\'s permissions, tap it. Then, choose the location access for the app.', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.green),
                title: Text('Tip: If these steps don’t work for you, get help from your device manufacturer.', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
