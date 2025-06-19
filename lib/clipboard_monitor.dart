import 'dart:async';
import 'package:flutter/services.dart';
import 'clipboard_database.dart';

class ClipboardMonitor {
  static final ClipboardMonitor instance = ClipboardMonitor._init();
  Timer? _timer;
  String? _lastClipboardContent;
  final Duration interval;

  ClipboardMonitor._init({this.interval = const Duration(seconds: 2)});

  void start() {
    _timer ??= Timer.periodic(interval, (_) => _checkClipboard());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    final content = clipboardData?.text?.trim();
    if (content != null && content.isNotEmpty && content != _lastClipboardContent) {
      _lastClipboardContent = content;
      await ClipboardDatabase.instance.insertEntry(
        ClipboardEntry(content: content, timestamp: DateTime.now()),
      );
    }
  }
} 