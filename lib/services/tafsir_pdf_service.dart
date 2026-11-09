import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/tafsir_work.dart';

class TafsirPdfPage {
  const TafsirPdfPage({
    required this.bytes,
    required this.width,
    required this.height,
    required this.pageCount,
  });
  final Uint8List bytes;
  final int width;
  final int height;
  final int pageCount;
}

class TafsirPdfService {
  static const channel = MethodChannel('com.qurankareem.app/tafsir_pdf');

  static Future<TafsirPdfPage> render(
    TafsirWork work,
    int page, {
    int width = 1800,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError(
        'The original scanned Tafsirs are available in the Android APK.',
      );
    }
    if (!work.isScanned || page < 1 || page > work.pageCount) {
      throw ArgumentError('Invalid Tafsir page');
    }
    final result = await channel.invokeMapMethod<String, dynamic>(
      'renderPage',
      {
        'asset': work.assetPath!,
        'page': page - 1,
        'width': width.clamp(600, 2200),
      },
    );
    if (result == null) throw StateError('Empty PDF render');
    return TafsirPdfPage(
      bytes: result['bytes'] as Uint8List,
      width: result['width'] as int,
      height: result['height'] as int,
      pageCount: result['pageCount'] as int,
    );
  }

  static Future<void> release() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await channel.invokeMethod<void>('release');
    }
  }
}
