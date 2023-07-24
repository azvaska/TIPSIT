import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bacari/pages/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../main.dart';
import '../api_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _id = '';
  late Image _image;
  bool _isLoading = true;
  late ApiProvider apiProvider;

  @override
  void initState() {
    super.initState();
    apiProvider = Provider.of<ApiProvider>(context, listen: false);
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {

    var response = await apiProvider.makeBackendCall('profile', null);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      var imageResponse =
          await apiProvider.makeBackendCall('image/${(data['id'])}', null);

      if (imageResponse.statusCode == 200) {
        _image = Image.memory(imageResponse.bodyBytes);
      } else {
        _image = Image.asset('assets/default-avatar.jpg');
      }

      setState(() {
        _id = data['id'];
        _name = data['username'];
        _email = data['email'];
        _isLoading = false;
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _image.image,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _email,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ApiProvider.storage.delete(key: 'jwt_token');
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MyApp()));
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
