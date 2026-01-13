import 'dart:io';
import 'package:flutter/services.dart';

class NativeShare {
  static const MethodChannel _channel =
      MethodChannel('com.tamatasoft.flowpaisa/native_share');

  /// Share a file using native Android sharing (bypasses share_plus FileProvider issues)
  static Future<bool> shareFile(String filePath) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Native share is only supported on Android');
    }

    try {
      final result =
          await _channel.invokeMethod('shareFile', {'filePath': filePath});
      return result == true;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
