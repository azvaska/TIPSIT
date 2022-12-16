import 'package:flutter/material.dart';

class RoomLogin extends StatefulWidget {
  const RoomLogin({super.key});

  @override
  State<RoomLogin> createState() => _RoomLoginState();
}

class _RoomLoginState extends State<RoomLogin> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false);
          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 50, bottom: 25),
                child: Text(
                  "Creare/Join Room",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      hintText: 'The name of the room'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 20),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password for the room'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    // height: 50,
                    width: 100,
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                  Container(
                    // height: 50,
                    width: 100,

                    decoration: const BoxDecoration(color: Colors.blue),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Join',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 130,
              ),
              const Text('New User? Create Account')
            ],
          ),
        ),
      ),
    );
  }
}
