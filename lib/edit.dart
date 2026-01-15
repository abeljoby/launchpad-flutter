import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launchpad/services/storage_service.dart';
import 'types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class Edit extends ConsumerStatefulWidget {
  final User? user;
  const Edit({super.key, required this.user});

  @override
  ConsumerState<Edit> createState() => _EditState();
}

class _EditState extends ConsumerState<Edit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _avatarUrlController;

  Future<void> handleUpload() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final storageService = ref.read(storageServiceProvider);
      final token = storageService.getToken();
      if (token != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://launchpad-api.tarento.dev/api/auth/upload/avatar'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(await http.MultipartFile.fromPath('file', image.path));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Updated Avatar Response Code: ${response.statusCode}');
        print('Updated Avatar Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          setState(() {
            _avatarUrlController.text = data['url'];
          });
        } else {
          throw Exception(
            'Failed to upload avatar: ${response.statusCode} ${response.body}',
          );
        }
      } else {
        throw Exception('No token found');
      }
    } catch (e) {
      print("Could not upload avatar: $e");
      rethrow;
    }
  }

  Future<void> updateProfile(User user) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final token = storageService.getToken();

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
          throw Exception(
            'Failed to update profile: ${response.statusCode} ${response.body}',
          );
        }
      } else {
        throw Exception('No token found');
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
    _avatarUrlController = TextEditingController(
      text: widget.user?.avatarUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
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
            Stack(
              clipBehavior:
                  Clip.none, // Ensures icon is visible even if it overlaps edge
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundImage: NetworkImage(
                    'https://launchpad-api.tarento.dev${_avatarUrlController.text}',
                  ),
                ),
                Positioned(
                  bottom: 0, // Adjusted for better visual alignment
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // Background for the icon to stand out
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Colors.white),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.upload, color: Colors.white),
                      onPressed: () => handleUpload(),
                    ),
                  ),
                ),
              ],
            ),
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
              minLines: 1,
              maxLines: 4,
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
                if (mounted) {
                  Navigator.of(context).pop(updatedUser);
                }
              } catch (e) {
                print("Failed to update profile: $e");
                // Optionally show error to user
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update profile: $e")),
                  );
                  Navigator.of(context).pop(null);
                }
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
