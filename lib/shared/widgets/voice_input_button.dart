import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/windows_dictation_stub.dart'
    if (dart.library.io) 'package:flowpaisa/core/utils/windows_dictation_io.dart';

/// A reusable cross-platform button that adds voice-to-text functionality to any [TextEditingController].
class VoiceInputButton extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onListeningChanged;
  final Color? color;
  final double size;

  const VoiceInputButton({
    super.key,
    required this.controller,
    this.focusNode,
    this.onListeningChanged,
    this.color,
    this.size = 20.0,
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Track the initial text and cursor selection before listening starts
  // to avoid word repetition issues during cumulative real-time updates.
  String _initialText = '';
  int _selectionStart = -1;
  int _selectionEnd = -1;

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  Future<void> _toggleListening() async {
    // 1. Windows Platform (uses native Cloud Dictation Win + H)
    if (!kIsWeb && Platform.isWindows) {
      if (widget.focusNode != null) {
        widget.focusNode!.requestFocus();
        // Give a tiny delay for focus to settle before invoking native input
        await Future.delayed(const Duration(milliseconds: 150));
      }
      triggerWindowsDictation();
      return;
    }

    // 2. Mobile Platforms (Android / iOS)
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) {
            if (status == 'notListening') {
              _setListeningState(false);
            }
          },
          onError: (error) {
            _setListeningState(false);
            ToastUtils.showErrorToast(
              context,
              ref,
              "Voice recognition error: ${error.errorMsg}",
            );
          },
        );

        if (available) {
          // Capture the text and cursor position before speech recognition starts
          _initialText = widget.controller.text;
          final selection = widget.controller.selection;
          if (selection.isValid && selection.start >= 0) {
            _selectionStart = selection.start;
            _selectionEnd = selection.end;
          } else {
            _selectionStart = _initialText.length;
            _selectionEnd = _initialText.length;
          }

          _setListeningState(true);
          _speech.listen(
            onResult: (result) {
              setState(() {
                _insertText(result.recognizedWords);
              });
              if (result.finalResult) {
                _setListeningState(false);
              }
            },
          );
        } else {
          ToastUtils.showErrorToast(
            context,
            ref,
            "Voice recognition is not available. Please check microphone permissions.",
          );
        }
      } catch (e) {
        ToastUtils.showErrorToast(
          context,
          ref,
          "Failed to initialize voice recognition: $e",
        );
      }
    } else {
      _speech.stop();
      _setListeningState(false);
    }
  }

  void _setListeningState(bool listening) {
    if (mounted && _isListening != listening) {
      setState(() {
        _isListening = listening;
      });
      if (widget.onListeningChanged != null) {
        widget.onListeningChanged!(listening);
      }
    }
  }

  /// Inserts the recognized text at the captured cursor position, avoiding repetition.
  void _insertText(String newText) {
    if (newText.isEmpty) return;
    
    // Add a leading space if we are inserting after a non-space character
    String textToInsert = newText;
    if (_selectionStart > 0 && _selectionStart <= _initialText.length) {
      final charBefore = _initialText.substring(_selectionStart - 1, _selectionStart);
      if (charBefore.trim().isNotEmpty) {
        textToInsert = ' $newText';
      }
    }
    
    // Always replace the range starting from the captured selection coordinates
    // using the initial text captured when the microphone was clicked.
    final updatedText = _initialText.replaceRange(_selectionStart, _selectionEnd, textToInsert);
    
    widget.controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: _selectionStart + textToInsert.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: _isListening
          ? Icon(
              Icons.mic,
              color: Colors.red,
              size: widget.size + 4,
            )
          : Icon(
              Icons.mic_none_outlined,
              color: widget.color ?? theme.colorScheme.onSurfaceVariant,
              size: widget.size,
            ),
      onPressed: _toggleListening,
      tooltip: _isListening ? "Stop listening" : "Speak to type",
    );
  }
}
