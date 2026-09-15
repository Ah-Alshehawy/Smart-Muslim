import 'package:equatable/equatable.dart';

class QuranJuzModel extends Equatable {
  final int juzNumber;
  final int startSurahNumber;
  final int startAyahNumber;
  final int endSurahNumber;
  final int endAyahNumber;
  final int startPage;
  final int endPage;
  final int totalAyahs;

  const QuranJuzModel({
    required this.juzNumber,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.endSurahNumber,
    required this.endAyahNumber,
    required this.startPage,
    required this.endPage,
    required this.totalAyahs,
  });

  factory QuranJuzModel.fromJson(Map<String, dynamic> json) {
    return QuranJuzModel(
      juzNumber: json['juz'] as int,
      startSurahNumber: json['start_surah'] as int,
      startAyahNumber: json['start_ayah'] as int,
      endSurahNumber: json['end_surah'] as int,
      endAyahNumber: json['end_ayah'] as int,
      startPage: json['start_page'] as int,
      endPage: json['end_page'] as int,
      totalAyahs: json['total_ayahs'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'juz': juzNumber,
    'start_surah': startSurahNumber,
    'start_ayah': startAyahNumber,
    'end_surah': endSurahNumber,
    'end_ayah': endAyahNumber,
    'start_page': startPage,
    'end_page': endPage,
    'total_ayahs': totalAyahs,
  };

  @override
  List<Object?> get props => [
        juzNumber,
        startSurahNumber,
        startAyahNumber,
        endSurahNumber,
        endAyahNumber,
        startPage,
        endPage,
        totalAyahs,
      ];
}
