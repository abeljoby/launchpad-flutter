import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launchpad/providers/auth_provider.dart';

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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      final response = await login(email, password);
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJsonString(response.body);

        // Update state via provider. This will trigger MyApp rebuild and switch to Home.
        await ref
            .read(authProvider.notifier)
            .login(loginResponse.accessToken, loginResponse.user);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error logging in: $e")));
      }
    }
  }

  Future<http.Response> login(String email, String password) async {
    return http.post(
      Uri.parse('https://launchpad-api.tarento.dev/api/auth/login'),
      body: {'email': email, 'password': password},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter password' : null,
              ),
              const SizedBox(height: 20),
              authState.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Login'),
                    ),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
