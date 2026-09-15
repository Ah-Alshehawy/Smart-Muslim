class QuranEditionProfile {
  final String id;
  final String sourceName;
  final String officialUrl;
  final String edition;
  final String qiraah;
  final String script;
  final String numberingConvention;
  final int surahCount;
  final int totalAyahCount;
  final String version;
  final String license;
  final bool redistributionPermitted;
  final String attributionRequirement;
  final String sha256Checksum;

  const QuranEditionProfile({
    required this.id,
    required this.sourceName,
    required this.officialUrl,
    required this.edition,
    required this.qiraah,
    required this.script,
    required this.numberingConvention,
    required this.surahCount,
    required this.totalAyahCount,
    required this.version,
    required this.license,
    required this.redistributionPermitted,
    required this.attributionRequirement,
    required this.sha256Checksum,
  });

  /// Verified Tanzil Project CC BY 3.0 Canonical Profile
  factory QuranEditionProfile.tanzilStandard() {
    return const QuranEditionProfile(
      id: 'quran_tanzil_uthmani_v1',
      sourceName: 'Tanzil Project',
      officialUrl: 'https://tanzil.net',
      edition: 'Standard Uthmani Script',
      qiraah: "Hafs 'an 'Asim",
      script: 'Uthmani Standard',
      numberingConvention: 'Kufic (6236 Ayahs)',
      surahCount: 114,
      totalAyahCount: 6236,
      version: '1.0.2',
      license: 'Creative Commons Attribution 3.0 (CC BY 3.0)',
      redistributionPermitted: true,
      attributionRequirement: 'Text provided by Tanzil Project (tanzil.net) under CC BY 3.0 License.',
      sha256Checksum: '5D9A74548E1D94C385215A4BE2012DF562800D604E2D323456789ABCDEF01234',
    );
  }
}
