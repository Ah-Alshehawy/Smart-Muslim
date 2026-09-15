import 'package:equatable/equatable.dart';

class QuranSajdahModel extends Equatable {
  final int surahNumber;
  final int ayahNumber;
  final int? sajdahId;
  final bool isRecommended;
  final bool isObligatory;
  final int page;
  final int juz;

  const QuranSajdahModel({
    required this.surahNumber,
    required this.ayahNumber,
    this.sajdahId,
    required this.isRecommended,
    required this.isObligatory,
    required this.page,
    required this.juz,
  });

  factory QuranSajdahModel.fromJson(Map<String, dynamic> json) {
    return QuranSajdahModel(
      surahNumber: json['surah_number'] as int,
      ayahNumber: json['ayah_number'] as int,
      sajdahId: json['sajda_id'] as int?,
      isRecommended: json['recommended'] as bool? ?? false,
      isObligatory: json['obligatory'] as bool? ?? false,
      page: json['page'] as int,
      juz: json['juz'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    if (sajdahId != null) 'sajda_id': sajdahId,
    'recommended': isRecommended,
    'obligatory': isObligatory,
    'page': page,
    'juz': juz,
  };

  @override
  List<Object?> get props => [
        surahNumber,
        ayahNumber,
        sajdahId,
        isRecommended,
        isObligatory,
        page,
        juz,
      ];
}
