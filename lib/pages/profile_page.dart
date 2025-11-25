import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../core/burn_fit_style.dart';
import '../core/error_handler.dart';
import '../data/auth_repo.dart';
import '../data/user_repo.dart';
import '../models/user_profile.dart';
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
    final profile = await widget.userRepo.getUserProfile();
    final googleUser = widget.authRepo.currentUser;
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _googleUser = googleUser;
        _goalController.text = _userProfile?.monthlyWorkoutGoal.toString() ?? '20';
        _volumeGoalController.text = _userProfile?.monthlyVolumeGoal.toString() ?? '100000';
      });
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
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 사진 선택'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              if (_userProfile?.profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('사진 삭제', style: TextStyle(color: Colors.red)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: _userProfile == null
          ? const Center(child: CircularProgressIndicator())
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
        Text(_googleUser?.displayName ?? '게스트', style: BurnFitStyle.title2),
        Text(_googleUser?.email ?? '', style: BurnFitStyle.caption),
      ],
    );
  }

  Widget _buildBodyInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('신체 정보', style: BurnFitStyle.title2),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UserInfoFormPage(userRepo: widget.userRepo)),
                    );
                    if (result == true) _loadData(); // 수정 완료 후 데이터 다시 로드
                  },
                  child: const Text('수정'),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('키: ${_userProfile!.height} cm', style: BurnFitStyle.body),
            const SizedBox(height: 8),
            Text('몸무게: ${_userProfile!.weight} kg', style: BurnFitStyle.body),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSettingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('운동 목표', style: BurnFitStyle.title2),
            const Divider(height: 24),
            Row(
              children: [
                const Expanded(child: Text('월별 운동 일수', style: BurnFitStyle.body)),
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
                const Expanded(child: Text('월별 총 볼륨', style: BurnFitStyle.body)),
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
                child: const Text('목표 저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}