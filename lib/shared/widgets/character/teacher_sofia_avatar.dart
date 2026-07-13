import 'package:flutter/material.dart';

import 'teacher_character.dart';

class TeacherSofiaAvatar extends StatelessWidget {
  const TeacherSofiaAvatar({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return TeacherCharacter(emotion: TeacherEmotion.smile, customSize: size);
  }
}
