import 'package:flutter/material.dart';
import 'exercise_set_card.dart';

class ExerciseSetCardDemo extends StatefulWidget {
  const ExerciseSetCardDemo({super.key});

  @override
  State<ExerciseSetCardDemo> createState() => _ExerciseSetCardDemoState();
}

class _ExerciseSetCardDemoState extends State<ExerciseSetCardDemo> {
  List<SetData> sets = [];

  @override
  void initState() {
    super.initState();
    // Initialize with 3 sets
    _addSet();
    _addSet();
    _addSet();
  }

  @override
  void dispose() {
    for (var set in sets) {
      set.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      sets.add(SetData());
    });
  }

  void _deleteLastSet() {
    if (sets.isNotEmpty) {
      setState(() {
        sets.last.dispose();
        sets.removeLast();
      });
    }
  }

  void _deleteSet(int index) {
    if (index >= 0 && index < sets.length) {
      setState(() {
        sets[index].dispose();
        sets.removeAt(index);
      });
    }
  }

  String _calculateTotalVolume() {
    double total = 0;
    for (var set in sets) {
      final kg = double.tryParse(set.kgController.text) ?? 0;
      final reps = double.tryParse(set.repsController.text) ?? 0;
      total += kg * reps;
    }
    return '${total.toStringAsFixed(0)}kg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      appBar: AppBar(
        title: const Text('Exercise Set Card Demo'),
        backgroundColor: const Color(0xFF252932),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ExerciseSetCard(
          exerciseNumber: '1',
          category: '하체',
          exerciseName: '스모 데드리프트',
          totalVolume: _calculateTotalVolume(),
          memo: '',
          sets: sets,
          onAddSet: _addSet,
          onDeleteLastSet: _deleteLastSet,
          onDeleteSet: _deleteSet,
        ),
      ),
    );
  }
}
