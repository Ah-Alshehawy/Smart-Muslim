import 'package:equatable/equatable.dart';

/// Inclusive range of ayahs whose verbatim Tanzil text forms part of a dhikr.
class QuranVerseRange extends Equatable {
  final int surah;
  final int fromAyah;
  final int toAyah;

  const QuranVerseRange(this.surah, this.fromAyah, this.toAyah);

  @override
  List<Object?> get props => [surah, fromAyah, toAyah];
}

class DhikrModel extends Equatable {
  final int id;
  final String title;
  final String textArabic;

  /// Reward stated in the narration itself (by meaning). Empty when the
  /// narration states no specific reward — never fill with editorial text.
  final String fadl;

  /// Editorial note (meaning or context), displayed separately from [fadl].
  final String note;
  final String sourceReference;
  final String? grade;
  final int targetCount;

  /// True when [textArabic] is a shortened form of the narrated text.
  final bool isAbridged;

  /// Quranic content of the dhikr; [textArabic] must equal the verbatim
  /// Tanzil text of these ranges (enforced by tests).
  final List<QuranVerseRange> quranVerses;

  const DhikrModel({
    required this.id,
    required this.title,
    required this.textArabic,
    required this.sourceReference,
    required this.targetCount,
    this.fadl = '',
    this.note = '',
    this.grade = 'صحيح',
    this.isAbridged = false,
    this.quranVerses = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        textArabic,
        fadl,
        note,
        sourceReference,
        grade,
        targetCount,
        isAbridged,
        quranVerses,
      ];
}

class DhikrCategoryModel extends Equatable {
  final String id;
  final String title;
  final String iconName;
  final List<DhikrModel> items;

  const DhikrCategoryModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.items,
  });

  @override
  List<Object?> get props => [id, title, iconName, items];
}
