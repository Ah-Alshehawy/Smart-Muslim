import 'package:equatable/equatable.dart';

/// A full-Quran recitation (one reciter, one moshaf) served as one MP3 per surah.
class ReciterModel extends Equatable {
  final int id;
  final int moshafId;
  final String nameArabic;
  final String nameEnglish;
  final String moshafNameArabic;

  /// Base URL ending with '/'; surah N is at `${serverUrl}NNN.mp3`.
  final String serverUrl;

  const ReciterModel({
    required this.id,
    required this.moshafId,
    required this.nameArabic,
    required this.nameEnglish,
    required this.moshafNameArabic,
    required this.serverUrl,
  });

  /// Stable key used for storage paths and preferences.
  String get key => '${id}_$moshafId';

  String surahUrl(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
    }
    return '$serverUrl${surahNumber.toString().padLeft(3, '0')}.mp3';
  }

  @override
  List<Object?> get props => [id, moshafId, nameArabic, nameEnglish, moshafNameArabic, serverUrl];
}
