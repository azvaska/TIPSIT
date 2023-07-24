import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bacari/pages/homepage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'pages/api_provider.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const storage = FlutterSecureStorage();

  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ApiProvider(),
        child: MaterialApp(
// title: 'My App Demo',
          theme: ThemeData(
            primarySwatch: Colors.red, // change the color theme if needed
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    // final Future<String?> jwtToken = MyApp.storage.read(key: 'jwt_token');
    final Future<String?> jwtToken = ApiProvider.storage.read(key: 'jwt_token');
    return FutureBuilder<String?>(
      future: jwtToken,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 199, 84, 84),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: const Text(
                      'Bacari',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic, // make it italic
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.mail_outline,
                      size: 32,
                    ),
                    label: const Text(
                      'Sign in with Email',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // OutlinedButton.icon(
                  //   onPressed: () {},
                  //   icon: Image.asset(
                  //     'assets/google.png',
                  //     width: 32,
                  //     height: 32,
                  //   ),
                  //   label: const Text(
                  //     'Sign in with Google',
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       // color: Colors.white,
                  //     ),
                  //   ),
                  //   style: OutlinedButton.styleFrom(
                  //       padding: const EdgeInsets.symmetric(
                  //           vertical: 16, horizontal: 32),
                  //       side: const BorderSide(width: 2.0, color: Colors.white),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(25),
                  //       ),
                  //       backgroundColor: Colors.white),
                  // ),
                  // const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New to Bacari?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          // padding: const EdgeInsets.symmetric(
                          //     vertical: 16, horizontal: 32),
                          side: const BorderSide(
                              width: 2.0, color: Colors.yellow),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.yellow,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
          return Container(); // add a return statement here
        }
      },
    );
  }
}
