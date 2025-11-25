import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/error_handler.dart';
import '../data/exercise_library_repo.dart';
import '../l10n/app_localizations.dart';

class LibraryPage extends StatefulWidget {
  final ExerciseLibraryRepo exerciseRepo;

  const LibraryPage({super.key, required this.exerciseRepo});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<Map<String, List<String>>> _libraryFuture;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  void _loadLibrary() {
    setState(() {
      _libraryFuture = widget.exerciseRepo.getLibrary();
    });
  }

  Future<void> _showEditDialog({String? oldBodyPart, String? oldExerciseName}) async {
    final l10n = AppLocalizations.of(context);
    final isEditing = oldBodyPart != null && oldExerciseName != null;
    final nameController = TextEditingController(text: oldExerciseName ?? '');
    String selectedBodyPart = oldBodyPart ?? AppConstants.bodyParts.first;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? l10n.editExercise : l10n.addExercise),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.exerciseName),
                  ),
                  DropdownButton<String>(
                    value: selectedBodyPart,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBodyPart = newValue!;
                      });
                    },
                    items: AppConstants.bodyParts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) return;

                try {
                  if (isEditing) {
                    await widget.exerciseRepo.updateExercise(oldBodyPart, oldExerciseName, selectedBodyPart, newName);
                  } else {
                    await widget.exerciseRepo.addExercise(selectedBodyPart, newName);
                  }
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ErrorHandler.showErrorSnackBar(context, l10n.saveFailed);
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _loadLibrary();
    }
  }

  Future<void> _deleteExercise(String bodyPart, String exerciseName) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      l10n.deleteExercise,
      l10n.deleteExerciseConfirm(exerciseName),
    );

    if (confirmed && mounted) {
      try {
        await widget.exerciseRepo.deleteExercise(bodyPart, exerciseName);
        _loadLibrary();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, l10n.deleteFailed);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ライブラリ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  onPressed: () => _showEditDialog(),
                ),
              ],
            ),
          ),
          // 본문
          Expanded(
            child: FutureBuilder<Map<String, List<String>>>(
        future: _libraryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context).errorOccurred(snapshot.error.toString())));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).libraryEmpty));
          }

          final library = snapshot.data!;
          return ListView(
            children: library.entries.map((entry) {
              final bodyPart = entry.key;
              final exercises = entry.value;
              return ExpansionTile(
                title: Text(bodyPart, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: exercises.map((exerciseName) {
                  return ListTile(
                    title: Text(exerciseName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditDialog(oldBodyPart: bodyPart, oldExerciseName: exerciseName),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _deleteExercise(bodyPart, exerciseName),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
      ),
        ],
      ),
    );
  }
}
