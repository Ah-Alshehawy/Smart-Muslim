import 'package:equatable/equatable.dart';

class QuranPageModel extends Equatable {
  final int pageNumber;
  final int startSurahNumber;
  final int startAyahNumber;
  final int endSurahNumber;
  final int endAyahNumber;

  const QuranPageModel({
    required this.pageNumber,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.endSurahNumber,
    required this.endAyahNumber,
  });

  factory QuranPageModel.fromJson(Map<String, dynamic> json) {
    return QuranPageModel(
      pageNumber: json['page'] as int,
      startSurahNumber: json['start_surah'] as int,
      startAyahNumber: json['start_ayah'] as int,
      endSurahNumber: json['end_surah'] as int,
      endAyahNumber: json['end_ayah'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': pageNumber,
    'start_surah': startSurahNumber,
    'start_ayah': startAyahNumber,
    'end_surah': endSurahNumber,
    'end_ayah': endAyahNumber,
  };

  @override
  List<Object?> get props => [
        pageNumber,
        startSurahNumber,
        startAyahNumber,
        endSurahNumber,
        endAyahNumber,
      ];
}
