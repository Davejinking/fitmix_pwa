import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../core/burn_fit_style.dart';
import '../core/error_handler.dart';
import '../data/auth_repo.dart';
import '../data/user_repo.dart';
import '../models/user_profile.dart';
import '../l10n/app_localizations.dart';
import 'user_info_form_page.dart';

class ProfilePage extends StatefulWidget {
  final UserRepo userRepo;
  final AuthRepo authRepo;

  const ProfilePage({super.key, required this.userRepo, required this.authRepo});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  GoogleSignInAccount? _googleUser;
  late TextEditingController _goalController;
  late TextEditingController _volumeGoalController;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController();
    _volumeGoalController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    print('🔄 프로필 데이터 로드 시작...');
    var profile = await widget.userRepo.getUserProfile();
    print('✅ 프로필 로드 완료: $profile');
    
    // 프로필이 없으면 기본값으로 생성
    if (profile == null) {
      print('⚠️ 프로필이 없음. 기본값으로 생성 중...');
      profile = UserProfile(
        weight: 70.0,
        height: 170,
        birthDate: DateTime(1990, 1, 1),
        gender: '남성',
        monthlyWorkoutGoal: 20,
        monthlyVolumeGoal: 100000.0,
      );
      await widget.userRepo.saveUserProfile(profile);
      print('✅ 기본 프로필 저장 완료');
    }
    
    final googleUser = widget.authRepo.currentUser;
    print('✅ Google 사용자 로드 완료: $googleUser');
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _googleUser = googleUser;
        _goalController.text = _userProfile?.monthlyWorkoutGoal.toString() ?? '20';
        _volumeGoalController.text = _userProfile?.monthlyVolumeGoal.toString() ?? '100000';
      });
      print('✅ UI 업데이트 완료');
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _volumeGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_userProfile == null) return;
    final newGoal = int.tryParse(_goalController.text);
    if (newGoal == null || newGoal <= 0) {
      ErrorHandler.showErrorSnackBar(context, '올바른 운동일수 목표를 입력하세요.');
      return;
    }
    final newVolumeGoal = double.tryParse(_volumeGoalController.text);
    if (newVolumeGoal == null || newVolumeGoal <= 0) {
      ErrorHandler.showErrorSnackBar(context, '올바른 볼륨 목표를 입력하세요.');
      return;
    }

    _userProfile!.monthlyWorkoutGoal = newGoal;
    _userProfile!.monthlyVolumeGoal = newVolumeGoal;
    await widget.userRepo.saveUserProfile(_userProfile!);
    if (mounted) {
      FocusScope.of(context).unfocus(); // 키보드 숨기기
      ErrorHandler.showSuccessSnackBar(context, '목표가 저장되었습니다.');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      final Uint8List imageBytes = await image.readAsBytes();
      if (_userProfile != null && mounted) {
        setState(() {
          _userProfile!.profileImage = imageBytes;
        });
        await widget.userRepo.saveUserProfile(_userProfile!);
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, '프로필 사진이 변경되었습니다.');
        }
      }
    }
  }

  Future<void> _deleteImage() async {
    if (_userProfile != null) {
      setState(() {
        _userProfile!.profileImage = null;
      });
      await widget.userRepo.saveUserProfile(_userProfile!);
      if (mounted) {
        ErrorHandler.showInfoSnackBar(context, '프로필 사진이 삭제되었습니다.');
      }
    }
  }

  Future<void> _showPhotoOptions() async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.selectFromGallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              if (_userProfile?.profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(l10n.deletePhoto, style: const TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _deleteImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: _userProfile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('프로필 로드 중...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildGoogleProfile(),
                const SizedBox(height: 32),
                _buildBodyInfoCard(),
                const SizedBox(height: 32),
                _buildGoalSettingCard(),
              ],
            ),
    );
  }

  Widget _buildGoogleProfile() {
    return Column(
      children: [
        InkWell(
          onTap: _showPhotoOptions,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _userProfile?.profileImage != null
                    ? MemoryImage(_userProfile!.profileImage!)
                    : _googleUser?.photoUrl != null
                        ? NetworkImage(_googleUser!.photoUrl!)
                        : null as ImageProvider?,
                child: _userProfile?.profileImage == null && _googleUser?.photoUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(_googleUser?.displayName ?? AppLocalizations.of(context).guest, style: BurnFitStyle.title2),
        Text(_googleUser?.email ?? '', style: BurnFitStyle.caption),
      ],
    );
  }

  Widget _buildBodyInfoCard() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.bodyInfo, style: BurnFitStyle.title2),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UserInfoFormPage(userRepo: widget.userRepo)),
                    );
                    if (result == true) _loadData(); // 수정 완료 후 데이터 다시 로드
                  },
                  child: Text(l10n.edit),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(l10n.height(_userProfile!.height.toString()), style: BurnFitStyle.body),
            const SizedBox(height: 8),
            Text(l10n.weight(_userProfile!.weight.toString()), style: BurnFitStyle.body),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSettingCard() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.workoutGoal, style: BurnFitStyle.title2),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(child: Text(l10n.monthlyWorkoutDays, style: BurnFitStyle.body)),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      suffixText: '일',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text(l10n.monthlyTotalVolume, style: BurnFitStyle.body)),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _volumeGoalController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      suffixText: 'kg',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _saveGoal,
                child: Text(l10n.saveGoal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}