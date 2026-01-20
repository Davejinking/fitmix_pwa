import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/services/pro_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('ProService Tests', () {
    late ProService service;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for Hive
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);

      service = ProService();
      await service.init();
    });

    tearDown(() async {
      // Clean up Hive and temporary directory
      await Hive.deleteFromDisk();
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore deletion errors on Windows or locked files
      }
    });

    test('Initial state should be false (unless persisted)', () async {
      // Since we use a fresh temp dir, it should be false
      expect(service.isPro, false);
    });

    test('restorePurchases should return true and set isPro to true (Mock behavior)', () async {
      expect(service.isPro, false);

      final result = await service.restorePurchases();

      expect(result, true);
      expect(service.isPro, true);
    });

    test('setProStatus updates state', () async {
      await service.setProStatus(true);
      expect(service.isPro, true);

      await service.setProStatus(false);
      expect(service.isPro, false);
    });
  });
}
