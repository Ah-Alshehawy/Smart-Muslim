import 'dart:io';

/// Type-safe identifier for all available Adhan alert sounds.
enum AdhanSoundId {
  makkah,
  takbeer,
  beep,
  fajr_makkah,
  fajr_madina,
  aqsa,
  rifaat,
  banna,
  shuaisha,
  husary,
  mustafa,
  abdulbasit,
  qatami,
  dosari;

  static AdhanSoundId fromKey(String? key) {
    if (key == null) return AdhanSoundId.makkah;
    switch (key.toLowerCase().trim()) {
      case 'takbeer': return AdhanSoundId.takbeer;
      case 'beep': return AdhanSoundId.beep;
      case 'fajr_makkah': return AdhanSoundId.fajr_makkah;
      case 'fajr_madina': return AdhanSoundId.fajr_madina;
      case 'aqsa': return AdhanSoundId.aqsa;
      case 'rifaat': return AdhanSoundId.rifaat;
      case 'banna': return AdhanSoundId.banna;
      case 'shuaisha': return AdhanSoundId.shuaisha;
      case 'husary': return AdhanSoundId.husary;
      case 'mustafa': return AdhanSoundId.mustafa;
      case 'abdulbasit': return AdhanSoundId.abdulbasit;
      case 'qatami': return AdhanSoundId.qatami;
      case 'dosari': return AdhanSoundId.dosari;
      case 'madinah': return AdhanSoundId.fajr_madina;
      case 'makkah':
      default: return AdhanSoundId.makkah;
    }
  }

  String get key => name;

  String get titleArabic {
    switch (this) {
      case AdhanSoundId.makkah: return 'أذان الحرم المكي';
      case AdhanSoundId.takbeer: return 'تكبيرات فقط';
      case AdhanSoundId.beep: return 'نغمة هادئة';
      case AdhanSoundId.fajr_makkah: return 'أذان الفجر - الحرم المكي';
      case AdhanSoundId.fajr_madina: return 'أذان الفجر - الحرم المدني';
      case AdhanSoundId.aqsa: return 'أذان المسجد الأقصى';
      case AdhanSoundId.rifaat: return 'أذان الشيخ محمد رفعت';
      case AdhanSoundId.banna: return 'أذان الشيخ محمود علي البنا';
      case AdhanSoundId.shuaisha: return 'أذان الشيخ أبو العينين شعيشع';
      case AdhanSoundId.husary: return 'أذان الشيخ الحصري';
      case AdhanSoundId.mustafa: return 'أذان الشيخ مصطفى إسماعيل';
      case AdhanSoundId.abdulbasit: return 'أذان الشيخ عبد الباسط';
      case AdhanSoundId.qatami: return 'أذان الشيخ ناصر القطامي';
      case AdhanSoundId.dosari: return 'أذان الشيخ ياسر الدوسري';
    }
  }

  String get titleEnglish {
    switch (this) {
      case AdhanSoundId.makkah: return 'Makkah Adhan';
      case AdhanSoundId.takbeer: return 'Takbeer Only';
      case AdhanSoundId.beep: return 'Gentle Chime';
      case AdhanSoundId.fajr_makkah: return 'Fajr - Makkah';
      case AdhanSoundId.fajr_madina: return 'Fajr - Madinah';
      case AdhanSoundId.aqsa: return 'Al-Aqsa Adhan';
      case AdhanSoundId.rifaat: return 'Sheikh Rifaat';
      case AdhanSoundId.banna: return 'Sheikh Al-Banna';
      case AdhanSoundId.shuaisha: return 'Sheikh Shuaisha';
      case AdhanSoundId.husary: return 'Sheikh Al-Husary';
      case AdhanSoundId.mustafa: return 'Sheikh Mustafa Ismail';
      case AdhanSoundId.abdulbasit: return 'Sheikh Abdul Basit';
      case AdhanSoundId.qatami: return 'Sheikh Al-Qatami';
      case AdhanSoundId.dosari: return 'Sheikh Al-Dosari';
    }
  }

  String get assetPath {
    switch (this) {
      case AdhanSoundId.makkah: return 'assets/audio/adhan.ogg';
      case AdhanSoundId.takbeer: return 'assets/audio/takbeer.ogg';
      case AdhanSoundId.beep: return 'assets/audio/tasbih_beep.wav';
      default: return 'assets/audio/adhan_${name}.mp3';
    }
  }

  String get androidRawResourceName {
    switch (this) {
      case AdhanSoundId.makkah: return 'adhan';
      case AdhanSoundId.takbeer: return 'takbeer';
      case AdhanSoundId.beep: return 'tasbih_beep';
      default: return 'adhan_${name}';
    }
  }

  String get androidChannelId {
    switch (this) {
      case AdhanSoundId.makkah: return 'smart_muslim_channel_adhan_makkah_v4';
      case AdhanSoundId.takbeer: return 'smart_muslim_channel_takbeer_v4';
      case AdhanSoundId.beep: return 'smart_muslim_channel_chime_v4';
      default: return 'smart_muslim_channel_adhan_${name}_v4';
    }
  }

  String get androidChannelNameArabic {
    switch (this) {
      case AdhanSoundId.makkah: return 'إشعارات أذان الحرم المكي';
      case AdhanSoundId.takbeer: return 'إشعارات تكبيرات الصلاة';
      case AdhanSoundId.beep: return 'إشعارات الصلاة النغمية';
      default: return 'إشعارات $titleArabic';
    }
  }

  String get androidChannelDescriptionArabic {
    switch (this) {
      case AdhanSoundId.makkah: return 'تنبيهات أذان الحرم المكي لدخول وقت الصلاة';
      case AdhanSoundId.takbeer: return 'تنبيهات بتكبيرات فقط لدخول وقت الصلاة';
      case AdhanSoundId.beep: return 'تنبيهات نغمية هادئة لدخول وقت الصلاة';
      default: return 'تنبيهات $titleArabic لدخول وقت الصلاة';
    }
  }
}

/// Single Source of Truth for resolving Adhan sound configuration across
/// UI settings, audio preview, notification channels, and alarm schedules.
abstract class AdhanSoundResolver {
  static const String silentChannelId = 'smart_muslim_channel_silent_v4';
  static const String silentChannelNameArabic = 'إشعارات الصلاة الصامتة';
  static const String silentChannelDescriptionArabic = 'تنبيهات صامتة بدون صوت لدخول وقت الصلاة';

  /// Resolves raw string key into a valid [AdhanSoundId]
  static AdhanSoundId resolve(String? soundKey) => AdhanSoundId.fromKey(soundKey);

  /// Returns Flutter asset path for in-app preview and playback
  static String getAssetPath(String? soundKey) => resolve(soundKey).assetPath;

  /// Returns Android raw resource identifier for platform notification sound
  static String getAndroidRawResource(String? soundKey) => resolve(soundKey).androidRawResourceName;

  /// Returns deterministic Android Notification Channel ID for this sound
  static String getChannelId({required bool audioEnabled, String? soundKey}) {
    if (!audioEnabled) return silentChannelId;
    return resolve(soundKey).androidChannelId;
  }

  /// List of all supported and verified audio options
  static List<AdhanSoundId> get availableSounds => AdhanSoundId.values;
}
