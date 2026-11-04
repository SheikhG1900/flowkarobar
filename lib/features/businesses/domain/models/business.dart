import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';

class Business {
  final String id;
  final String name;
  final String colorCode; // Hex string e.g. #FF5252
  final String? iconCodePoint; // Icon codePoint string
  /// Logical database name WITHOUT extension, e.g. 'flowkarobar' or 'business_123'.
  /// When accessing the physical file, append the appropriate extension ('.db').
  final String dbPath;
  final DateTime createdAt;
  final int? addSeq;
  Color? _color;

  Business({
    required this.id,
    required this.name,
    required this.colorCode,
    this.iconCodePoint,
    required this.dbPath,
    required this.createdAt,
    this.addSeq,
  });

  Color get color =>
      _color ??= Color(int.parse(colorCode.replaceAll('#', '0xFF')));

  Color foreColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return Color.lerp(Colors.white, color, 0.3) ?? theme.colorScheme.primary;
    } else {
      return Color.lerp(Colors.black, color, .8) ?? theme.colorScheme.primary;
    }
  }

  Color backColor(BuildContext context) {
    final theme = Theme.of(context);
    return Color.lerp(theme.colorScheme.onPrimary, color, 0.5) ??
        theme.colorScheme.onPrimary;
  }

  IconData get icon =>
      IconHelper.getIconData(iconCodePoint) ?? Symbols.business_center;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorCode': colorCode,
      'iconCodePoint': iconCodePoint,
      'dbPath': dbPath,
      'createdAt': createdAt.toIso8601String(),
      'addSeq': addSeq,
    };
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    final rawPath = map['dbPath'] ?? 'flowkarobar';
    final sanitizedPath =
        rawPath is String ? rawPath.replaceAll(RegExp(r'\.(db|sqlite)$'), '') : 'flowkarobar';

    return Business(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorCode: map['colorCode'] ?? map['color'] ?? '#2196F3',
      iconCodePoint: map['iconCodePoint'] ?? map['icon'],
      dbPath: sanitizedPath,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      addSeq: map['addSeq'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Business.fromJson(String source) =>
      Business.fromMap(json.decode(source));

  Business copyWith({
    String? id,
    String? name,
    String? colorCode,
    String? iconCodePoint,
    String? dbPath,
    DateTime? createdAt,
    int? addSeq,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      dbPath: dbPath ?? this.dbPath,
      createdAt: createdAt ?? this.createdAt,
      addSeq: addSeq ?? this.addSeq,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Business && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
