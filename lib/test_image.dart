import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Testing JFIF Image', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/teams/betis.jfif',
                width: 100,
                height: 100,
                errorBuilder: (c, e, s) => const Text('Error loading image', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
