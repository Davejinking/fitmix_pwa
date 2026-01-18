import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/tactical_exercise_list.dart';

/// 🔥 REFACTORED: Exercise Selection Page using TacticalExerciseList
/// 
/// This page now reuses the same polished UI from the Library tab,
/// but in Selection Mode (with checkmarks and confirmation button).
class ExerciseSelectionPageV2 extends StatelessWidget {
  const ExerciseSelectionPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.selectExercise.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'Courier',
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: TacticalExerciseList(
        isSelectionMode: true,
        onExercisesSelected: (selectedExercises) {
          // Return selected exercises to caller
          Navigator.pop(context, selectedExercises);
        },
      ),
    );
  }
}
