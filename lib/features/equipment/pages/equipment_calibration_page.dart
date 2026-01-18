import 'package:flutter/material.dart';

/// Calibration tool for fine-tuning equipment slot positions
/// Use this page to adjust alignment coordinates before finalizing
class EquipmentCalibrationPage extends StatefulWidget {
  const EquipmentCalibrationPage({super.key});

  @override
  State<EquipmentCalibrationPage> createState() => _EquipmentCalibrationPageState();
}

class _EquipmentCalibrationPageState extends State<EquipmentCalibrationPage> {
  // Adjustable coordinates for each slot
  final Map<String, Alignment> _slotPositions = {
    'head': const Alignment(-0.35, -0.78),
    'neck': const Alignment(0.35, -0.78),
    'mainHand': const Alignment(-0.82, -0.25),
    'offHand': const Alignment(0.82, -0.25),
    'gloves': const Alignment(-0.82, 0.15),
    'chest': const Alignment(0.82, 0.15),
    'legs': const Alignment(-0.25, 0.55),
    'boots': const Alignment(0.25, 0.55),
  };

  String? _selectedSlot;
  bool _showGrid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Equipment Calibration',
          style: TextStyle(
            fontFamily: 'Courier',
            color: Color(0xFFC7B377),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showGrid ? Icons.grid_on : Icons.grid_off,
              color: const Color(0xFFC7B377),
            ),
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.code,
              color: Color(0xFFC7B377),
            ),
            onPressed: _showCoordinates,
          ),
        ],
      ),
      body: Column(
        children: [
          // Main viewport
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background
                    Image.asset(
                      'assets/images/vertical_equipment_bg.jpg',
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF2A2520),
                          child: const Center(
                            child: Text(
                              'Background Image Not Found',
                              style: TextStyle(color: Color(0xFFD4C5A0)),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Debug Grid
                    if (_showGrid) _buildDebugGrid(),
                    
                    // Slots
                    ..._slotPositions.entries.map((entry) {
                      return _buildDraggableSlot(
                        slotKey: entry.key,
                        alignment: entry.value,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // Control Panel
          if (_selectedSlot != null) _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildDraggableSlot({
    required String slotKey,
    required Alignment alignment,
  }) {
    final isSelected = _selectedSlot == slotKey;
    
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSlot = slotKey;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _selectedSlot = slotKey;
            final renderBox = context.findRenderObject() as RenderBox;
            final size = renderBox.size;
            
            // Convert delta to alignment coordinates
            final dx = details.delta.dx / (size.width * 0.5) * (9 / 16);
            final dy = details.delta.dy / (size.height * 0.5);
            
            final currentAlignment = _slotPositions[slotKey]!;
            _slotPositions[slotKey] = Alignment(
              (currentAlignment.x + dx).clamp(-1.0, 1.0),
              (currentAlignment.y + dy).clamp(-1.0, 1.0),
            );
          });
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFC7B377).withValues(alpha: 0.5)
                : Colors.red.withValues(alpha: 0.3),
            border: Border.all(
              color: isSelected ? const Color(0xFFC7B377) : Colors.yellow,
              width: isSelected ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForSlot(slotKey),
                  size: 32,
                  color: const Color(0xFFD4C5A0),
                ),
                const SizedBox(height: 2),
                Text(
                  slotKey.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    final alignment = _slotPositions[_selectedSlot]!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1C1C1C),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adjusting: ${_selectedSlot!.toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC7B377),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'X (Horizontal)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Slider(
                      value: alignment.x,
                      min: -1.0,
                      max: 1.0,
                      activeColor: const Color(0xFFC7B377),
                      onChanged: (value) {
                        setState(() {
                          _slotPositions[_selectedSlot!] = Alignment(value, alignment.y);
                        });
                      },
                    ),
                    Text(
                      alignment.x.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xFFC7B377),
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Y (Vertical)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Slider(
                      value: alignment.y,
                      min: -1.0,
                      max: 1.0,
                      activeColor: const Color(0xFFC7B377),
                      onChanged: (value) {
                        setState(() {
                          _slotPositions[_selectedSlot!] = Alignment(alignment.x, value);
                        });
                      },
                    ),
                    Text(
                      alignment.y.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xFFC7B377),
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugGrid() {
    return IgnorePointer(
      child: Column(
        children: List.generate(17, (i) {
          return Expanded(
            child: Row(
              children: List.generate(9, (j) {
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: (i == 8 && j == 4)
                        ? const Center(
                            child: Icon(
                              Icons.center_focus_strong,
                              color: Colors.red,
                              size: 16,
                            ),
                          )
                        : null,
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  IconData _getIconForSlot(String slotKey) {
    switch (slotKey) {
      case 'head':
        return Icons.face;
      case 'neck':
        return Icons.circle_outlined;
      case 'mainHand':
        return Icons.fitness_center;
      case 'offHand':
        return Icons.shield;
      case 'gloves':
        return Icons.back_hand;
      case 'chest':
        return Icons.shield;
      case 'legs':
        return Icons.accessibility;
      case 'boots':
        return Icons.directions_walk;
      default:
        return Icons.help_outline;
    }
  }

  void _showCoordinates() {
    final code = StringBuffer();
    code.writeln('// Copy these coordinates to equipment_overlay_page.dart\n');
    
    _slotPositions.forEach((key, alignment) {
      code.writeln('_buildSlot(');
      code.writeln('  alignment: const Alignment(${alignment.x.toStringAsFixed(2)}, ${alignment.y.toStringAsFixed(2)}),');
      code.writeln('  slotKey: \'$key\',');
      code.writeln('  size: 70,');
      code.writeln('),\n');
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Coordinates',
          style: TextStyle(
            fontFamily: 'Courier',
            color: Color(0xFFC7B377),
          ),
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            code.toString(),
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFFC7B377)),
            ),
          ),
        ],
      ),
    );
  }
}
