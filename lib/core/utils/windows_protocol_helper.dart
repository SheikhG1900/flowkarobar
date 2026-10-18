import 'dart:io';
import 'package:flutter/foundation.dart';

class WindowsProtocolHelper {
  /// Registers the "flowpaisa" custom protocol scheme (flowpaisa://) in the Windows Registry.
  /// This registry location (HKEY_CURRENT_USER\Software\Classes) does NOT require Administrator privileges.
  /// Once registered, clicking a flowpaisa:// link anywhere on Windows (web browser, chat apps, files)
  /// will automatically launch the local Cashbook app and pass the link parameters.
  static Future<void> registerProtocol() async {
    if (!Platform.isWindows) return;

    try {
      final String executablePath = Platform.resolvedExecutable;
      
      // Register using a clean, robust PowerShell execution which has perfect quote safety
      final psCommand = '''
        New-Item -Path HKCU:\\Software\\Classes\\flowpaisa -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path HKCU:\\Software\\Classes\\flowpaisa -Name "(Default)" -Value "URL:flowpaisa Protocol" -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path HKCU:\\Software\\Classes\\flowpaisa -Name "URL Protocol" -Value "" -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path HKCU:\\Software\\Classes\\flowpaisa\\shell\\open\\command -Force -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path "HKCU:\\Software\\Classes\\flowpaisa\\shell\\open\\command" -Name "(Default)" -Value '"$executablePath" "%1"' -Force -ErrorAction SilentlyContinue | Out-Null
      ''';

      final result = await Process.run('powershell', ['-Command', psCommand]);
      if (result.exitCode != 0) {
        debugPrint('WindowsProtocolHelper: Failed to register protocol: ${result.stderr}');
      } else {
        debugPrint('WindowsProtocolHelper: Successfully registered flowpaisa:// protocol in Windows registry.');
      }
    } catch (e) {
      debugPrint('WindowsProtocolHelper: Failed to register protocol: $e');
    }
  }
}
