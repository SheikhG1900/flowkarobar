// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        icon,
        color,
        type,
        isDefault,
        isDeleted,
        createdAt,
        updatedAt,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String uuid;
  final String name;
  final String? icon;
  final String? color;
  final String type;
  final bool isDefault;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isNotSynced;
  const Category(
      {required this.uuid,
      required this.name,
      this.icon,
      this.color,
      required this.type,
      required this.isDefault,
      required this.isDeleted,
      required this.createdAt,
      required this.updatedAt,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['type'] = Variable<String>(type);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      uuid: Value(uuid),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      type: Value(type),
      isDefault: Value(isDefault),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      type: serializer.fromJson<String>(json['type']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'type': serializer.toJson<String>(type),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Category copyWith(
          {String? uuid,
          String? name,
          Value<String?> icon = const Value.absent(),
          Value<String?> color = const Value.absent(),
          String? type,
          bool? isDefault,
          bool? isDeleted,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isNotSynced}) =>
      Category(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        icon: icon.present ? icon.value : this.icon,
        color: color.present ? color.value : this.color,
        type: type ?? this.type,
        isDefault: isDefault ?? this.isDefault,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, icon, color, type, isDefault,
      isDeleted, createdAt, updatedAt, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.isDefault == this.isDefault &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isNotSynced == this.isNotSynced);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<String> type;
  final Value<bool> isDefault;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String uuid,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required String type,
    this.isDefault = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        type = Value(type);
  static Insertable<Category> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? type,
    Expression<bool>? isDefault,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String?>? icon,
      Value<String?>? color,
      Value<String>? type,
      Value<bool>? isDefault,
      Value<bool>? isDeleted,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        phone,
        email,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String uuid;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Contact(
      {required this.uuid,
      required this.name,
      this.phone,
      this.email,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Contact copyWith(
          {String? uuid,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Contact(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, phone, email, notes, createdAt,
      updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const ContactsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String uuid,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Contact> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return ContactsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryUuidMeta =
      const VerificationMeta('categoryUuid');
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
      'category_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (uuid)'));
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _linkedReceivableUuidMeta =
      const VerificationMeta('linkedReceivableUuid');
  @override
  late final GeneratedColumn<String> linkedReceivableUuid =
      GeneratedColumn<String>('linked_receivable_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedPayableUuidMeta =
      const VerificationMeta('linkedPayableUuid');
  @override
  late final GeneratedColumn<String> linkedPayableUuid =
      GeneratedColumn<String>('linked_payable_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paidRelationshipMeta =
      const VerificationMeta('paidRelationship');
  @override
  late final GeneratedColumn<String> paidRelationship = GeneratedColumn<String>(
      'paid_relationship', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAutoGeneratedMeta =
      const VerificationMeta('isAutoGenerated');
  @override
  late final GeneratedColumn<bool> isAutoGenerated = GeneratedColumn<bool>(
      'is_auto_generated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_auto_generated" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isScheduledMeta =
      const VerificationMeta('isScheduled');
  @override
  late final GeneratedColumn<bool> isScheduled = GeneratedColumn<bool>(
      'is_scheduled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_scheduled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _externalLinkIdMeta =
      const VerificationMeta('externalLinkId');
  @override
  late final GeneratedColumn<String> externalLinkId = GeneratedColumn<String>(
      'external_link_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        amount,
        type,
        categoryUuid,
        contactUuid,
        description,
        date,
        linkedReceivableUuid,
        linkedPayableUuid,
        paidRelationship,
        isAutoGenerated,
        isScheduled,
        externalLinkId,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
          _categoryUuidMeta,
          categoryUuid.isAcceptableOrUnknown(
              data['category_uuid']!, _categoryUuidMeta));
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('linked_receivable_uuid')) {
      context.handle(
          _linkedReceivableUuidMeta,
          linkedReceivableUuid.isAcceptableOrUnknown(
              data['linked_receivable_uuid']!, _linkedReceivableUuidMeta));
    }
    if (data.containsKey('linked_payable_uuid')) {
      context.handle(
          _linkedPayableUuidMeta,
          linkedPayableUuid.isAcceptableOrUnknown(
              data['linked_payable_uuid']!, _linkedPayableUuidMeta));
    }
    if (data.containsKey('paid_relationship')) {
      context.handle(
          _paidRelationshipMeta,
          paidRelationship.isAcceptableOrUnknown(
              data['paid_relationship']!, _paidRelationshipMeta));
    }
    if (data.containsKey('is_auto_generated')) {
      context.handle(
          _isAutoGeneratedMeta,
          isAutoGenerated.isAcceptableOrUnknown(
              data['is_auto_generated']!, _isAutoGeneratedMeta));
    }
    if (data.containsKey('is_scheduled')) {
      context.handle(
          _isScheduledMeta,
          isScheduled.isAcceptableOrUnknown(
              data['is_scheduled']!, _isScheduledMeta));
    }
    if (data.containsKey('external_link_id')) {
      context.handle(
          _externalLinkIdMeta,
          externalLinkId.isAcceptableOrUnknown(
              data['external_link_id']!, _externalLinkIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      categoryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_uuid']),
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      linkedReceivableUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}linked_receivable_uuid']),
      linkedPayableUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_payable_uuid']),
      paidRelationship: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}paid_relationship']),
      isAutoGenerated: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_auto_generated'])!,
      isScheduled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_scheduled'])!,
      externalLinkId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_link_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String uuid;
  final double amount;
  final String type;
  final String? categoryUuid;
  final String? contactUuid;
  final String? description;
  final DateTime date;
  final String? linkedReceivableUuid;
  final String? linkedPayableUuid;
  final String? paidRelationship;
  final bool isAutoGenerated;
  final bool isScheduled;
  final String? externalLinkId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Transaction(
      {required this.uuid,
      required this.amount,
      required this.type,
      this.categoryUuid,
      this.contactUuid,
      this.description,
      required this.date,
      this.linkedReceivableUuid,
      this.linkedPayableUuid,
      this.paidRelationship,
      required this.isAutoGenerated,
      required this.isScheduled,
      this.externalLinkId,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryUuid != null) {
      map['category_uuid'] = Variable<String>(categoryUuid);
    }
    if (!nullToAbsent || contactUuid != null) {
      map['contact_uuid'] = Variable<String>(contactUuid);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || linkedReceivableUuid != null) {
      map['linked_receivable_uuid'] = Variable<String>(linkedReceivableUuid);
    }
    if (!nullToAbsent || linkedPayableUuid != null) {
      map['linked_payable_uuid'] = Variable<String>(linkedPayableUuid);
    }
    if (!nullToAbsent || paidRelationship != null) {
      map['paid_relationship'] = Variable<String>(paidRelationship);
    }
    map['is_auto_generated'] = Variable<bool>(isAutoGenerated);
    map['is_scheduled'] = Variable<bool>(isScheduled);
    if (!nullToAbsent || externalLinkId != null) {
      map['external_link_id'] = Variable<String>(externalLinkId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      uuid: Value(uuid),
      amount: Value(amount),
      type: Value(type),
      categoryUuid: categoryUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryUuid),
      contactUuid: contactUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(contactUuid),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      linkedReceivableUuid: linkedReceivableUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedReceivableUuid),
      linkedPayableUuid: linkedPayableUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedPayableUuid),
      paidRelationship: paidRelationship == null && nullToAbsent
          ? const Value.absent()
          : Value(paidRelationship),
      isAutoGenerated: Value(isAutoGenerated),
      isScheduled: Value(isScheduled),
      externalLinkId: externalLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalLinkId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      uuid: serializer.fromJson<String>(json['uuid']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      categoryUuid: serializer.fromJson<String?>(json['categoryUuid']),
      contactUuid: serializer.fromJson<String?>(json['contactUuid']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      linkedReceivableUuid:
          serializer.fromJson<String?>(json['linkedReceivableUuid']),
      linkedPayableUuid:
          serializer.fromJson<String?>(json['linkedPayableUuid']),
      paidRelationship: serializer.fromJson<String?>(json['paidRelationship']),
      isAutoGenerated: serializer.fromJson<bool>(json['isAutoGenerated']),
      isScheduled: serializer.fromJson<bool>(json['isScheduled']),
      externalLinkId: serializer.fromJson<String?>(json['externalLinkId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'categoryUuid': serializer.toJson<String?>(categoryUuid),
      'contactUuid': serializer.toJson<String?>(contactUuid),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'linkedReceivableUuid': serializer.toJson<String?>(linkedReceivableUuid),
      'linkedPayableUuid': serializer.toJson<String?>(linkedPayableUuid),
      'paidRelationship': serializer.toJson<String?>(paidRelationship),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
      'isScheduled': serializer.toJson<bool>(isScheduled),
      'externalLinkId': serializer.toJson<String?>(externalLinkId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Transaction copyWith(
          {String? uuid,
          double? amount,
          String? type,
          Value<String?> categoryUuid = const Value.absent(),
          Value<String?> contactUuid = const Value.absent(),
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<String?> linkedReceivableUuid = const Value.absent(),
          Value<String?> linkedPayableUuid = const Value.absent(),
          Value<String?> paidRelationship = const Value.absent(),
          bool? isAutoGenerated,
          bool? isScheduled,
          Value<String?> externalLinkId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Transaction(
        uuid: uuid ?? this.uuid,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryUuid:
            categoryUuid.present ? categoryUuid.value : this.categoryUuid,
        contactUuid: contactUuid.present ? contactUuid.value : this.contactUuid,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        linkedReceivableUuid: linkedReceivableUuid.present
            ? linkedReceivableUuid.value
            : this.linkedReceivableUuid,
        linkedPayableUuid: linkedPayableUuid.present
            ? linkedPayableUuid.value
            : this.linkedPayableUuid,
        paidRelationship: paidRelationship.present
            ? paidRelationship.value
            : this.paidRelationship,
        isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
        isScheduled: isScheduled ?? this.isScheduled,
        externalLinkId:
            externalLinkId.present ? externalLinkId.value : this.externalLinkId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      linkedReceivableUuid: data.linkedReceivableUuid.present
          ? data.linkedReceivableUuid.value
          : this.linkedReceivableUuid,
      linkedPayableUuid: data.linkedPayableUuid.present
          ? data.linkedPayableUuid.value
          : this.linkedPayableUuid,
      paidRelationship: data.paidRelationship.present
          ? data.paidRelationship.value
          : this.paidRelationship,
      isAutoGenerated: data.isAutoGenerated.present
          ? data.isAutoGenerated.value
          : this.isAutoGenerated,
      isScheduled:
          data.isScheduled.present ? data.isScheduled.value : this.isScheduled,
      externalLinkId: data.externalLinkId.present
          ? data.externalLinkId.value
          : this.externalLinkId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('uuid: $uuid, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('linkedReceivableUuid: $linkedReceivableUuid, ')
          ..write('linkedPayableUuid: $linkedPayableUuid, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('isScheduled: $isScheduled, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      amount,
      type,
      categoryUuid,
      contactUuid,
      description,
      date,
      linkedReceivableUuid,
      linkedPayableUuid,
      paidRelationship,
      isAutoGenerated,
      isScheduled,
      externalLinkId,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.uuid == this.uuid &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.categoryUuid == this.categoryUuid &&
          other.contactUuid == this.contactUuid &&
          other.description == this.description &&
          other.date == this.date &&
          other.linkedReceivableUuid == this.linkedReceivableUuid &&
          other.linkedPayableUuid == this.linkedPayableUuid &&
          other.paidRelationship == this.paidRelationship &&
          other.isAutoGenerated == this.isAutoGenerated &&
          other.isScheduled == this.isScheduled &&
          other.externalLinkId == this.externalLinkId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> uuid;
  final Value<double> amount;
  final Value<String> type;
  final Value<String?> categoryUuid;
  final Value<String?> contactUuid;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<String?> linkedReceivableUuid;
  final Value<String?> linkedPayableUuid;
  final Value<String?> paidRelationship;
  final Value<bool> isAutoGenerated;
  final Value<bool> isScheduled;
  final Value<String?> externalLinkId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.uuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.linkedReceivableUuid = const Value.absent(),
    this.linkedPayableUuid = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.isScheduled = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String uuid,
    required double amount,
    required String type,
    this.categoryUuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime date,
    this.linkedReceivableUuid = const Value.absent(),
    this.linkedPayableUuid = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.isScheduled = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        amount = Value(amount),
        type = Value(type),
        date = Value(date);
  static Insertable<Transaction> custom({
    Expression<String>? uuid,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? categoryUuid,
    Expression<String>? contactUuid,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<String>? linkedReceivableUuid,
    Expression<String>? linkedPayableUuid,
    Expression<String>? paidRelationship,
    Expression<bool>? isAutoGenerated,
    Expression<bool>? isScheduled,
    Expression<String>? externalLinkId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (linkedReceivableUuid != null)
        'linked_receivable_uuid': linkedReceivableUuid,
      if (linkedPayableUuid != null) 'linked_payable_uuid': linkedPayableUuid,
      if (paidRelationship != null) 'paid_relationship': paidRelationship,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (isScheduled != null) 'is_scheduled': isScheduled,
      if (externalLinkId != null) 'external_link_id': externalLinkId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? uuid,
      Value<double>? amount,
      Value<String>? type,
      Value<String?>? categoryUuid,
      Value<String?>? contactUuid,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<String?>? linkedReceivableUuid,
      Value<String?>? linkedPayableUuid,
      Value<String?>? paidRelationship,
      Value<bool>? isAutoGenerated,
      Value<bool>? isScheduled,
      Value<String?>? externalLinkId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      uuid: uuid ?? this.uuid,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      contactUuid: contactUuid ?? this.contactUuid,
      description: description ?? this.description,
      date: date ?? this.date,
      linkedReceivableUuid: linkedReceivableUuid ?? this.linkedReceivableUuid,
      linkedPayableUuid: linkedPayableUuid ?? this.linkedPayableUuid,
      paidRelationship: paidRelationship ?? this.paidRelationship,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      isScheduled: isScheduled ?? this.isScheduled,
      externalLinkId: externalLinkId ?? this.externalLinkId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (linkedReceivableUuid.present) {
      map['linked_receivable_uuid'] =
          Variable<String>(linkedReceivableUuid.value);
    }
    if (linkedPayableUuid.present) {
      map['linked_payable_uuid'] = Variable<String>(linkedPayableUuid.value);
    }
    if (paidRelationship.present) {
      map['paid_relationship'] = Variable<String>(paidRelationship.value);
    }
    if (isAutoGenerated.present) {
      map['is_auto_generated'] = Variable<bool>(isAutoGenerated.value);
    }
    if (isScheduled.present) {
      map['is_scheduled'] = Variable<bool>(isScheduled.value);
    }
    if (externalLinkId.present) {
      map['external_link_id'] = Variable<String>(externalLinkId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('linkedReceivableUuid: $linkedReceivableUuid, ')
          ..write('linkedPayableUuid: $linkedPayableUuid, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('isScheduled: $isScheduled, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceivablesTable extends Receivables
    with TableInfo<$ReceivablesTable, Receivable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceivablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _receivedDateMeta =
      const VerificationMeta('receivedDate');
  @override
  late final GeneratedColumn<DateTime> receivedDate = GeneratedColumn<DateTime>(
      'received_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _linkedExpenseUuidMeta =
      const VerificationMeta('linkedExpenseUuid');
  @override
  late final GeneratedColumn<String> linkedExpenseUuid =
      GeneratedColumn<String>('linked_expense_uuid', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES transactions (uuid)'));
  static const VerificationMeta _linkedIncomeUuidMeta =
      const VerificationMeta('linkedIncomeUuid');
  @override
  late final GeneratedColumn<String> linkedIncomeUuid = GeneratedColumn<String>(
      'linked_income_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (uuid)'));
  static const VerificationMeta _autoCreateIncomeMeta =
      const VerificationMeta('autoCreateIncome');
  @override
  late final GeneratedColumn<bool> autoCreateIncome = GeneratedColumn<bool>(
      'auto_create_income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_create_income" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isScheduledMeta =
      const VerificationMeta('isScheduled');
  @override
  late final GeneratedColumn<bool> isScheduled = GeneratedColumn<bool>(
      'is_scheduled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_scheduled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _externalLinkIdMeta =
      const VerificationMeta('externalLinkId');
  @override
  late final GeneratedColumn<String> externalLinkId = GeneratedColumn<String>(
      'external_link_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        contactUuid,
        amount,
        description,
        date,
        dueDate,
        status,
        receivedDate,
        linkedExpenseUuid,
        linkedIncomeUuid,
        autoCreateIncome,
        isScheduled,
        externalLinkId,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receivables';
  @override
  VerificationContext validateIntegrity(Insertable<Receivable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    } else if (isInserting) {
      context.missing(_contactUuidMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('received_date')) {
      context.handle(
          _receivedDateMeta,
          receivedDate.isAcceptableOrUnknown(
              data['received_date']!, _receivedDateMeta));
    }
    if (data.containsKey('linked_expense_uuid')) {
      context.handle(
          _linkedExpenseUuidMeta,
          linkedExpenseUuid.isAcceptableOrUnknown(
              data['linked_expense_uuid']!, _linkedExpenseUuidMeta));
    }
    if (data.containsKey('linked_income_uuid')) {
      context.handle(
          _linkedIncomeUuidMeta,
          linkedIncomeUuid.isAcceptableOrUnknown(
              data['linked_income_uuid']!, _linkedIncomeUuidMeta));
    }
    if (data.containsKey('auto_create_income')) {
      context.handle(
          _autoCreateIncomeMeta,
          autoCreateIncome.isAcceptableOrUnknown(
              data['auto_create_income']!, _autoCreateIncomeMeta));
    }
    if (data.containsKey('is_scheduled')) {
      context.handle(
          _isScheduledMeta,
          isScheduled.isAcceptableOrUnknown(
              data['is_scheduled']!, _isScheduledMeta));
    }
    if (data.containsKey('external_link_id')) {
      context.handle(
          _externalLinkIdMeta,
          externalLinkId.isAcceptableOrUnknown(
              data['external_link_id']!, _externalLinkIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Receivable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receivable(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      receivedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_date']),
      linkedExpenseUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_expense_uuid']),
      linkedIncomeUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_income_uuid']),
      autoCreateIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_create_income'])!,
      isScheduled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_scheduled'])!,
      externalLinkId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_link_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $ReceivablesTable createAlias(String alias) {
    return $ReceivablesTable(attachedDatabase, alias);
  }
}

class Receivable extends DataClass implements Insertable<Receivable> {
  final String uuid;
  final String contactUuid;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final String status;
  final DateTime? receivedDate;
  final String? linkedExpenseUuid;
  final String? linkedIncomeUuid;
  final bool autoCreateIncome;
  final bool isScheduled;
  final String? externalLinkId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Receivable(
      {required this.uuid,
      required this.contactUuid,
      required this.amount,
      this.description,
      required this.date,
      this.dueDate,
      required this.status,
      this.receivedDate,
      this.linkedExpenseUuid,
      this.linkedIncomeUuid,
      required this.autoCreateIncome,
      required this.isScheduled,
      this.externalLinkId,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['contact_uuid'] = Variable<String>(contactUuid);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || receivedDate != null) {
      map['received_date'] = Variable<DateTime>(receivedDate);
    }
    if (!nullToAbsent || linkedExpenseUuid != null) {
      map['linked_expense_uuid'] = Variable<String>(linkedExpenseUuid);
    }
    if (!nullToAbsent || linkedIncomeUuid != null) {
      map['linked_income_uuid'] = Variable<String>(linkedIncomeUuid);
    }
    map['auto_create_income'] = Variable<bool>(autoCreateIncome);
    map['is_scheduled'] = Variable<bool>(isScheduled);
    if (!nullToAbsent || externalLinkId != null) {
      map['external_link_id'] = Variable<String>(externalLinkId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  ReceivablesCompanion toCompanion(bool nullToAbsent) {
    return ReceivablesCompanion(
      uuid: Value(uuid),
      contactUuid: Value(contactUuid),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      receivedDate: receivedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedDate),
      linkedExpenseUuid: linkedExpenseUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedExpenseUuid),
      linkedIncomeUuid: linkedIncomeUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedIncomeUuid),
      autoCreateIncome: Value(autoCreateIncome),
      isScheduled: Value(isScheduled),
      externalLinkId: externalLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalLinkId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Receivable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receivable(
      uuid: serializer.fromJson<String>(json['uuid']),
      contactUuid: serializer.fromJson<String>(json['contactUuid']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      receivedDate: serializer.fromJson<DateTime?>(json['receivedDate']),
      linkedExpenseUuid:
          serializer.fromJson<String?>(json['linkedExpenseUuid']),
      linkedIncomeUuid: serializer.fromJson<String?>(json['linkedIncomeUuid']),
      autoCreateIncome: serializer.fromJson<bool>(json['autoCreateIncome']),
      isScheduled: serializer.fromJson<bool>(json['isScheduled']),
      externalLinkId: serializer.fromJson<String?>(json['externalLinkId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'contactUuid': serializer.toJson<String>(contactUuid),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(status),
      'receivedDate': serializer.toJson<DateTime?>(receivedDate),
      'linkedExpenseUuid': serializer.toJson<String?>(linkedExpenseUuid),
      'linkedIncomeUuid': serializer.toJson<String?>(linkedIncomeUuid),
      'autoCreateIncome': serializer.toJson<bool>(autoCreateIncome),
      'isScheduled': serializer.toJson<bool>(isScheduled),
      'externalLinkId': serializer.toJson<String?>(externalLinkId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Receivable copyWith(
          {String? uuid,
          String? contactUuid,
          double? amount,
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<DateTime?> dueDate = const Value.absent(),
          String? status,
          Value<DateTime?> receivedDate = const Value.absent(),
          Value<String?> linkedExpenseUuid = const Value.absent(),
          Value<String?> linkedIncomeUuid = const Value.absent(),
          bool? autoCreateIncome,
          bool? isScheduled,
          Value<String?> externalLinkId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Receivable(
        uuid: uuid ?? this.uuid,
        contactUuid: contactUuid ?? this.contactUuid,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        status: status ?? this.status,
        receivedDate:
            receivedDate.present ? receivedDate.value : this.receivedDate,
        linkedExpenseUuid: linkedExpenseUuid.present
            ? linkedExpenseUuid.value
            : this.linkedExpenseUuid,
        linkedIncomeUuid: linkedIncomeUuid.present
            ? linkedIncomeUuid.value
            : this.linkedIncomeUuid,
        autoCreateIncome: autoCreateIncome ?? this.autoCreateIncome,
        isScheduled: isScheduled ?? this.isScheduled,
        externalLinkId:
            externalLinkId.present ? externalLinkId.value : this.externalLinkId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Receivable copyWithCompanion(ReceivablesCompanion data) {
    return Receivable(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      receivedDate: data.receivedDate.present
          ? data.receivedDate.value
          : this.receivedDate,
      linkedExpenseUuid: data.linkedExpenseUuid.present
          ? data.linkedExpenseUuid.value
          : this.linkedExpenseUuid,
      linkedIncomeUuid: data.linkedIncomeUuid.present
          ? data.linkedIncomeUuid.value
          : this.linkedIncomeUuid,
      autoCreateIncome: data.autoCreateIncome.present
          ? data.autoCreateIncome.value
          : this.autoCreateIncome,
      isScheduled:
          data.isScheduled.present ? data.isScheduled.value : this.isScheduled,
      externalLinkId: data.externalLinkId.present
          ? data.externalLinkId.value
          : this.externalLinkId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Receivable(')
          ..write('uuid: $uuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('linkedExpenseUuid: $linkedExpenseUuid, ')
          ..write('linkedIncomeUuid: $linkedIncomeUuid, ')
          ..write('autoCreateIncome: $autoCreateIncome, ')
          ..write('isScheduled: $isScheduled, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      contactUuid,
      amount,
      description,
      date,
      dueDate,
      status,
      receivedDate,
      linkedExpenseUuid,
      linkedIncomeUuid,
      autoCreateIncome,
      isScheduled,
      externalLinkId,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receivable &&
          other.uuid == this.uuid &&
          other.contactUuid == this.contactUuid &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.receivedDate == this.receivedDate &&
          other.linkedExpenseUuid == this.linkedExpenseUuid &&
          other.linkedIncomeUuid == this.linkedIncomeUuid &&
          other.autoCreateIncome == this.autoCreateIncome &&
          other.isScheduled == this.isScheduled &&
          other.externalLinkId == this.externalLinkId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class ReceivablesCompanion extends UpdateCompanion<Receivable> {
  final Value<String> uuid;
  final Value<String> contactUuid;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<DateTime?> receivedDate;
  final Value<String?> linkedExpenseUuid;
  final Value<String?> linkedIncomeUuid;
  final Value<bool> autoCreateIncome;
  final Value<bool> isScheduled;
  final Value<String?> externalLinkId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const ReceivablesCompanion({
    this.uuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.receivedDate = const Value.absent(),
    this.linkedExpenseUuid = const Value.absent(),
    this.linkedIncomeUuid = const Value.absent(),
    this.autoCreateIncome = const Value.absent(),
    this.isScheduled = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceivablesCompanion.insert({
    required String uuid,
    required String contactUuid,
    required double amount,
    this.description = const Value.absent(),
    required DateTime date,
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.receivedDate = const Value.absent(),
    this.linkedExpenseUuid = const Value.absent(),
    this.linkedIncomeUuid = const Value.absent(),
    this.autoCreateIncome = const Value.absent(),
    this.isScheduled = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        contactUuid = Value(contactUuid),
        amount = Value(amount),
        date = Value(date);
  static Insertable<Receivable> custom({
    Expression<String>? uuid,
    Expression<String>? contactUuid,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<DateTime>? receivedDate,
    Expression<String>? linkedExpenseUuid,
    Expression<String>? linkedIncomeUuid,
    Expression<bool>? autoCreateIncome,
    Expression<bool>? isScheduled,
    Expression<String>? externalLinkId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (receivedDate != null) 'received_date': receivedDate,
      if (linkedExpenseUuid != null) 'linked_expense_uuid': linkedExpenseUuid,
      if (linkedIncomeUuid != null) 'linked_income_uuid': linkedIncomeUuid,
      if (autoCreateIncome != null) 'auto_create_income': autoCreateIncome,
      if (isScheduled != null) 'is_scheduled': isScheduled,
      if (externalLinkId != null) 'external_link_id': externalLinkId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceivablesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? contactUuid,
      Value<double>? amount,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<DateTime?>? dueDate,
      Value<String>? status,
      Value<DateTime?>? receivedDate,
      Value<String?>? linkedExpenseUuid,
      Value<String?>? linkedIncomeUuid,
      Value<bool>? autoCreateIncome,
      Value<bool>? isScheduled,
      Value<String?>? externalLinkId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return ReceivablesCompanion(
      uuid: uuid ?? this.uuid,
      contactUuid: contactUuid ?? this.contactUuid,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      receivedDate: receivedDate ?? this.receivedDate,
      linkedExpenseUuid: linkedExpenseUuid ?? this.linkedExpenseUuid,
      linkedIncomeUuid: linkedIncomeUuid ?? this.linkedIncomeUuid,
      autoCreateIncome: autoCreateIncome ?? this.autoCreateIncome,
      isScheduled: isScheduled ?? this.isScheduled,
      externalLinkId: externalLinkId ?? this.externalLinkId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (receivedDate.present) {
      map['received_date'] = Variable<DateTime>(receivedDate.value);
    }
    if (linkedExpenseUuid.present) {
      map['linked_expense_uuid'] = Variable<String>(linkedExpenseUuid.value);
    }
    if (linkedIncomeUuid.present) {
      map['linked_income_uuid'] = Variable<String>(linkedIncomeUuid.value);
    }
    if (autoCreateIncome.present) {
      map['auto_create_income'] = Variable<bool>(autoCreateIncome.value);
    }
    if (isScheduled.present) {
      map['is_scheduled'] = Variable<bool>(isScheduled.value);
    }
    if (externalLinkId.present) {
      map['external_link_id'] = Variable<String>(externalLinkId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceivablesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('linkedExpenseUuid: $linkedExpenseUuid, ')
          ..write('linkedIncomeUuid: $linkedIncomeUuid, ')
          ..write('autoCreateIncome: $autoCreateIncome, ')
          ..write('isScheduled: $isScheduled, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayablesTable extends Payables with TableInfo<$PayablesTable, Payable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _paidDateMeta =
      const VerificationMeta('paidDate');
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
      'paid_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _linkedExpenseUuidMeta =
      const VerificationMeta('linkedExpenseUuid');
  @override
  late final GeneratedColumn<String> linkedExpenseUuid =
      GeneratedColumn<String>('linked_expense_uuid', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES transactions (uuid)'));
  static const VerificationMeta _linkedIncomeUuidMeta =
      const VerificationMeta('linkedIncomeUuid');
  @override
  late final GeneratedColumn<String> linkedIncomeUuid = GeneratedColumn<String>(
      'linked_income_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (uuid)'));
  static const VerificationMeta _autoCreateExpenseMeta =
      const VerificationMeta('autoCreateExpense');
  @override
  late final GeneratedColumn<bool> autoCreateExpense = GeneratedColumn<bool>(
      'auto_create_expense', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_create_expense" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isScheduledMeta =
      const VerificationMeta('isScheduled');
  @override
  late final GeneratedColumn<bool> isScheduled = GeneratedColumn<bool>(
      'is_scheduled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_scheduled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _externalLinkIdMeta =
      const VerificationMeta('externalLinkId');
  @override
  late final GeneratedColumn<String> externalLinkId = GeneratedColumn<String>(
      'external_link_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        contactUuid,
        amount,
        description,
        date,
        dueDate,
        status,
        paidDate,
        linkedExpenseUuid,
        linkedIncomeUuid,
        autoCreateExpense,
        isScheduled,
        externalLinkId,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payables';
  @override
  VerificationContext validateIntegrity(Insertable<Payable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    } else if (isInserting) {
      context.missing(_contactUuidMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('paid_date')) {
      context.handle(_paidDateMeta,
          paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta));
    }
    if (data.containsKey('linked_expense_uuid')) {
      context.handle(
          _linkedExpenseUuidMeta,
          linkedExpenseUuid.isAcceptableOrUnknown(
              data['linked_expense_uuid']!, _linkedExpenseUuidMeta));
    }
    if (data.containsKey('linked_income_uuid')) {
      context.handle(
          _linkedIncomeUuidMeta,
          linkedIncomeUuid.isAcceptableOrUnknown(
              data['linked_income_uuid']!, _linkedIncomeUuidMeta));
    }
    if (data.containsKey('auto_create_expense')) {
      context.handle(
          _autoCreateExpenseMeta,
          autoCreateExpense.isAcceptableOrUnknown(
              data['auto_create_expense']!, _autoCreateExpenseMeta));
    }
    if (data.containsKey('is_scheduled')) {
      context.handle(
          _isScheduledMeta,
          isScheduled.isAcceptableOrUnknown(
              data['is_scheduled']!, _isScheduledMeta));
    }
    if (data.containsKey('external_link_id')) {
      context.handle(
          _externalLinkIdMeta,
          externalLinkId.isAcceptableOrUnknown(
              data['external_link_id']!, _externalLinkIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Payable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payable(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      paidDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paid_date']),
      linkedExpenseUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_expense_uuid']),
      linkedIncomeUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_income_uuid']),
      autoCreateExpense: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_create_expense'])!,
      isScheduled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_scheduled'])!,
      externalLinkId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_link_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $PayablesTable createAlias(String alias) {
    return $PayablesTable(attachedDatabase, alias);
  }
}

class Payable extends DataClass implements Insertable<Payable> {
  final String uuid;
  final String contactUuid;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final String status;
  final DateTime? paidDate;
  final String? linkedExpenseUuid;
  final String? linkedIncomeUuid;
  final bool autoCreateExpense;
  final bool isScheduled;
  final String? externalLinkId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Payable(
      {required this.uuid,
      required this.contactUuid,
      required this.amount,
      this.description,
      required this.date,
      this.dueDate,
      required this.status,
      this.paidDate,
      this.linkedExpenseUuid,
      this.linkedIncomeUuid,
      required this.autoCreateExpense,
      required this.isScheduled,
      this.externalLinkId,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['contact_uuid'] = Variable<String>(contactUuid);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    if (!nullToAbsent || linkedExpenseUuid != null) {
      map['linked_expense_uuid'] = Variable<String>(linkedExpenseUuid);
    }
    if (!nullToAbsent || linkedIncomeUuid != null) {
      map['linked_income_uuid'] = Variable<String>(linkedIncomeUuid);
    }
    map['auto_create_expense'] = Variable<bool>(autoCreateExpense);
    map['is_scheduled'] = Variable<bool>(isScheduled);
    if (!nullToAbsent || externalLinkId != null) {
      map['external_link_id'] = Variable<String>(externalLinkId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  PayablesCompanion toCompanion(bool nullToAbsent) {
    return PayablesCompanion(
      uuid: Value(uuid),
      contactUuid: Value(contactUuid),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      paidDate: paidDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paidDate),
      linkedExpenseUuid: linkedExpenseUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedExpenseUuid),
      linkedIncomeUuid: linkedIncomeUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedIncomeUuid),
      autoCreateExpense: Value(autoCreateExpense),
      isScheduled: Value(isScheduled),
      externalLinkId: externalLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalLinkId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Payable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payable(
      uuid: serializer.fromJson<String>(json['uuid']),
      contactUuid: serializer.fromJson<String>(json['contactUuid']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      linkedExpenseUuid:
          serializer.fromJson<String?>(json['linkedExpenseUuid']),
      linkedIncomeUuid: serializer.fromJson<String?>(json['linkedIncomeUuid']),
      autoCreateExpense: serializer.fromJson<bool>(json['autoCreateExpense']),
      isScheduled: serializer.fromJson<bool>(json['isScheduled']),
      externalLinkId: serializer.fromJson<String?>(json['externalLinkId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'contactUuid': serializer.toJson<String>(contactUuid),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(status),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'linkedExpenseUuid': serializer.toJson<String?>(linkedExpenseUuid),
      'linkedIncomeUuid': serializer.toJson<String?>(linkedIncomeUuid),
      'autoCreateExpense': serializer.toJson<bool>(autoCreateExpense),
      'isScheduled': serializer.toJson<bool>(isScheduled),
      'externalLinkId': serializer.toJson<String?>(externalLinkId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Payable copyWith(
          {String? uuid,
          String? contactUuid,
          double? amount,
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<DateTime?> dueDate = const Value.absent(),
          String? status,
          Value<DateTime?> paidDate = const Value.absent(),
          Value<String?> linkedExpenseUuid = const Value.absent(),
          Value<String?> linkedIncomeUuid = const Value.absent(),
          bool? autoCreateExpense,
          bool? isScheduled,
          Value<String?> externalLinkId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Payable(
        uuid: uuid ?? this.uuid,
        contactUuid: contactUuid ?? this.contactUuid,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        status: status ?? this.status,
        paidDate: paidDate.present ? paidDate.value : this.paidDate,
        linkedExpenseUuid: linkedExpenseUuid.present
            ? linkedExpenseUuid.value
            : this.linkedExpenseUuid,
        linkedIncomeUuid: linkedIncomeUuid.present
            ? linkedIncomeUuid.value
            : this.linkedIncomeUuid,
        autoCreateExpense: autoCreateExpense ?? this.autoCreateExpense,
        isScheduled: isScheduled ?? this.isScheduled,
        externalLinkId:
            externalLinkId.present ? externalLinkId.value : this.externalLinkId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Payable copyWithCompanion(PayablesCompanion data) {
    return Payable(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      linkedExpenseUuid: data.linkedExpenseUuid.present
          ? data.linkedExpenseUuid.value
          : this.linkedExpenseUuid,
      linkedIncomeUuid: data.linkedIncomeUuid.present
          ? data.linkedIncomeUuid.value
          : this.linkedIncomeUuid,
      autoCreateExpense: data.autoCreateExpense.present
          ? data.autoCreateExpense.value
          : this.autoCreateExpense,
      isScheduled:
          data.isScheduled.present ? data.isScheduled.value : this.isScheduled,
      externalLinkId: data.externalLinkId.present
          ? data.externalLinkId.value
          : this.externalLinkId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payable(')
          ..write('uuid: $uuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('paidDate: $paidDate, ')
          ..write('linkedExpenseUuid: $linkedExpenseUuid, ')
          ..write('linkedIncomeUuid: $linkedIncomeUuid, ')
          ..write('autoCreateExpense: $autoCreateExpense, ')
          ..write('isScheduled: $isScheduled, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      contactUuid,
      amount,
      description,
      date,
      dueDate,
      status,
      paidDate,
      linkedExpenseUuid,
      linkedIncomeUuid,
      autoCreateExpense,
      isScheduled,
      externalLinkId,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payable &&
          other.uuid == this.uuid &&
          other.contactUuid == this.contactUuid &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.paidDate == this.paidDate &&
          other.linkedExpenseUuid == this.linkedExpenseUuid &&
          other.linkedIncomeUuid == this.linkedIncomeUuid &&
          other.autoCreateExpense == this.autoCreateExpense &&
          other.isScheduled == this.isScheduled &&
          other.externalLinkId == this.externalLinkId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class PayablesCompanion extends UpdateCompanion<Payable> {
  final Value<String> uuid;
  final Value<String> contactUuid;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<DateTime?> paidDate;
  final Value<String?> linkedExpenseUuid;
  final Value<String?> linkedIncomeUuid;
  final Value<bool> autoCreateExpense;
  final Value<bool> isScheduled;
  final Value<String?> externalLinkId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const PayablesCompanion({
    this.uuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.linkedExpenseUuid = const Value.absent(),
    this.linkedIncomeUuid = const Value.absent(),
    this.autoCreateExpense = const Value.absent(),
    this.isScheduled = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayablesCompanion.insert({
    required String uuid,
    required String contactUuid,
    required double amount,
    this.description = const Value.absent(),
    required DateTime date,
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.linkedExpenseUuid = const Value.absent(),
    this.linkedIncomeUuid = const Value.absent(),
    this.autoCreateExpense = const Value.absent(),
    this.isScheduled = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        contactUuid = Value(contactUuid),
        amount = Value(amount),
        date = Value(date);
  static Insertable<Payable> custom({
    Expression<String>? uuid,
    Expression<String>? contactUuid,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<DateTime>? paidDate,
    Expression<String>? linkedExpenseUuid,
    Expression<String>? linkedIncomeUuid,
    Expression<bool>? autoCreateExpense,
    Expression<bool>? isScheduled,
    Expression<String>? externalLinkId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (paidDate != null) 'paid_date': paidDate,
      if (linkedExpenseUuid != null) 'linked_expense_uuid': linkedExpenseUuid,
      if (linkedIncomeUuid != null) 'linked_income_uuid': linkedIncomeUuid,
      if (autoCreateExpense != null) 'auto_create_expense': autoCreateExpense,
      if (isScheduled != null) 'is_scheduled': isScheduled,
      if (externalLinkId != null) 'external_link_id': externalLinkId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayablesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? contactUuid,
      Value<double>? amount,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<DateTime?>? dueDate,
      Value<String>? status,
      Value<DateTime?>? paidDate,
      Value<String?>? linkedExpenseUuid,
      Value<String?>? linkedIncomeUuid,
      Value<bool>? autoCreateExpense,
      Value<bool>? isScheduled,
      Value<String?>? externalLinkId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return PayablesCompanion(
      uuid: uuid ?? this.uuid,
      contactUuid: contactUuid ?? this.contactUuid,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      linkedExpenseUuid: linkedExpenseUuid ?? this.linkedExpenseUuid,
      linkedIncomeUuid: linkedIncomeUuid ?? this.linkedIncomeUuid,
      autoCreateExpense: autoCreateExpense ?? this.autoCreateExpense,
      isScheduled: isScheduled ?? this.isScheduled,
      externalLinkId: externalLinkId ?? this.externalLinkId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (linkedExpenseUuid.present) {
      map['linked_expense_uuid'] = Variable<String>(linkedExpenseUuid.value);
    }
    if (linkedIncomeUuid.present) {
      map['linked_income_uuid'] = Variable<String>(linkedIncomeUuid.value);
    }
    if (autoCreateExpense.present) {
      map['auto_create_expense'] = Variable<bool>(autoCreateExpense.value);
    }
    if (isScheduled.present) {
      map['is_scheduled'] = Variable<bool>(isScheduled.value);
    }
    if (externalLinkId.present) {
      map['external_link_id'] = Variable<String>(externalLinkId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayablesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('paidDate: $paidDate, ')
          ..write('linkedExpenseUuid: $linkedExpenseUuid, ')
          ..write('linkedIncomeUuid: $linkedIncomeUuid, ')
          ..write('autoCreateExpense: $autoCreateExpense, ')
          ..write('isScheduled: $isScheduled, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceUuidMeta =
      const VerificationMeta('referenceUuid');
  @override
  late final GeneratedColumn<String> referenceUuid = GeneratedColumn<String>(
      'reference_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reminderDateMeta =
      const VerificationMeta('reminderDate');
  @override
  late final GeneratedColumn<DateTime> reminderDate = GeneratedColumn<DateTime>(
      'reminder_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isTriggeredMeta =
      const VerificationMeta('isTriggered');
  @override
  late final GeneratedColumn<bool> isTriggered = GeneratedColumn<bool>(
      'is_triggered', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_triggered" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        type,
        referenceUuid,
        reminderDate,
        isTriggered,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('reference_uuid')) {
      context.handle(
          _referenceUuidMeta,
          referenceUuid.isAcceptableOrUnknown(
              data['reference_uuid']!, _referenceUuidMeta));
    } else if (isInserting) {
      context.missing(_referenceUuidMeta);
    }
    if (data.containsKey('reminder_date')) {
      context.handle(
          _reminderDateMeta,
          reminderDate.isAcceptableOrUnknown(
              data['reminder_date']!, _reminderDateMeta));
    } else if (isInserting) {
      context.missing(_reminderDateMeta);
    }
    if (data.containsKey('is_triggered')) {
      context.handle(
          _isTriggeredMeta,
          isTriggered.isAcceptableOrUnknown(
              data['is_triggered']!, _isTriggeredMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      referenceUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_uuid'])!,
      reminderDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}reminder_date'])!,
      isTriggered: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_triggered'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String uuid;
  final String type;
  final String referenceUuid;
  final DateTime reminderDate;
  final bool isTriggered;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Reminder(
      {required this.uuid,
      required this.type,
      required this.referenceUuid,
      required this.reminderDate,
      required this.isTriggered,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['type'] = Variable<String>(type);
    map['reference_uuid'] = Variable<String>(referenceUuid);
    map['reminder_date'] = Variable<DateTime>(reminderDate);
    map['is_triggered'] = Variable<bool>(isTriggered);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      uuid: Value(uuid),
      type: Value(type),
      referenceUuid: Value(referenceUuid),
      reminderDate: Value(reminderDate),
      isTriggered: Value(isTriggered),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      uuid: serializer.fromJson<String>(json['uuid']),
      type: serializer.fromJson<String>(json['type']),
      referenceUuid: serializer.fromJson<String>(json['referenceUuid']),
      reminderDate: serializer.fromJson<DateTime>(json['reminderDate']),
      isTriggered: serializer.fromJson<bool>(json['isTriggered']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'type': serializer.toJson<String>(type),
      'referenceUuid': serializer.toJson<String>(referenceUuid),
      'reminderDate': serializer.toJson<DateTime>(reminderDate),
      'isTriggered': serializer.toJson<bool>(isTriggered),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Reminder copyWith(
          {String? uuid,
          String? type,
          String? referenceUuid,
          DateTime? reminderDate,
          bool? isTriggered,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Reminder(
        uuid: uuid ?? this.uuid,
        type: type ?? this.type,
        referenceUuid: referenceUuid ?? this.referenceUuid,
        reminderDate: reminderDate ?? this.reminderDate,
        isTriggered: isTriggered ?? this.isTriggered,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      type: data.type.present ? data.type.value : this.type,
      referenceUuid: data.referenceUuid.present
          ? data.referenceUuid.value
          : this.referenceUuid,
      reminderDate: data.reminderDate.present
          ? data.reminderDate.value
          : this.reminderDate,
      isTriggered:
          data.isTriggered.present ? data.isTriggered.value : this.isTriggered,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('referenceUuid: $referenceUuid, ')
          ..write('reminderDate: $reminderDate, ')
          ..write('isTriggered: $isTriggered, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, type, referenceUuid, reminderDate,
      isTriggered, createdAt, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.uuid == this.uuid &&
          other.type == this.type &&
          other.referenceUuid == this.referenceUuid &&
          other.reminderDate == this.reminderDate &&
          other.isTriggered == this.isTriggered &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> uuid;
  final Value<String> type;
  final Value<String> referenceUuid;
  final Value<DateTime> reminderDate;
  final Value<bool> isTriggered;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const RemindersCompanion({
    this.uuid = const Value.absent(),
    this.type = const Value.absent(),
    this.referenceUuid = const Value.absent(),
    this.reminderDate = const Value.absent(),
    this.isTriggered = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String uuid,
    required String type,
    required String referenceUuid,
    required DateTime reminderDate,
    this.isTriggered = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        type = Value(type),
        referenceUuid = Value(referenceUuid),
        reminderDate = Value(reminderDate);
  static Insertable<Reminder> custom({
    Expression<String>? uuid,
    Expression<String>? type,
    Expression<String>? referenceUuid,
    Expression<DateTime>? reminderDate,
    Expression<bool>? isTriggered,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (type != null) 'type': type,
      if (referenceUuid != null) 'reference_uuid': referenceUuid,
      if (reminderDate != null) 'reminder_date': reminderDate,
      if (isTriggered != null) 'is_triggered': isTriggered,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? type,
      Value<String>? referenceUuid,
      Value<DateTime>? reminderDate,
      Value<bool>? isTriggered,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return RemindersCompanion(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      referenceUuid: referenceUuid ?? this.referenceUuid,
      reminderDate: reminderDate ?? this.reminderDate,
      isTriggered: isTriggered ?? this.isTriggered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (referenceUuid.present) {
      map['reference_uuid'] = Variable<String>(referenceUuid.value);
    }
    if (reminderDate.present) {
      map['reminder_date'] = Variable<DateTime>(reminderDate.value);
    }
    if (isTriggered.present) {
      map['is_triggered'] = Variable<bool>(isTriggered.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('type: $type, ')
          ..write('referenceUuid: $referenceUuid, ')
          ..write('reminderDate: $reminderDate, ')
          ..write('isTriggered: $isTriggered, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WhatsAppQueueTable extends WhatsAppQueue
    with TableInfo<$WhatsAppQueueTable, WhatsAppQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WhatsAppQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deepLinkMeta =
      const VerificationMeta('deepLink');
  @override
  late final GeneratedColumn<String> deepLink = GeneratedColumn<String>(
      'deep_link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, contactUuid, message, deepLink, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'whats_app_queue';
  @override
  VerificationContext validateIntegrity(Insertable<WhatsAppQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    } else if (isInserting) {
      context.missing(_contactUuidMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('deep_link')) {
      context.handle(_deepLinkMeta,
          deepLink.isAcceptableOrUnknown(data['deep_link']!, _deepLinkMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WhatsAppQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WhatsAppQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      deepLink: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deep_link']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WhatsAppQueueTable createAlias(String alias) {
    return $WhatsAppQueueTable(attachedDatabase, alias);
  }
}

class WhatsAppQueueData extends DataClass
    implements Insertable<WhatsAppQueueData> {
  final int id;
  final String contactUuid;
  final String message;
  final String? deepLink;
  final String status;
  final DateTime createdAt;
  const WhatsAppQueueData(
      {required this.id,
      required this.contactUuid,
      required this.message,
      this.deepLink,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_uuid'] = Variable<String>(contactUuid);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || deepLink != null) {
      map['deep_link'] = Variable<String>(deepLink);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WhatsAppQueueCompanion toCompanion(bool nullToAbsent) {
    return WhatsAppQueueCompanion(
      id: Value(id),
      contactUuid: Value(contactUuid),
      message: Value(message),
      deepLink: deepLink == null && nullToAbsent
          ? const Value.absent()
          : Value(deepLink),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory WhatsAppQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WhatsAppQueueData(
      id: serializer.fromJson<int>(json['id']),
      contactUuid: serializer.fromJson<String>(json['contactUuid']),
      message: serializer.fromJson<String>(json['message']),
      deepLink: serializer.fromJson<String?>(json['deepLink']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactUuid': serializer.toJson<String>(contactUuid),
      'message': serializer.toJson<String>(message),
      'deepLink': serializer.toJson<String?>(deepLink),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WhatsAppQueueData copyWith(
          {int? id,
          String? contactUuid,
          String? message,
          Value<String?> deepLink = const Value.absent(),
          String? status,
          DateTime? createdAt}) =>
      WhatsAppQueueData(
        id: id ?? this.id,
        contactUuid: contactUuid ?? this.contactUuid,
        message: message ?? this.message,
        deepLink: deepLink.present ? deepLink.value : this.deepLink,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  WhatsAppQueueData copyWithCompanion(WhatsAppQueueCompanion data) {
    return WhatsAppQueueData(
      id: data.id.present ? data.id.value : this.id,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      message: data.message.present ? data.message.value : this.message,
      deepLink: data.deepLink.present ? data.deepLink.value : this.deepLink,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WhatsAppQueueData(')
          ..write('id: $id, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('message: $message, ')
          ..write('deepLink: $deepLink, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contactUuid, message, deepLink, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WhatsAppQueueData &&
          other.id == this.id &&
          other.contactUuid == this.contactUuid &&
          other.message == this.message &&
          other.deepLink == this.deepLink &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class WhatsAppQueueCompanion extends UpdateCompanion<WhatsAppQueueData> {
  final Value<int> id;
  final Value<String> contactUuid;
  final Value<String> message;
  final Value<String?> deepLink;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const WhatsAppQueueCompanion({
    this.id = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.message = const Value.absent(),
    this.deepLink = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WhatsAppQueueCompanion.insert({
    this.id = const Value.absent(),
    required String contactUuid,
    required String message,
    this.deepLink = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : contactUuid = Value(contactUuid),
        message = Value(message);
  static Insertable<WhatsAppQueueData> custom({
    Expression<int>? id,
    Expression<String>? contactUuid,
    Expression<String>? message,
    Expression<String>? deepLink,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (message != null) 'message': message,
      if (deepLink != null) 'deep_link': deepLink,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WhatsAppQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? contactUuid,
      Value<String>? message,
      Value<String?>? deepLink,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return WhatsAppQueueCompanion(
      id: id ?? this.id,
      contactUuid: contactUuid ?? this.contactUuid,
      message: message ?? this.message,
      deepLink: deepLink ?? this.deepLink,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (deepLink.present) {
      map['deep_link'] = Variable<String>(deepLink.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WhatsAppQueueCompanion(')
          ..write('id: $id, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('message: $message, ')
          ..write('deepLink: $deepLink, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CategoryUsageStatsTable extends CategoryUsageStats
    with TableInfo<$CategoryUsageStatsTable, CategoryUsageStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryUsageStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryUuidMeta =
      const VerificationMeta('categoryUuid');
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
      'category_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (uuid)'));
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUsedMeta =
      const VerificationMeta('lastUsed');
  @override
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
      'last_used', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, categoryUuid, usageCount, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_usage_stats';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryUsageStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
          _categoryUuidMeta,
          categoryUuid.isAcceptableOrUnknown(
              data['category_uuid']!, _categoryUuidMeta));
    } else if (isInserting) {
      context.missing(_categoryUuidMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('last_used')) {
      context.handle(_lastUsedMeta,
          lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryUsageStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryUsageStat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_uuid'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used']),
    );
  }

  @override
  $CategoryUsageStatsTable createAlias(String alias) {
    return $CategoryUsageStatsTable(attachedDatabase, alias);
  }
}

class CategoryUsageStat extends DataClass
    implements Insertable<CategoryUsageStat> {
  final int id;
  final String categoryUuid;
  final int usageCount;
  final DateTime? lastUsed;
  const CategoryUsageStat(
      {required this.id,
      required this.categoryUuid,
      required this.usageCount,
      this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_uuid'] = Variable<String>(categoryUuid);
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || lastUsed != null) {
      map['last_used'] = Variable<DateTime>(lastUsed);
    }
    return map;
  }

  CategoryUsageStatsCompanion toCompanion(bool nullToAbsent) {
    return CategoryUsageStatsCompanion(
      id: Value(id),
      categoryUuid: Value(categoryUuid),
      usageCount: Value(usageCount),
      lastUsed: lastUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsed),
    );
  }

  factory CategoryUsageStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryUsageStat(
      id: serializer.fromJson<int>(json['id']),
      categoryUuid: serializer.fromJson<String>(json['categoryUuid']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryUuid': serializer.toJson<String>(categoryUuid),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
    };
  }

  CategoryUsageStat copyWith(
          {int? id,
          String? categoryUuid,
          int? usageCount,
          Value<DateTime?> lastUsed = const Value.absent()}) =>
      CategoryUsageStat(
        id: id ?? this.id,
        categoryUuid: categoryUuid ?? this.categoryUuid,
        usageCount: usageCount ?? this.usageCount,
        lastUsed: lastUsed.present ? lastUsed.value : this.lastUsed,
      );
  CategoryUsageStat copyWithCompanion(CategoryUsageStatsCompanion data) {
    return CategoryUsageStat(
      id: data.id.present ? data.id.value : this.id,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryUsageStat(')
          ..write('id: $id, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryUuid, usageCount, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryUsageStat &&
          other.id == this.id &&
          other.categoryUuid == this.categoryUuid &&
          other.usageCount == this.usageCount &&
          other.lastUsed == this.lastUsed);
}

class CategoryUsageStatsCompanion extends UpdateCompanion<CategoryUsageStat> {
  final Value<int> id;
  final Value<String> categoryUuid;
  final Value<int> usageCount;
  final Value<DateTime?> lastUsed;
  const CategoryUsageStatsCompanion({
    this.id = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  CategoryUsageStatsCompanion.insert({
    this.id = const Value.absent(),
    required String categoryUuid,
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  }) : categoryUuid = Value(categoryUuid);
  static Insertable<CategoryUsageStat> custom({
    Expression<int>? id,
    Expression<String>? categoryUuid,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  CategoryUsageStatsCompanion copyWith(
      {Value<int>? id,
      Value<String>? categoryUuid,
      Value<int>? usageCount,
      Value<DateTime?>? lastUsed}) {
    return CategoryUsageStatsCompanion(
      id: id ?? this.id,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryUsageStatsCompanion(')
          ..write('id: $id, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }
}

class $ContactUsageStatsTable extends ContactUsageStats
    with TableInfo<$ContactUsageStatsTable, ContactUsageStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactUsageStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUsedMeta =
      const VerificationMeta('lastUsed');
  @override
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
      'last_used', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, contactUuid, usageCount, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_usage_stats';
  @override
  VerificationContext validateIntegrity(Insertable<ContactUsageStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    } else if (isInserting) {
      context.missing(_contactUuidMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('last_used')) {
      context.handle(_lastUsedMeta,
          lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactUsageStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactUsageStat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used']),
    );
  }

  @override
  $ContactUsageStatsTable createAlias(String alias) {
    return $ContactUsageStatsTable(attachedDatabase, alias);
  }
}

class ContactUsageStat extends DataClass
    implements Insertable<ContactUsageStat> {
  final int id;
  final String contactUuid;
  final int usageCount;
  final DateTime? lastUsed;
  const ContactUsageStat(
      {required this.id,
      required this.contactUuid,
      required this.usageCount,
      this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_uuid'] = Variable<String>(contactUuid);
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || lastUsed != null) {
      map['last_used'] = Variable<DateTime>(lastUsed);
    }
    return map;
  }

  ContactUsageStatsCompanion toCompanion(bool nullToAbsent) {
    return ContactUsageStatsCompanion(
      id: Value(id),
      contactUuid: Value(contactUuid),
      usageCount: Value(usageCount),
      lastUsed: lastUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsed),
    );
  }

  factory ContactUsageStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactUsageStat(
      id: serializer.fromJson<int>(json['id']),
      contactUuid: serializer.fromJson<String>(json['contactUuid']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactUuid': serializer.toJson<String>(contactUuid),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
    };
  }

  ContactUsageStat copyWith(
          {int? id,
          String? contactUuid,
          int? usageCount,
          Value<DateTime?> lastUsed = const Value.absent()}) =>
      ContactUsageStat(
        id: id ?? this.id,
        contactUuid: contactUuid ?? this.contactUuid,
        usageCount: usageCount ?? this.usageCount,
        lastUsed: lastUsed.present ? lastUsed.value : this.lastUsed,
      );
  ContactUsageStat copyWithCompanion(ContactUsageStatsCompanion data) {
    return ContactUsageStat(
      id: data.id.present ? data.id.value : this.id,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactUsageStat(')
          ..write('id: $id, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactUuid, usageCount, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactUsageStat &&
          other.id == this.id &&
          other.contactUuid == this.contactUuid &&
          other.usageCount == this.usageCount &&
          other.lastUsed == this.lastUsed);
}

class ContactUsageStatsCompanion extends UpdateCompanion<ContactUsageStat> {
  final Value<int> id;
  final Value<String> contactUuid;
  final Value<int> usageCount;
  final Value<DateTime?> lastUsed;
  const ContactUsageStatsCompanion({
    this.id = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  ContactUsageStatsCompanion.insert({
    this.id = const Value.absent(),
    required String contactUuid,
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  }) : contactUuid = Value(contactUuid);
  static Insertable<ContactUsageStat> custom({
    Expression<int>? id,
    Expression<String>? contactUuid,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  ContactUsageStatsCompanion copyWith(
      {Value<int>? id,
      Value<String>? contactUuid,
      Value<int>? usageCount,
      Value<DateTime?>? lastUsed}) {
    return ContactUsageStatsCompanion(
      id: id ?? this.id,
      contactUuid: contactUuid ?? this.contactUuid,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactUsageStatsCompanion(')
          ..write('id: $id, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(Insertable<UserPreference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final int id;
  final String key;
  final String value;
  final DateTime updatedAt;
  const UserPreference(
      {required this.id,
      required this.key,
      required this.value,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPreference copyWith(
          {int? id, String? key, String? value, DateTime? updatedAt}) =>
      UserPreference(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserPreferencesCompanion copyWith(
      {Value<int>? id,
      Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt}) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncLogTable extends SyncLog with TableInfo<$SyncLogTable, SyncLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _lastBackupMeta =
      const VerificationMeta('lastBackup');
  @override
  late final GeneratedColumn<DateTime> lastBackup = GeneratedColumn<DateTime>(
      'last_backup', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastRestoreMeta =
      const VerificationMeta('lastRestore');
  @override
  late final GeneratedColumn<DateTime> lastRestore = GeneratedColumn<DateTime>(
      'last_restore', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _driveFileIdMeta =
      const VerificationMeta('driveFileId');
  @override
  late final GeneratedColumn<String> driveFileId = GeneratedColumn<String>(
      'drive_file_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, lastBackup, lastRestore, driveFileId, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_log';
  @override
  VerificationContext validateIntegrity(Insertable<SyncLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_backup')) {
      context.handle(
          _lastBackupMeta,
          lastBackup.isAcceptableOrUnknown(
              data['last_backup']!, _lastBackupMeta));
    }
    if (data.containsKey('last_restore')) {
      context.handle(
          _lastRestoreMeta,
          lastRestore.isAcceptableOrUnknown(
              data['last_restore']!, _lastRestoreMeta));
    }
    if (data.containsKey('drive_file_id')) {
      context.handle(
          _driveFileIdMeta,
          driveFileId.isAcceptableOrUnknown(
              data['drive_file_id']!, _driveFileIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lastBackup: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_backup']),
      lastRestore: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_restore']),
      driveFileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}drive_file_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncLogTable createAlias(String alias) {
    return $SyncLogTable(attachedDatabase, alias);
  }
}

class SyncLogData extends DataClass implements Insertable<SyncLogData> {
  final int id;
  final DateTime? lastBackup;
  final DateTime? lastRestore;
  final String? driveFileId;
  final String? status;
  final DateTime createdAt;
  const SyncLogData(
      {required this.id,
      this.lastBackup,
      this.lastRestore,
      this.driveFileId,
      this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastBackup != null) {
      map['last_backup'] = Variable<DateTime>(lastBackup);
    }
    if (!nullToAbsent || lastRestore != null) {
      map['last_restore'] = Variable<DateTime>(lastRestore);
    }
    if (!nullToAbsent || driveFileId != null) {
      map['drive_file_id'] = Variable<String>(driveFileId);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncLogCompanion toCompanion(bool nullToAbsent) {
    return SyncLogCompanion(
      id: Value(id),
      lastBackup: lastBackup == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackup),
      lastRestore: lastRestore == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRestore),
      driveFileId: driveFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(driveFileId),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory SyncLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLogData(
      id: serializer.fromJson<int>(json['id']),
      lastBackup: serializer.fromJson<DateTime?>(json['lastBackup']),
      lastRestore: serializer.fromJson<DateTime?>(json['lastRestore']),
      driveFileId: serializer.fromJson<String?>(json['driveFileId']),
      status: serializer.fromJson<String?>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastBackup': serializer.toJson<DateTime?>(lastBackup),
      'lastRestore': serializer.toJson<DateTime?>(lastRestore),
      'driveFileId': serializer.toJson<String?>(driveFileId),
      'status': serializer.toJson<String?>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncLogData copyWith(
          {int? id,
          Value<DateTime?> lastBackup = const Value.absent(),
          Value<DateTime?> lastRestore = const Value.absent(),
          Value<String?> driveFileId = const Value.absent(),
          Value<String?> status = const Value.absent(),
          DateTime? createdAt}) =>
      SyncLogData(
        id: id ?? this.id,
        lastBackup: lastBackup.present ? lastBackup.value : this.lastBackup,
        lastRestore: lastRestore.present ? lastRestore.value : this.lastRestore,
        driveFileId: driveFileId.present ? driveFileId.value : this.driveFileId,
        status: status.present ? status.value : this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncLogData copyWithCompanion(SyncLogCompanion data) {
    return SyncLogData(
      id: data.id.present ? data.id.value : this.id,
      lastBackup:
          data.lastBackup.present ? data.lastBackup.value : this.lastBackup,
      lastRestore:
          data.lastRestore.present ? data.lastRestore.value : this.lastRestore,
      driveFileId:
          data.driveFileId.present ? data.driveFileId.value : this.driveFileId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogData(')
          ..write('id: $id, ')
          ..write('lastBackup: $lastBackup, ')
          ..write('lastRestore: $lastRestore, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lastBackup, lastRestore, driveFileId, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogData &&
          other.id == this.id &&
          other.lastBackup == this.lastBackup &&
          other.lastRestore == this.lastRestore &&
          other.driveFileId == this.driveFileId &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class SyncLogCompanion extends UpdateCompanion<SyncLogData> {
  final Value<int> id;
  final Value<DateTime?> lastBackup;
  final Value<DateTime?> lastRestore;
  final Value<String?> driveFileId;
  final Value<String?> status;
  final Value<DateTime> createdAt;
  const SyncLogCompanion({
    this.id = const Value.absent(),
    this.lastBackup = const Value.absent(),
    this.lastRestore = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncLogCompanion.insert({
    this.id = const Value.absent(),
    this.lastBackup = const Value.absent(),
    this.lastRestore = const Value.absent(),
    this.driveFileId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<SyncLogData> custom({
    Expression<int>? id,
    Expression<DateTime>? lastBackup,
    Expression<DateTime>? lastRestore,
    Expression<String>? driveFileId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastBackup != null) 'last_backup': lastBackup,
      if (lastRestore != null) 'last_restore': lastRestore,
      if (driveFileId != null) 'drive_file_id': driveFileId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncLogCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? lastBackup,
      Value<DateTime?>? lastRestore,
      Value<String?>? driveFileId,
      Value<String?>? status,
      Value<DateTime>? createdAt}) {
    return SyncLogCompanion(
      id: id ?? this.id,
      lastBackup: lastBackup ?? this.lastBackup,
      lastRestore: lastRestore ?? this.lastRestore,
      driveFileId: driveFileId ?? this.driveFileId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastBackup.present) {
      map['last_backup'] = Variable<DateTime>(lastBackup.value);
    }
    if (lastRestore.present) {
      map['last_restore'] = Variable<DateTime>(lastRestore.value);
    }
    if (driveFileId.present) {
      map['drive_file_id'] = Variable<String>(driveFileId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogCompanion(')
          ..write('id: $id, ')
          ..write('lastBackup: $lastBackup, ')
          ..write('lastRestore: $lastRestore, ')
          ..write('driveFileId: $driveFileId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppCurrenciesTable extends AppCurrencies
    with TableInfo<$AppCurrenciesTable, AppCurrency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppCurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _decimalPlacesMeta =
      const VerificationMeta('decimalPlaces');
  @override
  late final GeneratedColumn<int> decimalPlaces = GeneratedColumn<int>(
      'decimal_places', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        symbol,
        code,
        decimalPlaces,
        isDefault,
        isActive,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_currencies';
  @override
  VerificationContext validateIntegrity(Insertable<AppCurrency> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('decimal_places')) {
      context.handle(
          _decimalPlacesMeta,
          decimalPlaces.isAcceptableOrUnknown(
              data['decimal_places']!, _decimalPlacesMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  AppCurrency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppCurrency(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      decimalPlaces: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decimal_places'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $AppCurrenciesTable createAlias(String alias) {
    return $AppCurrenciesTable(attachedDatabase, alias);
  }
}

class AppCurrency extends DataClass implements Insertable<AppCurrency> {
  final String uuid;
  final String name;
  final String symbol;
  final String code;
  final int decimalPlaces;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const AppCurrency(
      {required this.uuid,
      required this.name,
      required this.symbol,
      required this.code,
      required this.decimalPlaces,
      required this.isDefault,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['code'] = Variable<String>(code);
    map['decimal_places'] = Variable<int>(decimalPlaces);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  AppCurrenciesCompanion toCompanion(bool nullToAbsent) {
    return AppCurrenciesCompanion(
      uuid: Value(uuid),
      name: Value(name),
      symbol: Value(symbol),
      code: Value(code),
      decimalPlaces: Value(decimalPlaces),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory AppCurrency.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppCurrency(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      code: serializer.fromJson<String>(json['code']),
      decimalPlaces: serializer.fromJson<int>(json['decimalPlaces']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'code': serializer.toJson<String>(code),
      'decimalPlaces': serializer.toJson<int>(decimalPlaces),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  AppCurrency copyWith(
          {String? uuid,
          String? name,
          String? symbol,
          String? code,
          int? decimalPlaces,
          bool? isDefault,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      AppCurrency(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        symbol: symbol ?? this.symbol,
        code: code ?? this.code,
        decimalPlaces: decimalPlaces ?? this.decimalPlaces,
        isDefault: isDefault ?? this.isDefault,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  AppCurrency copyWithCompanion(AppCurrenciesCompanion data) {
    return AppCurrency(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      code: data.code.present ? data.code.value : this.code,
      decimalPlaces: data.decimalPlaces.present
          ? data.decimalPlaces.value
          : this.decimalPlaces,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppCurrency(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('code: $code, ')
          ..write('decimalPlaces: $decimalPlaces, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, symbol, code, decimalPlaces,
      isDefault, isActive, createdAt, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppCurrency &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.code == this.code &&
          other.decimalPlaces == this.decimalPlaces &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class AppCurrenciesCompanion extends UpdateCompanion<AppCurrency> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> symbol;
  final Value<String> code;
  final Value<int> decimalPlaces;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const AppCurrenciesCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.code = const Value.absent(),
    this.decimalPlaces = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppCurrenciesCompanion.insert({
    required String uuid,
    required String name,
    required String symbol,
    required String code,
    this.decimalPlaces = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        symbol = Value(symbol),
        code = Value(code);
  static Insertable<AppCurrency> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<String>? code,
    Expression<int>? decimalPlaces,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (code != null) 'code': code,
      if (decimalPlaces != null) 'decimal_places': decimalPlaces,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppCurrenciesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? symbol,
      Value<String>? code,
      Value<int>? decimalPlaces,
      Value<bool>? isDefault,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return AppCurrenciesCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      code: code ?? this.code,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (decimalPlaces.present) {
      map['decimal_places'] = Variable<int>(decimalPlaces.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppCurrenciesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('code: $code, ')
          ..write('decimalPlaces: $decimalPlaces, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionSchedulesTable extends TransactionSchedules
    with TableInfo<$TransactionSchedulesTable, TransactionSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryUuidMeta =
      const VerificationMeta('categoryUuid');
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
      'category_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (uuid)'));
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paidRelationshipMeta =
      const VerificationMeta('paidRelationship');
  @override
  late final GeneratedColumn<String> paidRelationship = GeneratedColumn<String>(
      'paid_relationship', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _scheduleTypeMeta =
      const VerificationMeta('scheduleType');
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
      'schedule_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _selectedDaysOfWeekMeta =
      const VerificationMeta('selectedDaysOfWeek');
  @override
  late final GeneratedColumn<String> selectedDaysOfWeek =
      GeneratedColumn<String>('selected_days_of_week', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _selectedDaysOfMonthMeta =
      const VerificationMeta('selectedDaysOfMonth');
  @override
  late final GeneratedColumn<String> selectedDaysOfMonth =
      GeneratedColumn<String>('selected_days_of_month', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateOffsetMeta =
      const VerificationMeta('dueDateOffset');
  @override
  late final GeneratedColumn<int> dueDateOffset = GeneratedColumn<int>(
      'due_date_offset', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isPausedMeta =
      const VerificationMeta('isPaused');
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
      'is_paused', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paused" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastGeneratedDateMeta =
      const VerificationMeta('lastGeneratedDate');
  @override
  late final GeneratedColumn<DateTime> lastGeneratedDate =
      GeneratedColumn<DateTime>('last_generated_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isNotSyncedMeta =
      const VerificationMeta('isNotSynced');
  @override
  late final GeneratedColumn<bool> isNotSynced = GeneratedColumn<bool>(
      'is_not_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_not_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        amount,
        type,
        categoryUuid,
        contactUuid,
        description,
        paidRelationship,
        dueDate,
        scheduleType,
        selectedDaysOfWeek,
        selectedDaysOfMonth,
        dueDateOffset,
        isPaused,
        lastGeneratedDate,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_schedules';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
          _categoryUuidMeta,
          categoryUuid.isAcceptableOrUnknown(
              data['category_uuid']!, _categoryUuidMeta));
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('paid_relationship')) {
      context.handle(
          _paidRelationshipMeta,
          paidRelationship.isAcceptableOrUnknown(
              data['paid_relationship']!, _paidRelationshipMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
          _scheduleTypeMeta,
          scheduleType.isAcceptableOrUnknown(
              data['schedule_type']!, _scheduleTypeMeta));
    } else if (isInserting) {
      context.missing(_scheduleTypeMeta);
    }
    if (data.containsKey('selected_days_of_week')) {
      context.handle(
          _selectedDaysOfWeekMeta,
          selectedDaysOfWeek.isAcceptableOrUnknown(
              data['selected_days_of_week']!, _selectedDaysOfWeekMeta));
    }
    if (data.containsKey('selected_days_of_month')) {
      context.handle(
          _selectedDaysOfMonthMeta,
          selectedDaysOfMonth.isAcceptableOrUnknown(
              data['selected_days_of_month']!, _selectedDaysOfMonthMeta));
    }
    if (data.containsKey('due_date_offset')) {
      context.handle(
          _dueDateOffsetMeta,
          dueDateOffset.isAcceptableOrUnknown(
              data['due_date_offset']!, _dueDateOffsetMeta));
    }
    if (data.containsKey('is_paused')) {
      context.handle(_isPausedMeta,
          isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta));
    }
    if (data.containsKey('last_generated_date')) {
      context.handle(
          _lastGeneratedDateMeta,
          lastGeneratedDate.isAcceptableOrUnknown(
              data['last_generated_date']!, _lastGeneratedDateMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('is_not_synced')) {
      context.handle(
          _isNotSyncedMeta,
          isNotSynced.isAcceptableOrUnknown(
              data['is_not_synced']!, _isNotSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  TransactionSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionSchedule(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      categoryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_uuid']),
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      paidRelationship: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}paid_relationship']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      scheduleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schedule_type'])!,
      selectedDaysOfWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}selected_days_of_week']),
      selectedDaysOfMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_days_of_month']),
      dueDateOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_date_offset']),
      isPaused: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paused'])!,
      lastGeneratedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_generated_date']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $TransactionSchedulesTable createAlias(String alias) {
    return $TransactionSchedulesTable(attachedDatabase, alias);
  }
}

class TransactionSchedule extends DataClass
    implements Insertable<TransactionSchedule> {
  final String uuid;
  final double amount;
  final String type;
  final String? categoryUuid;
  final String? contactUuid;
  final String? description;
  final String? paidRelationship;
  final DateTime? dueDate;
  final String scheduleType;
  final String? selectedDaysOfWeek;
  final String? selectedDaysOfMonth;
  final int? dueDateOffset;
  final bool isPaused;
  final DateTime? lastGeneratedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const TransactionSchedule(
      {required this.uuid,
      required this.amount,
      required this.type,
      this.categoryUuid,
      this.contactUuid,
      this.description,
      this.paidRelationship,
      this.dueDate,
      required this.scheduleType,
      this.selectedDaysOfWeek,
      this.selectedDaysOfMonth,
      this.dueDateOffset,
      required this.isPaused,
      this.lastGeneratedDate,
      this.startDate,
      this.endDate,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryUuid != null) {
      map['category_uuid'] = Variable<String>(categoryUuid);
    }
    if (!nullToAbsent || contactUuid != null) {
      map['contact_uuid'] = Variable<String>(contactUuid);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || paidRelationship != null) {
      map['paid_relationship'] = Variable<String>(paidRelationship);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['schedule_type'] = Variable<String>(scheduleType);
    if (!nullToAbsent || selectedDaysOfWeek != null) {
      map['selected_days_of_week'] = Variable<String>(selectedDaysOfWeek);
    }
    if (!nullToAbsent || selectedDaysOfMonth != null) {
      map['selected_days_of_month'] = Variable<String>(selectedDaysOfMonth);
    }
    if (!nullToAbsent || dueDateOffset != null) {
      map['due_date_offset'] = Variable<int>(dueDateOffset);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    if (!nullToAbsent || lastGeneratedDate != null) {
      map['last_generated_date'] = Variable<DateTime>(lastGeneratedDate);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  TransactionSchedulesCompanion toCompanion(bool nullToAbsent) {
    return TransactionSchedulesCompanion(
      uuid: Value(uuid),
      amount: Value(amount),
      type: Value(type),
      categoryUuid: categoryUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryUuid),
      contactUuid: contactUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(contactUuid),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      paidRelationship: paidRelationship == null && nullToAbsent
          ? const Value.absent()
          : Value(paidRelationship),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      scheduleType: Value(scheduleType),
      selectedDaysOfWeek: selectedDaysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedDaysOfWeek),
      selectedDaysOfMonth: selectedDaysOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedDaysOfMonth),
      dueDateOffset: dueDateOffset == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDateOffset),
      isPaused: Value(isPaused),
      lastGeneratedDate: lastGeneratedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedDate),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory TransactionSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionSchedule(
      uuid: serializer.fromJson<String>(json['uuid']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      categoryUuid: serializer.fromJson<String?>(json['categoryUuid']),
      contactUuid: serializer.fromJson<String?>(json['contactUuid']),
      description: serializer.fromJson<String?>(json['description']),
      paidRelationship: serializer.fromJson<String?>(json['paidRelationship']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      selectedDaysOfWeek:
          serializer.fromJson<String?>(json['selectedDaysOfWeek']),
      selectedDaysOfMonth:
          serializer.fromJson<String?>(json['selectedDaysOfMonth']),
      dueDateOffset: serializer.fromJson<int?>(json['dueDateOffset']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      lastGeneratedDate:
          serializer.fromJson<DateTime?>(json['lastGeneratedDate']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'categoryUuid': serializer.toJson<String?>(categoryUuid),
      'contactUuid': serializer.toJson<String?>(contactUuid),
      'description': serializer.toJson<String?>(description),
      'paidRelationship': serializer.toJson<String?>(paidRelationship),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'selectedDaysOfWeek': serializer.toJson<String?>(selectedDaysOfWeek),
      'selectedDaysOfMonth': serializer.toJson<String?>(selectedDaysOfMonth),
      'dueDateOffset': serializer.toJson<int?>(dueDateOffset),
      'isPaused': serializer.toJson<bool>(isPaused),
      'lastGeneratedDate': serializer.toJson<DateTime?>(lastGeneratedDate),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  TransactionSchedule copyWith(
          {String? uuid,
          double? amount,
          String? type,
          Value<String?> categoryUuid = const Value.absent(),
          Value<String?> contactUuid = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> paidRelationship = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          String? scheduleType,
          Value<String?> selectedDaysOfWeek = const Value.absent(),
          Value<String?> selectedDaysOfMonth = const Value.absent(),
          Value<int?> dueDateOffset = const Value.absent(),
          bool? isPaused,
          Value<DateTime?> lastGeneratedDate = const Value.absent(),
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      TransactionSchedule(
        uuid: uuid ?? this.uuid,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryUuid:
            categoryUuid.present ? categoryUuid.value : this.categoryUuid,
        contactUuid: contactUuid.present ? contactUuid.value : this.contactUuid,
        description: description.present ? description.value : this.description,
        paidRelationship: paidRelationship.present
            ? paidRelationship.value
            : this.paidRelationship,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        scheduleType: scheduleType ?? this.scheduleType,
        selectedDaysOfWeek: selectedDaysOfWeek.present
            ? selectedDaysOfWeek.value
            : this.selectedDaysOfWeek,
        selectedDaysOfMonth: selectedDaysOfMonth.present
            ? selectedDaysOfMonth.value
            : this.selectedDaysOfMonth,
        dueDateOffset:
            dueDateOffset.present ? dueDateOffset.value : this.dueDateOffset,
        isPaused: isPaused ?? this.isPaused,
        lastGeneratedDate: lastGeneratedDate.present
            ? lastGeneratedDate.value
            : this.lastGeneratedDate,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  TransactionSchedule copyWithCompanion(TransactionSchedulesCompanion data) {
    return TransactionSchedule(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      description:
          data.description.present ? data.description.value : this.description,
      paidRelationship: data.paidRelationship.present
          ? data.paidRelationship.value
          : this.paidRelationship,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      selectedDaysOfWeek: data.selectedDaysOfWeek.present
          ? data.selectedDaysOfWeek.value
          : this.selectedDaysOfWeek,
      selectedDaysOfMonth: data.selectedDaysOfMonth.present
          ? data.selectedDaysOfMonth.value
          : this.selectedDaysOfMonth,
      dueDateOffset: data.dueDateOffset.present
          ? data.dueDateOffset.value
          : this.dueDateOffset,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      lastGeneratedDate: data.lastGeneratedDate.present
          ? data.lastGeneratedDate.value
          : this.lastGeneratedDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionSchedule(')
          ..write('uuid: $uuid, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('description: $description, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('dueDate: $dueDate, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('selectedDaysOfWeek: $selectedDaysOfWeek, ')
          ..write('selectedDaysOfMonth: $selectedDaysOfMonth, ')
          ..write('dueDateOffset: $dueDateOffset, ')
          ..write('isPaused: $isPaused, ')
          ..write('lastGeneratedDate: $lastGeneratedDate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      amount,
      type,
      categoryUuid,
      contactUuid,
      description,
      paidRelationship,
      dueDate,
      scheduleType,
      selectedDaysOfWeek,
      selectedDaysOfMonth,
      dueDateOffset,
      isPaused,
      lastGeneratedDate,
      startDate,
      endDate,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionSchedule &&
          other.uuid == this.uuid &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.categoryUuid == this.categoryUuid &&
          other.contactUuid == this.contactUuid &&
          other.description == this.description &&
          other.paidRelationship == this.paidRelationship &&
          other.dueDate == this.dueDate &&
          other.scheduleType == this.scheduleType &&
          other.selectedDaysOfWeek == this.selectedDaysOfWeek &&
          other.selectedDaysOfMonth == this.selectedDaysOfMonth &&
          other.dueDateOffset == this.dueDateOffset &&
          other.isPaused == this.isPaused &&
          other.lastGeneratedDate == this.lastGeneratedDate &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class TransactionSchedulesCompanion
    extends UpdateCompanion<TransactionSchedule> {
  final Value<String> uuid;
  final Value<double> amount;
  final Value<String> type;
  final Value<String?> categoryUuid;
  final Value<String?> contactUuid;
  final Value<String?> description;
  final Value<String?> paidRelationship;
  final Value<DateTime?> dueDate;
  final Value<String> scheduleType;
  final Value<String?> selectedDaysOfWeek;
  final Value<String?> selectedDaysOfMonth;
  final Value<int?> dueDateOffset;
  final Value<bool> isPaused;
  final Value<DateTime?> lastGeneratedDate;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const TransactionSchedulesCompanion({
    this.uuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.description = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.selectedDaysOfWeek = const Value.absent(),
    this.selectedDaysOfMonth = const Value.absent(),
    this.dueDateOffset = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.lastGeneratedDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionSchedulesCompanion.insert({
    required String uuid,
    required double amount,
    required String type,
    this.categoryUuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.description = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.dueDate = const Value.absent(),
    required String scheduleType,
    this.selectedDaysOfWeek = const Value.absent(),
    this.selectedDaysOfMonth = const Value.absent(),
    this.dueDateOffset = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.lastGeneratedDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        amount = Value(amount),
        type = Value(type),
        scheduleType = Value(scheduleType);
  static Insertable<TransactionSchedule> custom({
    Expression<String>? uuid,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? categoryUuid,
    Expression<String>? contactUuid,
    Expression<String>? description,
    Expression<String>? paidRelationship,
    Expression<DateTime>? dueDate,
    Expression<String>? scheduleType,
    Expression<String>? selectedDaysOfWeek,
    Expression<String>? selectedDaysOfMonth,
    Expression<int>? dueDateOffset,
    Expression<bool>? isPaused,
    Expression<DateTime>? lastGeneratedDate,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (description != null) 'description': description,
      if (paidRelationship != null) 'paid_relationship': paidRelationship,
      if (dueDate != null) 'due_date': dueDate,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (selectedDaysOfWeek != null)
        'selected_days_of_week': selectedDaysOfWeek,
      if (selectedDaysOfMonth != null)
        'selected_days_of_month': selectedDaysOfMonth,
      if (dueDateOffset != null) 'due_date_offset': dueDateOffset,
      if (isPaused != null) 'is_paused': isPaused,
      if (lastGeneratedDate != null) 'last_generated_date': lastGeneratedDate,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionSchedulesCompanion copyWith(
      {Value<String>? uuid,
      Value<double>? amount,
      Value<String>? type,
      Value<String?>? categoryUuid,
      Value<String?>? contactUuid,
      Value<String?>? description,
      Value<String?>? paidRelationship,
      Value<DateTime?>? dueDate,
      Value<String>? scheduleType,
      Value<String?>? selectedDaysOfWeek,
      Value<String?>? selectedDaysOfMonth,
      Value<int?>? dueDateOffset,
      Value<bool>? isPaused,
      Value<DateTime?>? lastGeneratedDate,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return TransactionSchedulesCompanion(
      uuid: uuid ?? this.uuid,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      contactUuid: contactUuid ?? this.contactUuid,
      description: description ?? this.description,
      paidRelationship: paidRelationship ?? this.paidRelationship,
      dueDate: dueDate ?? this.dueDate,
      scheduleType: scheduleType ?? this.scheduleType,
      selectedDaysOfWeek: selectedDaysOfWeek ?? this.selectedDaysOfWeek,
      selectedDaysOfMonth: selectedDaysOfMonth ?? this.selectedDaysOfMonth,
      dueDateOffset: dueDateOffset ?? this.dueDateOffset,
      isPaused: isPaused ?? this.isPaused,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (paidRelationship.present) {
      map['paid_relationship'] = Variable<String>(paidRelationship.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (selectedDaysOfWeek.present) {
      map['selected_days_of_week'] = Variable<String>(selectedDaysOfWeek.value);
    }
    if (selectedDaysOfMonth.present) {
      map['selected_days_of_month'] =
          Variable<String>(selectedDaysOfMonth.value);
    }
    if (dueDateOffset.present) {
      map['due_date_offset'] = Variable<int>(dueDateOffset.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (lastGeneratedDate.present) {
      map['last_generated_date'] = Variable<DateTime>(lastGeneratedDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionSchedulesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('description: $description, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('dueDate: $dueDate, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('selectedDaysOfWeek: $selectedDaysOfWeek, ')
          ..write('selectedDaysOfMonth: $selectedDaysOfMonth, ')
          ..write('dueDateOffset: $dueDateOffset, ')
          ..write('isPaused: $isPaused, ')
          ..write('lastGeneratedDate: $lastGeneratedDate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cloudVersionMeta =
      const VerificationMeta('cloudVersion');
  @override
  late final GeneratedColumn<int> cloudVersion = GeneratedColumn<int>(
      'cloud_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Idle'));
  static const VerificationMeta _syncStartedAtMeta =
      const VerificationMeta('syncStartedAt');
  @override
  late final GeneratedColumn<DateTime> syncStartedAt =
      GeneratedColumn<DateTime>('sync_started_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [deviceId, version, cloudVersion, lastSyncAt, syncStatus, syncStartedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('cloud_version')) {
      context.handle(
          _cloudVersionMeta,
          cloudVersion.isAcceptableOrUnknown(
              data['cloud_version']!, _cloudVersionMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('sync_started_at')) {
      context.handle(
          _syncStartedAtMeta,
          syncStartedAt.isAcceptableOrUnknown(
              data['sync_started_at']!, _syncStartedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      cloudVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cloud_version'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      syncStartedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}sync_started_at']),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String deviceId;
  final int version;
  final int cloudVersion;
  final DateTime? lastSyncAt;
  final String syncStatus;
  final DateTime? syncStartedAt;
  const SyncMetadataData(
      {required this.deviceId,
      required this.version,
      required this.cloudVersion,
      this.lastSyncAt,
      required this.syncStatus,
      this.syncStartedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['cloud_version'] = Variable<int>(cloudVersion);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncStartedAt != null) {
      map['sync_started_at'] = Variable<DateTime>(syncStartedAt);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      deviceId: Value(deviceId),
      version: Value(version),
      cloudVersion: Value(cloudVersion),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      syncStatus: Value(syncStatus),
      syncStartedAt: syncStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStartedAt),
    );
  }

  factory SyncMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      cloudVersion: serializer.fromJson<int>(json['cloudVersion']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncStartedAt: serializer.fromJson<DateTime?>(json['syncStartedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'cloudVersion': serializer.toJson<int>(cloudVersion),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncStartedAt': serializer.toJson<DateTime?>(syncStartedAt),
    };
  }

  SyncMetadataData copyWith(
          {String? deviceId,
          int? version,
          int? cloudVersion,
          Value<DateTime?> lastSyncAt = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> syncStartedAt = const Value.absent()}) =>
      SyncMetadataData(
        deviceId: deviceId ?? this.deviceId,
        version: version ?? this.version,
        cloudVersion: cloudVersion ?? this.cloudVersion,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        syncStatus: syncStatus ?? this.syncStatus,
        syncStartedAt:
            syncStartedAt.present ? syncStartedAt.value : this.syncStartedAt,
      );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      cloudVersion: data.cloudVersion.present
          ? data.cloudVersion.value
          : this.cloudVersion,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      syncStartedAt: data.syncStartedAt.present
          ? data.syncStartedAt.value
          : this.syncStartedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('cloudVersion: $cloudVersion, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncStartedAt: $syncStartedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      deviceId, version, cloudVersion, lastSyncAt, syncStatus, syncStartedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.cloudVersion == this.cloudVersion &&
          other.lastSyncAt == this.lastSyncAt &&
          other.syncStatus == this.syncStatus &&
          other.syncStartedAt == this.syncStartedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> deviceId;
  final Value<int> version;
  final Value<int> cloudVersion;
  final Value<DateTime?> lastSyncAt;
  final Value<String> syncStatus;
  final Value<DateTime?> syncStartedAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncStartedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String deviceId,
    this.version = const Value.absent(),
    this.cloudVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncStartedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<int>? cloudVersion,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? syncStartedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (cloudVersion != null) 'cloud_version': cloudVersion,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncStartedAt != null) 'sync_started_at': syncStartedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith(
      {Value<String>? deviceId,
      Value<int>? version,
      Value<int>? cloudVersion,
      Value<DateTime?>? lastSyncAt,
      Value<String>? syncStatus,
      Value<DateTime?>? syncStartedAt,
      Value<int>? rowid}) {
    return SyncMetadataCompanion(
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncStartedAt: syncStartedAt ?? this.syncStartedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (cloudVersion.present) {
      map['cloud_version'] = Variable<int>(cloudVersion.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncStartedAt.present) {
      map['sync_started_at'] = Variable<DateTime>(syncStartedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('cloudVersion: $cloudVersion, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncStartedAt: $syncStartedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ReceivablesTable receivables = $ReceivablesTable(this);
  late final $PayablesTable payables = $PayablesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $WhatsAppQueueTable whatsAppQueue = $WhatsAppQueueTable(this);
  late final $CategoryUsageStatsTable categoryUsageStats =
      $CategoryUsageStatsTable(this);
  late final $ContactUsageStatsTable contactUsageStats =
      $ContactUsageStatsTable(this);
  late final $UserPreferencesTable userPreferences =
      $UserPreferencesTable(this);
  late final $SyncLogTable syncLog = $SyncLogTable(this);
  late final $AppCurrenciesTable appCurrencies = $AppCurrenciesTable(this);
  late final $TransactionSchedulesTable transactionSchedules =
      $TransactionSchedulesTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        contacts,
        transactions,
        receivables,
        payables,
        reminders,
        whatsAppQueue,
        categoryUsageStats,
        contactUsageStats,
        userPreferences,
        syncLog,
        appCurrencies,
        transactionSchedules,
        syncMetadata
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String uuid,
  required String name,
  Value<String?> icon,
  Value<String?> color,
  required String type,
  Value<bool> isDefault,
  Value<bool> isDeleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String?> icon,
  Value<String?> color,
  Value<String> type,
  Value<bool> isDefault,
  Value<bool> isDeleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.categories.uuid, db.transactions.categoryUuid));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) =>
            f.categoryUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CategoryUsageStatsTable, List<CategoryUsageStat>>
      _categoryUsageStatsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.categoryUsageStats,
              aliasName: $_aliasNameGenerator(
                  db.categories.uuid, db.categoryUsageStats.categoryUuid));

  $$CategoryUsageStatsTableProcessedTableManager get categoryUsageStatsRefs {
    final manager =
        $$CategoryUsageStatsTableTableManager($_db, $_db.categoryUsageStats)
            .filter((f) =>
                f.categoryUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_categoryUsageStatsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionSchedulesTable,
      List<TransactionSchedule>> _transactionSchedulesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionSchedules,
          aliasName: $_aliasNameGenerator(
              db.categories.uuid, db.transactionSchedules.categoryUuid));

  $$TransactionSchedulesTableProcessedTableManager
      get transactionSchedulesRefs {
    final manager =
        $$TransactionSchedulesTableTableManager($_db, $_db.transactionSchedules)
            .filter((f) =>
                f.categoryUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionSchedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> categoryUsageStatsRefs(
      Expression<bool> Function($$CategoryUsageStatsTableFilterComposer f) f) {
    final $$CategoryUsageStatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.categoryUsageStats,
        getReferencedColumn: (t) => t.categoryUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryUsageStatsTableFilterComposer(
              $db: $db,
              $table: $db.categoryUsageStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionSchedulesRefs(
      Expression<bool> Function($$TransactionSchedulesTableFilterComposer f)
          f) {
    final $$TransactionSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactionSchedules,
        getReferencedColumn: (t) => t.categoryUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.transactionSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> categoryUsageStatsRefs<T extends Object>(
      Expression<T> Function($$CategoryUsageStatsTableAnnotationComposer a) f) {
    final $$CategoryUsageStatsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.categoryUsageStats,
            getReferencedColumn: (t) => t.categoryUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CategoryUsageStatsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.categoryUsageStats,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> transactionSchedulesRefs<T extends Object>(
      Expression<T> Function($$TransactionSchedulesTableAnnotationComposer a)
          f) {
    final $$TransactionSchedulesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.transactionSchedules,
            getReferencedColumn: (t) => t.categoryUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionSchedulesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionSchedules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool categoryUsageStatsRefs,
        bool transactionSchedulesRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            uuid: uuid,
            name: name,
            icon: icon,
            color: color,
            type: type,
            isDefault: isDefault,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            required String type,
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            uuid: uuid,
            name: name,
            icon: icon,
            color: color,
            type: type,
            isDefault: isDefault,
            isDeleted: isDeleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {transactionsRefs = false,
              categoryUsageStatsRefs = false,
              transactionSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (categoryUsageStatsRefs) db.categoryUsageStats,
                if (transactionSchedulesRefs) db.transactionSchedules
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryUuid == item.uuid),
                        typedResults: items),
                  if (categoryUsageStatsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            CategoryUsageStat>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._categoryUsageStatsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .categoryUsageStatsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryUuid == item.uuid),
                        typedResults: items),
                  if (transactionSchedulesRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            TransactionSchedule>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._transactionSchedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .transactionSchedulesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool categoryUsageStatsRefs,
        bool transactionSchedulesRefs})>;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String uuid,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.contacts.uuid, db.transactions.contactUuid));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
            (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReceivablesTable, List<Receivable>>
      _receivablesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.receivables,
              aliasName: $_aliasNameGenerator(
                  db.contacts.uuid, db.receivables.contactUuid));

  $$ReceivablesTableProcessedTableManager get receivablesRefs {
    final manager = $$ReceivablesTableTableManager($_db, $_db.receivables)
        .filter(
            (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_receivablesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PayablesTable, List<Payable>> _payablesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payables,
          aliasName:
              $_aliasNameGenerator(db.contacts.uuid, db.payables.contactUuid));

  $$PayablesTableProcessedTableManager get payablesRefs {
    final manager = $$PayablesTableTableManager($_db, $_db.payables).filter(
        (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_payablesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WhatsAppQueueTable, List<WhatsAppQueueData>>
      _whatsAppQueueRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.whatsAppQueue,
              aliasName: $_aliasNameGenerator(
                  db.contacts.uuid, db.whatsAppQueue.contactUuid));

  $$WhatsAppQueueTableProcessedTableManager get whatsAppQueueRefs {
    final manager = $$WhatsAppQueueTableTableManager($_db, $_db.whatsAppQueue)
        .filter(
            (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_whatsAppQueueRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ContactUsageStatsTable, List<ContactUsageStat>>
      _contactUsageStatsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.contactUsageStats,
              aliasName: $_aliasNameGenerator(
                  db.contacts.uuid, db.contactUsageStats.contactUuid));

  $$ContactUsageStatsTableProcessedTableManager get contactUsageStatsRefs {
    final manager = $$ContactUsageStatsTableTableManager(
            $_db, $_db.contactUsageStats)
        .filter(
            (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_contactUsageStatsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionSchedulesTable,
      List<TransactionSchedule>> _transactionSchedulesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionSchedules,
          aliasName: $_aliasNameGenerator(
              db.contacts.uuid, db.transactionSchedules.contactUuid));

  $$TransactionSchedulesTableProcessedTableManager
      get transactionSchedulesRefs {
    final manager = $$TransactionSchedulesTableTableManager(
            $_db, $_db.transactionSchedules)
        .filter(
            (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionSchedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> receivablesRefs(
      Expression<bool> Function($$ReceivablesTableFilterComposer f) f) {
    final $$ReceivablesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.receivables,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReceivablesTableFilterComposer(
              $db: $db,
              $table: $db.receivables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> payablesRefs(
      Expression<bool> Function($$PayablesTableFilterComposer f) f) {
    final $$PayablesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.payables,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayablesTableFilterComposer(
              $db: $db,
              $table: $db.payables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> whatsAppQueueRefs(
      Expression<bool> Function($$WhatsAppQueueTableFilterComposer f) f) {
    final $$WhatsAppQueueTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.whatsAppQueue,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WhatsAppQueueTableFilterComposer(
              $db: $db,
              $table: $db.whatsAppQueue,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> contactUsageStatsRefs(
      Expression<bool> Function($$ContactUsageStatsTableFilterComposer f) f) {
    final $$ContactUsageStatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.contactUsageStats,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactUsageStatsTableFilterComposer(
              $db: $db,
              $table: $db.contactUsageStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionSchedulesRefs(
      Expression<bool> Function($$TransactionSchedulesTableFilterComposer f)
          f) {
    final $$TransactionSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactionSchedules,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.transactionSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> receivablesRefs<T extends Object>(
      Expression<T> Function($$ReceivablesTableAnnotationComposer a) f) {
    final $$ReceivablesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.receivables,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReceivablesTableAnnotationComposer(
              $db: $db,
              $table: $db.receivables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> payablesRefs<T extends Object>(
      Expression<T> Function($$PayablesTableAnnotationComposer a) f) {
    final $$PayablesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.payables,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PayablesTableAnnotationComposer(
              $db: $db,
              $table: $db.payables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> whatsAppQueueRefs<T extends Object>(
      Expression<T> Function($$WhatsAppQueueTableAnnotationComposer a) f) {
    final $$WhatsAppQueueTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.whatsAppQueue,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WhatsAppQueueTableAnnotationComposer(
              $db: $db,
              $table: $db.whatsAppQueue,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> contactUsageStatsRefs<T extends Object>(
      Expression<T> Function($$ContactUsageStatsTableAnnotationComposer a) f) {
    final $$ContactUsageStatsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.contactUsageStats,
            getReferencedColumn: (t) => t.contactUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ContactUsageStatsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.contactUsageStats,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> transactionSchedulesRefs<T extends Object>(
      Expression<T> Function($$TransactionSchedulesTableAnnotationComposer a)
          f) {
    final $$TransactionSchedulesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.transactionSchedules,
            getReferencedColumn: (t) => t.contactUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionSchedulesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionSchedules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, $$ContactsTableReferences),
    Contact,
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool receivablesRefs,
        bool payablesRefs,
        bool whatsAppQueueRefs,
        bool contactUsageStatsRefs,
        bool transactionSchedulesRefs})> {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion(
            uuid: uuid,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion.insert(
            uuid: uuid,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ContactsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transactionsRefs = false,
              receivablesRefs = false,
              payablesRefs = false,
              whatsAppQueueRefs = false,
              contactUsageStatsRefs = false,
              transactionSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (receivablesRefs) db.receivables,
                if (payablesRefs) db.payables,
                if (whatsAppQueueRefs) db.whatsAppQueue,
                if (contactUsageStatsRefs) db.contactUsageStats,
                if (transactionSchedulesRefs) db.transactionSchedules
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items),
                  if (receivablesRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            Receivable>(
                        currentTable: table,
                        referencedTable:
                            $$ContactsTableReferences._receivablesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .receivablesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items),
                  if (payablesRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable, Payable>(
                        currentTable: table,
                        referencedTable:
                            $$ContactsTableReferences._payablesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .payablesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items),
                  if (whatsAppQueueRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            WhatsAppQueueData>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._whatsAppQueueRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .whatsAppQueueRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items),
                  if (contactUsageStatsRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            ContactUsageStat>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._contactUsageStatsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .contactUsageStatsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items),
                  if (transactionSchedulesRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            TransactionSchedule>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._transactionSchedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .transactionSchedulesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ContactsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, $$ContactsTableReferences),
    Contact,
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool receivablesRefs,
        bool payablesRefs,
        bool whatsAppQueueRefs,
        bool contactUsageStatsRefs,
        bool transactionSchedulesRefs})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String uuid,
  required double amount,
  required String type,
  Value<String?> categoryUuid,
  Value<String?> contactUuid,
  Value<String?> description,
  required DateTime date,
  Value<String?> linkedReceivableUuid,
  Value<String?> linkedPayableUuid,
  Value<String?> paidRelationship,
  Value<bool> isAutoGenerated,
  Value<bool> isScheduled,
  Value<String?> externalLinkId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> uuid,
  Value<double> amount,
  Value<String> type,
  Value<String?> categoryUuid,
  Value<String?> contactUuid,
  Value<String?> description,
  Value<DateTime> date,
  Value<String?> linkedReceivableUuid,
  Value<String?> linkedPayableUuid,
  Value<String?> paidRelationship,
  Value<bool> isAutoGenerated,
  Value<bool> isScheduled,
  Value<String?> externalLinkId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryUuidTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.transactions.categoryUuid, db.categories.uuid));

  $$CategoriesTableProcessedTableManager? get categoryUuid {
    final $_column = $_itemColumn<String>('category_uuid');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.transactions.contactUuid, db.contacts.uuid));

  $$ContactsTableProcessedTableManager? get contactUuid {
    final $_column = $_itemColumn<String>('contact_uuid');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedReceivableUuid => $composableBuilder(
      column: $table.linkedReceivableUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedPayableUuid => $composableBuilder(
      column: $table.linkedPayableUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidRelationship => $composableBuilder(
      column: $table.paidRelationship,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAutoGenerated => $composableBuilder(
      column: $table.isAutoGenerated,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryUuid {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ContactsTableFilterComposer get contactUuid {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedReceivableUuid => $composableBuilder(
      column: $table.linkedReceivableUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedPayableUuid => $composableBuilder(
      column: $table.linkedPayableUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidRelationship => $composableBuilder(
      column: $table.paidRelationship,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAutoGenerated => $composableBuilder(
      column: $table.isAutoGenerated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryUuid {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ContactsTableOrderingComposer get contactUuid {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get linkedReceivableUuid => $composableBuilder(
      column: $table.linkedReceivableUuid, builder: (column) => column);

  GeneratedColumn<String> get linkedPayableUuid => $composableBuilder(
      column: $table.linkedPayableUuid, builder: (column) => column);

  GeneratedColumn<String> get paidRelationship => $composableBuilder(
      column: $table.paidRelationship, builder: (column) => column);

  GeneratedColumn<bool> get isAutoGenerated => $composableBuilder(
      column: $table.isAutoGenerated, builder: (column) => column);

  GeneratedColumn<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => column);

  GeneratedColumn<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryUuid {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ContactsTableAnnotationComposer get contactUuid {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function({bool categoryUuid, bool contactUuid})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> categoryUuid = const Value.absent(),
            Value<String?> contactUuid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> linkedReceivableUuid = const Value.absent(),
            Value<String?> linkedPayableUuid = const Value.absent(),
            Value<String?> paidRelationship = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
            Value<String?> externalLinkId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            uuid: uuid,
            amount: amount,
            type: type,
            categoryUuid: categoryUuid,
            contactUuid: contactUuid,
            description: description,
            date: date,
            linkedReceivableUuid: linkedReceivableUuid,
            linkedPayableUuid: linkedPayableUuid,
            paidRelationship: paidRelationship,
            isAutoGenerated: isAutoGenerated,
            isScheduled: isScheduled,
            externalLinkId: externalLinkId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required double amount,
            required String type,
            Value<String?> categoryUuid = const Value.absent(),
            Value<String?> contactUuid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required DateTime date,
            Value<String?> linkedReceivableUuid = const Value.absent(),
            Value<String?> linkedPayableUuid = const Value.absent(),
            Value<String?> paidRelationship = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
            Value<String?> externalLinkId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            uuid: uuid,
            amount: amount,
            type: type,
            categoryUuid: categoryUuid,
            contactUuid: contactUuid,
            description: description,
            date: date,
            linkedReceivableUuid: linkedReceivableUuid,
            linkedPayableUuid: linkedPayableUuid,
            paidRelationship: paidRelationship,
            isAutoGenerated: isAutoGenerated,
            isScheduled: isScheduled,
            externalLinkId: externalLinkId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryUuid = false, contactUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryUuid,
                    referencedTable:
                        $$TransactionsTableReferences._categoryUuidTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._categoryUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable:
                        $$TransactionsTableReferences._contactUuidTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._contactUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function({bool categoryUuid, bool contactUuid})>;
typedef $$ReceivablesTableCreateCompanionBuilder = ReceivablesCompanion
    Function({
  required String uuid,
  required String contactUuid,
  required double amount,
  Value<String?> description,
  required DateTime date,
  Value<DateTime?> dueDate,
  Value<String> status,
  Value<DateTime?> receivedDate,
  Value<String?> linkedExpenseUuid,
  Value<String?> linkedIncomeUuid,
  Value<bool> autoCreateIncome,
  Value<bool> isScheduled,
  Value<String?> externalLinkId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$ReceivablesTableUpdateCompanionBuilder = ReceivablesCompanion
    Function({
  Value<String> uuid,
  Value<String> contactUuid,
  Value<double> amount,
  Value<String?> description,
  Value<DateTime> date,
  Value<DateTime?> dueDate,
  Value<String> status,
  Value<DateTime?> receivedDate,
  Value<String?> linkedExpenseUuid,
  Value<String?> linkedIncomeUuid,
  Value<bool> autoCreateIncome,
  Value<bool> isScheduled,
  Value<String?> externalLinkId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$ReceivablesTableReferences
    extends BaseReferences<_$AppDatabase, $ReceivablesTable, Receivable> {
  $$ReceivablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.receivables.contactUuid, db.contacts.uuid));

  $$ContactsTableProcessedTableManager get contactUuid {
    final $_column = $_itemColumn<String>('contact_uuid')!;

    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _linkedExpenseUuidTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.receivables.linkedExpenseUuid, db.transactions.uuid));

  $$TransactionsTableProcessedTableManager? get linkedExpenseUuid {
    final $_column = $_itemColumn<String>('linked_expense_uuid');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedExpenseUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _linkedIncomeUuidTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.receivables.linkedIncomeUuid, db.transactions.uuid));

  $$TransactionsTableProcessedTableManager? get linkedIncomeUuid {
    final $_column = $_itemColumn<String>('linked_income_uuid');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedIncomeUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReceivablesTableFilterComposer
    extends Composer<_$AppDatabase, $ReceivablesTable> {
  $$ReceivablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedDate => $composableBuilder(
      column: $table.receivedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoCreateIncome => $composableBuilder(
      column: $table.autoCreateIncome,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$ContactsTableFilterComposer get contactUuid {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get linkedExpenseUuid {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedExpenseUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get linkedIncomeUuid {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedIncomeUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReceivablesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceivablesTable> {
  $$ReceivablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedDate => $composableBuilder(
      column: $table.receivedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoCreateIncome => $composableBuilder(
      column: $table.autoCreateIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$ContactsTableOrderingComposer get contactUuid {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get linkedExpenseUuid {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedExpenseUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get linkedIncomeUuid {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedIncomeUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReceivablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceivablesTable> {
  $$ReceivablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedDate => $composableBuilder(
      column: $table.receivedDate, builder: (column) => column);

  GeneratedColumn<bool> get autoCreateIncome => $composableBuilder(
      column: $table.autoCreateIncome, builder: (column) => column);

  GeneratedColumn<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => column);

  GeneratedColumn<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactUuid {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get linkedExpenseUuid {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedExpenseUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get linkedIncomeUuid {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedIncomeUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReceivablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReceivablesTable,
    Receivable,
    $$ReceivablesTableFilterComposer,
    $$ReceivablesTableOrderingComposer,
    $$ReceivablesTableAnnotationComposer,
    $$ReceivablesTableCreateCompanionBuilder,
    $$ReceivablesTableUpdateCompanionBuilder,
    (Receivable, $$ReceivablesTableReferences),
    Receivable,
    PrefetchHooks Function(
        {bool contactUuid, bool linkedExpenseUuid, bool linkedIncomeUuid})> {
  $$ReceivablesTableTableManager(_$AppDatabase db, $ReceivablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceivablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceivablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceivablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> contactUuid = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> receivedDate = const Value.absent(),
            Value<String?> linkedExpenseUuid = const Value.absent(),
            Value<String?> linkedIncomeUuid = const Value.absent(),
            Value<bool> autoCreateIncome = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
            Value<String?> externalLinkId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceivablesCompanion(
            uuid: uuid,
            contactUuid: contactUuid,
            amount: amount,
            description: description,
            date: date,
            dueDate: dueDate,
            status: status,
            receivedDate: receivedDate,
            linkedExpenseUuid: linkedExpenseUuid,
            linkedIncomeUuid: linkedIncomeUuid,
            autoCreateIncome: autoCreateIncome,
            isScheduled: isScheduled,
            externalLinkId: externalLinkId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String contactUuid,
            required double amount,
            Value<String?> description = const Value.absent(),
            required DateTime date,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> receivedDate = const Value.absent(),
            Value<String?> linkedExpenseUuid = const Value.absent(),
            Value<String?> linkedIncomeUuid = const Value.absent(),
            Value<bool> autoCreateIncome = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
            Value<String?> externalLinkId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceivablesCompanion.insert(
            uuid: uuid,
            contactUuid: contactUuid,
            amount: amount,
            description: description,
            date: date,
            dueDate: dueDate,
            status: status,
            receivedDate: receivedDate,
            linkedExpenseUuid: linkedExpenseUuid,
            linkedIncomeUuid: linkedIncomeUuid,
            autoCreateIncome: autoCreateIncome,
            isScheduled: isScheduled,
            externalLinkId: externalLinkId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReceivablesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {contactUuid = false,
              linkedExpenseUuid = false,
              linkedIncomeUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable:
                        $$ReceivablesTableReferences._contactUuidTable(db),
                    referencedColumn:
                        $$ReceivablesTableReferences._contactUuidTable(db).uuid,
                  ) as T;
                }
                if (linkedExpenseUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.linkedExpenseUuid,
                    referencedTable: $$ReceivablesTableReferences
                        ._linkedExpenseUuidTable(db),
                    referencedColumn: $$ReceivablesTableReferences
                        ._linkedExpenseUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (linkedIncomeUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.linkedIncomeUuid,
                    referencedTable:
                        $$ReceivablesTableReferences._linkedIncomeUuidTable(db),
                    referencedColumn: $$ReceivablesTableReferences
                        ._linkedIncomeUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReceivablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReceivablesTable,
    Receivable,
    $$ReceivablesTableFilterComposer,
    $$ReceivablesTableOrderingComposer,
    $$ReceivablesTableAnnotationComposer,
    $$ReceivablesTableCreateCompanionBuilder,
    $$ReceivablesTableUpdateCompanionBuilder,
    (Receivable, $$ReceivablesTableReferences),
    Receivable,
    PrefetchHooks Function(
        {bool contactUuid, bool linkedExpenseUuid, bool linkedIncomeUuid})>;
typedef $$PayablesTableCreateCompanionBuilder = PayablesCompanion Function({
  required String uuid,
  required String contactUuid,
  required double amount,
  Value<String?> description,
  required DateTime date,
  Value<DateTime?> dueDate,
  Value<String> status,
  Value<DateTime?> paidDate,
  Value<String?> linkedExpenseUuid,
  Value<String?> linkedIncomeUuid,
  Value<bool> autoCreateExpense,
  Value<bool> isScheduled,
  Value<String?> externalLinkId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$PayablesTableUpdateCompanionBuilder = PayablesCompanion Function({
  Value<String> uuid,
  Value<String> contactUuid,
  Value<double> amount,
  Value<String?> description,
  Value<DateTime> date,
  Value<DateTime?> dueDate,
  Value<String> status,
  Value<DateTime?> paidDate,
  Value<String?> linkedExpenseUuid,
  Value<String?> linkedIncomeUuid,
  Value<bool> autoCreateExpense,
  Value<bool> isScheduled,
  Value<String?> externalLinkId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$PayablesTableReferences
    extends BaseReferences<_$AppDatabase, $PayablesTable, Payable> {
  $$PayablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.payables.contactUuid, db.contacts.uuid));

  $$ContactsTableProcessedTableManager get contactUuid {
    final $_column = $_itemColumn<String>('contact_uuid')!;

    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _linkedExpenseUuidTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.payables.linkedExpenseUuid, db.transactions.uuid));

  $$TransactionsTableProcessedTableManager? get linkedExpenseUuid {
    final $_column = $_itemColumn<String>('linked_expense_uuid');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedExpenseUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _linkedIncomeUuidTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.payables.linkedIncomeUuid, db.transactions.uuid));

  $$TransactionsTableProcessedTableManager? get linkedIncomeUuid {
    final $_column = $_itemColumn<String>('linked_income_uuid');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedIncomeUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PayablesTableFilterComposer
    extends Composer<_$AppDatabase, $PayablesTable> {
  $$PayablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
      column: $table.paidDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoCreateExpense => $composableBuilder(
      column: $table.autoCreateExpense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$ContactsTableFilterComposer get contactUuid {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get linkedExpenseUuid {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedExpenseUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get linkedIncomeUuid {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedIncomeUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PayablesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayablesTable> {
  $$PayablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
      column: $table.paidDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoCreateExpense => $composableBuilder(
      column: $table.autoCreateExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$ContactsTableOrderingComposer get contactUuid {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get linkedExpenseUuid {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedExpenseUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get linkedIncomeUuid {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedIncomeUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PayablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayablesTable> {
  $$PayablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<bool> get autoCreateExpense => $composableBuilder(
      column: $table.autoCreateExpense, builder: (column) => column);

  GeneratedColumn<bool> get isScheduled => $composableBuilder(
      column: $table.isScheduled, builder: (column) => column);

  GeneratedColumn<String> get externalLinkId => $composableBuilder(
      column: $table.externalLinkId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactUuid {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get linkedExpenseUuid {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedExpenseUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get linkedIncomeUuid {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.linkedIncomeUuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PayablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PayablesTable,
    Payable,
    $$PayablesTableFilterComposer,
    $$PayablesTableOrderingComposer,
    $$PayablesTableAnnotationComposer,
    $$PayablesTableCreateCompanionBuilder,
    $$PayablesTableUpdateCompanionBuilder,
    (Payable, $$PayablesTableReferences),
    Payable,
    PrefetchHooks Function(
        {bool contactUuid, bool linkedExpenseUuid, bool linkedIncomeUuid})> {
  $$PayablesTableTableManager(_$AppDatabase db, $PayablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> contactUuid = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> paidDate = const Value.absent(),
            Value<String?> linkedExpenseUuid = const Value.absent(),
            Value<String?> linkedIncomeUuid = const Value.absent(),
            Value<bool> autoCreateExpense = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
            Value<String?> externalLinkId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PayablesCompanion(
            uuid: uuid,
            contactUuid: contactUuid,
            amount: amount,
            description: description,
            date: date,
            dueDate: dueDate,
            status: status,
            paidDate: paidDate,
            linkedExpenseUuid: linkedExpenseUuid,
            linkedIncomeUuid: linkedIncomeUuid,
            autoCreateExpense: autoCreateExpense,
            isScheduled: isScheduled,
            externalLinkId: externalLinkId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String contactUuid,
            required double amount,
            Value<String?> description = const Value.absent(),
            required DateTime date,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> paidDate = const Value.absent(),
            Value<String?> linkedExpenseUuid = const Value.absent(),
            Value<String?> linkedIncomeUuid = const Value.absent(),
            Value<bool> autoCreateExpense = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
            Value<String?> externalLinkId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PayablesCompanion.insert(
            uuid: uuid,
            contactUuid: contactUuid,
            amount: amount,
            description: description,
            date: date,
            dueDate: dueDate,
            status: status,
            paidDate: paidDate,
            linkedExpenseUuid: linkedExpenseUuid,
            linkedIncomeUuid: linkedIncomeUuid,
            autoCreateExpense: autoCreateExpense,
            isScheduled: isScheduled,
            externalLinkId: externalLinkId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PayablesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {contactUuid = false,
              linkedExpenseUuid = false,
              linkedIncomeUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable:
                        $$PayablesTableReferences._contactUuidTable(db),
                    referencedColumn:
                        $$PayablesTableReferences._contactUuidTable(db).uuid,
                  ) as T;
                }
                if (linkedExpenseUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.linkedExpenseUuid,
                    referencedTable:
                        $$PayablesTableReferences._linkedExpenseUuidTable(db),
                    referencedColumn: $$PayablesTableReferences
                        ._linkedExpenseUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (linkedIncomeUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.linkedIncomeUuid,
                    referencedTable:
                        $$PayablesTableReferences._linkedIncomeUuidTable(db),
                    referencedColumn: $$PayablesTableReferences
                        ._linkedIncomeUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PayablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PayablesTable,
    Payable,
    $$PayablesTableFilterComposer,
    $$PayablesTableOrderingComposer,
    $$PayablesTableAnnotationComposer,
    $$PayablesTableCreateCompanionBuilder,
    $$PayablesTableUpdateCompanionBuilder,
    (Payable, $$PayablesTableReferences),
    Payable,
    PrefetchHooks Function(
        {bool contactUuid, bool linkedExpenseUuid, bool linkedIncomeUuid})>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String uuid,
  required String type,
  required String referenceUuid,
  required DateTime reminderDate,
  Value<bool> isTriggered,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> uuid,
  Value<String> type,
  Value<String> referenceUuid,
  Value<DateTime> reminderDate,
  Value<bool> isTriggered,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceUuid => $composableBuilder(
      column: $table.referenceUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reminderDate => $composableBuilder(
      column: $table.reminderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTriggered => $composableBuilder(
      column: $table.isTriggered, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceUuid => $composableBuilder(
      column: $table.referenceUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reminderDate => $composableBuilder(
      column: $table.reminderDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTriggered => $composableBuilder(
      column: $table.isTriggered, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get referenceUuid => $composableBuilder(
      column: $table.referenceUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get reminderDate => $composableBuilder(
      column: $table.reminderDate, builder: (column) => column);

  GeneratedColumn<bool> get isTriggered => $composableBuilder(
      column: $table.isTriggered, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> referenceUuid = const Value.absent(),
            Value<DateTime> reminderDate = const Value.absent(),
            Value<bool> isTriggered = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion(
            uuid: uuid,
            type: type,
            referenceUuid: referenceUuid,
            reminderDate: reminderDate,
            isTriggered: isTriggered,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String type,
            required String referenceUuid,
            required DateTime reminderDate,
            Value<bool> isTriggered = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            uuid: uuid,
            type: type,
            referenceUuid: referenceUuid,
            reminderDate: reminderDate,
            isTriggered: isTriggered,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()>;
typedef $$WhatsAppQueueTableCreateCompanionBuilder = WhatsAppQueueCompanion
    Function({
  Value<int> id,
  required String contactUuid,
  required String message,
  Value<String?> deepLink,
  Value<String> status,
  Value<DateTime> createdAt,
});
typedef $$WhatsAppQueueTableUpdateCompanionBuilder = WhatsAppQueueCompanion
    Function({
  Value<int> id,
  Value<String> contactUuid,
  Value<String> message,
  Value<String?> deepLink,
  Value<String> status,
  Value<DateTime> createdAt,
});

final class $$WhatsAppQueueTableReferences extends BaseReferences<_$AppDatabase,
    $WhatsAppQueueTable, WhatsAppQueueData> {
  $$WhatsAppQueueTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.whatsAppQueue.contactUuid, db.contacts.uuid));

  $$ContactsTableProcessedTableManager get contactUuid {
    final $_column = $_itemColumn<String>('contact_uuid')!;

    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WhatsAppQueueTableFilterComposer
    extends Composer<_$AppDatabase, $WhatsAppQueueTable> {
  $$WhatsAppQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deepLink => $composableBuilder(
      column: $table.deepLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ContactsTableFilterComposer get contactUuid {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WhatsAppQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $WhatsAppQueueTable> {
  $$WhatsAppQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deepLink => $composableBuilder(
      column: $table.deepLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ContactsTableOrderingComposer get contactUuid {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WhatsAppQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $WhatsAppQueueTable> {
  $$WhatsAppQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get deepLink =>
      $composableBuilder(column: $table.deepLink, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactUuid {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WhatsAppQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WhatsAppQueueTable,
    WhatsAppQueueData,
    $$WhatsAppQueueTableFilterComposer,
    $$WhatsAppQueueTableOrderingComposer,
    $$WhatsAppQueueTableAnnotationComposer,
    $$WhatsAppQueueTableCreateCompanionBuilder,
    $$WhatsAppQueueTableUpdateCompanionBuilder,
    (WhatsAppQueueData, $$WhatsAppQueueTableReferences),
    WhatsAppQueueData,
    PrefetchHooks Function({bool contactUuid})> {
  $$WhatsAppQueueTableTableManager(_$AppDatabase db, $WhatsAppQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WhatsAppQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WhatsAppQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WhatsAppQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> contactUuid = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String?> deepLink = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WhatsAppQueueCompanion(
            id: id,
            contactUuid: contactUuid,
            message: message,
            deepLink: deepLink,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String contactUuid,
            required String message,
            Value<String?> deepLink = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WhatsAppQueueCompanion.insert(
            id: id,
            contactUuid: contactUuid,
            message: message,
            deepLink: deepLink,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WhatsAppQueueTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({contactUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable:
                        $$WhatsAppQueueTableReferences._contactUuidTable(db),
                    referencedColumn: $$WhatsAppQueueTableReferences
                        ._contactUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WhatsAppQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WhatsAppQueueTable,
    WhatsAppQueueData,
    $$WhatsAppQueueTableFilterComposer,
    $$WhatsAppQueueTableOrderingComposer,
    $$WhatsAppQueueTableAnnotationComposer,
    $$WhatsAppQueueTableCreateCompanionBuilder,
    $$WhatsAppQueueTableUpdateCompanionBuilder,
    (WhatsAppQueueData, $$WhatsAppQueueTableReferences),
    WhatsAppQueueData,
    PrefetchHooks Function({bool contactUuid})>;
typedef $$CategoryUsageStatsTableCreateCompanionBuilder
    = CategoryUsageStatsCompanion Function({
  Value<int> id,
  required String categoryUuid,
  Value<int> usageCount,
  Value<DateTime?> lastUsed,
});
typedef $$CategoryUsageStatsTableUpdateCompanionBuilder
    = CategoryUsageStatsCompanion Function({
  Value<int> id,
  Value<String> categoryUuid,
  Value<int> usageCount,
  Value<DateTime?> lastUsed,
});

final class $$CategoryUsageStatsTableReferences extends BaseReferences<
    _$AppDatabase, $CategoryUsageStatsTable, CategoryUsageStat> {
  $$CategoryUsageStatsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryUuidTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.categoryUsageStats.categoryUuid, db.categories.uuid));

  $$CategoriesTableProcessedTableManager get categoryUuid {
    final $_column = $_itemColumn<String>('category_uuid')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CategoryUsageStatsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryUsageStatsTable> {
  $$CategoryUsageStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryUuid {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryUsageStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryUsageStatsTable> {
  $$CategoryUsageStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryUuid {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryUsageStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryUsageStatsTable> {
  $$CategoryUsageStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryUuid {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryUsageStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryUsageStatsTable,
    CategoryUsageStat,
    $$CategoryUsageStatsTableFilterComposer,
    $$CategoryUsageStatsTableOrderingComposer,
    $$CategoryUsageStatsTableAnnotationComposer,
    $$CategoryUsageStatsTableCreateCompanionBuilder,
    $$CategoryUsageStatsTableUpdateCompanionBuilder,
    (CategoryUsageStat, $$CategoryUsageStatsTableReferences),
    CategoryUsageStat,
    PrefetchHooks Function({bool categoryUuid})> {
  $$CategoryUsageStatsTableTableManager(
      _$AppDatabase db, $CategoryUsageStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryUsageStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryUsageStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryUsageStatsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> categoryUuid = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime?> lastUsed = const Value.absent(),
          }) =>
              CategoryUsageStatsCompanion(
            id: id,
            categoryUuid: categoryUuid,
            usageCount: usageCount,
            lastUsed: lastUsed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String categoryUuid,
            Value<int> usageCount = const Value.absent(),
            Value<DateTime?> lastUsed = const Value.absent(),
          }) =>
              CategoryUsageStatsCompanion.insert(
            id: id,
            categoryUuid: categoryUuid,
            usageCount: usageCount,
            lastUsed: lastUsed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoryUsageStatsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryUuid,
                    referencedTable: $$CategoryUsageStatsTableReferences
                        ._categoryUuidTable(db),
                    referencedColumn: $$CategoryUsageStatsTableReferences
                        ._categoryUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CategoryUsageStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryUsageStatsTable,
    CategoryUsageStat,
    $$CategoryUsageStatsTableFilterComposer,
    $$CategoryUsageStatsTableOrderingComposer,
    $$CategoryUsageStatsTableAnnotationComposer,
    $$CategoryUsageStatsTableCreateCompanionBuilder,
    $$CategoryUsageStatsTableUpdateCompanionBuilder,
    (CategoryUsageStat, $$CategoryUsageStatsTableReferences),
    CategoryUsageStat,
    PrefetchHooks Function({bool categoryUuid})>;
typedef $$ContactUsageStatsTableCreateCompanionBuilder
    = ContactUsageStatsCompanion Function({
  Value<int> id,
  required String contactUuid,
  Value<int> usageCount,
  Value<DateTime?> lastUsed,
});
typedef $$ContactUsageStatsTableUpdateCompanionBuilder
    = ContactUsageStatsCompanion Function({
  Value<int> id,
  Value<String> contactUuid,
  Value<int> usageCount,
  Value<DateTime?> lastUsed,
});

final class $$ContactUsageStatsTableReferences extends BaseReferences<
    _$AppDatabase, $ContactUsageStatsTable, ContactUsageStat> {
  $$ContactUsageStatsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias($_aliasNameGenerator(
          db.contactUsageStats.contactUuid, db.contacts.uuid));

  $$ContactsTableProcessedTableManager get contactUuid {
    final $_column = $_itemColumn<String>('contact_uuid')!;

    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ContactUsageStatsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactUsageStatsTable> {
  $$ContactUsageStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnFilters(column));

  $$ContactsTableFilterComposer get contactUuid {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactUsageStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactUsageStatsTable> {
  $$ContactUsageStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnOrderings(column));

  $$ContactsTableOrderingComposer get contactUuid {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactUsageStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactUsageStatsTable> {
  $$ContactUsageStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactUuid {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactUsageStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactUsageStatsTable,
    ContactUsageStat,
    $$ContactUsageStatsTableFilterComposer,
    $$ContactUsageStatsTableOrderingComposer,
    $$ContactUsageStatsTableAnnotationComposer,
    $$ContactUsageStatsTableCreateCompanionBuilder,
    $$ContactUsageStatsTableUpdateCompanionBuilder,
    (ContactUsageStat, $$ContactUsageStatsTableReferences),
    ContactUsageStat,
    PrefetchHooks Function({bool contactUuid})> {
  $$ContactUsageStatsTableTableManager(
      _$AppDatabase db, $ContactUsageStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactUsageStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactUsageStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactUsageStatsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> contactUuid = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime?> lastUsed = const Value.absent(),
          }) =>
              ContactUsageStatsCompanion(
            id: id,
            contactUuid: contactUuid,
            usageCount: usageCount,
            lastUsed: lastUsed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String contactUuid,
            Value<int> usageCount = const Value.absent(),
            Value<DateTime?> lastUsed = const Value.absent(),
          }) =>
              ContactUsageStatsCompanion.insert(
            id: id,
            contactUuid: contactUuid,
            usageCount: usageCount,
            lastUsed: lastUsed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ContactUsageStatsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({contactUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable: $$ContactUsageStatsTableReferences
                        ._contactUuidTable(db),
                    referencedColumn: $$ContactUsageStatsTableReferences
                        ._contactUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ContactUsageStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactUsageStatsTable,
    ContactUsageStat,
    $$ContactUsageStatsTableFilterComposer,
    $$ContactUsageStatsTableOrderingComposer,
    $$ContactUsageStatsTableAnnotationComposer,
    $$ContactUsageStatsTableCreateCompanionBuilder,
    $$ContactUsageStatsTableUpdateCompanionBuilder,
    (ContactUsageStat, $$ContactUsageStatsTableReferences),
    ContactUsageStat,
    PrefetchHooks Function({bool contactUuid})>;
typedef $$UserPreferencesTableCreateCompanionBuilder = UserPreferencesCompanion
    Function({
  Value<int> id,
  required String key,
  required String value,
  Value<DateTime> updatedAt,
});
typedef $$UserPreferencesTableUpdateCompanionBuilder = UserPreferencesCompanion
    Function({
  Value<int> id,
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
});

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserPreferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserPreferencesTable,
    UserPreference,
    $$UserPreferencesTableFilterComposer,
    $$UserPreferencesTableOrderingComposer,
    $$UserPreferencesTableAnnotationComposer,
    $$UserPreferencesTableCreateCompanionBuilder,
    $$UserPreferencesTableUpdateCompanionBuilder,
    (
      UserPreference,
      BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>
    ),
    UserPreference,
    PrefetchHooks Function()> {
  $$UserPreferencesTableTableManager(
      _$AppDatabase db, $UserPreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserPreferencesCompanion(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserPreferencesCompanion.insert(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserPreferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserPreferencesTable,
    UserPreference,
    $$UserPreferencesTableFilterComposer,
    $$UserPreferencesTableOrderingComposer,
    $$UserPreferencesTableAnnotationComposer,
    $$UserPreferencesTableCreateCompanionBuilder,
    $$UserPreferencesTableUpdateCompanionBuilder,
    (
      UserPreference,
      BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>
    ),
    UserPreference,
    PrefetchHooks Function()>;
typedef $$SyncLogTableCreateCompanionBuilder = SyncLogCompanion Function({
  Value<int> id,
  Value<DateTime?> lastBackup,
  Value<DateTime?> lastRestore,
  Value<String?> driveFileId,
  Value<String?> status,
  Value<DateTime> createdAt,
});
typedef $$SyncLogTableUpdateCompanionBuilder = SyncLogCompanion Function({
  Value<int> id,
  Value<DateTime?> lastBackup,
  Value<DateTime?> lastRestore,
  Value<String?> driveFileId,
  Value<String?> status,
  Value<DateTime> createdAt,
});

class $$SyncLogTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastBackup => $composableBuilder(
      column: $table.lastBackup, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastRestore => $composableBuilder(
      column: $table.lastRestore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driveFileId => $composableBuilder(
      column: $table.driveFileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncLogTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastBackup => $composableBuilder(
      column: $table.lastBackup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastRestore => $composableBuilder(
      column: $table.lastRestore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driveFileId => $composableBuilder(
      column: $table.driveFileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastBackup => $composableBuilder(
      column: $table.lastBackup, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRestore => $composableBuilder(
      column: $table.lastRestore, builder: (column) => column);

  GeneratedColumn<String> get driveFileId => $composableBuilder(
      column: $table.driveFileId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncLogTable,
    SyncLogData,
    $$SyncLogTableFilterComposer,
    $$SyncLogTableOrderingComposer,
    $$SyncLogTableAnnotationComposer,
    $$SyncLogTableCreateCompanionBuilder,
    $$SyncLogTableUpdateCompanionBuilder,
    (SyncLogData, BaseReferences<_$AppDatabase, $SyncLogTable, SyncLogData>),
    SyncLogData,
    PrefetchHooks Function()> {
  $$SyncLogTableTableManager(_$AppDatabase db, $SyncLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> lastBackup = const Value.absent(),
            Value<DateTime?> lastRestore = const Value.absent(),
            Value<String?> driveFileId = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncLogCompanion(
            id: id,
            lastBackup: lastBackup,
            lastRestore: lastRestore,
            driveFileId: driveFileId,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> lastBackup = const Value.absent(),
            Value<DateTime?> lastRestore = const Value.absent(),
            Value<String?> driveFileId = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncLogCompanion.insert(
            id: id,
            lastBackup: lastBackup,
            lastRestore: lastRestore,
            driveFileId: driveFileId,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncLogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncLogTable,
    SyncLogData,
    $$SyncLogTableFilterComposer,
    $$SyncLogTableOrderingComposer,
    $$SyncLogTableAnnotationComposer,
    $$SyncLogTableCreateCompanionBuilder,
    $$SyncLogTableUpdateCompanionBuilder,
    (SyncLogData, BaseReferences<_$AppDatabase, $SyncLogTable, SyncLogData>),
    SyncLogData,
    PrefetchHooks Function()>;
typedef $$AppCurrenciesTableCreateCompanionBuilder = AppCurrenciesCompanion
    Function({
  required String uuid,
  required String name,
  required String symbol,
  required String code,
  Value<int> decimalPlaces,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$AppCurrenciesTableUpdateCompanionBuilder = AppCurrenciesCompanion
    Function({
  Value<String> uuid,
  Value<String> name,
  Value<String> symbol,
  Value<String> code,
  Value<int> decimalPlaces,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

class $$AppCurrenciesTableFilterComposer
    extends Composer<_$AppDatabase, $AppCurrenciesTable> {
  $$AppCurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));
}

class $$AppCurrenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppCurrenciesTable> {
  $$AppCurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));
}

class $$AppCurrenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppCurrenciesTable> {
  $$AppCurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);
}

class $$AppCurrenciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppCurrenciesTable,
    AppCurrency,
    $$AppCurrenciesTableFilterComposer,
    $$AppCurrenciesTableOrderingComposer,
    $$AppCurrenciesTableAnnotationComposer,
    $$AppCurrenciesTableCreateCompanionBuilder,
    $$AppCurrenciesTableUpdateCompanionBuilder,
    (
      AppCurrency,
      BaseReferences<_$AppDatabase, $AppCurrenciesTable, AppCurrency>
    ),
    AppCurrency,
    PrefetchHooks Function()> {
  $$AppCurrenciesTableTableManager(_$AppDatabase db, $AppCurrenciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppCurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppCurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppCurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<int> decimalPlaces = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppCurrenciesCompanion(
            uuid: uuid,
            name: name,
            symbol: symbol,
            code: code,
            decimalPlaces: decimalPlaces,
            isDefault: isDefault,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            required String symbol,
            required String code,
            Value<int> decimalPlaces = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppCurrenciesCompanion.insert(
            uuid: uuid,
            name: name,
            symbol: symbol,
            code: code,
            decimalPlaces: decimalPlaces,
            isDefault: isDefault,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppCurrenciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppCurrenciesTable,
    AppCurrency,
    $$AppCurrenciesTableFilterComposer,
    $$AppCurrenciesTableOrderingComposer,
    $$AppCurrenciesTableAnnotationComposer,
    $$AppCurrenciesTableCreateCompanionBuilder,
    $$AppCurrenciesTableUpdateCompanionBuilder,
    (
      AppCurrency,
      BaseReferences<_$AppDatabase, $AppCurrenciesTable, AppCurrency>
    ),
    AppCurrency,
    PrefetchHooks Function()>;
typedef $$TransactionSchedulesTableCreateCompanionBuilder
    = TransactionSchedulesCompanion Function({
  required String uuid,
  required double amount,
  required String type,
  Value<String?> categoryUuid,
  Value<String?> contactUuid,
  Value<String?> description,
  Value<String?> paidRelationship,
  Value<DateTime?> dueDate,
  required String scheduleType,
  Value<String?> selectedDaysOfWeek,
  Value<String?> selectedDaysOfMonth,
  Value<int?> dueDateOffset,
  Value<bool> isPaused,
  Value<DateTime?> lastGeneratedDate,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$TransactionSchedulesTableUpdateCompanionBuilder
    = TransactionSchedulesCompanion Function({
  Value<String> uuid,
  Value<double> amount,
  Value<String> type,
  Value<String?> categoryUuid,
  Value<String?> contactUuid,
  Value<String?> description,
  Value<String?> paidRelationship,
  Value<DateTime?> dueDate,
  Value<String> scheduleType,
  Value<String?> selectedDaysOfWeek,
  Value<String?> selectedDaysOfMonth,
  Value<int?> dueDateOffset,
  Value<bool> isPaused,
  Value<DateTime?> lastGeneratedDate,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$TransactionSchedulesTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionSchedulesTable, TransactionSchedule> {
  $$TransactionSchedulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryUuidTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.transactionSchedules.categoryUuid, db.categories.uuid));

  $$CategoriesTableProcessedTableManager? get categoryUuid {
    final $_column = $_itemColumn<String>('category_uuid');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias($_aliasNameGenerator(
          db.transactionSchedules.contactUuid, db.contacts.uuid));

  $$ContactsTableProcessedTableManager? get contactUuid {
    final $_column = $_itemColumn<String>('contact_uuid');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionSchedulesTable> {
  $$TransactionSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidRelationship => $composableBuilder(
      column: $table.paidRelationship,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduleType => $composableBuilder(
      column: $table.scheduleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedDaysOfWeek => $composableBuilder(
      column: $table.selectedDaysOfWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedDaysOfMonth => $composableBuilder(
      column: $table.selectedDaysOfMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueDateOffset => $composableBuilder(
      column: $table.dueDateOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPaused => $composableBuilder(
      column: $table.isPaused, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastGeneratedDate => $composableBuilder(
      column: $table.lastGeneratedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryUuid {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ContactsTableFilterComposer get contactUuid {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionSchedulesTable> {
  $$TransactionSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidRelationship => $composableBuilder(
      column: $table.paidRelationship,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleType => $composableBuilder(
      column: $table.scheduleType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedDaysOfWeek => $composableBuilder(
      column: $table.selectedDaysOfWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedDaysOfMonth => $composableBuilder(
      column: $table.selectedDaysOfMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueDateOffset => $composableBuilder(
      column: $table.dueDateOffset,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPaused => $composableBuilder(
      column: $table.isPaused, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastGeneratedDate => $composableBuilder(
      column: $table.lastGeneratedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryUuid {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ContactsTableOrderingComposer get contactUuid {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionSchedulesTable> {
  $$TransactionSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get paidRelationship => $composableBuilder(
      column: $table.paidRelationship, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get scheduleType => $composableBuilder(
      column: $table.scheduleType, builder: (column) => column);

  GeneratedColumn<String> get selectedDaysOfWeek => $composableBuilder(
      column: $table.selectedDaysOfWeek, builder: (column) => column);

  GeneratedColumn<String> get selectedDaysOfMonth => $composableBuilder(
      column: $table.selectedDaysOfMonth, builder: (column) => column);

  GeneratedColumn<int> get dueDateOffset => $composableBuilder(
      column: $table.dueDateOffset, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<DateTime> get lastGeneratedDate => $composableBuilder(
      column: $table.lastGeneratedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryUuid {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ContactsTableAnnotationComposer get contactUuid {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactUuid,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionSchedulesTable,
    TransactionSchedule,
    $$TransactionSchedulesTableFilterComposer,
    $$TransactionSchedulesTableOrderingComposer,
    $$TransactionSchedulesTableAnnotationComposer,
    $$TransactionSchedulesTableCreateCompanionBuilder,
    $$TransactionSchedulesTableUpdateCompanionBuilder,
    (TransactionSchedule, $$TransactionSchedulesTableReferences),
    TransactionSchedule,
    PrefetchHooks Function({bool categoryUuid, bool contactUuid})> {
  $$TransactionSchedulesTableTableManager(
      _$AppDatabase db, $TransactionSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionSchedulesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionSchedulesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> categoryUuid = const Value.absent(),
            Value<String?> contactUuid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> paidRelationship = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> scheduleType = const Value.absent(),
            Value<String?> selectedDaysOfWeek = const Value.absent(),
            Value<String?> selectedDaysOfMonth = const Value.absent(),
            Value<int?> dueDateOffset = const Value.absent(),
            Value<bool> isPaused = const Value.absent(),
            Value<DateTime?> lastGeneratedDate = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionSchedulesCompanion(
            uuid: uuid,
            amount: amount,
            type: type,
            categoryUuid: categoryUuid,
            contactUuid: contactUuid,
            description: description,
            paidRelationship: paidRelationship,
            dueDate: dueDate,
            scheduleType: scheduleType,
            selectedDaysOfWeek: selectedDaysOfWeek,
            selectedDaysOfMonth: selectedDaysOfMonth,
            dueDateOffset: dueDateOffset,
            isPaused: isPaused,
            lastGeneratedDate: lastGeneratedDate,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required double amount,
            required String type,
            Value<String?> categoryUuid = const Value.absent(),
            Value<String?> contactUuid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> paidRelationship = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            required String scheduleType,
            Value<String?> selectedDaysOfWeek = const Value.absent(),
            Value<String?> selectedDaysOfMonth = const Value.absent(),
            Value<int?> dueDateOffset = const Value.absent(),
            Value<bool> isPaused = const Value.absent(),
            Value<DateTime?> lastGeneratedDate = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionSchedulesCompanion.insert(
            uuid: uuid,
            amount: amount,
            type: type,
            categoryUuid: categoryUuid,
            contactUuid: contactUuid,
            description: description,
            paidRelationship: paidRelationship,
            dueDate: dueDate,
            scheduleType: scheduleType,
            selectedDaysOfWeek: selectedDaysOfWeek,
            selectedDaysOfMonth: selectedDaysOfMonth,
            dueDateOffset: dueDateOffset,
            isPaused: isPaused,
            lastGeneratedDate: lastGeneratedDate,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionSchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryUuid = false, contactUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryUuid,
                    referencedTable: $$TransactionSchedulesTableReferences
                        ._categoryUuidTable(db),
                    referencedColumn: $$TransactionSchedulesTableReferences
                        ._categoryUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable: $$TransactionSchedulesTableReferences
                        ._contactUuidTable(db),
                    referencedColumn: $$TransactionSchedulesTableReferences
                        ._contactUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionSchedulesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TransactionSchedulesTable,
        TransactionSchedule,
        $$TransactionSchedulesTableFilterComposer,
        $$TransactionSchedulesTableOrderingComposer,
        $$TransactionSchedulesTableAnnotationComposer,
        $$TransactionSchedulesTableCreateCompanionBuilder,
        $$TransactionSchedulesTableUpdateCompanionBuilder,
        (TransactionSchedule, $$TransactionSchedulesTableReferences),
        TransactionSchedule,
        PrefetchHooks Function({bool categoryUuid, bool contactUuid})>;
typedef $$SyncMetadataTableCreateCompanionBuilder = SyncMetadataCompanion
    Function({
  required String deviceId,
  Value<int> version,
  Value<int> cloudVersion,
  Value<DateTime?> lastSyncAt,
  Value<String> syncStatus,
  Value<DateTime?> syncStartedAt,
  Value<int> rowid,
});
typedef $$SyncMetadataTableUpdateCompanionBuilder = SyncMetadataCompanion
    Function({
  Value<String> deviceId,
  Value<int> version,
  Value<int> cloudVersion,
  Value<DateTime?> lastSyncAt,
  Value<String> syncStatus,
  Value<DateTime?> syncStartedAt,
  Value<int> rowid,
});

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cloudVersion => $composableBuilder(
      column: $table.cloudVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncStartedAt => $composableBuilder(
      column: $table.syncStartedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cloudVersion => $composableBuilder(
      column: $table.cloudVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncStartedAt => $composableBuilder(
      column: $table.syncStartedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get cloudVersion => $composableBuilder(
      column: $table.cloudVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get syncStartedAt => $composableBuilder(
      column: $table.syncStartedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataData,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataData,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>
    ),
    SyncMetadataData,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> deviceId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> cloudVersion = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> syncStartedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion(
            deviceId: deviceId,
            version: version,
            cloudVersion: cloudVersion,
            lastSyncAt: lastSyncAt,
            syncStatus: syncStatus,
            syncStartedAt: syncStartedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String deviceId,
            Value<int> version = const Value.absent(),
            Value<int> cloudVersion = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> syncStartedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataCompanion.insert(
            deviceId: deviceId,
            version: version,
            cloudVersion: cloudVersion,
            lastSyncAt: lastSyncAt,
            syncStatus: syncStatus,
            syncStartedAt: syncStartedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetadataTable,
    SyncMetadataData,
    $$SyncMetadataTableFilterComposer,
    $$SyncMetadataTableOrderingComposer,
    $$SyncMetadataTableAnnotationComposer,
    $$SyncMetadataTableCreateCompanionBuilder,
    $$SyncMetadataTableUpdateCompanionBuilder,
    (
      SyncMetadataData,
      BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>
    ),
    SyncMetadataData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$ReceivablesTableTableManager get receivables =>
      $$ReceivablesTableTableManager(_db, _db.receivables);
  $$PayablesTableTableManager get payables =>
      $$PayablesTableTableManager(_db, _db.payables);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$WhatsAppQueueTableTableManager get whatsAppQueue =>
      $$WhatsAppQueueTableTableManager(_db, _db.whatsAppQueue);
  $$CategoryUsageStatsTableTableManager get categoryUsageStats =>
      $$CategoryUsageStatsTableTableManager(_db, _db.categoryUsageStats);
  $$ContactUsageStatsTableTableManager get contactUsageStats =>
      $$ContactUsageStatsTableTableManager(_db, _db.contactUsageStats);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$SyncLogTableTableManager get syncLog =>
      $$SyncLogTableTableManager(_db, _db.syncLog);
  $$AppCurrenciesTableTableManager get appCurrencies =>
      $$AppCurrenciesTableTableManager(_db, _db.appCurrencies);
  $$TransactionSchedulesTableTableManager get transactionSchedules =>
      $$TransactionSchedulesTableTableManager(_db, _db.transactionSchedules);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
