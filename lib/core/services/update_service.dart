import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final bool isMandatory;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    this.isMandatory = false,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String,
      downloadUrl: json['downloadUrl'] as String,
      releaseNotes: json['releaseNotes'] as String? ?? 'A new version is available.',
      isMandatory: json['isMandatory'] as bool? ?? false,
    );
  }
}

class UpdateService {
  // IMPORTANT: Because your main repository is Private, you cannot host this file 
  // in the private repo. You must create a second PUBLIC repository (e.g. `khata-releases`)
  // or use AWS S3 / Firebase Hosting, and put the URL here.
  static const String _updateJsonUrl = 'https://raw.githubusercontent.com/shaikhakramshakil/khata-releases/main/version.json';
  
  final Dio _dio = Dio();

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      if (!Platform.isWindows) return null; // We only support auto-update on Windows for now

      final response = await _dio.get(
        _updateJsonUrl,
        options: Options(
          headers: {'Cache-Control': 'no-cache'}, // Prevent caching old version
        ),
      );

      final Map<String, dynamic> data;
      if (response.data is String) {
        data = jsonDecode(response.data);
      } else {
        data = response.data;
      }

      final updateInfo = UpdateInfo.fromJson(data);
      final currentVersion = await _getCurrentVersion();

      if (_isNewerVersion(updateInfo.version, currentVersion)) {
        return updateInfo;
      }
    } catch (e) {
      debugPrint('Error checking for update: $e');
    }
    return null;
  }

  Future<String> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  bool _isNewerVersion(String newVersion, String currentVersion) {
    final v1 = newVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2 = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (var i = 0; i < 3; i++) {
      final p1 = i < v1.length ? v1[i] : 0;
      final p2 = i < v2.length ? v2[i] : 0;
      if (p1 > p2) return true;
      if (p1 < p2) return false;
    }
    return false;
  }

  Future<File?> downloadUpdate(String url, Function(int, int) onReceiveProgress) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}\\RukminiKhata_Update.exe';

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );

      return File(savePath);
    } catch (e) {
      debugPrint('Error downloading update: $e');
      return null;
    }
  }

  void installUpdateAndRestart(File installerFile) async {
    try {
      // Run the installer in silent or normal mode
      await Process.start(
        installerFile.path, 
        ['/SILENT'], // Use /VERYSILENT to hide completely, or just run it normally
        mode: ProcessStartMode.detached,
      );
      
      // Close the current app so the installer can overwrite the .exe
      exit(0);
    } catch (e) {
      debugPrint('Error starting installer: $e');
    }
  }
}
