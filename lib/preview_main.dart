import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launchpad/home.dart';
import 'package:launchpad/login.dart';
import 'preview.dart';

void main() {
  runApp(ProviderScope(child: PreviewApp()));
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Preview',
      home: Scaffold(
        appBar: AppBar(title: const Text('Widget Preview')),
        body: Preview(
          pages: [
            // Add your widgets here for preview
            ('Home', (context) => Home()),
            ('Login', (context) => LoginPage()),
            // ('Edit Modal' (context) => EditModalPreview()),
          ],
          sizes: const [
            Size(320, 480), // Mobile
            Size(375, 667), // iPhone 8
            Size(414, 896), // iPhone 11 Pro Max
            Size(768, 1024), // Tablet
          ],
        ),
      ),
    );
  }
}
