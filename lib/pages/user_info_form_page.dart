import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/burn_fit_style.dart';
import '../core/error_handler.dart';
import '../data/user_repo.dart';
import '../models/user_profile.dart';

class UserInfoFormPage extends StatefulWidget {
  final UserRepo userRepo;

  const UserInfoFormPage({super.key, required this.userRepo});

  @override
  State<UserInfoFormPage> createState() => _UserInfoFormPageState();
}

class _UserInfoFormPageState extends State<UserInfoFormPage> {
  // Form state
  double? _weight;
  int? _height;
  DateTime? _birthDate;
  String? _gender;

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();

  bool get _isFormComplete =>
      _weight != null && _height != null && _birthDate != null && _gender != null;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await widget.userRepo.getUserProfile();
    if (profile != null) {
      setState(() {
        _weight = profile.weight;
        _height = profile.height;
        _birthDate = profile.birthDate;
        _gender = profile.gender;

        _weightController.text = '${_weight!.toStringAsFixed(1)} kg';
        _heightController.text = '$_height cm';
        _birthDateController.text = DateFormat('yyyy년 MM월 dd일').format(_birthDate!);
        _genderController.text = _gender!;
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  // --- Picker Logic ---

  Future<void> _showPicker({
    required BuildContext context,
    required String title,
    required Widget picker,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          color: Theme.of(context).canvasColor,
          child: Column(
            children: [
              // HandleBar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: BurnFitStyle.mediumGray,
                ),
              ),
              const SizedBox(height: 10),
              // Title & Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소', style: TextStyle(color: BurnFitStyle.secondaryGrayText)),
                    ),
                    Text(title, style: BurnFitStyle.body.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context);
                      },
                      child: const Text('확인', style: TextStyle(color: BurnFitStyle.primaryBlue)),
                    ),
                  ],
                ),
              ),
              // Picker
              Expanded(child: picker),
            ],
          ),
        );
      },
    );
  }

  void _showWeightPicker() {
    int selectedKg = _weight?.floor() ?? 70;
    int selectedGram = ((_weight ?? 70.0) * 10).remainder(10).toInt();

    _showPicker(
      context: context,
      title: '몸무게를 입력해 주세요.',
      picker: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPickerWheel(
            width: 80,
            itemCount: 201, // 30kg ~ 230kg
            initialItem: selectedKg - 30,
            itemBuilder: (context, index) => Center(child: Text('${index + 30}')),
            onSelectedItemChanged: (index) => selectedKg = index + 30,
          ),
          const Text('.'),
          _buildPickerWheel(
            width: 80,
            itemCount: 10,
            initialItem: selectedGram,
            itemBuilder: (context, index) => Center(child: Text('$index')),
            onSelectedItemChanged: (index) => selectedGram = index,
          ),
          const Text('kg'),
        ],
      ),
      onConfirm: () {
        setState(() {
          _weight = selectedKg + (selectedGram / 10.0);
          _weightController.text = '${_weight!.toStringAsFixed(1)} kg';
        });
      },
    );
  }

  void _showHeightPicker() {
    int selectedCm = _height ?? 170;
    _showPicker(
      context: context,
      title: '키를 입력해 주세요.',
      picker: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPickerWheel(
            width: 100,
            itemCount: 151, // 100cm ~ 250cm
            initialItem: selectedCm - 100,
            itemBuilder: (context, index) => Center(child: Text('${index + 100}')),
            onSelectedItemChanged: (index) => selectedCm = index + 100,
          ),
          const Text('cm'),
        ],
      ),
      onConfirm: () {
        setState(() {
          _height = selectedCm;
          _heightController.text = '$_height cm';
        });
      },
    );
  }

  void _showDatePicker() {
    DateTime tempDate = _birthDate ?? DateTime(1990, 1, 1);
    _showPicker(
      context: context,
      title: '생년월일을 입력해 주세요.',
      picker: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: tempDate,
        maximumDate: DateTime.now(),
        minimumDate: DateTime(1920, 1, 1),
        onDateTimeChanged: (DateTime newDate) {
          tempDate = newDate;
        },
      ),
      onConfirm: () {
        setState(() {
          _birthDate = tempDate;
          _birthDateController.text = DateFormat('yyyy년 MM월 dd일').format(_birthDate!);
        });
      },
    );
  }

  void _showGenderPicker() {
    final genders = ['남성', '여성'];
    int selectedIndex = _gender == null ? 0 : genders.indexOf(_gender!);
    _showPicker(
      context: context,
      title: '성별을 알려주세요.',
      picker: _buildPickerWheel(
        itemCount: genders.length,
        initialItem: selectedIndex,
        itemBuilder: (context, index) => Center(child: Text(genders[index])),
        onSelectedItemChanged: (index) => selectedIndex = index,
      ),
      onConfirm: () {
        setState(() {
          _gender = genders[selectedIndex];
          _genderController.text = _gender!;
        });
      },
    );
  }

  Widget _buildPickerWheel({
    double width = 100,
    required int itemCount,
    required int initialItem,
    required Widget Function(BuildContext, int) itemBuilder,
    required void Function(int) onSelectedItemChanged,
  }) {
    return SizedBox(
      width: width,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 32.0,
        onSelectedItemChanged: onSelectedItemChanged,
        children: List<Widget>.generate(itemCount, (index) => itemBuilder(context, index)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // 3.1 HeaderComponent
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BurnFitStyle.darkGrayText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // 3.2 BodyComponent
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '운동을 시작하기 위해\n필수 정보를 알려주세요.',
                style: BurnFitStyle.title1,
              ),
              const SizedBox(height: 8),
              Text(
                '입력 정보는 운동 추천 용도로만 사용합니다.',
                style: BurnFitStyle.body.copyWith(color: BurnFitStyle.secondaryGrayText),
              ),
              const SizedBox(height: 32),
              // UserInfoForm
              _FormInputTextField(label: '몸무게 *', hint: '몸무게를 입력해 주세요.', controller: _weightController, onTap: _showWeightPicker),
              const SizedBox(height: 16),
              _FormInputTextField(label: '키 *', hint: '키를 입력해 주세요.', controller: _heightController, onTap: _showHeightPicker),
              const SizedBox(height: 16),
              _FormInputTextField(label: '생년월일 *', hint: '생년월일을 입력해 주세요.', controller: _birthDateController, onTap: _showDatePicker),
              const SizedBox(height: 16),
              _FormInputTextField(label: '성별 *', hint: '성별을 알려주세요.', controller: _genderController, onTap: _showGenderPicker),
              const Spacer(),
              // NextButton
              ElevatedButton(
                onPressed: _isFormComplete
                    ? () async {
                        // 기존 프로필을 불러와서 덮어쓰기 (목표값 유지)
                        final existingProfile = await widget.userRepo.getUserProfile();
                        final newProfile = UserProfile(
                          weight: _weight!,
                          height: _height!,
                          birthDate: _birthDate!,
                          gender: _gender!,
                          monthlyWorkoutGoal: existingProfile?.monthlyWorkoutGoal ?? 20,
                          monthlyVolumeGoal: existingProfile?.monthlyVolumeGoal ?? 100000.0,
                          profileImage: existingProfile?.profileImage,
                        );
                        try {
                          await widget.userRepo.saveUserProfile(newProfile);
                          if (mounted) Navigator.pop(context, true); // 성공 시 true 반환
                        } catch (e) {
                          ErrorHandler.showErrorSnackBar(context, '정보 저장에 실패했습니다.');
                        }
                      } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BurnFitStyle.primaryBlue,
                  disabledBackgroundColor: BurnFitStyle.lightGray,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  '다음',
                  style: BurnFitStyle.body.copyWith(
                    color: _isFormComplete ? BurnFitStyle.white : BurnFitStyle.secondaryGrayText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormInputTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _FormInputTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BurnFitStyle.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: BurnFitStyle.body.copyWith(color: BurnFitStyle.secondaryGrayText),
            filled: true,
            fillColor: BurnFitStyle.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}