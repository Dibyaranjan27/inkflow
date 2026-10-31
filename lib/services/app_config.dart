import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Centralized configuration provider for Inkflow.
/// Reads sensitive secrets safely without committing them to version control:
///
/// Priority resolution order:
/// 1. `--dart-define=GOOGLE_BOOKS_API_KEY=...` or `--dart-define-from-file=local.properties`
/// 2. Android native `local.properties` loaded via Gradle `resValue` & MethodChannel
/// 3. Host filesystem `android/local.properties` or `local.properties` (desktop/debug mode)
class AppConfig {
  static const MethodChannel _channel = MethodChannel('com.dibya.inkflow/config');
  static String? _cachedApiKey;

  /// Retrieves the Google Books API Key without exposing it in source control.
  static Future<String> getGoogleBooksApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey!;
    }

    // 1. Compile-time environment variable (--dart-define / --dart-define-from-file)
    const envKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) {
      _cachedApiKey = envKey;
      return envKey;
    }

    // 2. Android native resValue (populated from android/local.properties by Gradle)
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final nativeKey = await _channel.invokeMethod<String>('getGoogleBooksApiKey');
        if (nativeKey != null && nativeKey.trim().isNotEmpty) {
          _cachedApiKey = nativeKey.trim();
          return _cachedApiKey!;
        }
      } catch (_) {
        // Platform channel not available or running outside Android runtime
      }
    }

    // 3. Local filesystem check for development/debug desktop environments
    if (!kIsWeb) {
      try {
        final candidatePaths = [
          'android/local.properties',
          'local.properties',
          '../local.properties',
        ];

        for (final path in candidatePaths) {
          final file = File(path);
          if (file.existsSync()) {
            final lines = file.readAsLinesSync();
            for (final line in lines) {
              final trimmed = line.trim();
              if (trimmed.startsWith('#') || trimmed.isEmpty) continue;
              if (trimmed.startsWith('GOOGLE_BOOKS_API_KEY=') ||
                  trimmed.startsWith('google.books.api.key=')) {
                final parts = trimmed.split('=');
                if (parts.length >= 2) {
                  final keyVal = parts.sublist(1).join('=').trim();
                  if (keyVal.isNotEmpty) {
                    _cachedApiKey = keyVal;
                    return keyVal;
                  }
                }
              }
            }
          }
        }
      } catch (_) {
        // Ignored in restricted environments
      }
    }

    return '';
  }
}
