import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevScreen extends ConsumerStatefulWidget {
  const DevScreen({super.key});

  @override
  ConsumerState<DevScreen> createState() => _DevScreenState();
}

class _DevScreenState extends ConsumerState<DevScreen> {
  Map<String, String> _prefsEntries = {};
  bool _loading = true;
  String? _error;

  static String? _getString(SharedPreferences prefs, String key) {
    try {
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  static int? _getInt(SharedPreferences prefs, String key) {
    try {
      return prefs.getInt(key);
    } catch (_) {
      return null;
    }
  }

  static bool? _getBool(SharedPreferences prefs, String key) {
    try {
      return prefs.getBool(key);
    } catch (_) {
      return null;
    }
  }

  static double? _getDouble(SharedPreferences prefs, String key) {
    try {
      return prefs.getDouble(key);
    } catch (_) {
      return null;
    }
  }

  static List<String>? _getStringList(SharedPreferences prefs, String key) {
    try {
      return prefs.getStringList(key);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final Map<String, String> entries = {};
      for (final key in keys) {
        String value;
        final str = _getString(prefs, key);
        final i = _getInt(prefs, key);
        final b = _getBool(prefs, key);
        final d = _getDouble(prefs, key);
        final list = _getStringList(prefs, key);
        if (str != null) {
          value = str;
        } else if (i != null) {
          value = i.toString();
        } else if (b != null) {
          value = b.toString();
        } else if (d != null) {
          value = d.toString();
        } else if (list != null) {
          value = list.join(', ');
        } else {
          value = '(unknown)';
        }
        entries[key] = value;
      }
      if (mounted) {
        setState(() {
          _prefsEntries = entries;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadPrefs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : _prefsEntries.isEmpty
                  ? const Center(child: Text('No SharedPreferences entries.'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          'SharedPreferences (${_prefsEntries.length} keys)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._prefsEntries.entries.map(
                          (e) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    e.value,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
