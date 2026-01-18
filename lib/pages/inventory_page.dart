import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../core/iron_theme.dart';
import '../core/service_locator.dart';
import '../data/equipment_repo.dart';
import '../models/equipment.dart';

/// RPG 스타일 장비 인벤토리 페이지
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late EquipmentRepo _equipmentRepo;
  EquipmentCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _equipmentRepo = getIt<EquipmentRepo>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IronTheme.background,
      appBar: AppBar(
        backgroundColor: IronTheme.background,
        title: const Text(
          'IRON ARMORY',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 필터
          _buildCategoryFilter(),
          
          // 장비 그리드
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _equipmentRepo.listenable(),
              builder: (context, Box<Equipment> box, _) {
                var items = box.values.toList();
                
                // 카테고리 필터 적용
                if (_selectedCategory != null) {
                  items = items.where((e) => e.category == _selectedCategory).toList();
                }
                
                // 등급순 정렬 (높은 등급 먼저)
                items.sort((a, b) => b.rarityIndex.compareTo(a.rarityIndex));
                
                if (items.isEmpty) {
                  return _buildEmptyState();
                }
                
                return _buildEquipmentGrid(items);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(null, '전체'),
          ...EquipmentCategory.values.map((cat) => 
            _buildFilterChip(cat, cat.displayName)
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(EquipmentCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          HapticFeedback.selectionClick();
          setState(() => _selectedCategory = category);
        },
        backgroundColor: IronTheme.surface,
        selectedColor: Colors.amber.withValues(alpha: 0.3),
        labelStyle: TextStyle(
          color: isSelected ? Colors.amber : IronTheme.textMedium,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? Colors.amber : IronTheme.surfaceHighlight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEquipmentGrid(List<Equipment> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildEquipmentCard(items[index]),
    );
  }

  Widget _buildEquipmentCard(Equipment equipment) {
    final rarityColor = Color(equipment.rarity.colorValue);
    
    return GestureDetector(
      onTap: () => _showEquipmentDetail(equipment),
      onLongPress: () => _showEquipmentOptions(equipment),
      child: Container(
        decoration: BoxDecoration(
          color: IronTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rarityColor.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // 이미지 영역
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: IronTheme.surfaceHighlight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: equipment.imagePath != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.file(
                          File(equipment.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(equipment.category),
                        size: 40,
                        color: rarityColor,
                      ),
              ),
            ),
            
            // 이름 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rarityColor.withValues(alpha: 0.3),
                    rarityColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Text(
                equipment.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: IronTheme.textLow,
          ),
          const SizedBox(height: 16),
          Text(
            '장비가 없습니다',
            style: TextStyle(
              color: IronTheme.textMedium,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+ 버튼을 눌러 첫 장비를 등록하세요',
            style: TextStyle(
              color: IronTheme.textLow,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: _showAddEquipmentDialog,
      backgroundColor: Colors.amber,
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  IconData _getCategoryIcon(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.helmet:
        return Icons.sports_martial_arts;
      case EquipmentCategory.armor:
        return Icons.checkroom;
      case EquipmentCategory.gloves:
        return Icons.back_hand;
      case EquipmentCategory.belt:
        return Icons.straighten;
      case EquipmentCategory.boots:
        return Icons.ice_skating;
      case EquipmentCategory.weapon:
        return Icons.shield;
      case EquipmentCategory.accessory:
        return Icons.star;
    }
  }

  void _showEquipmentDetail(Equipment equipment) {
    final rarityColor = Color(equipment.rarity.colorValue);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: IronTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: rarityColor, width: 2),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: IronTheme.textLow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 이미지
                if (equipment.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(equipment.imagePath!),
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: IronTheme.surfaceHighlight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCategoryIcon(equipment.category),
                      size: 50,
                      color: rarityColor,
                    ),
                  ),
                const SizedBox(height: 16),
                
                // 등급 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rarityColor),
                  ),
                  child: Text(
                    equipment.rarity.displayName.toUpperCase(),
                    style: TextStyle(
                      color: rarityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 이름
                Text(
                  equipment.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (equipment.brand != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    equipment.brand!,
                    style: TextStyle(
                      color: IronTheme.textMedium,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                
                // 통계
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: IronTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        '총 볼륨',
                        '${_formatVolume(equipment.totalVolumeLifted)} kg',
                        Icons.fitness_center,
                      ),
                      const Divider(color: IronTheme.surfaceHighlight),
                      _buildStatRow(
                        '완료 세트',
                        '${equipment.totalSetsCompleted} 세트',
                        Icons.check_circle_outline,
                      ),
                      if (equipment.purchaseDate != null) ...[
                        const Divider(color: IronTheme.surfaceHighlight),
                        _buildStatRow(
                          '구매일',
                          _formatDate(equipment.purchaseDate!),
                          Icons.calendar_today,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: IronTheme.textMedium, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: IronTheme.textMedium, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEquipmentOptions(Equipment equipment) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: IronTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('수정', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditEquipmentDialog(equipment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(equipment);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Equipment equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: IronTheme.surface,
        title: const Text('장비 삭제', style: TextStyle(color: Colors.white)),
        content: Text(
          '"${equipment.name}"을(를) 삭제하시겠습니까?',
          style: TextStyle(color: IronTheme.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: IronTheme.textMedium)),
          ),
          TextButton(
            onPressed: () async {
              await _equipmentRepo.delete(equipment.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEquipmentDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEquipmentSheet(
        onSave: (equipment) async {
          await _equipmentRepo.save(equipment);
        },
      ),
    );
  }

  Future<void> _showEditEquipmentDialog(Equipment equipment) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEquipmentSheet(
        equipment: equipment,
        onSave: (updated) async {
          await _equipmentRepo.save(updated);
        },
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: IronTheme.surface,
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Iron Armory', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRarityLegend(EquipmentRarity.common, '다이소급'),
            _buildRarityLegend(EquipmentRarity.uncommon, '데카트론급'),
            _buildRarityLegend(EquipmentRarity.rare, '나이키/아디다스급'),
            _buildRarityLegend(EquipmentRarity.epic, '로그/리복급'),
            _buildRarityLegend(EquipmentRarity.legendary, 'SBD/카딜로급'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityLegend(EquipmentRarity rarity, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Color(rarity.colorValue),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${rarity.displayName} - $desc',
            style: TextStyle(color: IronTheme.textMedium, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}


/// 장비 추가/수정 시트
class _AddEquipmentSheet extends StatefulWidget {
  final Equipment? equipment;
  final Future<void> Function(Equipment) onSave;

  const _AddEquipmentSheet({
    this.equipment,
    required this.onSave,
  });

  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  String? _imagePath;
  EquipmentCategory _category = EquipmentCategory.accessory;
  EquipmentRarity _rarity = EquipmentRarity.common;
  DateTime? _purchaseDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.equipment != null) {
      _nameController.text = widget.equipment!.name;
      _brandController.text = widget.equipment!.brand ?? '';
      _imagePath = widget.equipment!.imagePath;
      _category = widget.equipment!.category;
      _rarity = widget.equipment!.rarity;
      _purchaseDate = widget.equipment!.purchaseDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.equipment != null;
    
    return Container(
      decoration: BoxDecoration(
        color: IronTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: IronTheme.textLow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 타이틀
              Text(
                isEditing ? '장비 수정' : '새 장비 등록',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // 이미지 선택
              _buildImagePicker(),
              const SizedBox(height: 20),
              
              // 이름 입력
              _buildTextField(
                controller: _nameController,
                label: '장비명',
                hint: 'SBD Belt 13mm',
              ),
              const SizedBox(height: 16),
              
              // 브랜드 입력
              _buildTextField(
                controller: _brandController,
                label: '브랜드 (선택)',
                hint: 'SBD, Nike, Adidas...',
              ),
              const SizedBox(height: 20),
              
              // 카테고리 선택
              _buildCategorySelector(),
              const SizedBox(height: 20),
              
              // 등급 선택
              _buildRaritySelector(),
              const SizedBox(height: 20),
              
              // 구매일 선택
              _buildDatePicker(),
              const SizedBox(height: 32),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          isEditing ? '수정 완료' : '장비 등록',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: IronTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: IronTheme.surfaceHighlight,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePath = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: IronTheme.textLow,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '사진 추가',
                    style: TextStyle(
                      color: IronTheme.textMedium,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: IronTheme.textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: IronTheme.textLow),
            filled: true,
            fillColor: IronTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: TextStyle(
            color: IronTheme.textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EquipmentCategory.values.map((cat) {
            final isSelected = _category == cat;
            return ChoiceChip(
              label: Text(cat.displayName),
              selected: isSelected,
              onSelected: (_) => setState(() => _category = cat),
              backgroundColor: IronTheme.background,
              selectedColor: Colors.amber.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: isSelected ? Colors.amber : IronTheme.textMedium,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? Colors.amber : IronTheme.surfaceHighlight,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRaritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '등급',
          style: TextStyle(
            color: IronTheme.textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EquipmentRarity.values.map((rarity) {
            final isSelected = _rarity == rarity;
            final color = Color(rarity.colorValue);
            return ChoiceChip(
              label: Text(rarity.displayName),
              selected: isSelected,
              onSelected: (_) => setState(() => _rarity = rarity),
              backgroundColor: IronTheme.background,
              selectedColor: color.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: isSelected ? color : IronTheme.textMedium,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? color : IronTheme.surfaceHighlight,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구매일 (선택)',
          style: TextStyle(
            color: IronTheme.textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: IronTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: IronTheme.textLow,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _purchaseDate != null
                      ? '${_purchaseDate!.year}.${_purchaseDate!.month.toString().padLeft(2, '0')}.${_purchaseDate!.day.toString().padLeft(2, '0')}'
                      : '날짜 선택',
                  style: TextStyle(
                    color: _purchaseDate != null 
                        ? Colors.white 
                        : IronTheme.textLow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: IronTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('카메라', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('갤러리', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() => _imagePath = image.path);
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _purchaseDate = date);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장비명을 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final equipment = Equipment(
      id: widget.equipment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      imagePath: _imagePath,
      categoryIndex: _category.index,
      rarityIndex: _rarity.index,
      purchaseDate: _purchaseDate,
      createdAt: widget.equipment?.createdAt ?? DateTime.now(),
      totalVolumeLifted: widget.equipment?.totalVolumeLifted ?? 0,
      totalSetsCompleted: widget.equipment?.totalSetsCompleted ?? 0,
      linkedExercises: widget.equipment?.linkedExercises ?? [],
    );

    await widget.onSave(equipment);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
