import 'package:equatable/equatable.dart';

class AyahModel extends Equatable {
  final int surahNumber;
  final int numberInSurah;
  final String textUthmani;
  final String textEnglish;
  final int juz;
  final int page;
  final bool isSajdah;
  final int? sajdahId;

  const AyahModel({
    required this.surahNumber,
    required this.numberInSurah,
    required this.textUthmani,
    this.textEnglish = '',
    required this.juz,
    required this.page,
    this.isSajdah = false,
    this.sajdahId,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      surahNumber: json['surah'] as int? ?? json['surahNumber'] as int? ?? 1,
      numberInSurah: json['ayah'] as int? ?? json['numberInSurah'] as int? ?? json['number'] as int? ?? 1,
      textUthmani: json['text'] as String? ?? json['textUthmani'] as String? ?? '',
      textEnglish: json['text_en'] as String? ?? json['textEnglish'] as String? ?? '',
      juz: json['juz'] as int? ?? 1,
      page: json['page'] as int? ?? 1,
      isSajdah: json['sajda'] == true || (json['isSajdah'] == true),
      sajdahId: json['sajda_id'] as int? ?? json['sajdahId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'surah': surahNumber,
    'ayah': numberInSurah,
    'text': textUthmani,
    'text_en': textEnglish,
    'juz': juz,
    'page': page,
    'sajda': isSajdah,
    if (sajdahId != null) 'sajda_id': sajdahId,
  };

  @override
  List<Object?> get props => [
        surahNumber,
        numberInSurah,
        textUthmani,
        textEnglish,
        juz,
        page,
        isSajdah,
        sajdahId,
      ];
}
