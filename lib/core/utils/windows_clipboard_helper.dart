import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsClipboardHelper {
  /// Copies a raw PNG image bytes to the Windows Clipboard using the registered "PNG" clipboard format.
  /// This ensures apps like WhatsApp, Telegram, Slack, etc., paste it with perfect transparent backgrounds.
  static bool copyPngToClipboard(Uint8List pngBytes) {
    if (!Platform.isWindows) return false;

    Pointer<NativeType>? hpngMem;

    try {
      hpngMem = GlobalAlloc(GHND, pngBytes.length);
      if (hpngMem == nullptr) return false;

      final pPng = GlobalLock(hpngMem);
      if (pPng == nullptr) {
        GlobalFree(hpngMem);
        return false;
      }

      try {
        final pngList = pPng.cast<Uint8>().asTypedList(pngBytes.length);
        pngList.setAll(0, pngBytes);
      } finally {
        GlobalUnlock(hpngMem);
      }

      if (OpenClipboard(0) == 0) {
        GlobalFree(hpngMem);
        return false;
      }

      try {
        EmptyClipboard();

        final pngFormatName = 'PNG'.toNativeUtf16();
        final pngFormatId = RegisterClipboardFormat(pngFormatName);
        free(pngFormatName);

        if (pngFormatId != 0) {
          if (SetClipboardData(pngFormatId, hpngMem.address) == 0) {
            GlobalFree(hpngMem);
            return false;
          }
        } else {
          GlobalFree(hpngMem);
          return false;
        }

        return true;
      } finally {
        CloseClipboard();
      }
    } catch (_) {
      return false;
    }
  }

  /// Copies both raw PNG image bytes and text to the Windows Clipboard.
  /// Sets:
  /// 1. "PNG" format (raw png bytes) for transparent image paste (WhatsApp, Slack, Slack, Discord, Telegram, etc.)
  /// 2. CF_UNICODETEXT format for accompanying text
  /// 3. CF_HDROP format (file list) as a solid fallback
  static bool copyPngAndTextToClipboard(String text, Uint8List pngBytes, String filePath) {
    if (!Platform.isWindows) return false;

    Pointer<NativeType>? hdropMem;
    Pointer<NativeType>? htextMem;
    Pointer<NativeType>? hpngMem;

    try {
      // 1. Prepare HDROP for file
      final windowsPath = filePath.replaceAll('/', '\\');
      const dropFilesSize = 20;
      final pathUnits = windowsPath.codeUnits;
      final pathBytesLength = (pathUnits.length + 2) * 2; 
      final hdropSize = dropFilesSize + pathBytesLength;

      hdropMem = GlobalAlloc(GHND, hdropSize);
      if (hdropMem != nullptr) {
        final pDrop = GlobalLock(hdropMem);
        if (pDrop != nullptr) {
          try {
            final bytes = pDrop.cast<Uint8>();
            bytes.asTypedList(4).buffer.asByteData().setUint32(0, 20, Endian.host);
            bytes.asTypedList(12).buffer.asByteData().setUint32(4, 0, Endian.host);
            bytes.asTypedList(12).buffer.asByteData().setUint32(8, 0, Endian.host);
            bytes.asTypedList(16).buffer.asByteData().setUint32(12, 0, Endian.host);
            bytes.asTypedList(20).buffer.asByteData().setUint32(16, 1, Endian.host);

            final pathBytes = bytes.elementAt(20).cast<Uint16>();
            final pathList = pathBytes.asTypedList(pathUnits.length + 2);
            for (var i = 0; i < pathUnits.length; i++) {
              pathList[i] = pathUnits[i];
            }
            pathList[pathUnits.length] = 0;
            pathList[pathUnits.length + 1] = 0;
          } finally {
            GlobalUnlock(hdropMem);
          }
        }
      }

      // 2. Prepare text (CF_UNICODETEXT)
      final textUnits = text.codeUnits;
      final textBytesLength = (textUnits.length + 1) * 2;
      htextMem = GlobalAlloc(GHND, textBytesLength);
      if (htextMem != nullptr) {
        final pText = GlobalLock(htextMem);
        if (pText != nullptr) {
          try {
            final textList = pText.cast<Uint16>().asTypedList(textUnits.length + 1);
            for (var i = 0; i < textUnits.length; i++) {
              textList[i] = textUnits[i];
            }
            textList[textUnits.length] = 0;
          } finally {
            GlobalUnlock(htextMem);
          }
        }
      }

      // 3. Prepare raw PNG bytes
      hpngMem = GlobalAlloc(GHND, pngBytes.length);
      if (hpngMem != nullptr) {
        final pPng = GlobalLock(hpngMem);
        if (pPng != nullptr) {
          try {
            final pngList = pPng.cast<Uint8>().asTypedList(pngBytes.length);
            pngList.setAll(0, pngBytes);
          } finally {
            GlobalUnlock(hpngMem);
          }
        }
      }

      // 4. Open Clipboard
      if (OpenClipboard(0) == 0) {
        if (hdropMem != nullptr) GlobalFree(hdropMem);
        if (htextMem != nullptr) GlobalFree(htextMem);
        if (hpngMem != nullptr) GlobalFree(hpngMem);
        return false;
      }

      try {
        EmptyClipboard();

        // Set HDROP
        if (hdropMem != nullptr) {
          if (SetClipboardData(CF_HDROP, hdropMem.address) == 0) {
            GlobalFree(hdropMem);
          }
        }

        // Set Text
        if (htextMem != nullptr) {
          if (SetClipboardData(CF_UNICODETEXT, htextMem.address) == 0) {
            GlobalFree(htextMem);
          }
        }

        // Set PNG (registered clipboard format)
        if (hpngMem != nullptr) {
          final pngFormatName = 'PNG'.toNativeUtf16();
          final pngFormatId = RegisterClipboardFormat(pngFormatName);
          free(pngFormatName);

          if (pngFormatId != 0) {
            if (SetClipboardData(pngFormatId, hpngMem.address) == 0) {
              GlobalFree(hpngMem);
            }
          } else {
            GlobalFree(hpngMem);
          }
        }

        return true;
      } finally {
        CloseClipboard();
      }
    } catch (_) {
      return false;
    }
  }

  /// Deprecated, use copyPngToClipboard for full transparent support.
  static bool copyFileToClipboard(String filePath) {
    if (!Platform.isWindows) return false;

    try {
      final windowsPath = filePath.replaceAll('/', '\\');
      const dropFilesSize = 20;
      final pathUnits = windowsPath.codeUnits;
      final pathBytesLength = (pathUnits.length + 2) * 2; 
      final totalSize = dropFilesSize + pathBytesLength;

      final hGlobal = GlobalAlloc(GHND, totalSize);
      if (hGlobal == nullptr) return false;

      final pGlobal = GlobalLock(hGlobal);
      if (pGlobal == nullptr) {
        GlobalFree(hGlobal);
        return false;
      }

      try {
        final bytes = pGlobal.cast<Uint8>();
        bytes.asTypedList(4).buffer.asByteData().setUint32(0, 20, Endian.host);
        bytes.asTypedList(12).buffer.asByteData().setUint32(4, 0, Endian.host);
        bytes.asTypedList(12).buffer.asByteData().setUint32(8, 0, Endian.host);
        bytes.asTypedList(16).buffer.asByteData().setUint32(12, 0, Endian.host);
        bytes.asTypedList(20).buffer.asByteData().setUint32(16, 1, Endian.host);

        final pathBytes = bytes.elementAt(20).cast<Uint16>();
        final pathList = pathBytes.asTypedList(pathUnits.length + 2);
        for (var i = 0; i < pathUnits.length; i++) {
          pathList[i] = pathUnits[i];
        }
        pathList[pathUnits.length] = 0;
        pathList[pathUnits.length + 1] = 0;
      } finally {
        GlobalUnlock(hGlobal);
      }

      if (OpenClipboard(0) == 0) {
        GlobalFree(hGlobal);
        return false;
      }

      try {
        EmptyClipboard();
        if (SetClipboardData(CF_HDROP, hGlobal.address) == 0) {
          GlobalFree(hGlobal);
          return false;
        }
        return true;
      } finally {
        CloseClipboard();
      }
    } catch (_) {
      return false;
    }
  }

  /// Deprecated, use copyPngAndTextToClipboard for full transparent support.
  static bool copyTextAndFileToClipboard(String text, String filePath) {
    if (!Platform.isWindows) return false;

    try {
      final windowsPath = filePath.replaceAll('/', '\\');
      const dropFilesSize = 20;
      final pathUnits = windowsPath.codeUnits;
      final pathBytesLength = (pathUnits.length + 2) * 2; 
      final hdropSize = dropFilesSize + pathBytesLength;

      final hdropMem = GlobalAlloc(GHND, hdropSize);
      if (hdropMem == nullptr) return false;

      final pDrop = GlobalLock(hdropMem);
      if (pDrop == nullptr) {
        GlobalFree(hdropMem);
        return false;
      }

      try {
        final bytes = pDrop.cast<Uint8>();
        bytes.asTypedList(4).buffer.asByteData().setUint32(0, 20, Endian.host);
        bytes.asTypedList(12).buffer.asByteData().setUint32(4, 0, Endian.host);
        bytes.asTypedList(12).buffer.asByteData().setUint32(8, 0, Endian.host);
        bytes.asTypedList(16).buffer.asByteData().setUint32(12, 0, Endian.host);
        bytes.asTypedList(20).buffer.asByteData().setUint32(16, 1, Endian.host);

        final pathBytes = bytes.elementAt(20).cast<Uint16>();
        final pathList = pathBytes.asTypedList(pathUnits.length + 2);
        for (var i = 0; i < pathUnits.length; i++) {
          pathList[i] = pathUnits[i];
        }
        pathList[pathUnits.length] = 0;
        pathList[pathUnits.length + 1] = 0;
      } finally {
        GlobalUnlock(hdropMem);
      }

      final textUnits = text.codeUnits;
      final textBytesLength = (textUnits.length + 1) * 2;

      final htextMem = GlobalAlloc(GHND, textBytesLength);
      if (htextMem == nullptr) {
        GlobalFree(hdropMem);
        return false;
      }

      final pText = GlobalLock(htextMem);
      if (pText == nullptr) {
        GlobalFree(hdropMem);
        GlobalFree(htextMem);
        return false;
      }

      try {
        final textList = pText.cast<Uint16>().asTypedList(textUnits.length + 1);
        for (var i = 0; i < textUnits.length; i++) {
          textList[i] = textUnits[i];
        }
        textList[textUnits.length] = 0;
      } finally {
        GlobalUnlock(htextMem);
      }

      if (OpenClipboard(0) == 0) {
        GlobalFree(hdropMem);
        GlobalFree(htextMem);
        return false;
      }

      try {
        EmptyClipboard();
        
        if (SetClipboardData(CF_HDROP, hdropMem.address) == 0) {
          GlobalFree(hdropMem);
        }
        
        if (SetClipboardData(CF_UNICODETEXT, htextMem.address) == 0) {
          GlobalFree(htextMem);
        }

        return true;
      } finally {
        CloseClipboard();
      }
    } catch (_) {
      return false;
    }
  }
}
