import 'package:flutter/material.dart';

import '../../../../../shared/widgets/primary_button.dart';

class SceneActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLarge;

  const SceneActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: label,
      onPressed: onPressed,
      isLarge: isLarge,
    );
  }
}
