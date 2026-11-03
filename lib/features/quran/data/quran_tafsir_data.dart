class QuranTafsirData {
  /// Verbatim Tafsir text keyed by surah, then ayah.
  ///
  /// Intentionally empty: the previous entries were paraphrased rather than
  /// verbatim Tafsir al-Muyassar text, which violates the content governance
  /// policy (docs/content-governance.md). Populate only from a verified,
  /// licensed verbatim dataset (e.g. King Fahd Complex Tafsir al-Muyassar).
  static const Map<int, Map<int, String>> _verbatimTafsir = {};

  /// Display name of the Tafsir source shown above the text.
  static const String sourceName = 'التفسير الميسر';

  /// Returns the verbatim Tafsir for the ayah, or null when none is available.
  /// Callers must hide the Tafsir section when this returns null.
  static String? getAyahTafsir(int surahNumber, int ayahNumber) {
    return _verbatimTafsir[surahNumber]?[ayahNumber];
  }
}
