import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launchpad/providers/auth_provider.dart';
import 'types.dart';
import 'package:launchpad/edit.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  @override
  void initState() {
    super.initState();
    // User is already loaded by AuthProvider
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    // No need to navigate manually, MyApp will switch to LoginPage
  }

  Future<void> _handleEdit(User currentUser) async {
    final result = await showDialog<User>(
      context: context,
      builder: (context) => Edit(user: currentUser),
    );

    if (result != null) {
      await ref.read(authProvider.notifier).updateUser(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Welcome, ${user.name}'),
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
                  onPressed: () => _handleEdit(user),
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
                      'https://launchpad-api.tarento.dev${user.avatarUrl}',
                    ),
                  ),
                  Text(
                    user.name,
                    style: TextStyle(fontSize: 16, fontWeight: .w600),
                  ),
                  Column(
                    children: [
                      Text("ID: ${user.id}"),
                      Text("Role: ${user.role}"),
                      Text("Email: ${user.email}"),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Text("About: ${user.bio!}"),
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
