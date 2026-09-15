import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  const sampleRate = 44100;
  const durationSec = 0.50; // 500 milliseconds (optimal for ExoPlayer buffer & audible clarity)
  const baseFrequency = 880.0; // A5 note - clear, elegant, warm chime
  const harmonicFrequency = 1760.0; // A6 harmonic overtone for natural timbre
  const maxAmplitude = 26000.0; // Clear volume through mobile speakers

  final totalSamples = (sampleRate * durationSec).round();
  final attackSamples = (sampleRate * 0.03).round(); // 30ms smooth fade-in
  final decaySamples = totalSamples - attackSamples;

  final pcmData = Int16List(totalSamples);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final fundamental = math.sin(2 * math.pi * baseFrequency * t);
    final harmonic = 0.25 * math.sin(2 * math.pi * harmonicFrequency * t);
    final waveVal = (fundamental + harmonic) / 1.25;

    double envelope;
    if (i < attackSamples) {
      envelope = i / attackSamples;
    } else {
      final decayProgress = (i - attackSamples) / decaySamples;
      // Natural smooth exponential chime decay
      envelope = math.exp(-4.0 * decayProgress);
    }

    final sample = (waveVal * envelope * maxAmplitude).clamp(-32768.0, 32767.0).round();
    pcmData[i] = sample;
  }

  final dataByteLength = totalSamples * 2;
  final wavHeader = ByteData(44);

  // RIFF Chunk
  wavHeader.setUint8(0, 0x52); // 'R'
  wavHeader.setUint8(1, 0x49); // 'I'
  wavHeader.setUint8(2, 0x46); // 'F'
  wavHeader.setUint8(3, 0x46); // 'F'
  wavHeader.setUint32(4, 36 + dataByteLength, Endian.little);
  wavHeader.setUint8(8, 0x57);  // 'W'
  wavHeader.setUint8(9, 0x41);  // 'A'
  wavHeader.setUint8(10, 0x56); // 'V'
  wavHeader.setUint8(11, 0x45); // 'E'

  // fmt subchunk
  wavHeader.setUint8(12, 0x66); // 'f'
  wavHeader.setUint8(13, 0x6D); // 'm'
  wavHeader.setUint8(14, 0x74); // 't'
  wavHeader.setUint8(15, 0x20); // ' '
  wavHeader.setUint32(16, 16, Endian.little); // PCM chunk size
  wavHeader.setUint16(20, 1, Endian.little);  // PCM format
  wavHeader.setUint16(22, 1, Endian.little);  // Mono
  wavHeader.setUint32(24, sampleRate, Endian.little);
  wavHeader.setUint32(28, sampleRate * 2, Endian.little); // Byte rate (44100 * 2)
  wavHeader.setUint16(32, 2, Endian.little);  // Block align
  wavHeader.setUint16(34, 16, Endian.little); // Bits per sample

  // data subchunk
  wavHeader.setUint8(36, 0x64); // 'd'
  wavHeader.setUint8(37, 0x61); // 'a'
  wavHeader.setUint8(38, 0x74); // 't'
  wavHeader.setUint8(39, 0x61); // 'a'
  wavHeader.setUint32(40, dataByteLength, Endian.little);

  final byteList = Uint8List(44 + dataByteLength);
  byteList.setRange(0, 44, wavHeader.buffer.asUint8List());
  byteList.setRange(44, 44 + dataByteLength, pcmData.buffer.asUint8List());

  final assetFile = File('assets/audio/tasbih_beep.wav');
  assetFile.writeAsBytesSync(byteList);
  stdout.writeln('Generated ${assetFile.path}: ${byteList.length} bytes');

  final rawFile = File('android/app/src/main/res/raw/tasbih_beep.wav');
  if (rawFile.parent.existsSync()) {
    rawFile.writeAsBytesSync(byteList);
    stdout.writeln('Copied to ${rawFile.path}: ${byteList.length} bytes');
  }
}
