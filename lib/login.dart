import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'types.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/home.dart';

// Response object for login
// {
//   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzIiwiZW1haWwiOiJqb2huQHRhcmVudG8uY29tIiwiZXhwIjoxNzY4Mzk5MjU3fQ.R-tcaa1UUzddwbrA9Ie1Od7vWX0cprdWKaAuGGVym4I",
//   "token_type": "bearer",
//   "user": {
//     "id": 3,
//     "email": "john@tarento.com",
//     "name": "John Tarento",
//     "avatar_url": "/api/files/avatars/1767973057_tarento_group_logo.jpeg",
//     "bio": null,
//     "role": "project_manager"
//   }
// }
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJsonString(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return LoginResponse(
      accessToken: data['access_token'],
      tokenType: data['token_type'],
      user: User.fromJson(data['user']),
    );
  }
}

// A simple login page that interacts with the Launchpad API
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Set SharedPreferences user data
  Future<void> setUser(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', loginResponse.accessToken);
      await prefs.setString('token_type', loginResponse.tokenType);
      await prefs.setString('user', jsonEncode(loginResponse.user));
  }

  // Handle login to Launchpad API
  Future<void> _handleLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    print('Logging in with Email: $email, Password: $password');

    try {
      final response = await login(email, password);
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJsonString(response.body);
        await setUser(loginResponse);
        print('Login successful: ${loginResponse.user.name}');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        print('Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error logging in: $e");
    }
  }

  Future<http.Response> login(String email, String password) async {
    return http.post(Uri.parse('https://launchpad-api.tarento.dev/api/auth/login'),
      body: {'email': email, 'password': password});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleLogin(),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}