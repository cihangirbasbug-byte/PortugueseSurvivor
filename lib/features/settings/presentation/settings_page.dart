import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Ayarlar'),
      ),
      body: const SafeArea(
        child: Center(child: Text('Uygulama ayarlari yakinda buraya gelecek.')),
      ),
    );
  }
}
