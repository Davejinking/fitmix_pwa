import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class SoundGenerator {
  /// Generate a WAV file with a sine wave tone
  static Future<String> generateTone({
    required String filename,
    required double frequency, // Hz
    required double duration, // Seconds
    double volume = 0.5,
    int sampleRate = 44100,
  }) async {
    final int numSamples = (duration * sampleRate).toInt();
    final int numChannels = 1;
    final int byteRate = sampleRate * numChannels * 2; // 16-bit
    final int blockAlign = numChannels * 2;
    final int dataSize = numSamples * blockAlign;
    final int fileSize = 36 + dataSize;

    final ByteData header = ByteData(44);

    // RIFF chunk
    _writeString(header, 0, 'RIFF');
    header.setUint32(4, fileSize, Endian.little);
    _writeString(header, 8, 'WAVE');

    // fmt chunk
    _writeString(header, 12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little); // AudioFormat (PCM)
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, 16, Endian.little); // BitsPerSample

    // data chunk
    _writeString(header, 36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    // PCM Data
    final Int16List pcmData = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      final double time = i / sampleRate;
      final double angle = 2 * pi * frequency * time;
      // Apply a simple envelope (fade in/out) to avoid clicks
      double amplitude = volume;
      if (i < 500) amplitude *= (i / 500); // Fade in
      if (i > numSamples - 500) amplitude *= ((numSamples - i) / 500); // Fade out

      pcmData[i] = (sin(angle) * 32767 * amplitude).toInt();
    }

    // Write to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');

    final BytesBuilder bytes = BytesBuilder();
    bytes.add(header.buffer.asUint8List());
    bytes.add(pcmData.buffer.asUint8List());

    await file.writeAsBytes(bytes.toBytes());
    return file.path;
  }

  static void _writeString(ByteData data, int offset, String value) {
    for (int i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }
}
