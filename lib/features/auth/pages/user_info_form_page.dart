import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/burn_fit_style.dart';
import '../../../core/error_handler.dart';
import '../../../data/user_repo.dart';
import '../../../models/user_profile.dart';
import '../../../l10n/app_localizations.dart';

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
    if (profile != null && mounted) {
      final locale = Localizations.localeOf(context).languageCode;
      setState(() {
        _weight = profile.weight;
        _height = profile.height;
        _birthDate = profile.birthDate;
        _gender = profile.gender;

        _weightController.text = '${_weight!.toStringAsFixed(1)} kg';
        _heightController.text = '$_height cm';
        _birthDateController.text = DateFormat('yMMMd', locale).format(_birthDate!);
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
                      child: Text(AppLocalizations.of(context).cancel, style: const TextStyle(color: BurnFitStyle.secondaryGrayText)),
                    ),
                    Text(title, style: BurnFitStyle.body.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context).confirm, style: const TextStyle(color: BurnFitStyle.primaryBlue)),
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

    final l10n = AppLocalizations.of(context);
    _showPicker(
      context: context,
      title: l10n.enterWeight,
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
    final l10n = AppLocalizations.of(context);
    _showPicker(
      context: context,
      title: l10n.enterHeight,
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
    final l10n = AppLocalizations.of(context);
    _showPicker(
      context: context,
      title: l10n.enterBirthDate,
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
          final locale = Localizations.localeOf(context).languageCode;
          _birthDateController.text = DateFormat('yMMMd', locale).format(_birthDate!);
        });
      },
    );
  }

  void _showGenderPicker() {
    final l10n = AppLocalizations.of(context);
    final genders = [l10n.male, l10n.female];
    int selectedIndex = _gender == null ? 0 : genders.indexOf(_gender!);
    _showPicker(
      context: context,
      title: l10n.enterGender,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // 3.1 HeaderComponent
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge?.color),
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
              Text(
                l10n.requiredInfo,
                style: BurnFitStyle.title1.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.infoUsageNotice,
                style: BurnFitStyle.body.copyWith(
                  color: isDark ? Colors.grey[400] : BurnFitStyle.secondaryGrayText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
              // UserInfoForm
              _FormInputTextField(label: l10n.weightLabel, hint: l10n.enterWeight, controller: _weightController, onTap: _showWeightPicker),
              const SizedBox(height: 16),
              _FormInputTextField(label: l10n.heightLabel, hint: l10n.enterHeight, controller: _heightController, onTap: _showHeightPicker),
              const SizedBox(height: 16),
              _FormInputTextField(label: l10n.birthDate, hint: l10n.enterBirthDate, controller: _birthDateController, onTap: _showDatePicker),
              const SizedBox(height: 16),
              _FormInputTextField(label: l10n.gender, hint: l10n.enterGender, controller: _genderController, onTap: _showGenderPicker),
              const Spacer(),
              // NextButton
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isFormComplete
                      ? [
                          BoxShadow(
                            color: BurnFitStyle.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
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
                            if (mounted) {
                              ErrorHandler.showErrorSnackBar(context, l10n.saveInfoFailed);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BurnFitStyle.primaryBlue,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.next,
                    style: TextStyle(
                      fontSize: 17,
                      color: _isFormComplete ? Colors.white : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValue = controller.text.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : BurnFitStyle.darkGrayText,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasValue 
                ? BurnFitStyle.primaryBlue.withValues(alpha: 0.3)
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              width: 1.5,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : BurnFitStyle.darkGrayText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              suffixIcon: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
