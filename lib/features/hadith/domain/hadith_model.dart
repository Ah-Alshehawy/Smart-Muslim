import 'package:equatable/equatable.dart';

class HadithModel extends Equatable {
  final int number;
  final String title;
  final String narrator;
  final String textArabic;
  final String explanation;
  final String sourceBook;
  final String collection; // e.g. 'الأربعون النووية', 'صحيح البخاري', 'صحيح مسلم', 'رياض الصالحين'
  final String grade; // e.g. 'صحيح متفق عليه', 'صحيح', 'حسن'
  final String? gradeSource;
  final String? chapter;
  final String? hadithNumberInBook;
  final List<String> topics;
  final bool isMutafaqAlayh;

  const HadithModel({
    required this.number,
    required this.title,
    required this.narrator,
    required this.textArabic,
    required this.explanation,
    required this.sourceBook,
    required this.grade,
    this.collection = 'الأربعون النووية',
    this.gradeSource,
    this.chapter,
    this.hadithNumberInBook,
    this.topics = const [],
    this.isMutafaqAlayh = false,
  });

  @override
  List<Object?> get props => [
        number,
        title,
        narrator,
        textArabic,
        explanation,
        sourceBook,
        collection,
        grade,
        gradeSource,
        chapter,
        hadithNumberInBook,
        topics,
        isMutafaqAlayh,
      ];
}
