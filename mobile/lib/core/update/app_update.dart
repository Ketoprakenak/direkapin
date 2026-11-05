import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/api_client.dart';

part 'app_update.g.dart';

const _linksChannel = MethodChannel('direkapin/links');

/// `true` jika [latest] lebih baru dari [current]; format `1.2.3`, tanpa `+build`.
/// Format lain dianggap tidak lebih baru supaya banner tidak muncul keliru.
bool isNewerVersion(String latest, String current) {
  List<int>? parse(String version) {
    final parts = version.split('+').first.split('.');
    if (parts.length != 3) return null;
    final numbers = parts.map(int.tryParse).toList();
    return numbers.contains(null) ? null : numbers.cast<int>();
  }

  final a = parse(latest);
  final b = parse(current);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return false;
}

/// Versi baru dari `/version`, atau `null` jika tidak ada atau gagal dicek.
@Riverpod(keepAlive: true)
Future<({String version, String url})?> availableUpdate(Ref ref) async {
  try {
    final response = await ref
        .watch(apiClientProvider)
        .get<Map<String, dynamic>>('/version');
    final latest = response.data!['latestVersion'] as String;
    final current = (await PackageInfo.fromPlatform()).version;
    if (!isNewerVersion(latest, current)) return null;
    return (version: latest, url: response.data!['downloadUrl'] as String);
  } catch (_) {
    // Cek versi tidak boleh mengganggu Beranda.
    return null;
  }
}

/// `false` jika [url] tidak bisa dibuka.
Future<bool> openDownloadLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !{'http', 'https'}.contains(uri.scheme)) return false;
  try {
    await _linksChannel.invokeMethod<void>('open', {'url': url});
    return true;
  } on PlatformException {
    return false;
  }
}
