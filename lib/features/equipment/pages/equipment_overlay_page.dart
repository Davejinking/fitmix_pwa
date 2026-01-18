import 'package:flutter/material.dart';
import 'inventory_page.dart';

/// Pixel-Perfect Equipment Screen using Image Overlay (Stack & Align)
/// Background: Dark Fantasy RPG Vertical Image (9:16 ratio)
class EquipmentOverlayPage extends StatefulWidget {
  const EquipmentOverlayPage({super.key});

  @override
  State<EquipmentOverlayPage> createState() => _EquipmentOverlayPageState();
}

class _EquipmentOverlayPageState extends State<EquipmentOverlayPage> {
  final bool _isLoading = false;

  // Equipment Data (Mock - Replace with actual data model)
  final Map<String, IconData?> _equippedItems = {
    'head': Icons.face,
    'neck': Icons.circle_outlined,
    'mainHand': Icons.fitness_center,
    'offHand': Icons.shield,
    'gloves': Icons.back_hand,
    'chest': Icons.shield, // Armor
    'legs': Icons.accessibility,
    'boots': Icons.directions_walk,
  };

  // 🔥 Debug mode - 좌표 확인용 (좌표 맞추기 위해 true로 변경)
  static const bool _showDebugBorders = true;

  @override
  void initState() {
    super.initState();
    // Load equipment data here when integrating with your data model
    // _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC7B377)),
      );
    }

    // 🔥 Scaffold 제거 - 부모(CharacterPage)가 이미 Scaffold 제공
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16, // Lock aspect ratio to match the image
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Background Image (Passive Design)
            Image.asset(
              'assets/images/vertical_equipment_bg.jpg',
              fit: BoxFit.cover, // Fill the AspectRatio container perfectly
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Container(
                  color: const Color(0xFF2A2520),
                  child: const Center(
                    child: Text(
                      'Background Image Not Found\nPlace vertical_equipment_bg.jpg\nin assets/images/',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD4C5A0),
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Layer 2: Interactive Slots (Active Overlay)
                // Precise coordinates mapped 1:1 to the image
                
                // HEAD (Top Left)
                _buildSlot(
                  alignment: const Alignment(-0.35, -0.78),
                  slotKey: 'head',
                  size: 68,
                ),
                // NECK (Top Right)
                _buildSlot(
                  alignment: const Alignment(0.35, -0.78),
                  slotKey: 'neck',
                  size: 68,
                ),
                
                // WEAPON (Left Mid-High)
                _buildSlot(
                  alignment: const Alignment(-0.80, -0.25),
                  slotKey: 'mainHand',
                  size: 68,
                ),
                // SHIELD (Right Mid-High)
                _buildSlot(
                  alignment: const Alignment(0.80, -0.25),
                  slotKey: 'offHand',
                  size: 68,
                ),
                
                // GLOVES (Left Low)
                _buildSlot(
                  alignment: const Alignment(-0.80, 0.15),
                  slotKey: 'gloves',
                  size: 68,
                ),
                // CHEST (Right Low)
                _buildSlot(
                  alignment: const Alignment(0.80, 0.15),
                  slotKey: 'chest',
                  size: 68,
                ),
                
                // LEGS (Bottom Left)
                _buildSlot(
                  alignment: const Alignment(-0.28, 0.58),
                  slotKey: 'legs',
                  size: 68,
                ),
                // BOOTS (Bottom Right)
                _buildSlot(
                  alignment: const Alignment(0.28, 0.58),
                  slotKey: 'boots',
                  size: 68,
                ),
                
                // Bottom Inventory Grid (Quick Items)
                _buildInventoryGrid(),
                
                // Debug: Show alignment grid (Remove in production)
                // _buildDebugGrid(),
              ],
            ),
          ),
        );
  }

  /// Build bottom inventory grid overlay
  Widget _buildInventoryGrid() {
    return Align(
      alignment: const Alignment(0.0, 0.88), // 🔥 INVENTORY 텍스트 바로 아래
      child: SizedBox(
        width: 360, // 🔥 너비 증가
        height: 90, // 🔥 높이 조정 (2줄)
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: 16, // 2줄 x 8칸
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onInventorySlotTapped(index),
              child: Container(
                decoration: BoxDecoration(
                  // 🔥 Debug: 파란 테두리로 표시
                  border: _showDebugBorders
                      ? Border.all(color: Colors.blue.withValues(alpha: 0.8), width: 2)
                      : null,
                ),
                child: Center(
                  child: index == 0
                      ? Icon(
                          Icons.healing,
                          size: 22,
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onInventorySlotTapped(int index) {
    // Handle quick item usage
    debugPrint('Inventory slot $index tapped');
  }

  /// Build a transparent interactive slot with ripple effect
  Widget _buildSlot({
    required Alignment alignment,
    required String slotKey,
    required double size,
  }) {
    final itemIcon = _equippedItems[slotKey];
    
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => _onSlotTapped(slotKey),
        child: Container(
          width: size,
          height: size,
          // 🔥 Debug: 좌표 확인용
          decoration: _showDebugBorders
              ? BoxDecoration(
                  border: Border.all(color: Colors.red.withValues(alpha: 0.8), width: 2),
                )
              : null, // 완전 투명
          child: Center(
            child: itemIcon != null
                ? Icon(
                    itemIcon,
                    size: 50.0, // 🔥 크기 증가
                    color: Colors.white.withValues(alpha: 0.9), // 🔥 밝은 흰색
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  )
                : Icon(
                    Icons.add_circle_outline,
                    size: 30.0,
                    color: Colors.white.withValues(alpha: 0.3), // 🔥 빈 슬롯 힌트
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _onSlotTapped(String slotKey) {
    // Navigate to inventory or show equipment selection
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InventoryPage()),
    );
  }

  /// Debug Grid (Optional - for alignment testing)
  /// Uncomment in Stack children to enable: _buildDebugGrid(),
  // ignore: unused_element
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
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
