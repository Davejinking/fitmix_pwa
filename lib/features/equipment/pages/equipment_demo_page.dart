import 'package:flutter/material.dart';
import 'equipment_overlay_page.dart';
import 'equipment_calibration_page.dart';
import '../../analysis/pages/diablo_status_page.dart';

/// Demo page to showcase both equipment implementations
/// Use this to compare old vs new approach
class EquipmentDemoPage extends StatelessWidget {
  const EquipmentDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Equipment Screens',
          style: TextStyle(
            fontFamily: 'Courier',
            color: Color(0xFFC7B377),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                'CHOOSE YOUR EQUIPMENT SCREEN',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC7B377),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // New Overlay Implementation
              _buildOptionCard(
                context,
                title: 'NEW: Image Overlay',
                subtitle: 'Pixel-perfect with background image',
                icon: Icons.layers,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EquipmentOverlayPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Calibration Tool
              _buildOptionCard(
                context,
                title: 'Calibration Tool',
                subtitle: 'Fine-tune slot positions',
                icon: Icons.tune,
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EquipmentCalibrationPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Original Implementation
              _buildOptionCard(
                context,
                title: 'ORIGINAL: Diablo Style',
                subtitle: 'Code-drawn UI elements',
                icon: Icons.code,
                color: const Color(0xFF9E9E9E),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DiabloStatusPage(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  border: Border.all(
                    color: const Color(0xFFC7B377),
                    width: 2,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 SETUP INSTRUCTIONS',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC7B377),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. Add vertical_equipment_bg.jpg to assets/images/\n'
                      '2. Run "flutter pub get" if needed\n'
                      '3. Restart app to load new assets\n'
                      '4. Use Calibration Tool to adjust positions\n'
                      '5. Copy coordinates to overlay page',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 11,
                        color: Colors.grey,
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

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1C1C1C),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
