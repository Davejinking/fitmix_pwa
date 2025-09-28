import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/error_handler.dart';
import '../data/exercise_library_repo.dart';

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
    final isEditing = oldBodyPart != null && oldExerciseName != null;
    final nameController = TextEditingController(text: oldExerciseName ?? '');
    String selectedBodyPart = oldBodyPart ?? AppConstants.bodyParts.first;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? '운동 수정' : '운동 추가'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '운동 이름'),
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
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
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
                  Navigator.pop(context, true);
                } catch (e) {
                  ErrorHandler.showErrorSnackBar(context, '저장에 실패했습니다.');
                }
              },
              child: const Text('저장'),
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
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      '운동 삭제',
      '\'$exerciseName\' 운동을 삭제하시겠습니까?',
    );

    if (confirmed) {
      try {
        await widget.exerciseRepo.deleteExercise(bodyPart, exerciseName);
        _loadLibrary();
      } catch (e) {
        ErrorHandler.showErrorSnackBar(context, '삭제에 실패했습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, List<String>>>(
        future: _libraryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('운동 라이브러리가 비어있습니다.'));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
