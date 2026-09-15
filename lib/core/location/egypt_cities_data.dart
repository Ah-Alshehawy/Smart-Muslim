import 'location_model.dart';

class EgyptAndWorldCitiesData {
  /// Comprehensive dataset of Egypt's 27 Governorates & Major Cities
  static const List<LocationModel> egyptCities = [
    // 1. القاهرة
    LocationModel(latitude: 30.0444, longitude: 31.2357, cityName: 'القاهرة', countryName: 'مصر', governorate: 'محافظة القاهرة', isAutoGps: false),
    LocationModel(latitude: 30.0131, longitude: 31.4289, cityName: 'القاهرة الجديدة', countryName: 'مصر', governorate: 'محافظة القاهرة', isAutoGps: false),
    LocationModel(latitude: 30.0889, longitude: 31.3439, cityName: 'مدينة نصر / مصر الجديدة', countryName: 'مصر', governorate: 'محافظة القاهرة', isAutoGps: false),
    LocationModel(latitude: 30.1378, longitude: 31.7000, cityName: 'الشروق / بدر / العاصمة الإدارية', countryName: 'مصر', governorate: 'محافظة القاهرة', isAutoGps: false),

    // 2. الجيزة
    LocationModel(latitude: 30.0131, longitude: 31.2089, cityName: 'الجيزة', countryName: 'مصر', governorate: 'محافظة الجيزة', isAutoGps: false),
    LocationModel(latitude: 29.9870, longitude: 30.9500, cityName: 'السادس من أكتوبر', countryName: 'مصر', governorate: 'محافظة الجيزة', isAutoGps: false),
    LocationModel(latitude: 30.0531, longitude: 30.9700, cityName: 'الشيخ زايد', countryName: 'مصر', governorate: 'محافظة الجيزة', isAutoGps: false),

    // 3. الإسكندرية
    LocationModel(latitude: 31.2001, longitude: 29.9187, cityName: 'الإسكندرية', countryName: 'مصر', governorate: 'محافظة الإسكندرية', isAutoGps: false),
    LocationModel(latitude: 30.9833, longitude: 29.6167, cityName: 'برج العرب', countryName: 'مصر', governorate: 'محافظة الإسكندرية', isAutoGps: false),

    // 4. القليوبية
    LocationModel(latitude: 30.4667, longitude: 31.1833, cityName: 'بنها', countryName: 'مصر', governorate: 'محافظة القليوبية', isAutoGps: false),
    LocationModel(latitude: 30.1286, longitude: 31.2422, cityName: 'شبرا الخيمة', countryName: 'مصر', governorate: 'محافظة القليوبية', isAutoGps: false),
    LocationModel(latitude: 30.1794, longitude: 31.4089, cityName: 'العبور', countryName: 'مصر', governorate: 'محافظة القليوبية', isAutoGps: false),

    // 5. الشرقية
    LocationModel(latitude: 30.5877, longitude: 31.5020, cityName: 'الزقازيق', countryName: 'مصر', governorate: 'محافظة الشرقية', isAutoGps: false),
    LocationModel(latitude: 30.2988, longitude: 31.7450, cityName: 'العاشر من رمضان', countryName: 'مصر', governorate: 'محافظة الشرقية', isAutoGps: false),

    // 6. الدقهلية
    LocationModel(latitude: 31.0409, longitude: 31.3785, cityName: 'المنصورة', countryName: 'مصر', governorate: 'محافظة الدقهلية', isAutoGps: false),
    LocationModel(latitude: 31.2583, longitude: 31.3500, cityName: 'بلقاس / شربين', countryName: 'مصر', governorate: 'محافظة الدقهلية', isAutoGps: false),

    // 7. الغربية
    LocationModel(latitude: 30.7865, longitude: 31.0004, cityName: 'طنطا', countryName: 'مصر', governorate: 'محافظة الغربية', isAutoGps: false),
    LocationModel(latitude: 30.9697, longitude: 31.1648, cityName: 'المحلة الكبرى', countryName: 'مصر', governorate: 'محافظة الغربية', isAutoGps: false),

    // 8. المنوفية
    LocationModel(latitude: 30.5598, longitude: 31.0089, cityName: 'شبين الكوم', countryName: 'مصر', governorate: 'محافظة المنوفية', isAutoGps: false),
    LocationModel(latitude: 30.3833, longitude: 30.5167, cityName: 'مدينة السادات', countryName: 'مصر', governorate: 'محافظة المنوفية', isAutoGps: false),

    // 9. كفر الشيخ
    LocationModel(latitude: 31.1107, longitude: 30.9388, cityName: 'كفر الشيخ', countryName: 'مصر', governorate: 'محافظة كفر الشيخ', isAutoGps: false),
    LocationModel(latitude: 31.3833, longitude: 30.6333, cityName: 'دسوق / بلطيم', countryName: 'مصر', governorate: 'محافظة كفر الشيخ', isAutoGps: false),

    // 10. دمياط
    LocationModel(latitude: 31.4175, longitude: 31.8144, cityName: 'دمياط', countryName: 'مصر', governorate: 'محافظة دمياط', isAutoGps: false),
    LocationModel(latitude: 31.4500, longitude: 31.6667, cityName: 'دمياط الجديدة / رأس البر', countryName: 'مصر', governorate: 'محافظة دمياط', isAutoGps: false),

    // 11. بورسعيد
    LocationModel(latitude: 31.2653, longitude: 32.3019, cityName: 'بورسعيد', countryName: 'مصر', governorate: 'محافظة بورسعيد', isAutoGps: false),
    LocationModel(latitude: 31.2600, longitude: 32.3100, cityName: 'بورفؤاد', countryName: 'مصر', governorate: 'محافظة بورسعيد', isAutoGps: false),

    // 12. الإسماعيلية
    LocationModel(latitude: 30.5965, longitude: 32.2715, cityName: 'الإسماعيلية', countryName: 'مصر', governorate: 'محافظة الإسماعيلية', isAutoGps: false),
    LocationModel(latitude: 30.4167, longitude: 32.1833, cityName: 'فايد / القنطرة', countryName: 'مصر', governorate: 'محافظة الإسماعيلية', isAutoGps: false),

    // 13. السويس
    LocationModel(latitude: 29.9668, longitude: 32.5498, cityName: 'السويس', countryName: 'مصر', governorate: 'محافظة السويس', isAutoGps: false),
    LocationModel(latitude: 29.6167, longitude: 32.3333, cityName: 'العين السخنة', countryName: 'مصر', governorate: 'محافظة السويس', isAutoGps: false),

    // 14. البحيرة
    LocationModel(latitude: 31.0364, longitude: 30.4689, cityName: 'دمنهور', countryName: 'مصر', governorate: 'محافظة البحيرة', isAutoGps: false),
    LocationModel(latitude: 30.8333, longitude: 30.5333, cityName: 'إيتاي البارود / كفر الدوار', countryName: 'مصر', governorate: 'محافظة البحيرة', isAutoGps: false),
    LocationModel(latitude: 30.3833, longitude: 30.3500, cityName: 'وادي النطرون', countryName: 'مصر', governorate: 'محافظة البحيرة', isAutoGps: false),

    // 15. الفيوم
    LocationModel(latitude: 29.3082, longitude: 30.8428, cityName: 'الفيوم', countryName: 'مصر', governorate: 'محافظة الفيوم', isAutoGps: false),
    LocationModel(latitude: 29.4167, longitude: 30.6833, cityName: 'سنورس / أبشواي', countryName: 'مصر', governorate: 'محافظة الفيوم', isAutoGps: false),

    // 16. بني سويف
    LocationModel(latitude: 29.0661, longitude: 31.0994, cityName: 'بني سويف', countryName: 'مصر', governorate: 'محافظة بني سويف', isAutoGps: false),
    LocationModel(latitude: 29.1333, longitude: 31.2500, cityName: 'بني سويف الجديدة / الواسطى', countryName: 'مصر', governorate: 'محافظة بني سويف', isAutoGps: false),

    // 17. المنيا
    LocationModel(latitude: 28.1099, longitude: 30.7503, cityName: 'المنيا', countryName: 'مصر', governorate: 'محافظة المنيا', isAutoGps: false),
    LocationModel(latitude: 28.2975, longitude: 30.7558, cityName: 'ملوي / مغاغة', countryName: 'مصر', governorate: 'محافظة المنيا', isAutoGps: false),

    // 18. أسيوط
    LocationModel(latitude: 27.1809, longitude: 31.1837, cityName: 'أسيوط', countryName: 'مصر', governorate: 'محافظة أسيوط', isAutoGps: false),
    LocationModel(latitude: 27.2833, longitude: 31.1667, cityName: 'أسيوط الجديدة / ديروط', countryName: 'مصر', governorate: 'محافظة أسيوط', isAutoGps: false),

    // 19. سوهاج
    LocationModel(latitude: 26.5569, longitude: 31.6948, cityName: 'سوهاج', countryName: 'مصر', governorate: 'محافظة سوهاج', isAutoGps: false),
    LocationModel(latitude: 26.3333, longitude: 31.8167, cityName: 'طهطا / جرجا', countryName: 'مصر', governorate: 'محافظة سوهاج', isAutoGps: false),

    // 20. قنا
    LocationModel(latitude: 26.1551, longitude: 32.7160, cityName: 'قنا', countryName: 'مصر', governorate: 'محافظة قنا', isAutoGps: false),
    LocationModel(latitude: 26.0333, longitude: 32.2833, cityName: 'نجع حمادي / قوص', countryName: 'مصر', governorate: 'محافظة قنا', isAutoGps: false),

    // 21. الأقصر
    LocationModel(latitude: 25.6872, longitude: 32.6396, cityName: 'الأقصر', countryName: 'مصر', governorate: 'محافظة الأقصر', isAutoGps: false),
    LocationModel(latitude: 25.6000, longitude: 32.5500, cityName: 'إسنا / أرمنت', countryName: 'مصر', governorate: 'محافظة الأقصر', isAutoGps: false),

    // 22. أسوان
    LocationModel(latitude: 24.0889, longitude: 32.8998, cityName: 'أسوان', countryName: 'مصر', governorate: 'محافظة أسوان', isAutoGps: false),
    LocationModel(latitude: 24.4667, longitude: 32.9500, cityName: 'كوم أمبو / إدفو', countryName: 'مصر', governorate: 'محافظة أسوان', isAutoGps: false),
    LocationModel(latitude: 22.3500, longitude: 31.6167, cityName: 'أبو سمبل', countryName: 'مصر', governorate: 'محافظة أسوان', isAutoGps: false),

    // 23. البحر الأحمر
    LocationModel(latitude: 27.2579, longitude: 33.8116, cityName: 'الغردقة', countryName: 'مصر', governorate: 'محافظة البحر الأحمر', isAutoGps: false),
    LocationModel(latitude: 26.1167, longitude: 34.2833, cityName: 'القصير / سفاجا', countryName: 'مصر', governorate: 'محافظة البحر الأحمر', isAutoGps: false),
    LocationModel(latitude: 25.0667, longitude: 34.8833, cityName: 'مرسى علم / الشلاتين', countryName: 'مصر', governorate: 'محافظة البحر الأحمر', isAutoGps: false),

    // 24. الوادي الجديد
    LocationModel(latitude: 25.4514, longitude: 30.5463, cityName: 'الخارجة', countryName: 'مصر', governorate: 'محافظة الوادي الجديد', isAutoGps: false),
    LocationModel(latitude: 25.6833, longitude: 28.9833, cityName: 'الداخلة / الفرافرة', countryName: 'مصر', governorate: 'محافظة الوادي الجديد', isAutoGps: false),

    // 25. مطروح
    LocationModel(latitude: 31.3543, longitude: 27.2373, cityName: 'مرسى مطروح', countryName: 'مصر', governorate: 'محافظة مطروح', isAutoGps: false),
    LocationModel(latitude: 30.8333, longitude: 28.9500, cityName: 'العلمين / الساحل الشمالي', countryName: 'مصر', governorate: 'محافظة مطروح', isAutoGps: false),
    LocationModel(latitude: 29.2000, longitude: 25.5167, cityName: 'سيوة / الضبعة', countryName: 'مصر', governorate: 'محافظة مطروح', isAutoGps: false),

    // 26. شمال سيناء
    LocationModel(latitude: 31.1325, longitude: 33.8033, cityName: 'العريش', countryName: 'مصر', governorate: 'محافظة شمال سيناء', isAutoGps: false),
    LocationModel(latitude: 31.2833, longitude: 34.2333, cityName: 'رفح / الشيخ زويد', countryName: 'مصر', governorate: 'محافظة شمال سيناء', isAutoGps: false),

    // 27. جنوب سيناء
    LocationModel(latitude: 27.9158, longitude: 34.3299, cityName: 'شرم الشيخ', countryName: 'مصر', governorate: 'محافظة جنوب سيناء', isAutoGps: false),
    LocationModel(latitude: 28.5000, longitude: 34.5167, cityName: 'دهب / نويبع / طابا', countryName: 'مصر', governorate: 'محافظة جنوب سيناء', isAutoGps: false),
    LocationModel(latitude: 28.5500, longitude: 33.9500, cityName: 'سانت كاترين / طور سيناء', countryName: 'مصر', governorate: 'محافظة جنوب سيناء', isAutoGps: false),
  ];

  /// Arab Capitals and Major Islamic Centers
  static const List<LocationModel> arabAndWorldCities = [
    LocationModel(latitude: 21.4225, longitude: 39.8262, cityName: 'مكة المكرمة', countryName: 'المملكة العربية السعودية', governorate: 'منطقة مكة المكرمة', isAutoGps: false),
    LocationModel(latitude: 24.4672, longitude: 39.6112, cityName: 'المدينة المنورة', countryName: 'المملكة العربية السعودية', governorate: 'منطقة المدينة المنورة', isAutoGps: false),
    LocationModel(latitude: 24.7136, longitude: 46.6753, cityName: 'الرياض', countryName: 'المملكة العربية السعودية', governorate: 'منطقة الرياض', isAutoGps: false),
    LocationModel(latitude: 21.5433, longitude: 39.1728, cityName: 'جدة', countryName: 'المملكة العربية السعودية', governorate: 'منطقة مكة المكرمة', isAutoGps: false),
    LocationModel(latitude: 31.7683, longitude: 35.2137, cityName: 'القدس الشريف', countryName: 'فلسطين', governorate: 'محافظة القدس', isAutoGps: false),
    LocationModel(latitude: 31.5017, longitude: 34.4668, cityName: 'غزة', countryName: 'فلسطين', governorate: 'قطاع غزة', isAutoGps: false),
    LocationModel(latitude: 25.2048, longitude: 55.2708, cityName: 'دبي', countryName: 'الإمارات العربية المتحدة', governorate: 'إمارة دبي', isAutoGps: false),
    LocationModel(latitude: 24.4539, longitude: 54.3773, cityName: 'أبو ظبي', countryName: 'الإمارات العربية المتحدة', governorate: 'إمارة أبو ظبي', isAutoGps: false),
    LocationModel(latitude: 31.9539, longitude: 35.9106, cityName: 'عمان', countryName: 'الأردن', governorate: 'محافظة العاصمة', isAutoGps: false),
    LocationModel(latitude: 33.5138, longitude: 36.2765, cityName: 'دمشق', countryName: 'سوريا', governorate: 'دمشق', isAutoGps: false),
    LocationModel(latitude: 33.8938, longitude: 35.5018, cityName: 'بيروت', countryName: 'لبنان', governorate: 'بيروت', isAutoGps: false),
    LocationModel(latitude: 33.3152, longitude: 44.3661, cityName: 'بغداد', countryName: 'العراق', governorate: 'محافظة بغداد', isAutoGps: false),
    LocationModel(latitude: 29.3759, longitude: 47.9774, cityName: 'الكويت', countryName: 'الكويت', governorate: 'العاصمة', isAutoGps: false),
    LocationModel(latitude: 25.2854, longitude: 51.5310, cityName: 'الدوحة', countryName: 'قطر', governorate: 'الدوحة', isAutoGps: false),
    LocationModel(latitude: 26.2285, longitude: 50.5860, cityName: 'المنامة', countryName: 'البحرين', governorate: 'محافظة العاصمة', isAutoGps: false),
    LocationModel(latitude: 23.5880, longitude: 58.3829, cityName: 'مسقط', countryName: 'سلطنة عمان', governorate: 'محافظة مسقط', isAutoGps: false),
    LocationModel(latitude: 15.3694, longitude: 44.1910, cityName: 'صنعاء', countryName: 'اليمن', governorate: 'أمانة العاصمة', isAutoGps: false),
    LocationModel(latitude: 36.8065, longitude: 10.1815, cityName: 'تونس', countryName: 'تونس', governorate: 'ولاية تونس', isAutoGps: false),
    LocationModel(latitude: 36.7538, longitude: 3.0588, cityName: 'الجزائر', countryName: 'الجزائر', governorate: 'ولاية الجزائر', isAutoGps: false),
    LocationModel(latitude: 34.0209, longitude: -6.8416, cityName: 'الرباط', countryName: 'المغرب', governorate: 'جهة الرباط', isAutoGps: false),
    LocationModel(latitude: 33.5731, longitude: -7.5898, cityName: 'الدار البيضاء', countryName: 'المغرب', governorate: 'جهة الدار البيضاء', isAutoGps: false),
    LocationModel(latitude: 32.8872, longitude: 13.1913, cityName: 'طرابلس', countryName: 'ليبيا', governorate: 'شعبية طرابلس', isAutoGps: false),
    LocationModel(latitude: 15.5007, longitude: 32.5599, cityName: 'الخرطوم', countryName: 'السودان', governorate: 'ولاية الخرطوم', isAutoGps: false),
    LocationModel(latitude: 41.0082, longitude: 28.9784, cityName: 'إسطنبول', countryName: 'تركيا', governorate: 'إسطنبول', isAutoGps: false),
    LocationModel(latitude: 51.5074, longitude: -0.1278, cityName: 'لندن (London)', countryName: 'المملكة المتحدة (UK)', governorate: 'Greater London', isAutoGps: false),
    LocationModel(latitude: 48.8566, longitude: 2.3522, cityName: 'باريس (Paris)', countryName: 'فرنسا (France)', governorate: 'Île-de-France', isAutoGps: false),
    LocationModel(latitude: 40.7128, longitude: -74.0060, cityName: 'نيويورك (New York)', countryName: 'الولايات المتحدة (USA)', governorate: 'New York', isAutoGps: false),
    LocationModel(latitude: 3.1390, longitude: 101.6869, cityName: 'كوالالمبور (Kuala Lumpur)', countryName: 'ماليزيا (Malaysia)', governorate: 'Wilayah Persekutuan', isAutoGps: false),
    LocationModel(latitude: -6.2088, longitude: 106.8456, cityName: 'جاكرتا (Jakarta)', countryName: 'إندونيسيا (Indonesia)', governorate: 'DKI Jakarta', isAutoGps: false),
  ];

  static List<LocationModel> getAllCities() {
    return [...egyptCities, ...arabAndWorldCities];
  }
}
