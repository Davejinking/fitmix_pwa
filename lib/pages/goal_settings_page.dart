import 'package:flutter/material.dart';
import '../core/iron_theme.dart';
import '../widgets/common/iron_app_bar.dart';
import '../core/service_locator.dart';
import '../data/user_repo.dart';
import '../models/user_profile.dart';
import '../core/l10n_extensions.dart';

class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
  late UserRepo _userRepo;
  late TextEditingController _goalController;
  bool _isLoading = false;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _userRepo = getIt<UserRepo>();
    _goalController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    final profile = await _userRepo.getUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _goalController.text = profile?.monthlyWorkoutGoal.toString() ?? '20';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_userProfile == null) return;

    final newGoal = int.tryParse(_goalController.text);
    if (newGoal == null || newGoal <= 0 || newGoal > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.validWorkoutDaysGoal)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedProfile = _userProfile!.copyWith(
        monthlyWorkoutGoal: newGoal,
      );
      await _userRepo.saveUserProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.goalSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving goal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IronTheme.background,
      appBar: IronAppBar(
        title: 'Goal Settings',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTHLY WORKOUT GOAL',
                    style: TextStyle(
                      color: IronTheme.textMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: IronTheme.textHigh),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: IronTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: 'DAYS',
                      suffixStyle: TextStyle(color: IronTheme.textMedium),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IronTheme.primary,
                        foregroundColor: IronTheme.textHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SAVE GOAL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
