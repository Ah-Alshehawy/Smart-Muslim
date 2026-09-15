
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UpdateService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults(const {
        'latest_version': '0.1.0',
        'force_update_version': '0.0.1',
        'update_url': 'https://mega.nz/file/8lJ23TxC#XnRyVJH3zfKqlRNFk1yxb8LzXH5pJmNSC4_sNoPCsCY',
      });
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Failed to fetch remote config: $e');
    }
  }

  static Future<UpdateStatus> checkUpdateStatus() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = _parseVersion(packageInfo.version);
    
    final latestVersion = _parseVersion(_remoteConfig.getString('latest_version'));
    final forceUpdateVersion = _parseVersion(_remoteConfig.getString('force_update_version'));

    if (currentVersion < forceUpdateVersion) {
      return UpdateStatus.forced;
    } else if (currentVersion < latestVersion) {
      return UpdateStatus.available;
    }
    return UpdateStatus.upToDate;
  }

  static Future<void> openDownloadPage() async {
    final urlStr = _remoteConfig.getString('update_url');
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Helper to parse version string (e.g. "0.2.0") to integer for comparison
  static int _parseVersion(String version) {
    // Basic semver to int converter (e.g., 0.2.0 -> 00200)
    // Assumes single/double digit segments
    try {
      final parts = version.split('-')[0].split('.');
      if (parts.length >= 3) {
        final major = int.parse(parts[0]);
        final minor = int.parse(parts[1]);
        final patch = int.parse(parts[2]);
        return (major * 10000) + (minor * 100) + patch;
      }
    } catch (e) {
      debugPrint('Version parse error: $e');
    }
    return 0;
  }
}

enum UpdateStatus {
  upToDate,
  available,
  forced,
}
