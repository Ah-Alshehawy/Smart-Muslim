import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran/data/quran_repository.dart';
import '../../../quran/domain/surah_model.dart';
import '../../data/recitation_download_service.dart';
import '../../data/reciters_data.dart';
import '../../domain/reciter_model.dart';

/// Lists the 114 surahs for a chosen reciter. Surahs stream over the internet
/// unless the user downloads them, after which they play offline.
class RecitationScreen extends StatefulWidget {
  final int? initialSurahNumber;

  const RecitationScreen({super.key, this.initialSurahNumber});

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  static const String _reciterPrefsKey = 'smart_muslim_reciter_key';

  final RecitationDownloadService _downloads = RecitationDownloadService();
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<PlayerState>? _playerStateSub;

  ReciterModel _reciter = RecitersData.reciters.first;
  Set<int> _downloaded = {};
  final Map<int, double?> _inProgress = {};
  int _storageBytes = 0;

  int? _playingSurah;
  bool _isPlaying = false;
  bool _isBuffering = false;

  List<SurahModel> get _surahs => QuranRepository.allSurahs;

  @override
  void initState() {
    super.initState();
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing && state.processingState != ProcessingState.completed;
        _isBuffering = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        if (state.processingState == ProcessingState.completed) _isPlaying = false;
      });
    });
    _init();
  }

  Future<void> _init() async {
    await QuranRepository.ensureLoaded();
    final store = await SharedPreferences.getInstance();
    final savedKey = store.getString(_reciterPrefsKey);
    final saved = RecitersData.reciters.where((r) => r.key == savedKey);
    if (saved.isNotEmpty) _reciter = saved.first;
    await _refreshDownloads();

    final initial = widget.initialSurahNumber;
    if (initial != null && initial > 1 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.jumpTo((initial - 1) * 72.0);
      });
    }
  }

  Future<void> _refreshDownloads() async {
    final downloaded = await _downloads.downloadedSurahs(_reciter);
    final bytes = await _downloads.storageBytes(_reciter);
    if (!mounted) return;
    setState(() {
      _downloaded = downloaded;
      _storageBytes = bytes;
    });
  }

  Future<void> _selectReciter(ReciterModel reciter) async {
    await _player.stop();
    final store = await SharedPreferences.getInstance();
    await store.setString(_reciterPrefsKey, reciter.key);
    setState(() {
      _reciter = reciter;
      _playingSurah = null;
      _inProgress.clear();
    });
    await _refreshDownloads();
  }

  Future<void> _togglePlay(int surahNumber) async {
    if (_playingSurah == surahNumber) {
      _isPlaying ? await _player.pause() : await _player.play();
      return;
    }

    setState(() => _playingSurah = surahNumber);
    try {
      if (_downloaded.contains(surahNumber)) {
        final file = await _downloads.localFile(_reciter, surahNumber);
        await _player.setFilePath(file.path);
      } else {
        await _player.setUrl(_reciter.surahUrl(surahNumber));
      }
      await _player.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _playingSurah = null);
      _showError(_downloaded.contains(surahNumber)
          ? 'تعذر تشغيل الملف المحفوظ'
          : 'تعذر تشغيل التلاوة. تأكد من الاتصال بالإنترنت أو نزّل السورة أولًا.');
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    if (mounted) setState(() => _playingSurah = null);
  }

  Future<void> _download(int surahNumber) async {
    setState(() => _inProgress[surahNumber] = null);
    try {
      await _downloads.download(
        _reciter,
        surahNumber,
        onProgress: (progress) {
          if (mounted) setState(() => _inProgress[surahNumber] = progress);
        },
      );
    } catch (e) {
      _showError('تعذر تنزيل سورة ${_surahName(surahNumber)}. تأكد من الاتصال بالإنترنت ثم أعد المحاولة.');
    } finally {
      if (mounted) setState(() => _inProgress.remove(surahNumber));
      await _refreshDownloads();
    }
  }

  Future<void> _confirmDelete(int surahNumber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التلاوة المحفوظة'),
        content: Text('حذف سورة ${_surahName(surahNumber)} بصوت ${_reciter.nameArabic} من الجهاز؟ يمكنك تنزيلها مرة أخرى لاحقًا.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_playingSurah == surahNumber) await _stop();
    await _downloads.delete(_reciter, surahNumber);
    await _refreshDownloads();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  String _surahName(int number) {
    final match = _surahs.where((s) => s.number == number);
    return match.isNotEmpty ? match.first.nameArabic : '$number';
  }

  static String _digits(String value) {
    const western = '0123456789';
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    return value.split('').map((c) {
      final i = western.indexOf(c);
      return i < 0 ? c : eastern[i];
    }).join();
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '٠ ميغابايت';
    final mb = bytes / (1024 * 1024);
    return '${_digits(mb.toStringAsFixed(mb < 10 ? 1 : 0))} ميغابايت';
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('التلاوات الصوتية', style: AppTypography.titleLarge(isDark)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'القارئ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ReciterModel>(
                  value: _reciter,
                  isExpanded: true,
                  items: RecitersData.reciters
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.nameArabic)))
                      .toList(),
                  onChanged: (r) {
                    if (r != null && r != _reciter) _selectReciter(r);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              '${_reciter.moshafNameArabic} · محفوظ على الجهاز: '
              '${_digits('${_downloaded.length}')} سورة (${_formatSize(_storageBytes)})',
              style: TextStyle(fontSize: 12, color: secondary),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _surahs.length,
              itemExtent: 72,
              itemBuilder: (context, index) => _buildSurahTile(_surahs[index], isDark, secondary),
            ),
          ),
          if (_playingSurah != null) _buildPlayerBar(isDark),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'مصدر التلاوات: ${RecitersData.sourceName}',
              style: TextStyle(fontSize: 11, color: secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTile(SurahModel surah, bool isDark, Color secondary) {
    final number = surah.number;
    final isDownloaded = _downloaded.contains(number);
    final isDownloading = _inProgress.containsKey(number);
    final isCurrent = _playingSurah == number;

    Widget downloadAction;
    if (isDownloading) {
      downloadAction = SizedBox(
        width: 48,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, value: _inProgress[number]),
          ),
        ),
      );
    } else if (isDownloaded) {
      downloadAction = IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'حذف من الجهاز',
        onPressed: () => _confirmDelete(number),
      );
    } else {
      downloadAction = IconButton(
        icon: const Icon(Icons.download_outlined),
        tooltip: 'تنزيل للاستماع بدون إنترنت',
        onPressed: () => _download(number),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.emeraldGreen.withValues(alpha: isCurrent ? 1 : 0.12),
        child: Text(
          _digits('$number'),
          style: TextStyle(
            fontSize: 13,
            color: isCurrent ? Colors.white : AppColors.emeraldGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text('سورة ${surah.nameArabic}', style: AppTypography.bodyLarge(isDark)),
      subtitle: Text(
        '${surah.revelationType} · ${_digits('${surah.totalAyahs}')} آية'
        '${isDownloaded ? ' · محفوظة' : ''}',
        style: TextStyle(fontSize: 12, color: isDownloaded ? AppColors.emeraldGreen : secondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(isCurrent && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
            color: AppColors.emeraldGreen,
            iconSize: 32,
            tooltip: isCurrent && _isPlaying ? 'إيقاف مؤقت' : 'استماع',
            onPressed: () => _togglePlay(number),
          ),
          downloadAction,
        ],
      ),
    );
  }

  Widget _buildPlayerBar(bool isDark) {
    final number = _playingSurah!;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightBackground,
      elevation: 4,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'سورة ${_surahName(number)} — ${_reciter.nameArabic}',
                      style: AppTypography.bodyMedium(isDark).copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isBuffering)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      tooltip: _isPlaying ? 'إيقاف مؤقت' : 'متابعة',
                      onPressed: () => _togglePlay(number),
                    ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    tooltip: 'إيقاف',
                    onPressed: _stop,
                  ),
                ],
              ),
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _player.duration ?? Duration.zero;
                  final max = duration.inMilliseconds.toDouble();
                  return Slider(
                    value: max <= 0 ? 0 : position.inMilliseconds.clamp(0, max.toInt()).toDouble(),
                    max: max <= 0 ? 1 : max,
                    activeColor: AppColors.emeraldGreen,
                    onChanged: max <= 0 ? null : (v) => _player.seek(Duration(milliseconds: v.toInt())),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
