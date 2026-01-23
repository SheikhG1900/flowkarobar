import 'dart:convert';

class SyncVersionFile {
  final int version;
  final DateTime createdAt;
  final String deviceId;
  final Map<String, List<Map<String, dynamic>>> changes;

  SyncVersionFile({
    required this.version,
    required this.createdAt,
    required this.deviceId,
    required this.changes,
  });

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'deviceId': deviceId,
      'changes': changes,
    };
  }

  factory SyncVersionFile.fromMap(Map<String, dynamic> map) {
    return SyncVersionFile(
      version: map['version'] ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      deviceId: map['deviceId'] ?? '',
      changes: Map<String, List<dynamic>>.from(map['changes'] ?? {}).map(
        (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncVersionFile.fromJson(String source) => SyncVersionFile.fromMap(json.decode(source));
}
