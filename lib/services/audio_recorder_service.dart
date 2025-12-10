import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  // Singleton pattern
  static final AudioRecorderService _instance = AudioRecorderService._internal();
  factory AudioRecorderService() => _instance;
  AudioRecorderService._internal();

  Future<void> init() async {
    // Check permissions
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<String> _getFilePath(String cueName) async {
    final dir = await getApplicationDocumentsDirectory();
    final customDir = Directory('${dir.path}/voice_custom');
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
    return '${customDir.path}/$cueName.m4a';
  }

  Future<void> startRecording(String cueName) async {
    try {
      if (await _recorder.hasPermission()) {
        final path = await _getFilePath(cueName);

        const config = RecordConfig(encoder: AudioEncoder.aacLc);

        await _recorder.start(config, path: path);
      }
    } catch (e) {
      print('Recording error: $e');
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      return path;
    } catch (e) {
      print('Stop recording error: $e');
      return null;
    }
  }

  Future<void> playRecording(String cueName) async {
    try {
      final path = await _getFilePath(cueName);
      final file = File(path);
      if (await file.exists()) {
        await _player.play(DeviceFileSource(path));
      } else {
        print('File not found: $path');
      }
    } catch (e) {
      print('Playback error: $e');
    }
  }

  Future<bool> hasRecording(String cueName) async {
    final path = await _getFilePath(cueName);
    return File(path).exists();
  }

  Future<void> deleteRecording(String cueName) async {
    final path = await _getFilePath(cueName);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
