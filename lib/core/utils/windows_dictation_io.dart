import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

void triggerWindowsDictation() {
  if (Platform.isWindows) {
    using((arena) {
      // Allocate 4 INPUT structures for Win down, H down, H up, Win up
      final inputs = arena<INPUT>(4);

      // 1. Press Win
      inputs[0].type = INPUT_KEYBOARD;
      inputs[0].ki.wVk = VK_LWIN;

      // 2. Press H
      inputs[1].type = INPUT_KEYBOARD;
      inputs[1].ki.wVk = const VIRTUAL_KEY(0x48); // 'H' key is 0x48

      // 3. Release H
      inputs[2].type = INPUT_KEYBOARD;
      inputs[2].ki.wVk = const VIRTUAL_KEY(0x48);
      inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

      // 4. Release Win
      inputs[3].type = INPUT_KEYBOARD;
      inputs[3].ki.wVk = VK_LWIN;
      inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

      SendInput(4, inputs, sizeOf<INPUT>());
    });
  }
}
