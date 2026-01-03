// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
      [id, name, icon, color, type, isDefault, createdAt];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String? icon;
  final String? color;
  final String type;
  final bool isDefault;
  final DateTime createdAt;
  const Category(
      {required this.id,
      required this.name,
      this.icon,
      this.color,
      required this.type,
      required this.isDefault,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['type'] = Variable<String>(type);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      type: Value(type),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      type: serializer.fromJson<String>(json['type']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'type': serializer.toJson<String>(type),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith(
          {int? id,
          String? name,
          Value<String?> icon = const Value.absent(),
          Value<String?> color = const Value.absent(),
          String? type,
          bool? isDefault,
          DateTime? createdAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon.present ? icon.value : this.icon,
        color: color.present ? color.value : this.color,
        type: type ?? this.type,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, color, type, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<String> type;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required String type,
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        type = Value(type);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? type,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? icon,
      Value<String?>? color,
      Value<String>? type,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, phone, email, notes, createdAt, updatedAt];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
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
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Contact(
      {required this.id,
      required this.name,
      this.phone,
      this.email,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
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
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Contact copyWith(
          {int? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, email, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Contact> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ContactsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
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
  static const VerificationMeta _linkedExpenseIdMeta =
      const VerificationMeta('linkedExpenseId');
  @override
  late final GeneratedColumn<int> linkedExpenseId = GeneratedColumn<int>(
      'linked_expense_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _linkedIncomeIdMeta =
      const VerificationMeta('linkedIncomeId');
  @override
  late final GeneratedColumn<int> linkedIncomeId = GeneratedColumn<int>(
      'linked_income_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contactId,
        amount,
        description,
        date,
        dueDate,
        status,
        linkedExpenseId,
        linkedIncomeId,
        autoCreateIncome,
        externalLinkId,
        createdAt,
        updatedAt
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
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
    if (data.containsKey('linked_expense_id')) {
      context.handle(
          _linkedExpenseIdMeta,
          linkedExpenseId.isAcceptableOrUnknown(
              data['linked_expense_id']!, _linkedExpenseIdMeta));
    }
    if (data.containsKey('linked_income_id')) {
      context.handle(
          _linkedIncomeIdMeta,
          linkedIncomeId.isAcceptableOrUnknown(
              data['linked_income_id']!, _linkedIncomeIdMeta));
    }
    if (data.containsKey('auto_create_income')) {
      context.handle(
          _autoCreateIncomeMeta,
          autoCreateIncome.isAcceptableOrUnknown(
              data['auto_create_income']!, _autoCreateIncomeMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Receivable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receivable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
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
      linkedExpenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}linked_expense_id']),
      linkedIncomeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}linked_income_id']),
      autoCreateIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_create_income'])!,
      externalLinkId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_link_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReceivablesTable createAlias(String alias) {
    return $ReceivablesTable(attachedDatabase, alias);
  }
}

class Receivable extends DataClass implements Insertable<Receivable> {
  final int id;
  final int contactId;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final String status;
  final int? linkedExpenseId;
  final int? linkedIncomeId;
  final bool autoCreateIncome;
  final String? externalLinkId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Receivable(
      {required this.id,
      required this.contactId,
      required this.amount,
      this.description,
      required this.date,
      this.dueDate,
      required this.status,
      this.linkedExpenseId,
      this.linkedIncomeId,
      required this.autoCreateIncome,
      this.externalLinkId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || linkedExpenseId != null) {
      map['linked_expense_id'] = Variable<int>(linkedExpenseId);
    }
    if (!nullToAbsent || linkedIncomeId != null) {
      map['linked_income_id'] = Variable<int>(linkedIncomeId);
    }
    map['auto_create_income'] = Variable<bool>(autoCreateIncome);
    if (!nullToAbsent || externalLinkId != null) {
      map['external_link_id'] = Variable<String>(externalLinkId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReceivablesCompanion toCompanion(bool nullToAbsent) {
    return ReceivablesCompanion(
      id: Value(id),
      contactId: Value(contactId),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      linkedExpenseId: linkedExpenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedExpenseId),
      linkedIncomeId: linkedIncomeId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedIncomeId),
      autoCreateIncome: Value(autoCreateIncome),
      externalLinkId: externalLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalLinkId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Receivable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receivable(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int>(json['contactId']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      linkedExpenseId: serializer.fromJson<int?>(json['linkedExpenseId']),
      linkedIncomeId: serializer.fromJson<int?>(json['linkedIncomeId']),
      autoCreateIncome: serializer.fromJson<bool>(json['autoCreateIncome']),
      externalLinkId: serializer.fromJson<String?>(json['externalLinkId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(status),
      'linkedExpenseId': serializer.toJson<int?>(linkedExpenseId),
      'linkedIncomeId': serializer.toJson<int?>(linkedIncomeId),
      'autoCreateIncome': serializer.toJson<bool>(autoCreateIncome),
      'externalLinkId': serializer.toJson<String?>(externalLinkId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Receivable copyWith(
          {int? id,
          int? contactId,
          double? amount,
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<DateTime?> dueDate = const Value.absent(),
          String? status,
          Value<int?> linkedExpenseId = const Value.absent(),
          Value<int?> linkedIncomeId = const Value.absent(),
          bool? autoCreateIncome,
          Value<String?> externalLinkId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Receivable(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        status: status ?? this.status,
        linkedExpenseId: linkedExpenseId.present
            ? linkedExpenseId.value
            : this.linkedExpenseId,
        linkedIncomeId:
            linkedIncomeId.present ? linkedIncomeId.value : this.linkedIncomeId,
        autoCreateIncome: autoCreateIncome ?? this.autoCreateIncome,
        externalLinkId:
            externalLinkId.present ? externalLinkId.value : this.externalLinkId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Receivable(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('linkedExpenseId: $linkedExpenseId, ')
          ..write('linkedIncomeId: $linkedIncomeId, ')
          ..write('autoCreateIncome: $autoCreateIncome, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      contactId,
      amount,
      description,
      date,
      dueDate,
      status,
      linkedExpenseId,
      linkedIncomeId,
      autoCreateIncome,
      externalLinkId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receivable &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.linkedExpenseId == this.linkedExpenseId &&
          other.linkedIncomeId == this.linkedIncomeId &&
          other.autoCreateIncome == this.autoCreateIncome &&
          other.externalLinkId == this.externalLinkId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReceivablesCompanion extends UpdateCompanion<Receivable> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<int?> linkedExpenseId;
  final Value<int?> linkedIncomeId;
  final Value<bool> autoCreateIncome;
  final Value<String?> externalLinkId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ReceivablesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedExpenseId = const Value.absent(),
    this.linkedIncomeId = const Value.absent(),
    this.autoCreateIncome = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReceivablesCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    required double amount,
    this.description = const Value.absent(),
    required DateTime date,
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedExpenseId = const Value.absent(),
    this.linkedIncomeId = const Value.absent(),
    this.autoCreateIncome = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : contactId = Value(contactId),
        amount = Value(amount),
        date = Value(date);
  static Insertable<Receivable> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<int>? linkedExpenseId,
    Expression<int>? linkedIncomeId,
    Expression<bool>? autoCreateIncome,
    Expression<String>? externalLinkId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (linkedExpenseId != null) 'linked_expense_id': linkedExpenseId,
      if (linkedIncomeId != null) 'linked_income_id': linkedIncomeId,
      if (autoCreateIncome != null) 'auto_create_income': autoCreateIncome,
      if (externalLinkId != null) 'external_link_id': externalLinkId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReceivablesCompanion copyWith(
      {Value<int>? id,
      Value<int>? contactId,
      Value<double>? amount,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<DateTime?>? dueDate,
      Value<String>? status,
      Value<int?>? linkedExpenseId,
      Value<int?>? linkedIncomeId,
      Value<bool>? autoCreateIncome,
      Value<String?>? externalLinkId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ReceivablesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      linkedExpenseId: linkedExpenseId ?? this.linkedExpenseId,
      linkedIncomeId: linkedIncomeId ?? this.linkedIncomeId,
      autoCreateIncome: autoCreateIncome ?? this.autoCreateIncome,
      externalLinkId: externalLinkId ?? this.externalLinkId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
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
    if (linkedExpenseId.present) {
      map['linked_expense_id'] = Variable<int>(linkedExpenseId.value);
    }
    if (linkedIncomeId.present) {
      map['linked_income_id'] = Variable<int>(linkedIncomeId.value);
    }
    if (autoCreateIncome.present) {
      map['auto_create_income'] = Variable<bool>(autoCreateIncome.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceivablesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('linkedExpenseId: $linkedExpenseId, ')
          ..write('linkedIncomeId: $linkedIncomeId, ')
          ..write('autoCreateIncome: $autoCreateIncome, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PayablesTable extends Payables with TableInfo<$PayablesTable, Payable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
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
  static const VerificationMeta _linkedExpenseIdMeta =
      const VerificationMeta('linkedExpenseId');
  @override
  late final GeneratedColumn<int> linkedExpenseId = GeneratedColumn<int>(
      'linked_expense_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contactId,
        amount,
        description,
        date,
        dueDate,
        status,
        linkedExpenseId,
        autoCreateExpense,
        externalLinkId,
        createdAt,
        updatedAt
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
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
    if (data.containsKey('linked_expense_id')) {
      context.handle(
          _linkedExpenseIdMeta,
          linkedExpenseId.isAcceptableOrUnknown(
              data['linked_expense_id']!, _linkedExpenseIdMeta));
    }
    if (data.containsKey('auto_create_expense')) {
      context.handle(
          _autoCreateExpenseMeta,
          autoCreateExpense.isAcceptableOrUnknown(
              data['auto_create_expense']!, _autoCreateExpenseMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
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
      linkedExpenseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}linked_expense_id']),
      autoCreateExpense: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_create_expense'])!,
      externalLinkId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_link_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PayablesTable createAlias(String alias) {
    return $PayablesTable(attachedDatabase, alias);
  }
}

class Payable extends DataClass implements Insertable<Payable> {
  final int id;
  final int contactId;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final String status;
  final int? linkedExpenseId;
  final bool autoCreateExpense;
  final String? externalLinkId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Payable(
      {required this.id,
      required this.contactId,
      required this.amount,
      this.description,
      required this.date,
      this.dueDate,
      required this.status,
      this.linkedExpenseId,
      required this.autoCreateExpense,
      this.externalLinkId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || linkedExpenseId != null) {
      map['linked_expense_id'] = Variable<int>(linkedExpenseId);
    }
    map['auto_create_expense'] = Variable<bool>(autoCreateExpense);
    if (!nullToAbsent || externalLinkId != null) {
      map['external_link_id'] = Variable<String>(externalLinkId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PayablesCompanion toCompanion(bool nullToAbsent) {
    return PayablesCompanion(
      id: Value(id),
      contactId: Value(contactId),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      status: Value(status),
      linkedExpenseId: linkedExpenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedExpenseId),
      autoCreateExpense: Value(autoCreateExpense),
      externalLinkId: externalLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalLinkId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Payable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payable(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int>(json['contactId']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      linkedExpenseId: serializer.fromJson<int?>(json['linkedExpenseId']),
      autoCreateExpense: serializer.fromJson<bool>(json['autoCreateExpense']),
      externalLinkId: serializer.fromJson<String?>(json['externalLinkId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'status': serializer.toJson<String>(status),
      'linkedExpenseId': serializer.toJson<int?>(linkedExpenseId),
      'autoCreateExpense': serializer.toJson<bool>(autoCreateExpense),
      'externalLinkId': serializer.toJson<String?>(externalLinkId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Payable copyWith(
          {int? id,
          int? contactId,
          double? amount,
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<DateTime?> dueDate = const Value.absent(),
          String? status,
          Value<int?> linkedExpenseId = const Value.absent(),
          bool? autoCreateExpense,
          Value<String?> externalLinkId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Payable(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        status: status ?? this.status,
        linkedExpenseId: linkedExpenseId.present
            ? linkedExpenseId.value
            : this.linkedExpenseId,
        autoCreateExpense: autoCreateExpense ?? this.autoCreateExpense,
        externalLinkId:
            externalLinkId.present ? externalLinkId.value : this.externalLinkId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Payable(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('linkedExpenseId: $linkedExpenseId, ')
          ..write('autoCreateExpense: $autoCreateExpense, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      contactId,
      amount,
      description,
      date,
      dueDate,
      status,
      linkedExpenseId,
      autoCreateExpense,
      externalLinkId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payable &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.linkedExpenseId == this.linkedExpenseId &&
          other.autoCreateExpense == this.autoCreateExpense &&
          other.externalLinkId == this.externalLinkId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PayablesCompanion extends UpdateCompanion<Payable> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<int?> linkedExpenseId;
  final Value<bool> autoCreateExpense;
  final Value<String?> externalLinkId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PayablesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedExpenseId = const Value.absent(),
    this.autoCreateExpense = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PayablesCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    required double amount,
    this.description = const Value.absent(),
    required DateTime date,
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedExpenseId = const Value.absent(),
    this.autoCreateExpense = const Value.absent(),
    this.externalLinkId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : contactId = Value(contactId),
        amount = Value(amount),
        date = Value(date);
  static Insertable<Payable> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<int>? linkedExpenseId,
    Expression<bool>? autoCreateExpense,
    Expression<String>? externalLinkId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (linkedExpenseId != null) 'linked_expense_id': linkedExpenseId,
      if (autoCreateExpense != null) 'auto_create_expense': autoCreateExpense,
      if (externalLinkId != null) 'external_link_id': externalLinkId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PayablesCompanion copyWith(
      {Value<int>? id,
      Value<int>? contactId,
      Value<double>? amount,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<DateTime?>? dueDate,
      Value<String>? status,
      Value<int?>? linkedExpenseId,
      Value<bool>? autoCreateExpense,
      Value<String?>? externalLinkId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PayablesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      linkedExpenseId: linkedExpenseId ?? this.linkedExpenseId,
      autoCreateExpense: autoCreateExpense ?? this.autoCreateExpense,
      externalLinkId: externalLinkId ?? this.externalLinkId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
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
    if (linkedExpenseId.present) {
      map['linked_expense_id'] = Variable<int>(linkedExpenseId.value);
    }
    if (autoCreateExpense.present) {
      map['auto_create_expense'] = Variable<bool>(autoCreateExpense.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayablesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('linkedExpenseId: $linkedExpenseId, ')
          ..write('autoCreateExpense: $autoCreateExpense, ')
          ..write('externalLinkId: $externalLinkId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
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
  static const VerificationMeta _linkedReceivableIdMeta =
      const VerificationMeta('linkedReceivableId');
  @override
  late final GeneratedColumn<int> linkedReceivableId = GeneratedColumn<int>(
      'linked_receivable_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES receivables (id)'));
  static const VerificationMeta _linkedPayableIdMeta =
      const VerificationMeta('linkedPayableId');
  @override
  late final GeneratedColumn<int> linkedPayableId = GeneratedColumn<int>(
      'linked_payable_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES payables (id)'));
  static const VerificationMeta _paidRelationshipMeta =
      const VerificationMeta('paidRelationship');
  @override
  late final GeneratedColumn<String> paidRelationship = GeneratedColumn<String>(
      'paid_relationship', aliasedName, true,
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        type,
        categoryId,
        contactId,
        description,
        date,
        linkedReceivableId,
        linkedPayableId,
        paidRelationship,
        createdAt,
        updatedAt
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
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
    if (data.containsKey('linked_receivable_id')) {
      context.handle(
          _linkedReceivableIdMeta,
          linkedReceivableId.isAcceptableOrUnknown(
              data['linked_receivable_id']!, _linkedReceivableIdMeta));
    }
    if (data.containsKey('linked_payable_id')) {
      context.handle(
          _linkedPayableIdMeta,
          linkedPayableId.isAcceptableOrUnknown(
              data['linked_payable_id']!, _linkedPayableIdMeta));
    }
    if (data.containsKey('paid_relationship')) {
      context.handle(
          _paidRelationshipMeta,
          paidRelationship.isAcceptableOrUnknown(
              data['paid_relationship']!, _paidRelationshipMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      linkedReceivableId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}linked_receivable_id']),
      linkedPayableId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}linked_payable_id']),
      paidRelationship: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}paid_relationship']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final String type;
  final int? categoryId;
  final int? contactId;
  final String? description;
  final DateTime date;
  final int? linkedReceivableId;
  final int? linkedPayableId;
  final String? paidRelationship;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Transaction(
      {required this.id,
      required this.amount,
      required this.type,
      this.categoryId,
      this.contactId,
      this.description,
      required this.date,
      this.linkedReceivableId,
      this.linkedPayableId,
      this.paidRelationship,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || linkedReceivableId != null) {
      map['linked_receivable_id'] = Variable<int>(linkedReceivableId);
    }
    if (!nullToAbsent || linkedPayableId != null) {
      map['linked_payable_id'] = Variable<int>(linkedPayableId);
    }
    if (!nullToAbsent || paidRelationship != null) {
      map['paid_relationship'] = Variable<String>(paidRelationship);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      linkedReceivableId: linkedReceivableId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedReceivableId),
      linkedPayableId: linkedPayableId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedPayableId),
      paidRelationship: paidRelationship == null && nullToAbsent
          ? const Value.absent()
          : Value(paidRelationship),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      linkedReceivableId: serializer.fromJson<int?>(json['linkedReceivableId']),
      linkedPayableId: serializer.fromJson<int?>(json['linkedPayableId']),
      paidRelationship: serializer.fromJson<String?>(json['paidRelationship']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<int?>(categoryId),
      'contactId': serializer.toJson<int?>(contactId),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'linkedReceivableId': serializer.toJson<int?>(linkedReceivableId),
      'linkedPayableId': serializer.toJson<int?>(linkedPayableId),
      'paidRelationship': serializer.toJson<String?>(paidRelationship),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Transaction copyWith(
          {int? id,
          double? amount,
          String? type,
          Value<int?> categoryId = const Value.absent(),
          Value<int?> contactId = const Value.absent(),
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<int?> linkedReceivableId = const Value.absent(),
          Value<int?> linkedPayableId = const Value.absent(),
          Value<String?> paidRelationship = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Transaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        contactId: contactId.present ? contactId.value : this.contactId,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        linkedReceivableId: linkedReceivableId.present
            ? linkedReceivableId.value
            : this.linkedReceivableId,
        linkedPayableId: linkedPayableId.present
            ? linkedPayableId.value
            : this.linkedPayableId,
        paidRelationship: paidRelationship.present
            ? paidRelationship.value
            : this.paidRelationship,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('contactId: $contactId, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('linkedReceivableId: $linkedReceivableId, ')
          ..write('linkedPayableId: $linkedPayableId, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      amount,
      type,
      categoryId,
      contactId,
      description,
      date,
      linkedReceivableId,
      linkedPayableId,
      paidRelationship,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.contactId == this.contactId &&
          other.description == this.description &&
          other.date == this.date &&
          other.linkedReceivableId == this.linkedReceivableId &&
          other.linkedPayableId == this.linkedPayableId &&
          other.paidRelationship == this.paidRelationship &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> type;
  final Value<int?> categoryId;
  final Value<int?> contactId;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<int?> linkedReceivableId;
  final Value<int?> linkedPayableId;
  final Value<String?> paidRelationship;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.linkedReceivableId = const Value.absent(),
    this.linkedPayableId = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String type,
    this.categoryId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime date,
    this.linkedReceivableId = const Value.absent(),
    this.linkedPayableId = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : amount = Value(amount),
        type = Value(type),
        date = Value(date);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<int>? categoryId,
    Expression<int>? contactId,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<int>? linkedReceivableId,
    Expression<int>? linkedPayableId,
    Expression<String>? paidRelationship,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (contactId != null) 'contact_id': contactId,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (linkedReceivableId != null)
        'linked_receivable_id': linkedReceivableId,
      if (linkedPayableId != null) 'linked_payable_id': linkedPayableId,
      if (paidRelationship != null) 'paid_relationship': paidRelationship,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<String>? type,
      Value<int?>? categoryId,
      Value<int?>? contactId,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<int?>? linkedReceivableId,
      Value<int?>? linkedPayableId,
      Value<String?>? paidRelationship,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      contactId: contactId ?? this.contactId,
      description: description ?? this.description,
      date: date ?? this.date,
      linkedReceivableId: linkedReceivableId ?? this.linkedReceivableId,
      linkedPayableId: linkedPayableId ?? this.linkedPayableId,
      paidRelationship: paidRelationship ?? this.paidRelationship,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (linkedReceivableId.present) {
      map['linked_receivable_id'] = Variable<int>(linkedReceivableId.value);
    }
    if (linkedPayableId.present) {
      map['linked_payable_id'] = Variable<int>(linkedPayableId.value);
    }
    if (paidRelationship.present) {
      map['paid_relationship'] = Variable<String>(paidRelationship.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('contactId: $contactId, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('linkedReceivableId: $linkedReceivableId, ')
          ..write('linkedPayableId: $linkedPayableId, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<int> referenceId = GeneratedColumn<int>(
      'reference_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, referenceId, reminderDate, isTriggered, createdAt];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    } else if (isInserting) {
      context.missing(_referenceIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reference_id'])!,
      reminderDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}reminder_date'])!,
      isTriggered: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_triggered'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final String type;
  final int referenceId;
  final DateTime reminderDate;
  final bool isTriggered;
  final DateTime createdAt;
  const Reminder(
      {required this.id,
      required this.type,
      required this.referenceId,
      required this.reminderDate,
      required this.isTriggered,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['reference_id'] = Variable<int>(referenceId);
    map['reminder_date'] = Variable<DateTime>(reminderDate);
    map['is_triggered'] = Variable<bool>(isTriggered);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      type: Value(type),
      referenceId: Value(referenceId),
      reminderDate: Value(reminderDate),
      isTriggered: Value(isTriggered),
      createdAt: Value(createdAt),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      referenceId: serializer.fromJson<int>(json['referenceId']),
      reminderDate: serializer.fromJson<DateTime>(json['reminderDate']),
      isTriggered: serializer.fromJson<bool>(json['isTriggered']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'referenceId': serializer.toJson<int>(referenceId),
      'reminderDate': serializer.toJson<DateTime>(reminderDate),
      'isTriggered': serializer.toJson<bool>(isTriggered),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Reminder copyWith(
          {int? id,
          String? type,
          int? referenceId,
          DateTime? reminderDate,
          bool? isTriggered,
          DateTime? createdAt}) =>
      Reminder(
        id: id ?? this.id,
        type: type ?? this.type,
        referenceId: referenceId ?? this.referenceId,
        reminderDate: reminderDate ?? this.reminderDate,
        isTriggered: isTriggered ?? this.isTriggered,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('referenceId: $referenceId, ')
          ..write('reminderDate: $reminderDate, ')
          ..write('isTriggered: $isTriggered, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, referenceId, reminderDate, isTriggered, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.type == this.type &&
          other.referenceId == this.referenceId &&
          other.reminderDate == this.reminderDate &&
          other.isTriggered == this.isTriggered &&
          other.createdAt == this.createdAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String> type;
  final Value<int> referenceId;
  final Value<DateTime> reminderDate;
  final Value<bool> isTriggered;
  final Value<DateTime> createdAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.reminderDate = const Value.absent(),
    this.isTriggered = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required int referenceId,
    required DateTime reminderDate,
    this.isTriggered = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : type = Value(type),
        referenceId = Value(referenceId),
        reminderDate = Value(reminderDate);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? referenceId,
    Expression<DateTime>? reminderDate,
    Expression<bool>? isTriggered,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (referenceId != null) 'reference_id': referenceId,
      if (reminderDate != null) 'reminder_date': reminderDate,
      if (isTriggered != null) 'is_triggered': isTriggered,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RemindersCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<int>? referenceId,
      Value<DateTime>? reminderDate,
      Value<bool>? isTriggered,
      Value<DateTime>? createdAt}) {
    return RemindersCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      reminderDate: reminderDate ?? this.reminderDate,
      isTriggered: isTriggered ?? this.isTriggered,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<int>(referenceId.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('referenceId: $referenceId, ')
          ..write('reminderDate: $reminderDate, ')
          ..write('isTriggered: $isTriggered, ')
          ..write('createdAt: $createdAt')
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
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
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
      [id, contactId, message, deepLink, status, createdAt];
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
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
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
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
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
  final int contactId;
  final String message;
  final String? deepLink;
  final String status;
  final DateTime createdAt;
  const WhatsAppQueueData(
      {required this.id,
      required this.contactId,
      required this.message,
      this.deepLink,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
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
      contactId: Value(contactId),
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
      contactId: serializer.fromJson<int>(json['contactId']),
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
      'contactId': serializer.toJson<int>(contactId),
      'message': serializer.toJson<String>(message),
      'deepLink': serializer.toJson<String?>(deepLink),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WhatsAppQueueData copyWith(
          {int? id,
          int? contactId,
          String? message,
          Value<String?> deepLink = const Value.absent(),
          String? status,
          DateTime? createdAt}) =>
      WhatsAppQueueData(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        message: message ?? this.message,
        deepLink: deepLink.present ? deepLink.value : this.deepLink,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('WhatsAppQueueData(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('message: $message, ')
          ..write('deepLink: $deepLink, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contactId, message, deepLink, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WhatsAppQueueData &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.message == this.message &&
          other.deepLink == this.deepLink &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class WhatsAppQueueCompanion extends UpdateCompanion<WhatsAppQueueData> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<String> message;
  final Value<String?> deepLink;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const WhatsAppQueueCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.message = const Value.absent(),
    this.deepLink = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WhatsAppQueueCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    required String message,
    this.deepLink = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : contactId = Value(contactId),
        message = Value(message);
  static Insertable<WhatsAppQueueData> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? message,
    Expression<String>? deepLink,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (message != null) 'message': message,
      if (deepLink != null) 'deep_link': deepLink,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WhatsAppQueueCompanion copyWith(
      {Value<int>? id,
      Value<int>? contactId,
      Value<String>? message,
      Value<String?>? deepLink,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return WhatsAppQueueCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
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
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
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
          ..write('contactId: $contactId, ')
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
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
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
  List<GeneratedColumn> get $columns => [id, categoryId, usageCount, lastUsed];
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
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
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
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
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
  final int categoryId;
  final int usageCount;
  final DateTime? lastUsed;
  const CategoryUsageStat(
      {required this.id,
      required this.categoryId,
      required this.usageCount,
      this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || lastUsed != null) {
      map['last_used'] = Variable<DateTime>(lastUsed);
    }
    return map;
  }

  CategoryUsageStatsCompanion toCompanion(bool nullToAbsent) {
    return CategoryUsageStatsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
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
      categoryId: serializer.fromJson<int>(json['categoryId']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
    };
  }

  CategoryUsageStat copyWith(
          {int? id,
          int? categoryId,
          int? usageCount,
          Value<DateTime?> lastUsed = const Value.absent()}) =>
      CategoryUsageStat(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        usageCount: usageCount ?? this.usageCount,
        lastUsed: lastUsed.present ? lastUsed.value : this.lastUsed,
      );
  @override
  String toString() {
    return (StringBuffer('CategoryUsageStat(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, usageCount, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryUsageStat &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.usageCount == this.usageCount &&
          other.lastUsed == this.lastUsed);
}

class CategoryUsageStatsCompanion extends UpdateCompanion<CategoryUsageStat> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<int> usageCount;
  final Value<DateTime?> lastUsed;
  const CategoryUsageStatsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  CategoryUsageStatsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  }) : categoryId = Value(categoryId);
  static Insertable<CategoryUsageStat> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  CategoryUsageStatsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<int>? usageCount,
      Value<DateTime?>? lastUsed}) {
    return CategoryUsageStatsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
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
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
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
          ..write('categoryId: $categoryId, ')
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
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
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
  List<GeneratedColumn> get $columns => [id, contactId, usageCount, lastUsed];
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
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
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
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
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
  final int contactId;
  final int usageCount;
  final DateTime? lastUsed;
  const ContactUsageStat(
      {required this.id,
      required this.contactId,
      required this.usageCount,
      this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || lastUsed != null) {
      map['last_used'] = Variable<DateTime>(lastUsed);
    }
    return map;
  }

  ContactUsageStatsCompanion toCompanion(bool nullToAbsent) {
    return ContactUsageStatsCompanion(
      id: Value(id),
      contactId: Value(contactId),
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
      contactId: serializer.fromJson<int>(json['contactId']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
    };
  }

  ContactUsageStat copyWith(
          {int? id,
          int? contactId,
          int? usageCount,
          Value<DateTime?> lastUsed = const Value.absent()}) =>
      ContactUsageStat(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        usageCount: usageCount ?? this.usageCount,
        lastUsed: lastUsed.present ? lastUsed.value : this.lastUsed,
      );
  @override
  String toString() {
    return (StringBuffer('ContactUsageStat(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactId, usageCount, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactUsageStat &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.usageCount == this.usageCount &&
          other.lastUsed == this.lastUsed);
}

class ContactUsageStatsCompanion extends UpdateCompanion<ContactUsageStat> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<int> usageCount;
  final Value<DateTime?> lastUsed;
  const ContactUsageStatsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  ContactUsageStatsCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    this.usageCount = const Value.absent(),
    this.lastUsed = const Value.absent(),
  }) : contactId = Value(contactId);
  static Insertable<ContactUsageStat> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  ContactUsageStatsCompanion copyWith(
      {Value<int>? id,
      Value<int>? contactId,
      Value<int>? usageCount,
      Value<DateTime?>? lastUsed}) {
    return ContactUsageStatsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
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
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
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
          ..write('contactId: $contactId, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $ReceivablesTable receivables = $ReceivablesTable(this);
  late final $PayablesTable payables = $PayablesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $WhatsAppQueueTable whatsAppQueue = $WhatsAppQueueTable(this);
  late final $CategoryUsageStatsTable categoryUsageStats =
      $CategoryUsageStatsTable(this);
  late final $ContactUsageStatsTable contactUsageStats =
      $ContactUsageStatsTable(this);
  late final $UserPreferencesTable userPreferences =
      $UserPreferencesTable(this);
  late final $SyncLogTable syncLog = $SyncLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        contacts,
        receivables,
        payables,
        transactions,
        reminders,
        whatsAppQueue,
        categoryUsageStats,
        contactUsageStats,
        userPreferences,
        syncLog
      ];
}
