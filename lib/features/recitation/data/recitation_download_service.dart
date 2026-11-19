import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../domain/reciter_model.dart';

/// Stores downloaded surah recitations under the app documents directory:
/// `recitations/<reciter.key>/<NNN>.mp3`. Files are written to a `.part`
/// file first and renamed only after the full body has arrived, so an
/// interrupted download never looks complete.
class RecitationDownloadService {
  RecitationDownloadService({http.Client? client, Future<Directory> Function()? baseDirectory})
      : _client = client ?? http.Client(),
        _baseDirectory = baseDirectory ?? getApplicationDocumentsDirectory;

  final http.Client _client;
  final Future<Directory> Function() _baseDirectory;

  Future<Directory> _reciterDir(ReciterModel reciter) async {
    final base = await _baseDirectory();
    return Directory('${base.path}${Platform.pathSeparator}recitations'
        '${Platform.pathSeparator}${reciter.key}');
  }

  Future<File> localFile(ReciterModel reciter, int surahNumber) async {
    final dir = await _reciterDir(reciter);
    return File('${dir.path}${Platform.pathSeparator}${surahNumber.toString().padLeft(3, '0')}.mp3');
  }

  Future<bool> isDownloaded(ReciterModel reciter, int surahNumber) async {
    return (await localFile(reciter, surahNumber)).exists();
  }

  /// Surah numbers already downloaded for [reciter].
  Future<Set<int>> downloadedSurahs(ReciterModel reciter) async {
    final dir = await _reciterDir(reciter);
    if (!await dir.exists()) return {};
    final result = <int>{};
    await for (final entity in dir.list()) {
      final name = entity.uri.pathSegments.last;
      if (entity is File && name.endsWith('.mp3')) {
        final number = int.tryParse(name.substring(0, name.length - 4));
        if (number != null) result.add(number);
      }
    }
    return result;
  }

  /// Downloads one surah. [onProgress] receives 0.0–1.0, or null when the
  /// server does not report a size. Throws [HttpException] on failure.
  Future<File> download(
    ReciterModel reciter,
    int surahNumber, {
    void Function(double? progress)? onProgress,
  }) async {
    final target = await localFile(reciter, surahNumber);
    await target.parent.create(recursive: true);
    final partial = File('${target.path}.part');

    final response = await _client.send(http.Request('GET', Uri.parse(reciter.surahUrl(surahNumber))));
    if (response.statusCode != 200) {
      await response.stream.drain<void>();
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(reciter.surahUrl(surahNumber)));
    }

    final total = response.contentLength;
    var received = 0;
    final sink = partial.openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(total != null && total > 0 ? received / total : null);
      }
      await sink.close();
    } catch (_) {
      await sink.close();
      if (await partial.exists()) await partial.delete();
      rethrow;
    }

    if (received == 0 || (total != null && received != total)) {
      await partial.delete();
      throw HttpException('Incomplete download ($received of ${total ?? '?'} bytes)',
          uri: Uri.parse(reciter.surahUrl(surahNumber)));
    }
    return partial.rename(target.path);
  }

  Future<void> delete(ReciterModel reciter, int surahNumber) async {
    final file = await localFile(reciter, surahNumber);
    if (await file.exists()) await file.delete();
  }

  /// Total bytes used by downloaded recitations of [reciter].
  Future<int> storageBytes(ReciterModel reciter) async {
    final dir = await _reciterDir(reciter);
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.mp3')) total += await entity.length();
    }
    return total;
  }
}
