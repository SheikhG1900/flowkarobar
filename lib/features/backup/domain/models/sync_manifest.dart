import 'dart:convert';

class SyncManifest {
  final int version;
  final String? lockedBy;
  final DateTime? lockedAt;

  SyncManifest({
    required this.version,
    this.lockedBy,
    this.lockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'lockedBy': lockedBy,
      'lockedAt': lockedAt?.toUtc().toIso8601String(),
    };
  }

  factory SyncManifest.fromMap(Map<String, dynamic> map) {
    return SyncManifest(
      version: map['version'] ?? 0,
      lockedBy: map['lockedBy'],
      lockedAt: map['lockedAt'] != null ? DateTime.parse(map['lockedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncManifest.fromJson(String source) => SyncManifest.fromMap(json.decode(source));

  SyncManifest copyWith({
    int? version,
    String? lockedBy,
    DateTime? lockedAt,
  }) {
    return SyncManifest(
      version: version ?? this.version,
      lockedBy: lockedBy ?? this.lockedBy,
      lockedAt: lockedAt ?? this.lockedAt,
    );
  }
}
