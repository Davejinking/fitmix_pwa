import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import 'exercise_log_card.dart';

/// Demo page to showcase ExerciseLogCard widget
class ExerciseLogCardDemo extends StatelessWidget {
  const ExerciseLogCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final squatExercise = Exercise(
      name: 'Squat',
      bodyPart: 'Legs',
      sets: [
        ExerciseSet(weight: 60.0, reps: 10, isCompleted: true),
        ExerciseSet(weight: 80.0, reps: 8, isCompleted: true),
        ExerciseSet(weight: 100.0, reps: 6, isCompleted: true), // PR
        ExerciseSet(weight: 100.0, reps: 5, isCompleted: true), // PR
        ExerciseSet(weight: 90.0, reps: 8, isCompleted: true),
      ],
    );

    final benchPressExercise = Exercise(
      name: 'Bench Press',
      bodyPart: 'Chest',
      sets: [
        ExerciseSet(weight: 50.0, reps: 12, isCompleted: true),
        ExerciseSet(weight: 60.0, reps: 10, isCompleted: true),
        ExerciseSet(weight: 70.0, reps: 8, isCompleted: true),
        ExerciseSet(weight: 75.0, reps: 6, isCompleted: true), // PR
      ],
    );

    final deadliftExercise = Exercise(
      name: 'Deadlift',
      bodyPart: 'Back',
      sets: [
        ExerciseSet(weight: 100.0, reps: 5, isCompleted: true),
        ExerciseSet(weight: 120.0, reps: 5, isCompleted: true),
        ExerciseSet(weight: 140.0, reps: 3, isCompleted: true), // PR
        ExerciseSet(weight: 140.0, reps: 2, isCompleted: true), // PR
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'Exercise Log Card Demo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                'WORKOUT LOG - 2026.01.10',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Exercise Log Cards
              ExerciseLogCard(
                exercise: squatExercise,
                personalRecord: 100.0, // PR weight
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Squat card tapped'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              
              ExerciseLogCard(
                exercise: benchPressExercise,
                personalRecord: 75.0, // PR weight
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bench Press card tapped'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              
              ExerciseLogCard(
                exercise: deadliftExercise,
                personalRecord: 140.0, // PR weight
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deadlift card tapped'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESIGN NOTES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Industrial/Noir aesthetic with sharp corners\n'
                      '• Monospaced font (Courier) for data alignment\n'
                      '• PR (Personal Record) highlighted in Orange\n'
                      '• Best weight displayed in Neon Blue badge\n'
                      '• Dark grey surface with subtle borders',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
