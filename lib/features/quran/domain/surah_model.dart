import 'package:equatable/equatable.dart';

class SurahModel extends Equatable {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String revelationType; // 'مكية' or 'مدنية' / 'Meccan' or 'Medinan'
  final int totalAyahs;
  final String nameTransliteration;
  final int wordsCount;
  final int lettersCount;
  final int startPage;

  const SurahModel({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.revelationType,
    required this.totalAyahs,
    this.nameTransliteration = '',
    this.wordsCount = 0,
    this.lettersCount = 0,
    this.startPage = 1,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      nameArabic: json['name_ar'] as String? ?? json['nameArabic'] as String? ?? '',
      nameEnglish: json['name_en'] as String? ?? json['nameEnglish'] as String? ?? '',
      revelationType: json['revelation_place_ar'] as String? ?? json['revelationType'] as String? ?? 'مكية',
      totalAyahs: json['verses_count'] as int? ?? json['totalAyahs'] as int? ?? 0,
      nameTransliteration: json['name_transliteration'] as String? ?? '',
      wordsCount: json['words_count'] as int? ?? 0,
      lettersCount: json['letters_count'] as int? ?? 0,
      startPage: json['start_page'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'name_ar': nameArabic,
    'name_en': nameEnglish,
    'name_transliteration': nameTransliteration,
    'revelation_place_ar': revelationType,
    'verses_count': totalAyahs,
    'words_count': wordsCount,
    'letters_count': lettersCount,
    'start_page': startPage,
  };

  @override
  List<Object?> get props => [
        number,
        nameArabic,
        nameEnglish,
        revelationType,
        totalAyahs,
        nameTransliteration,
        wordsCount,
        lettersCount,
        startPage,
      ];
}
