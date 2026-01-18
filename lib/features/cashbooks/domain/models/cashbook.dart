import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';

class Cashbook {
  final String id;
  final String name;
  final String colorCode; // Hex string e.g. #FF5252
  final String? iconCodePoint; // Icon codePoint string
  final String dbPath; // Filename like 'flowpaisa.db' or 'travel.db'
  final DateTime createdAt;

  Cashbook({
    required this.id,
    required this.name,
    required this.colorCode,
    this.iconCodePoint,
    required this.dbPath,
    required this.createdAt,
  });

  Color get color => Color(int.parse(colorCode.replaceAll('#', '0xFF')));

  IconData get icon =>
      IconHelper.getIconData(iconCodePoint) ?? Symbols.water_drop;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorCode': colorCode,
      'iconCodePoint': iconCodePoint,
      'dbPath': dbPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Cashbook.fromMap(Map<String, dynamic> map) {
    return Cashbook(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorCode: map['colorCode'] ?? map['color'] ?? '#2196F3',
      iconCodePoint: map['iconCodePoint'] ?? map['icon'],
      dbPath: map['dbPath'] ?? 'flowpaisa.db',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Cashbook.fromJson(String source) =>
      Cashbook.fromMap(json.decode(source));

  Cashbook copyWith({
    String? id,
    String? name,
    String? colorCode,
    String? iconCodePoint,
    String? dbPath,
    DateTime? createdAt,
  }) {
    return Cashbook(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      dbPath: dbPath ?? this.dbPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cashbook && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
