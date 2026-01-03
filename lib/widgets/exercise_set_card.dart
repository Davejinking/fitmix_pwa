import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ExerciseSetCard extends StatefulWidget {
  final String exerciseNumber;
  final String category;
  final String exerciseName;
  final String totalVolume;
  final String? memo;
  final List<SetData> sets;
  final VoidCallback? onAddSet;
  final VoidCallback? onDeleteLastSet;
  final Function(int index)? onDeleteSet;

  const ExerciseSetCard({
    super.key,
    required this.exerciseNumber,
    required this.category,
    required this.exerciseName,
    this.totalVolume = '0kg',
    this.memo,
    this.sets = const [],
    this.onAddSet,
    this.onDeleteLastSet,
    this.onDeleteSet,
  });

  @override
  State<ExerciseSetCard> createState() => _ExerciseSetCardState();
}

class _ExerciseSetCardState extends State<ExerciseSetCard> {
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.memo);
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252932),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Title Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.exerciseNumber,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' ${widget.category} | ${widget.exerciseName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
            ],
          ),
          const SizedBox(height: 12),

          // Sub-Info Row
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).totalVolumeShort(widget.totalVolume.replaceAll('kg', '')),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context).recentRecord,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Memo Field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF323844),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _memoController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).memo,
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Column Headers
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context).setLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'kg',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  AppLocalizations.of(context).repsUnit,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context).completeLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Set Rows
          ...List.generate(
            widget.sets.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SetRow(
                setNumber: index + 1,
                data: widget.sets[index],
                onDelete: () => widget.onDeleteSet?.call(index),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Footer Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onDeleteLastSet,
                child: Text(
                  '- ${AppLocalizations.of(context).deleteSet}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                onPressed: widget.onAddSet,
                child: Text(
                  '+ ${AppLocalizations.of(context).addSet}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SetRow extends StatelessWidget {
  final int setNumber;
  final SetData data;
  final VoidCallback? onDelete;

  const SetRow({
    super.key,
    required this.setNumber,
    required this.data,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Set Number
        Expanded(
          flex: 2,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF5C6B7F),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '$setNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Kg Input
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: data.kgController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Reps Input
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: data.repsController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Delete Icon
        Expanded(
          flex: 2,
          child: IconButton(
            onPressed: onDelete,
            icon: const Icon(
              CupertinoIcons.trash,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class SetData {
  final TextEditingController kgController;
  final TextEditingController repsController;

  SetData({
    String? kg,
    String? reps,
  })  : kgController = TextEditingController(text: kg),
        repsController = TextEditingController(text: reps);

  void dispose() {
    kgController.dispose();
    repsController.dispose();
  }
}
