import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launchpad/login.dart';
import 'package:launchpad/home.dart';
import 'package:launchpad/services/storage_service.dart';
import 'package:launchpad/providers/auth_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();

  // Initialize StorageService
  final storageService = StorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Launchpad',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: authState.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (authState.isAuthenticated ? const Home() : const LoginPage()),
    );
  }
}
