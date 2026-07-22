import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: const SafeArea(
        child: Center(child: Text('Uygulama ayarlari yakinda buraya gelecek.')),
      ),
    );
  }
}
