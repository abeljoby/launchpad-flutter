import 'package:flutter/material.dart';
import 'types.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Edit extends StatefulWidget {
  final User? user;
  const Edit({super.key, required this.user});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  Future<void> updateProfile(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null) {
        final response = await http.put(
          Uri.parse('https://launchpad-api.tarento.dev/api/auth/me'),
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: {
            'name': user.name,
            'bio': user.bio ?? '',
            'avatar_url': user.avatarUrl,
          },
        );
        
        print('Update Profile Response Code: ${response.statusCode}');
        print('Update Profile Response Body: ${response.body}');

        if (response.statusCode != 200) {
          throw Exception('Failed to update profile: ${response.statusCode} ${response.body}');
        }
      }
    } catch (e) {
      print("Could not update profile: $e");
      rethrow; 
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _bioController = TextEditingController(text: widget.user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              User updatedUser = User(
                id: widget.user!.id,
                email: widget.user!.email,
                name: _nameController.text,
                avatarUrl: widget.user!.avatarUrl,
                bio: _bioController.text,
                role: widget.user!.role,
              );
              try {
                await updateProfile(updatedUser);
              } catch (e) {
                print("Failed to update profile: $e");
                Navigator.of(context).pop(null);
              }
              Navigator.of(context).pop(updatedUser);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
