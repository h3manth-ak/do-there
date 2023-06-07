import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('DO THERE',
            style:TextStyle(
              color: Colors.white54,
              fontSize: 20,
              fontStyle: FontStyle.italic
            )),
        backgroundColor: Colors.black45,
      ),
      body: SafeArea(
        
        child: Column(
        
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 160,
              bottom: 25,
            ),
            child: Center(
                child: Column(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.of(context).pushNamed('notify_home');
                  },
                  child:Container(
                  
                  height: 150,
                  width: 120,
                  decoration: BoxDecoration(
                      border: Border.all(
                        //<-- SEE HERE
                        width: 2,
                        color: Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                          image:AssetImage('assets/images/notify.webp'),
                          fit: BoxFit.contain)),
                    
                  
                ),
                ),
                



                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Notify',
                      style: TextStyle(color: Colors.white54, fontSize: 20)),
                )
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 70,
              bottom: 25,
            ),
            child: Center(
                child: Column(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.of(context).pushNamed('reminder_home');
                  },
                  child: Container(
                  height: 150,
                  width: 120,
                  decoration: BoxDecoration(
                      border: Border.all(
                        //<-- SEE HERE
                        width: 2,
                        color: Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      image:const DecorationImage(
                          image: AssetImage('assets/images/track-order.png'),
                          fit: BoxFit.contain)),
                  // child: Image.network(
                  //     'https://cdn-icons-png.flaticon.com/512/3799/3799832.png'),
                ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Reminder',
                      style: TextStyle(color: Colors.white54, fontSize: 20)),
                )
              ],
            )),
          ),
        ],
      )),
    );
  }
}
