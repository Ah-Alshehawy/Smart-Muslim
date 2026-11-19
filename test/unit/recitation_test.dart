import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_muslim/features/recitation/data/recitation_download_service.dart';
import 'package:smart_muslim/features/recitation/data/reciters_data.dart';
import 'package:smart_muslim/features/recitation/domain/reciter_model.dart';

void main() {
  group('Reciters data', () {
    test('Every reciter is a unique Hafs recitation served over HTTPS', () {
      expect(RecitersData.reciters, isNotEmpty);
      final keys = RecitersData.reciters.map((r) => r.key).toSet();
      expect(keys.length, RecitersData.reciters.length);
      for (final r in RecitersData.reciters) {
        expect(r.serverUrl.startsWith('https://'), isTrue, reason: r.nameEnglish);
        expect(r.serverUrl.endsWith('/'), isTrue, reason: r.nameEnglish);
        expect(r.moshafNameArabic.contains('حفص عن عاصم'), isTrue, reason: r.nameEnglish);
        expect(r.nameArabic.trim(), isNotEmpty);
      }
    });

    test('Surah URLs use three-digit file names and reject out-of-range surahs', () {
      final r = RecitersData.reciters.first;
      expect(r.surahUrl(1), '${r.serverUrl}001.mp3');
      expect(r.surahUrl(114), '${r.serverUrl}114.mp3');
      expect(() => r.surahUrl(0), throwsRangeError);
      expect(() => r.surahUrl(115), throwsRangeError);
    });
  });

  group('RecitationDownloadService', () {
    const reciter = ReciterModel(
      id: 1,
      moshafId: 1,
      nameArabic: 'قارئ',
      nameEnglish: 'Reciter',
      moshafNameArabic: 'حفص عن عاصم - مرتل',
      serverUrl: 'https://example.test/r1/',
    );
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('recitation_test');
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    RecitationDownloadService serviceWith(MockClientStreamHandler handler) =>
        RecitationDownloadService(client: MockClient.streaming(handler), baseDirectory: () async => tempDir);

    test('Completed download is saved, listed, sized and deletable', () async {
      final bytes = List<int>.generate(1000, (i) => i % 256);
      final service = serviceWith((request, _) async {
        expect(request.url.toString(), 'https://example.test/r1/002.mp3');
        return http.StreamedResponse(Stream.fromIterable([bytes.sublist(0, 400), bytes.sublist(400)]), 200,
            contentLength: bytes.length);
      });

      final progress = <double?>[];
      final file = await service.download(reciter, 2, onProgress: progress.add);

      expect(await file.readAsBytes(), bytes);
      expect(progress.last, 1.0);
      expect(await service.downloadedSurahs(reciter), {2});
      expect(await service.storageBytes(reciter), 1000);
      expect(await File('${file.path}.part').exists(), isFalse);

      await service.delete(reciter, 2);
      expect(await service.isDownloaded(reciter, 2), isFalse);
    });

    test('HTTP error leaves no file behind', () async {
      final service = serviceWith((_, __) async => http.StreamedResponse(Stream.value([1, 2, 3]), 404));
      await expectLater(service.download(reciter, 3), throwsA(isA<HttpException>()));
      expect(await service.isDownloaded(reciter, 3), isFalse);
      expect(await service.downloadedSurahs(reciter), isEmpty);
    });

    test('Truncated download is discarded instead of saved as complete', () async {
      final service = serviceWith((_, __) async =>
          http.StreamedResponse(Stream.value(List<int>.filled(500, 7)), 200, contentLength: 1000));
      await expectLater(service.download(reciter, 4), throwsA(isA<HttpException>()));
      final file = await service.localFile(reciter, 4);
      expect(await file.exists(), isFalse);
      expect(await File('${file.path}.part').exists(), isFalse);
    });
  });
}
