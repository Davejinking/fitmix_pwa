import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ExerciseFilterModal extends StatefulWidget {
  final Set<String> selectedMuscles;
  final Set<String> selectedEquipment;
  final Function(Set<String> muscles, Set<String> equipment) onApply;

  const ExerciseFilterModal({
    super.key,
    required this.selectedMuscles,
    required this.selectedEquipment,
    required this.onApply,
  });

  @override
  State<ExerciseFilterModal> createState() => _ExerciseFilterModalState();
}

class _ExerciseFilterModalState extends State<ExerciseFilterModal> {
  late Set<String> _selectedMuscles;
  late Set<String> _selectedEquipment;

  // Keys for internal logic (lowercase for consistency with exercise data)
  final List<String> _muscleKeys = [
    'chest',
    'back',
    'shoulders',
    'legs',
    'arms',
    'abs',
    'cardio',
  ];

  final List<String> _equipmentKeys = [
    'barbell',
    'dumbbell',
    'cable',
    'machine',
    'bodyweight',
    'kettlebell',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMuscles = Set.from(widget.selectedMuscles);
    _selectedEquipment = Set.from(widget.selectedEquipment);
  }

  void _reset() {
    setState(() {
      _selectedMuscles.clear();
      _selectedEquipment.clear();
    });
  }

  void _apply() {
    widget.onApply(_selectedMuscles, _selectedEquipment);
    Navigator.pop(context);
  }

  // Helper to get localized muscle name
  String _getLocalizedMuscle(String key, AppLocalizations l10n) {
    switch (key.toLowerCase()) {
      case 'chest': return l10n.chest;
      case 'back': return l10n.back;
      case 'shoulders': return l10n.shoulders;
      case 'legs': return l10n.legs;
      case 'arms': return l10n.arms;
      case 'abs': return l10n.abs;
      case 'cardio': return l10n.cardio;
      default: return key.toUpperCase();
    }
  }

  // Helper to get localized equipment name
  String _getLocalizedEquipment(String key, AppLocalizations l10n) {
    switch (key.toLowerCase()) {
      case 'barbell': return l10n.barbell;
      case 'dumbbell': return l10n.dumbbell;
      case 'cable': return l10n.cable;
      case 'machine': return l10n.machine;
      case 'bodyweight': return l10n.bodyweight;
      case 'kettlebell': return l10n.kettlebell;
      default: return key.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF101622).withValues(alpha: 0.95),
            const Color(0xFF0A0E16),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF0D59F2).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            height: 24,
            alignment: Alignment.center,
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF0D59F2).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF0D59F2)),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    l10n.filterParameters,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      fontFamily: 'Courier',
                      shadows: [
                        Shadow(
                          color: const Color(0xFF0D59F2).withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    l10n.reset,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D59F2),
                      letterSpacing: 1.5,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Target Muscle Section
                  _buildSection(
                    l10n.targetMuscle,
                    _muscleKeys,
                    _selectedMuscles,
                    (muscle) {
                      setState(() {
                        if (_selectedMuscles.contains(muscle)) {
                          _selectedMuscles.remove(muscle);
                        } else {
                          _selectedMuscles.add(muscle);
                        }
                      });
                    },
                    l10n,
                    true, // isMuscle
                  ),

                  const SizedBox(height: 24),

                  // Equipment Type Section
                  _buildSection(
                    l10n.equipmentType,
                    _equipmentKeys,
                    _selectedEquipment,
                    (equipment) {
                      setState(() {
                        if (_selectedEquipment.contains(equipment)) {
                          _selectedEquipment.remove(equipment);
                        } else {
                          _selectedEquipment.add(equipment);
                        }
                      });
                    },
                    l10n,
                    false, // isEquipment
                  ),

                  const SizedBox(height: 32),

                  // Tactical Control Bar
                  _buildTacticalControlBar(l10n),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Accent
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0D59F2).withValues(alpha: 0.2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFF0D59F2),
                  ),
                ),
                Expanded(flex: 2, child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> items,
    Set<String> selectedItems,
    Function(String) onTap,
    AppLocalizations l10n,
    bool isMuscle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header - Tactical style with glowing indicator
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF0D59F2),
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D59F2).withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Chips - Blue Neon Style (matching Add Exercise Modal)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            final localizedLabel = isMuscle 
                ? _getLocalizedMuscle(item, l10n)
                : _getLocalizedEquipment(item, l10n);
            
            return GestureDetector(
              onTap: () => onTap(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF0D59F2).withValues(alpha: 0.2) 
                      : const Color(0xFF1A1A1A),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF0D59F2) 
                        : const Color(0xFF27272A),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0D59F2).withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  localizedLabel.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF71717A),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontFamily: 'Courier',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTacticalControlBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: InkWell(
          onTap: _apply,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Premium Blue Gradient
              gradient: const LinearGradient(
                colors: [Color(0xFF2962FF), Color(0xFF0039CB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // Glowing Effect
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2962FF).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              l10n.applyFilters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
