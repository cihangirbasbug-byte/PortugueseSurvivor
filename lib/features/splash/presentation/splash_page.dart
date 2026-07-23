import 'dart:async';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.language, size: 90, color: Color(0xFF0E8A4B)),
            SizedBox(height: 30),
            Text(
              'Portuguese Survivor',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F35),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Learn Portuguese.\nLive Portugal.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
