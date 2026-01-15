import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth.dart';
import 'package:flutter_application_1/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'types.dart';
import 'package:flutter_application_1/edit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? _user;

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        _user = User.fromJson(jsonDecode(userJson));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> _handleLogout() async {
    await logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _handleEdit() async {
    // var res = await http.get(
    //   Uri.parse('https://launchpad-api.tarento.dev/api/auth/me'),
    // );
    // print(res.body);

    final result = await showDialog<User>(
      context: context,
      builder: (context) => Edit(user: _user),
    );

    if (result != null) {
      setState(() {
        _user = result;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Welcome, ${_user!.name}'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: .start,
          spacing: 48,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                const Text(
                  'Your Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _handleEdit,
                ),
              ],
            ),
            Center(
              child: Column(
                spacing: 24,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      'https://launchpad-api.tarento.dev${_user!.avatarUrl}',
                    ),
                  ),
                  Text(
                    _user!.name,
                    style: TextStyle(fontSize: 16, fontWeight: .w600),
                  ),
                  Column(
                    children: [
                      Text("ID: ${_user!.id}"),
                      Text("Role: ${_user!.role}"),
                      Text("Email: ${_user!.email}"),
                      if (_user?.bio != null && _user!.bio!.isNotEmpty)
                        Text("About: ${_user!.bio}"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
