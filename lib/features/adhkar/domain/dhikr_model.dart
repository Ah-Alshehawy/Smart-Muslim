import 'package:equatable/equatable.dart';

class DhikrModel extends Equatable {
  final int id;
  final String title;
  final String textArabic;
  final String benefit;
  final String sourceReference;
  final String? grade;
  final int targetCount;

  const DhikrModel({
    required this.id,
    required this.title,
    required this.textArabic,
    required this.benefit,
    required this.sourceReference,
    required this.targetCount,
    this.grade = 'صحيح',
  });

  @override
  List<Object?> get props => [id, title, textArabic, benefit, sourceReference, grade, targetCount];
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
