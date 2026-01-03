import 'package:flutter/material.dart';
import '../data/exercise_library_repo.dart';
import '../models/exercise.dart';
import '../l10n/app_localizations.dart';

/// 공통 운동 선택 페이지
class ExerciseSelectionPage extends StatefulWidget {
  final ExerciseLibraryRepo exerciseRepo;
  
  const ExerciseSelectionPage({super.key, required this.exerciseRepo});

  @override
  State<ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  final List<Exercise> _selectedExercises = [];
  Map<String, List<String>> _library = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      final lib = await widget.exerciseRepo.getLibrary();
      if (mounted) setState(() { _library = lib; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleExercise(String name, String bodyPart) {
    setState(() {
      final index = _selectedExercises.indexWhere((e) => e.name == name);
      if (index >= 0) {
        _selectedExercises.removeAt(index);
      } else {
        _selectedExercises.add(Exercise(name: name, bodyPart: bodyPart));
      }
    });
  }

  bool _isSelected(String name) => _selectedExercises.any((e) => e.name == name);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(l10n.selectExercise),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedExercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF), 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedExercises.length}개', 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in _library.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  ...entry.value.map((name) {
                    final isSelected = _isSelected(name);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF007AFF).withValues(alpha: 0.2) 
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent, 
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          name, 
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF007AFF) : Colors.white, 
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle_outline, 
                          color: isSelected ? const Color(0xFF007AFF) : Colors.grey[600],
                        ),
                        onTap: () => _toggleExercise(name, entry.key),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ],
            ),
      bottomNavigationBar: _selectedExercises.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3), 
                    blurRadius: 8, 
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _selectedExercises),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    l10n.addExercises(_selectedExercises.length), 
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
    );
  }
}
