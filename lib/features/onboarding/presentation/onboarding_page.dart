import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/mission_onboarding_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/home_page.dart';
import '../../lesson/presentation/lesson_page.dart';
import 'widgets/dialogue_components.dart';

enum _OnboardingStep {
  teacherWelcome,
  picoGreeting,
  askName,
  teacherFollowUp,
  missionIntroduction,
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.missionId = 'mission_001',
    this.entryFromHome = false,
  });

  final String missionId;
  final bool entryFromHome;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _nameController = TextEditingController();
  final MissionOnboardingService _onboardingService = MissionOnboardingService();
  _OnboardingStep _step = _OnboardingStep.teacherWelcome;

  bool _showTyping = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() {
        _showTyping = false;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForStep(_step)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: _stepContent(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _stepActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case _OnboardingStep.teacherWelcome:
        return _DialogueStage(
          key: const ValueKey<String>('teacherWelcome'),
          avatar: const DialogueAvatar(
            role: DialogueAvatarRole.teacherSofia,
            teacherExpression: TeacherSofiaExpression.happy,
          ),
          bubbles: [
            if (_showTyping) const TypingIndicator(),
            if (!_showTyping)
              const TeacherBubble(
                message: 'Olá!\n\nBem-vindo à Escola da Amizade!',
              ),
          ],
        );
      case _OnboardingStep.picoGreeting:
        return const _DialogueStage(
          key: ValueKey<String>('picoGreeting'),
          avatar: DialogueAvatar(role: DialogueAvatarRole.pico),
          bubbles: [
            TeacherBubble(message: 'Olá!'),
          ],
        );
      case _OnboardingStep.askName:
        return _DialogueStage(
          key: const ValueKey<String>('askName'),
          avatar: const DialogueAvatar(
            role: DialogueAvatarRole.teacherSofia,
            teacherExpression: TeacherSofiaExpression.speaking,
          ),
          bubbles: [
            const TeacherBubble(
              message: 'Como te chamas?',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'O teu nome',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
      case _OnboardingStep.teacherFollowUp:
        final playerName = _normalizedName();
        return _DialogueStage(
          key: const ValueKey<String>('teacherFollowUp'),
          avatar: const DialogueAvatar(
            role: DialogueAvatarRole.teacherSofia,
            teacherExpression: TeacherSofiaExpression.encouraging,
          ),
          bubbles: [
            TeacherBubble(
              message: 'Prazer em conhecer-te, $playerName!',
            ),
            StudentBubble(
              message: 'Vamos começar!',
            ),
          ],
        );
      case _OnboardingStep.missionIntroduction:
        return _DialogueStage(
          key: const ValueKey<String>('missionIntro'),
          avatar: const DialogueAvatar(
            role: DialogueAvatarRole.teacherSofia,
            teacherExpression: TeacherSofiaExpression.thinking,
          ),
          bubbles: [
            const TeacherBubble(
              message: 'Missão 001: Primeiro Dia de Aula\n\nHoje vais aprender a cumprimentar em português europeu.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.speechBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '+20 XP',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.cardText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.favorite_rounded, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    '+10 Courage',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.cardText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _stepActions() {
    switch (_step) {
      case _OnboardingStep.teacherWelcome:
      case _OnboardingStep.picoGreeting:
      case _OnboardingStep.teacherFollowUp:
        return ContinueButton(
          label: 'Continuar',
          onPressed: _nextStep,
        );
      case _OnboardingStep.askName:
        return ContinueButton(
          label: 'Confirmar nome',
          onPressed: _normalizedName().isEmpty ? null : _nextStep,
        );
      case _OnboardingStep.missionIntroduction:
        return ContinueButton(
          label: 'Começar missão',
          onPressed: _startMission,
        );
    }
  }

  void _nextStep() {
    setState(() {
      _step = switch (_step) {
        _OnboardingStep.teacherWelcome => _OnboardingStep.picoGreeting,
        _OnboardingStep.picoGreeting => _OnboardingStep.askName,
        _OnboardingStep.askName => _OnboardingStep.teacherFollowUp,
        _OnboardingStep.teacherFollowUp => _OnboardingStep.missionIntroduction,
        _OnboardingStep.missionIntroduction => _OnboardingStep.missionIntroduction,
      };
    });
  }

  Future<void> _startMission() async {
    final prefs = await SharedPreferences.getInstance();
    final playerName = _normalizedName();
    if (playerName.isNotEmpty) {
      await prefs.setString('player_name', playerName);
    }
    await _onboardingService.markCompleted(widget.missionId);

    if (!mounted) return;
    if (widget.entryFromHome) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonPage(missionId: widget.missionId),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }

  String _titleForStep(_OnboardingStep step) {
    switch (step) {
      case _OnboardingStep.teacherWelcome:
        return 'Teacher Sofia Welcome';
      case _OnboardingStep.picoGreeting:
        return 'Pico Greeting';
      case _OnboardingStep.askName:
        return 'Conhecermo-nos';
      case _OnboardingStep.teacherFollowUp:
        return 'Vamos começar';
      case _OnboardingStep.missionIntroduction:
        return 'Mission Introduction';
    }
  }

  String _normalizedName() => _nameController.text.trim();
}

class _DialogueStage extends StatelessWidget {
  const _DialogueStage({
    super.key,
    required this.avatar,
    required this.bubbles,
  });

  final Widget avatar;
  final List<Widget> bubbles;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...bubbles,
            ],
          ),
        ),
      ],
    );
  }
}