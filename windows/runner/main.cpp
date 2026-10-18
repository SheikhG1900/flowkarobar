#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>
#include <vector>

#include "flutter_window.h"
#include "utils.h"

// Define the unique AppLinks message ID
#define APPLINK_MSG_ID (WM_USER + 2)

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Try to find if an existing window of Flowpaisa is already running
  // Window class matches FLUTTER_RUNNER_WIN32_WINDOW
  HWND hwndExisting = FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"flowpaisa");
  if (hwndExisting != NULL) {
    // We found an existing window!
    // Bring the existing window to the foreground and activate it
    if (IsIconic(hwndExisting)) {
      ShowWindow(hwndExisting, SW_RESTORE);
    } else {
      ShowWindow(hwndExisting, SW_SHOW);
    }
    SetForegroundWindow(hwndExisting);
    SetFocus(hwndExisting);

    // Forward the deep link command line arguments to the existing window so app_links can process it
    int argc;
    LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv != NULL && argc > 1) {
      std::wstring argStr = argv[1];
      // Check if argument is custom scheme or web redirect
      if (argStr.rfind(L"flowpaisa://", 0) == 0 || argStr.find(L"tamatasoft.github.io") != std::wstring::npos) {
        // Convert UTF-16 wide string to standard UTF-8 (since app_links plugin expects a char* payload)
        int size_needed = WideCharToMultiByte(CP_UTF8, 0, argStr.c_str(), (int)argStr.length(), NULL, 0, NULL, NULL);
        std::string utf8Link(size_needed, 0);
        WideCharToMultiByte(CP_UTF8, 0, argStr.c_str(), (int)argStr.length(), &utf8Link[0], size_needed, NULL, NULL);

        COPYDATASTRUCT cds;
        cds.dwData = APPLINK_MSG_ID; // Match the ID used inside the app_links plugin!
        cds.cbData = static_cast<DWORD>(utf8Link.length() + 1); // Length including null terminator
        cds.lpData = const_cast<LPVOID>(reinterpret_cast<const void*>(utf8Link.c_str()));
        SendMessageW(hwndExisting, WM_COPYDATA, reinterpret_cast<WPARAM>(hwndExisting), reinterpret_cast<LPARAM>(&cds));
      }
      LocalFree(argv);
    }
    return EXIT_SUCCESS; // Terminate this secondary instance immediately!
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"flowpaisa", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
