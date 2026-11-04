// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProductCategoriesTable extends ProductCategories
    with TableInfo<$ProductCategoriesTable, ProductCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductCategoriesTable(this.attachedDatabase, [this._alias]);
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
  List<GeneratedColumn> get $columns =>
      [uuid, name, icon, color, createdAt, updatedAt, isDeleted, isNotSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_categories';
  @override
  VerificationContext validateIntegrity(Insertable<ProductCategory> instance,
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
  ProductCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductCategory(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
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
  $ProductCategoriesTable createAlias(String alias) {
    return $ProductCategoriesTable(attachedDatabase, alias);
  }
}

class ProductCategory extends DataClass implements Insertable<ProductCategory> {
  final String uuid;
  final String name;
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const ProductCategory(
      {required this.uuid,
      required this.name,
      this.icon,
      this.color,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
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
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  ProductCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ProductCategoriesCompanion(
      uuid: Value(uuid),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory ProductCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductCategory(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
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
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  ProductCategory copyWith(
          {String? uuid,
          String? name,
          Value<String?> icon = const Value.absent(),
          Value<String?> color = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      ProductCategory(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        icon: icon.present ? icon.value : this.icon,
        color: color.present ? color.value : this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  ProductCategory copyWithCompanion(ProductCategoriesCompanion data) {
    return ProductCategory(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductCategory(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, name, icon, color, createdAt, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductCategory &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class ProductCategoriesCompanion extends UpdateCompanion<ProductCategory> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const ProductCategoriesCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductCategoriesCompanion.insert({
    required String uuid,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<ProductCategory> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductCategoriesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String?>? icon,
      Value<String?>? color,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return ProductCategoriesCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
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
    return (StringBuffer('ProductCategoriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
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
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCustomerMeta =
      const VerificationMeta('isCustomer');
  @override
  late final GeneratedColumn<bool> isCustomer = GeneratedColumn<bool>(
      'is_customer', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_customer" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isSupplierMeta =
      const VerificationMeta('isSupplier');
  @override
  late final GeneratedColumn<bool> isSupplier = GeneratedColumn<bool>(
      'is_supplier', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_supplier" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _creditLimitMeta =
      const VerificationMeta('creditLimit');
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
      'credit_limit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _taxNumberMeta =
      const VerificationMeta('taxNumber');
  @override
  late final GeneratedColumn<String> taxNumber = GeneratedColumn<String>(
      'tax_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bankAccountMeta =
      const VerificationMeta('bankAccount');
  @override
  late final GeneratedColumn<String> bankAccount = GeneratedColumn<String>(
      'bank_account', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bankIfscMeta =
      const VerificationMeta('bankIfsc');
  @override
  late final GeneratedColumn<String> bankIfsc = GeneratedColumn<String>(
      'bank_ifsc', aliasedName, true,
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
  static const VerificationMeta _addSeqMeta = const VerificationMeta('addSeq');
  @override
  late final GeneratedColumn<int> addSeq = GeneratedColumn<int>(
      'add_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        phone,
        email,
        notes,
        address,
        isCustomer,
        isSupplier,
        creditLimit,
        taxNumber,
        bankName,
        bankAccount,
        bankIfsc,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced,
        addSeq
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
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('is_customer')) {
      context.handle(
          _isCustomerMeta,
          isCustomer.isAcceptableOrUnknown(
              data['is_customer']!, _isCustomerMeta));
    }
    if (data.containsKey('is_supplier')) {
      context.handle(
          _isSupplierMeta,
          isSupplier.isAcceptableOrUnknown(
              data['is_supplier']!, _isSupplierMeta));
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
          _creditLimitMeta,
          creditLimit.isAcceptableOrUnknown(
              data['credit_limit']!, _creditLimitMeta));
    }
    if (data.containsKey('tax_number')) {
      context.handle(_taxNumberMeta,
          taxNumber.isAcceptableOrUnknown(data['tax_number']!, _taxNumberMeta));
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    }
    if (data.containsKey('bank_account')) {
      context.handle(
          _bankAccountMeta,
          bankAccount.isAcceptableOrUnknown(
              data['bank_account']!, _bankAccountMeta));
    }
    if (data.containsKey('bank_ifsc')) {
      context.handle(_bankIfscMeta,
          bankIfsc.isAcceptableOrUnknown(data['bank_ifsc']!, _bankIfscMeta));
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
    if (data.containsKey('add_seq')) {
      context.handle(_addSeqMeta,
          addSeq.isAcceptableOrUnknown(data['add_seq']!, _addSeqMeta));
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
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      isCustomer: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_customer'])!,
      isSupplier: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_supplier'])!,
      creditLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit_limit']),
      taxNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tax_number']),
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name']),
      bankAccount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_account']),
      bankIfsc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_ifsc']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
      addSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}add_seq']),
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
  final String? address;
  final bool isCustomer;
  final bool isSupplier;
  final double? creditLimit;
  final String? taxNumber;
  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  final int? addSeq;
  const Contact(
      {required this.uuid,
      required this.name,
      this.phone,
      this.email,
      this.notes,
      this.address,
      required this.isCustomer,
      required this.isSupplier,
      this.creditLimit,
      this.taxNumber,
      this.bankName,
      this.bankAccount,
      this.bankIfsc,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced,
      this.addSeq});
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
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['is_customer'] = Variable<bool>(isCustomer);
    map['is_supplier'] = Variable<bool>(isSupplier);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    if (!nullToAbsent || taxNumber != null) {
      map['tax_number'] = Variable<String>(taxNumber);
    }
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || bankAccount != null) {
      map['bank_account'] = Variable<String>(bankAccount);
    }
    if (!nullToAbsent || bankIfsc != null) {
      map['bank_ifsc'] = Variable<String>(bankIfsc);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    if (!nullToAbsent || addSeq != null) {
      map['add_seq'] = Variable<int>(addSeq);
    }
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
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      isCustomer: Value(isCustomer),
      isSupplier: Value(isSupplier),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      taxNumber: taxNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(taxNumber),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      bankAccount: bankAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccount),
      bankIfsc: bankIfsc == null && nullToAbsent
          ? const Value.absent()
          : Value(bankIfsc),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
      addSeq:
          addSeq == null && nullToAbsent ? const Value.absent() : Value(addSeq),
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
      address: serializer.fromJson<String?>(json['address']),
      isCustomer: serializer.fromJson<bool>(json['isCustomer']),
      isSupplier: serializer.fromJson<bool>(json['isSupplier']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      taxNumber: serializer.fromJson<String?>(json['taxNumber']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      bankAccount: serializer.fromJson<String?>(json['bankAccount']),
      bankIfsc: serializer.fromJson<String?>(json['bankIfsc']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
      addSeq: serializer.fromJson<int?>(json['addSeq']),
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
      'address': serializer.toJson<String?>(address),
      'isCustomer': serializer.toJson<bool>(isCustomer),
      'isSupplier': serializer.toJson<bool>(isSupplier),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'taxNumber': serializer.toJson<String?>(taxNumber),
      'bankName': serializer.toJson<String?>(bankName),
      'bankAccount': serializer.toJson<String?>(bankAccount),
      'bankIfsc': serializer.toJson<String?>(bankIfsc),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
      'addSeq': serializer.toJson<int?>(addSeq),
    };
  }

  Contact copyWith(
          {String? uuid,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> address = const Value.absent(),
          bool? isCustomer,
          bool? isSupplier,
          Value<double?> creditLimit = const Value.absent(),
          Value<String?> taxNumber = const Value.absent(),
          Value<String?> bankName = const Value.absent(),
          Value<String?> bankAccount = const Value.absent(),
          Value<String?> bankIfsc = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced,
          Value<int?> addSeq = const Value.absent()}) =>
      Contact(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        notes: notes.present ? notes.value : this.notes,
        address: address.present ? address.value : this.address,
        isCustomer: isCustomer ?? this.isCustomer,
        isSupplier: isSupplier ?? this.isSupplier,
        creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
        taxNumber: taxNumber.present ? taxNumber.value : this.taxNumber,
        bankName: bankName.present ? bankName.value : this.bankName,
        bankAccount: bankAccount.present ? bankAccount.value : this.bankAccount,
        bankIfsc: bankIfsc.present ? bankIfsc.value : this.bankIfsc,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
        addSeq: addSeq.present ? addSeq.value : this.addSeq,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
      address: data.address.present ? data.address.value : this.address,
      isCustomer:
          data.isCustomer.present ? data.isCustomer.value : this.isCustomer,
      isSupplier:
          data.isSupplier.present ? data.isSupplier.value : this.isSupplier,
      creditLimit:
          data.creditLimit.present ? data.creditLimit.value : this.creditLimit,
      taxNumber: data.taxNumber.present ? data.taxNumber.value : this.taxNumber,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      bankAccount:
          data.bankAccount.present ? data.bankAccount.value : this.bankAccount,
      bankIfsc: data.bankIfsc.present ? data.bankIfsc.value : this.bankIfsc,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
      addSeq: data.addSeq.present ? data.addSeq.value : this.addSeq,
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
          ..write('address: $address, ')
          ..write('isCustomer: $isCustomer, ')
          ..write('isSupplier: $isSupplier, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('bankName: $bankName, ')
          ..write('bankAccount: $bankAccount, ')
          ..write('bankIfsc: $bankIfsc, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('addSeq: $addSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      name,
      phone,
      email,
      notes,
      address,
      isCustomer,
      isSupplier,
      creditLimit,
      taxNumber,
      bankName,
      bankAccount,
      bankIfsc,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced,
      addSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.address == this.address &&
          other.isCustomer == this.isCustomer &&
          other.isSupplier == this.isSupplier &&
          other.creditLimit == this.creditLimit &&
          other.taxNumber == this.taxNumber &&
          other.bankName == this.bankName &&
          other.bankAccount == this.bankAccount &&
          other.bankIfsc == this.bankIfsc &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced &&
          other.addSeq == this.addSeq);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<String?> address;
  final Value<bool> isCustomer;
  final Value<bool> isSupplier;
  final Value<double?> creditLimit;
  final Value<String?> taxNumber;
  final Value<String?> bankName;
  final Value<String?> bankAccount;
  final Value<String?> bankIfsc;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int?> addSeq;
  final Value<int> rowid;
  const ContactsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.address = const Value.absent(),
    this.isCustomer = const Value.absent(),
    this.isSupplier = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.taxNumber = const Value.absent(),
    this.bankName = const Value.absent(),
    this.bankAccount = const Value.absent(),
    this.bankIfsc = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.addSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String uuid,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.address = const Value.absent(),
    this.isCustomer = const Value.absent(),
    this.isSupplier = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.taxNumber = const Value.absent(),
    this.bankName = const Value.absent(),
    this.bankAccount = const Value.absent(),
    this.bankIfsc = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.addSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Contact> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<String>? address,
    Expression<bool>? isCustomer,
    Expression<bool>? isSupplier,
    Expression<double>? creditLimit,
    Expression<String>? taxNumber,
    Expression<String>? bankName,
    Expression<String>? bankAccount,
    Expression<String>? bankIfsc,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? addSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (address != null) 'address': address,
      if (isCustomer != null) 'is_customer': isCustomer,
      if (isSupplier != null) 'is_supplier': isSupplier,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (taxNumber != null) 'tax_number': taxNumber,
      if (bankName != null) 'bank_name': bankName,
      if (bankAccount != null) 'bank_account': bankAccount,
      if (bankIfsc != null) 'bank_ifsc': bankIfsc,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (addSeq != null) 'add_seq': addSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String?>? notes,
      Value<String?>? address,
      Value<bool>? isCustomer,
      Value<bool>? isSupplier,
      Value<double?>? creditLimit,
      Value<String?>? taxNumber,
      Value<String?>? bankName,
      Value<String?>? bankAccount,
      Value<String?>? bankIfsc,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int?>? addSeq,
      Value<int>? rowid}) {
    return ContactsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      address: address ?? this.address,
      isCustomer: isCustomer ?? this.isCustomer,
      isSupplier: isSupplier ?? this.isSupplier,
      creditLimit: creditLimit ?? this.creditLimit,
      taxNumber: taxNumber ?? this.taxNumber,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      addSeq: addSeq ?? this.addSeq,
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
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (isCustomer.present) {
      map['is_customer'] = Variable<bool>(isCustomer.value);
    }
    if (isSupplier.present) {
      map['is_supplier'] = Variable<bool>(isSupplier.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (taxNumber.present) {
      map['tax_number'] = Variable<String>(taxNumber.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (bankAccount.present) {
      map['bank_account'] = Variable<String>(bankAccount.value);
    }
    if (bankIfsc.present) {
      map['bank_ifsc'] = Variable<String>(bankIfsc.value);
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
    if (addSeq.present) {
      map['add_seq'] = Variable<int>(addSeq.value);
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
          ..write('address: $address, ')
          ..write('isCustomer: $isCustomer, ')
          ..write('isSupplier: $isSupplier, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('taxNumber: $taxNumber, ')
          ..write('bankName: $bankName, ')
          ..write('bankAccount: $bankAccount, ')
          ..write('bankIfsc: $bankIfsc, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('addSeq: $addSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _openingDateMeta =
      const VerificationMeta('openingDate');
  @override
  late final GeneratedColumn<DateTime> openingDate = GeneratedColumn<DateTime>(
      'opening_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
  static const VerificationMeta _creditLimitMeta =
      const VerificationMeta('creditLimit');
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
      'credit_limit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _billingCycleDayMeta =
      const VerificationMeta('billingCycleDay');
  @override
  late final GeneratedColumn<int> billingCycleDay = GeneratedColumn<int>(
      'billing_cycle_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _paymentDueDaysMeta =
      const VerificationMeta('paymentDueDays');
  @override
  late final GeneratedColumn<int> paymentDueDays = GeneratedColumn<int>(
      'payment_due_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _linkedAccountUuidMeta =
      const VerificationMeta('linkedAccountUuid');
  @override
  late final GeneratedColumn<String> linkedAccountUuid =
      GeneratedColumn<String>('linked_account_uuid', aliasedName, true,
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
  static const VerificationMeta _addSeqMeta = const VerificationMeta('addSeq');
  @override
  late final GeneratedColumn<int> addSeq = GeneratedColumn<int>(
      'add_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        type,
        icon,
        color,
        openingBalance,
        openingDate,
        isActive,
        creditLimit,
        billingCycleDay,
        paymentDueDays,
        linkedAccountUuid,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced,
        addSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
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
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    }
    if (data.containsKey('opening_date')) {
      context.handle(
          _openingDateMeta,
          openingDate.isAcceptableOrUnknown(
              data['opening_date']!, _openingDateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
          _creditLimitMeta,
          creditLimit.isAcceptableOrUnknown(
              data['credit_limit']!, _creditLimitMeta));
    }
    if (data.containsKey('billing_cycle_day')) {
      context.handle(
          _billingCycleDayMeta,
          billingCycleDay.isAcceptableOrUnknown(
              data['billing_cycle_day']!, _billingCycleDayMeta));
    }
    if (data.containsKey('payment_due_days')) {
      context.handle(
          _paymentDueDaysMeta,
          paymentDueDays.isAcceptableOrUnknown(
              data['payment_due_days']!, _paymentDueDaysMeta));
    }
    if (data.containsKey('linked_account_uuid')) {
      context.handle(
          _linkedAccountUuidMeta,
          linkedAccountUuid.isAcceptableOrUnknown(
              data['linked_account_uuid']!, _linkedAccountUuidMeta));
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
    if (data.containsKey('add_seq')) {
      context.handle(_addSeqMeta,
          addSeq.isAcceptableOrUnknown(data['add_seq']!, _addSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance'])!,
      openingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}opening_date'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      creditLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit_limit']),
      billingCycleDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}billing_cycle_day']),
      paymentDueDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_due_days']),
      linkedAccountUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_account_uuid']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
      addSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}add_seq']),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String uuid;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final double openingBalance;
  final DateTime openingDate;
  final bool isActive;
  final double? creditLimit;
  final int? billingCycleDay;
  final int? paymentDueDays;
  final String? linkedAccountUuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  final int? addSeq;
  const Account(
      {required this.uuid,
      required this.name,
      required this.type,
      this.icon,
      this.color,
      required this.openingBalance,
      required this.openingDate,
      required this.isActive,
      this.creditLimit,
      this.billingCycleDay,
      this.paymentDueDays,
      this.linkedAccountUuid,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced,
      this.addSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['opening_balance'] = Variable<double>(openingBalance);
    map['opening_date'] = Variable<DateTime>(openingDate);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    if (!nullToAbsent || billingCycleDay != null) {
      map['billing_cycle_day'] = Variable<int>(billingCycleDay);
    }
    if (!nullToAbsent || paymentDueDays != null) {
      map['payment_due_days'] = Variable<int>(paymentDueDays);
    }
    if (!nullToAbsent || linkedAccountUuid != null) {
      map['linked_account_uuid'] = Variable<String>(linkedAccountUuid);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    if (!nullToAbsent || addSeq != null) {
      map['add_seq'] = Variable<int>(addSeq);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      type: Value(type),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      openingBalance: Value(openingBalance),
      openingDate: Value(openingDate),
      isActive: Value(isActive),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      billingCycleDay: billingCycleDay == null && nullToAbsent
          ? const Value.absent()
          : Value(billingCycleDay),
      paymentDueDays: paymentDueDays == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDays),
      linkedAccountUuid: linkedAccountUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAccountUuid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
      addSeq:
          addSeq == null && nullToAbsent ? const Value.absent() : Value(addSeq),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      openingDate: serializer.fromJson<DateTime>(json['openingDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      billingCycleDay: serializer.fromJson<int?>(json['billingCycleDay']),
      paymentDueDays: serializer.fromJson<int?>(json['paymentDueDays']),
      linkedAccountUuid:
          serializer.fromJson<String?>(json['linkedAccountUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
      addSeq: serializer.fromJson<int?>(json['addSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'openingDate': serializer.toJson<DateTime>(openingDate),
      'isActive': serializer.toJson<bool>(isActive),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'billingCycleDay': serializer.toJson<int?>(billingCycleDay),
      'paymentDueDays': serializer.toJson<int?>(paymentDueDays),
      'linkedAccountUuid': serializer.toJson<String?>(linkedAccountUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
      'addSeq': serializer.toJson<int?>(addSeq),
    };
  }

  Account copyWith(
          {String? uuid,
          String? name,
          String? type,
          Value<String?> icon = const Value.absent(),
          Value<String?> color = const Value.absent(),
          double? openingBalance,
          DateTime? openingDate,
          bool? isActive,
          Value<double?> creditLimit = const Value.absent(),
          Value<int?> billingCycleDay = const Value.absent(),
          Value<int?> paymentDueDays = const Value.absent(),
          Value<String?> linkedAccountUuid = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced,
          Value<int?> addSeq = const Value.absent()}) =>
      Account(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        type: type ?? this.type,
        icon: icon.present ? icon.value : this.icon,
        color: color.present ? color.value : this.color,
        openingBalance: openingBalance ?? this.openingBalance,
        openingDate: openingDate ?? this.openingDate,
        isActive: isActive ?? this.isActive,
        creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
        billingCycleDay: billingCycleDay.present
            ? billingCycleDay.value
            : this.billingCycleDay,
        paymentDueDays:
            paymentDueDays.present ? paymentDueDays.value : this.paymentDueDays,
        linkedAccountUuid: linkedAccountUuid.present
            ? linkedAccountUuid.value
            : this.linkedAccountUuid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
        addSeq: addSeq.present ? addSeq.value : this.addSeq,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      openingDate:
          data.openingDate.present ? data.openingDate.value : this.openingDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      creditLimit:
          data.creditLimit.present ? data.creditLimit.value : this.creditLimit,
      billingCycleDay: data.billingCycleDay.present
          ? data.billingCycleDay.value
          : this.billingCycleDay,
      paymentDueDays: data.paymentDueDays.present
          ? data.paymentDueDays.value
          : this.paymentDueDays,
      linkedAccountUuid: data.linkedAccountUuid.present
          ? data.linkedAccountUuid.value
          : this.linkedAccountUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
      addSeq: data.addSeq.present ? data.addSeq.value : this.addSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('openingDate: $openingDate, ')
          ..write('isActive: $isActive, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('billingCycleDay: $billingCycleDay, ')
          ..write('paymentDueDays: $paymentDueDays, ')
          ..write('linkedAccountUuid: $linkedAccountUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('addSeq: $addSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      name,
      type,
      icon,
      color,
      openingBalance,
      openingDate,
      isActive,
      creditLimit,
      billingCycleDay,
      paymentDueDays,
      linkedAccountUuid,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced,
      addSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.openingBalance == this.openingBalance &&
          other.openingDate == this.openingDate &&
          other.isActive == this.isActive &&
          other.creditLimit == this.creditLimit &&
          other.billingCycleDay == this.billingCycleDay &&
          other.paymentDueDays == this.paymentDueDays &&
          other.linkedAccountUuid == this.linkedAccountUuid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced &&
          other.addSeq == this.addSeq);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<double> openingBalance;
  final Value<DateTime> openingDate;
  final Value<bool> isActive;
  final Value<double?> creditLimit;
  final Value<int?> billingCycleDay;
  final Value<int?> paymentDueDays;
  final Value<String?> linkedAccountUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int?> addSeq;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.openingDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.billingCycleDay = const Value.absent(),
    this.paymentDueDays = const Value.absent(),
    this.linkedAccountUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.addSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uuid,
    required String name,
    required String type,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.openingDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.billingCycleDay = const Value.absent(),
    this.paymentDueDays = const Value.absent(),
    this.linkedAccountUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.addSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        type = Value(type);
  static Insertable<Account> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<double>? openingBalance,
    Expression<DateTime>? openingDate,
    Expression<bool>? isActive,
    Expression<double>? creditLimit,
    Expression<int>? billingCycleDay,
    Expression<int>? paymentDueDays,
    Expression<String>? linkedAccountUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? addSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (openingDate != null) 'opening_date': openingDate,
      if (isActive != null) 'is_active': isActive,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (billingCycleDay != null) 'billing_cycle_day': billingCycleDay,
      if (paymentDueDays != null) 'payment_due_days': paymentDueDays,
      if (linkedAccountUuid != null) 'linked_account_uuid': linkedAccountUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (addSeq != null) 'add_seq': addSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? icon,
      Value<String?>? color,
      Value<double>? openingBalance,
      Value<DateTime>? openingDate,
      Value<bool>? isActive,
      Value<double?>? creditLimit,
      Value<int?>? billingCycleDay,
      Value<int?>? paymentDueDays,
      Value<String?>? linkedAccountUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int?>? addSeq,
      Value<int>? rowid}) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      openingBalance: openingBalance ?? this.openingBalance,
      openingDate: openingDate ?? this.openingDate,
      isActive: isActive ?? this.isActive,
      creditLimit: creditLimit ?? this.creditLimit,
      billingCycleDay: billingCycleDay ?? this.billingCycleDay,
      paymentDueDays: paymentDueDays ?? this.paymentDueDays,
      linkedAccountUuid: linkedAccountUuid ?? this.linkedAccountUuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      addSeq: addSeq ?? this.addSeq,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (openingDate.present) {
      map['opening_date'] = Variable<DateTime>(openingDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (billingCycleDay.present) {
      map['billing_cycle_day'] = Variable<int>(billingCycleDay.value);
    }
    if (paymentDueDays.present) {
      map['payment_due_days'] = Variable<int>(paymentDueDays.value);
    }
    if (linkedAccountUuid.present) {
      map['linked_account_uuid'] = Variable<String>(linkedAccountUuid.value);
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
    if (addSeq.present) {
      map['add_seq'] = Variable<int>(addSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('openingDate: $openingDate, ')
          ..write('isActive: $isActive, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('billingCycleDay: $billingCycleDay, ')
          ..write('paymentDueDays: $paymentDueDays, ')
          ..write('linkedAccountUuid: $linkedAccountUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('addSeq: $addSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _orderNumberMeta =
      const VerificationMeta('orderNumber');
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
      'order_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderTypeMeta =
      const VerificationMeta('orderType');
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
      'order_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderDateMeta =
      const VerificationMeta('orderDate');
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
      'order_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _taxAmountMeta =
      const VerificationMeta('taxAmount');
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
      'tax_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('UNPAID'));
  static const VerificationMeta _deliveryStatusMeta =
      const VerificationMeta('deliveryStatus');
  @override
  late final GeneratedColumn<String> deliveryStatus = GeneratedColumn<String>(
      'delivery_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _shippingProviderMeta =
      const VerificationMeta('shippingProvider');
  @override
  late final GeneratedColumn<String> shippingProvider = GeneratedColumn<String>(
      'shipping_provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackingNumberMeta =
      const VerificationMeta('trackingNumber');
  @override
  late final GeneratedColumn<String> trackingNumber = GeneratedColumn<String>(
      'tracking_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deliveredDateMeta =
      const VerificationMeta('deliveredDate');
  @override
  late final GeneratedColumn<DateTime> deliveredDate =
      GeneratedColumn<DateTime>('delivered_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        contactUuid,
        orderNumber,
        orderType,
        orderDate,
        dueDate,
        subtotal,
        discountAmount,
        taxAmount,
        totalAmount,
        paymentStatus,
        deliveryStatus,
        shippingProvider,
        trackingNumber,
        deliveredDate,
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
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<Order> instance,
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
    }
    if (data.containsKey('order_number')) {
      context.handle(
          _orderNumberMeta,
          orderNumber.isAcceptableOrUnknown(
              data['order_number']!, _orderNumberMeta));
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('order_type')) {
      context.handle(_orderTypeMeta,
          orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta));
    } else if (isInserting) {
      context.missing(_orderTypeMeta);
    }
    if (data.containsKey('order_date')) {
      context.handle(_orderDateMeta,
          orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta));
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('tax_amount')) {
      context.handle(_taxAmountMeta,
          taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    }
    if (data.containsKey('delivery_status')) {
      context.handle(
          _deliveryStatusMeta,
          deliveryStatus.isAcceptableOrUnknown(
              data['delivery_status']!, _deliveryStatusMeta));
    }
    if (data.containsKey('shipping_provider')) {
      context.handle(
          _shippingProviderMeta,
          shippingProvider.isAcceptableOrUnknown(
              data['shipping_provider']!, _shippingProviderMeta));
    }
    if (data.containsKey('tracking_number')) {
      context.handle(
          _trackingNumberMeta,
          trackingNumber.isAcceptableOrUnknown(
              data['tracking_number']!, _trackingNumberMeta));
    }
    if (data.containsKey('delivered_date')) {
      context.handle(
          _deliveredDateMeta,
          deliveredDate.isAcceptableOrUnknown(
              data['delivered_date']!, _deliveredDateMeta));
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
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid']),
      orderNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_number'])!,
      orderType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_type'])!,
      orderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}order_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_amount'])!,
      taxAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_amount'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
      deliveryStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}delivery_status'])!,
      shippingProvider: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shipping_provider']),
      trackingNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tracking_number']),
      deliveredDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}delivered_date']),
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
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final String uuid;
  final String? contactUuid;
  final String orderNumber;
  final String orderType;
  final DateTime orderDate;
  final DateTime? dueDate;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentStatus;
  final String deliveryStatus;
  final String? shippingProvider;
  final String? trackingNumber;
  final DateTime? deliveredDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Order(
      {required this.uuid,
      this.contactUuid,
      required this.orderNumber,
      required this.orderType,
      required this.orderDate,
      this.dueDate,
      required this.subtotal,
      required this.discountAmount,
      required this.taxAmount,
      required this.totalAmount,
      required this.paymentStatus,
      required this.deliveryStatus,
      this.shippingProvider,
      this.trackingNumber,
      this.deliveredDate,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || contactUuid != null) {
      map['contact_uuid'] = Variable<String>(contactUuid);
    }
    map['order_number'] = Variable<String>(orderNumber);
    map['order_type'] = Variable<String>(orderType);
    map['order_date'] = Variable<DateTime>(orderDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['delivery_status'] = Variable<String>(deliveryStatus);
    if (!nullToAbsent || shippingProvider != null) {
      map['shipping_provider'] = Variable<String>(shippingProvider);
    }
    if (!nullToAbsent || trackingNumber != null) {
      map['tracking_number'] = Variable<String>(trackingNumber);
    }
    if (!nullToAbsent || deliveredDate != null) {
      map['delivered_date'] = Variable<DateTime>(deliveredDate);
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

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      uuid: Value(uuid),
      contactUuid: contactUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(contactUuid),
      orderNumber: Value(orderNumber),
      orderType: Value(orderType),
      orderDate: Value(orderDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      taxAmount: Value(taxAmount),
      totalAmount: Value(totalAmount),
      paymentStatus: Value(paymentStatus),
      deliveryStatus: Value(deliveryStatus),
      shippingProvider: shippingProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(shippingProvider),
      trackingNumber: trackingNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingNumber),
      deliveredDate: deliveredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Order.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      uuid: serializer.fromJson<String>(json['uuid']),
      contactUuid: serializer.fromJson<String?>(json['contactUuid']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      orderType: serializer.fromJson<String>(json['orderType']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      deliveryStatus: serializer.fromJson<String>(json['deliveryStatus']),
      shippingProvider: serializer.fromJson<String?>(json['shippingProvider']),
      trackingNumber: serializer.fromJson<String?>(json['trackingNumber']),
      deliveredDate: serializer.fromJson<DateTime?>(json['deliveredDate']),
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
      'contactUuid': serializer.toJson<String?>(contactUuid),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'orderType': serializer.toJson<String>(orderType),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'deliveryStatus': serializer.toJson<String>(deliveryStatus),
      'shippingProvider': serializer.toJson<String?>(shippingProvider),
      'trackingNumber': serializer.toJson<String?>(trackingNumber),
      'deliveredDate': serializer.toJson<DateTime?>(deliveredDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Order copyWith(
          {String? uuid,
          Value<String?> contactUuid = const Value.absent(),
          String? orderNumber,
          String? orderType,
          DateTime? orderDate,
          Value<DateTime?> dueDate = const Value.absent(),
          double? subtotal,
          double? discountAmount,
          double? taxAmount,
          double? totalAmount,
          String? paymentStatus,
          String? deliveryStatus,
          Value<String?> shippingProvider = const Value.absent(),
          Value<String?> trackingNumber = const Value.absent(),
          Value<DateTime?> deliveredDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Order(
        uuid: uuid ?? this.uuid,
        contactUuid: contactUuid.present ? contactUuid.value : this.contactUuid,
        orderNumber: orderNumber ?? this.orderNumber,
        orderType: orderType ?? this.orderType,
        orderDate: orderDate ?? this.orderDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        subtotal: subtotal ?? this.subtotal,
        discountAmount: discountAmount ?? this.discountAmount,
        taxAmount: taxAmount ?? this.taxAmount,
        totalAmount: totalAmount ?? this.totalAmount,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        shippingProvider: shippingProvider.present
            ? shippingProvider.value
            : this.shippingProvider,
        trackingNumber:
            trackingNumber.present ? trackingNumber.value : this.trackingNumber,
        deliveredDate:
            deliveredDate.present ? deliveredDate.value : this.deliveredDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      orderNumber:
          data.orderNumber.present ? data.orderNumber.value : this.orderNumber,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      deliveryStatus: data.deliveryStatus.present
          ? data.deliveryStatus.value
          : this.deliveryStatus,
      shippingProvider: data.shippingProvider.present
          ? data.shippingProvider.value
          : this.shippingProvider,
      trackingNumber: data.trackingNumber.present
          ? data.trackingNumber.value
          : this.trackingNumber,
      deliveredDate: data.deliveredDate.present
          ? data.deliveredDate.value
          : this.deliveredDate,
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
    return (StringBuffer('Order(')
          ..write('uuid: $uuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('orderType: $orderType, ')
          ..write('orderDate: $orderDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('shippingProvider: $shippingProvider, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('deliveredDate: $deliveredDate, ')
          ..write('notes: $notes, ')
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
      orderNumber,
      orderType,
      orderDate,
      dueDate,
      subtotal,
      discountAmount,
      taxAmount,
      totalAmount,
      paymentStatus,
      deliveryStatus,
      shippingProvider,
      trackingNumber,
      deliveredDate,
      notes,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.uuid == this.uuid &&
          other.contactUuid == this.contactUuid &&
          other.orderNumber == this.orderNumber &&
          other.orderType == this.orderType &&
          other.orderDate == this.orderDate &&
          other.dueDate == this.dueDate &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.taxAmount == this.taxAmount &&
          other.totalAmount == this.totalAmount &&
          other.paymentStatus == this.paymentStatus &&
          other.deliveryStatus == this.deliveryStatus &&
          other.shippingProvider == this.shippingProvider &&
          other.trackingNumber == this.trackingNumber &&
          other.deliveredDate == this.deliveredDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> uuid;
  final Value<String?> contactUuid;
  final Value<String> orderNumber;
  final Value<String> orderType;
  final Value<DateTime> orderDate;
  final Value<DateTime?> dueDate;
  final Value<double> subtotal;
  final Value<double> discountAmount;
  final Value<double> taxAmount;
  final Value<double> totalAmount;
  final Value<String> paymentStatus;
  final Value<String> deliveryStatus;
  final Value<String?> shippingProvider;
  final Value<String?> trackingNumber;
  final Value<DateTime?> deliveredDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const OrdersCompanion({
    this.uuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.orderType = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.shippingProvider = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.deliveredDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String uuid,
    this.contactUuid = const Value.absent(),
    required String orderNumber,
    required String orderType,
    required DateTime orderDate,
    this.dueDate = const Value.absent(),
    required double subtotal,
    this.discountAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    required double totalAmount,
    this.paymentStatus = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.shippingProvider = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.deliveredDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        orderNumber = Value(orderNumber),
        orderType = Value(orderType),
        orderDate = Value(orderDate),
        subtotal = Value(subtotal),
        totalAmount = Value(totalAmount);
  static Insertable<Order> custom({
    Expression<String>? uuid,
    Expression<String>? contactUuid,
    Expression<String>? orderNumber,
    Expression<String>? orderType,
    Expression<DateTime>? orderDate,
    Expression<DateTime>? dueDate,
    Expression<double>? subtotal,
    Expression<double>? discountAmount,
    Expression<double>? taxAmount,
    Expression<double>? totalAmount,
    Expression<String>? paymentStatus,
    Expression<String>? deliveryStatus,
    Expression<String>? shippingProvider,
    Expression<String>? trackingNumber,
    Expression<DateTime>? deliveredDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (orderNumber != null) 'order_number': orderNumber,
      if (orderType != null) 'order_type': orderType,
      if (orderDate != null) 'order_date': orderDate,
      if (dueDate != null) 'due_date': dueDate,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (deliveryStatus != null) 'delivery_status': deliveryStatus,
      if (shippingProvider != null) 'shipping_provider': shippingProvider,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (deliveredDate != null) 'delivered_date': deliveredDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith(
      {Value<String>? uuid,
      Value<String?>? contactUuid,
      Value<String>? orderNumber,
      Value<String>? orderType,
      Value<DateTime>? orderDate,
      Value<DateTime?>? dueDate,
      Value<double>? subtotal,
      Value<double>? discountAmount,
      Value<double>? taxAmount,
      Value<double>? totalAmount,
      Value<String>? paymentStatus,
      Value<String>? deliveryStatus,
      Value<String?>? shippingProvider,
      Value<String?>? trackingNumber,
      Value<DateTime?>? deliveredDate,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return OrdersCompanion(
      uuid: uuid ?? this.uuid,
      contactUuid: contactUuid ?? this.contactUuid,
      orderNumber: orderNumber ?? this.orderNumber,
      orderType: orderType ?? this.orderType,
      orderDate: orderDate ?? this.orderDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      shippingProvider: shippingProvider ?? this.shippingProvider,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveredDate: deliveredDate ?? this.deliveredDate,
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
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (deliveryStatus.present) {
      map['delivery_status'] = Variable<String>(deliveryStatus.value);
    }
    if (shippingProvider.present) {
      map['shipping_provider'] = Variable<String>(shippingProvider.value);
    }
    if (trackingNumber.present) {
      map['tracking_number'] = Variable<String>(trackingNumber.value);
    }
    if (deliveredDate.present) {
      map['delivered_date'] = Variable<DateTime>(deliveredDate.value);
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
    return (StringBuffer('OrdersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('orderType: $orderType, ')
          ..write('orderDate: $orderDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('shippingProvider: $shippingProvider, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('deliveredDate: $deliveredDate, ')
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
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _orderUuidMeta =
      const VerificationMeta('orderUuid');
  @override
  late final GeneratedColumn<String> orderUuid = GeneratedColumn<String>(
      'order_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (uuid)'));
  static const VerificationMeta _categoryUuidMeta =
      const VerificationMeta('categoryUuid');
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
      'category_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _accountUuidMeta =
      const VerificationMeta('accountUuid');
  @override
  late final GeneratedColumn<String> accountUuid = GeneratedColumn<String>(
      'account_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (uuid)'));
  static const VerificationMeta _processedDateMeta =
      const VerificationMeta('processedDate');
  @override
  late final GeneratedColumn<DateTime> processedDate =
      GeneratedColumn<DateTime>('processed_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('CASH'));
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
        contactUuid,
        orderUuid,
        categoryUuid,
        description,
        date,
        accountUuid,
        processedDate,
        paymentMethod,
        linkedReceivableUuid,
        linkedPayableUuid,
        paidRelationship,
        isAutoGenerated,
        isScheduled,
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
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    }
    if (data.containsKey('order_uuid')) {
      context.handle(_orderUuidMeta,
          orderUuid.isAcceptableOrUnknown(data['order_uuid']!, _orderUuidMeta));
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
          _categoryUuidMeta,
          categoryUuid.isAcceptableOrUnknown(
              data['category_uuid']!, _categoryUuidMeta));
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
    if (data.containsKey('account_uuid')) {
      context.handle(
          _accountUuidMeta,
          accountUuid.isAcceptableOrUnknown(
              data['account_uuid']!, _accountUuidMeta));
    }
    if (data.containsKey('processed_date')) {
      context.handle(
          _processedDateMeta,
          processedDate.isAcceptableOrUnknown(
              data['processed_date']!, _processedDateMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
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
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid']),
      orderUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_uuid']),
      categoryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_uuid']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      accountUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_uuid']),
      processedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}processed_date']),
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
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
  final String? contactUuid;
  final String? orderUuid;
  final String? categoryUuid;
  final String? description;
  final DateTime date;
  final String? accountUuid;
  final DateTime? processedDate;
  final String paymentMethod;
  final String? linkedReceivableUuid;
  final String? linkedPayableUuid;
  final String? paidRelationship;
  final bool isAutoGenerated;
  final bool isScheduled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Transaction(
      {required this.uuid,
      required this.amount,
      required this.type,
      this.contactUuid,
      this.orderUuid,
      this.categoryUuid,
      this.description,
      required this.date,
      this.accountUuid,
      this.processedDate,
      required this.paymentMethod,
      this.linkedReceivableUuid,
      this.linkedPayableUuid,
      this.paidRelationship,
      required this.isAutoGenerated,
      required this.isScheduled,
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
    if (!nullToAbsent || contactUuid != null) {
      map['contact_uuid'] = Variable<String>(contactUuid);
    }
    if (!nullToAbsent || orderUuid != null) {
      map['order_uuid'] = Variable<String>(orderUuid);
    }
    if (!nullToAbsent || categoryUuid != null) {
      map['category_uuid'] = Variable<String>(categoryUuid);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || accountUuid != null) {
      map['account_uuid'] = Variable<String>(accountUuid);
    }
    if (!nullToAbsent || processedDate != null) {
      map['processed_date'] = Variable<DateTime>(processedDate);
    }
    map['payment_method'] = Variable<String>(paymentMethod);
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
      contactUuid: contactUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(contactUuid),
      orderUuid: orderUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(orderUuid),
      categoryUuid: categoryUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryUuid),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      accountUuid: accountUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(accountUuid),
      processedDate: processedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(processedDate),
      paymentMethod: Value(paymentMethod),
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
      contactUuid: serializer.fromJson<String?>(json['contactUuid']),
      orderUuid: serializer.fromJson<String?>(json['orderUuid']),
      categoryUuid: serializer.fromJson<String?>(json['categoryUuid']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      accountUuid: serializer.fromJson<String?>(json['accountUuid']),
      processedDate: serializer.fromJson<DateTime?>(json['processedDate']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      linkedReceivableUuid:
          serializer.fromJson<String?>(json['linkedReceivableUuid']),
      linkedPayableUuid:
          serializer.fromJson<String?>(json['linkedPayableUuid']),
      paidRelationship: serializer.fromJson<String?>(json['paidRelationship']),
      isAutoGenerated: serializer.fromJson<bool>(json['isAutoGenerated']),
      isScheduled: serializer.fromJson<bool>(json['isScheduled']),
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
      'contactUuid': serializer.toJson<String?>(contactUuid),
      'orderUuid': serializer.toJson<String?>(orderUuid),
      'categoryUuid': serializer.toJson<String?>(categoryUuid),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'accountUuid': serializer.toJson<String?>(accountUuid),
      'processedDate': serializer.toJson<DateTime?>(processedDate),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'linkedReceivableUuid': serializer.toJson<String?>(linkedReceivableUuid),
      'linkedPayableUuid': serializer.toJson<String?>(linkedPayableUuid),
      'paidRelationship': serializer.toJson<String?>(paidRelationship),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
      'isScheduled': serializer.toJson<bool>(isScheduled),
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
          Value<String?> contactUuid = const Value.absent(),
          Value<String?> orderUuid = const Value.absent(),
          Value<String?> categoryUuid = const Value.absent(),
          Value<String?> description = const Value.absent(),
          DateTime? date,
          Value<String?> accountUuid = const Value.absent(),
          Value<DateTime?> processedDate = const Value.absent(),
          String? paymentMethod,
          Value<String?> linkedReceivableUuid = const Value.absent(),
          Value<String?> linkedPayableUuid = const Value.absent(),
          Value<String?> paidRelationship = const Value.absent(),
          bool? isAutoGenerated,
          bool? isScheduled,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Transaction(
        uuid: uuid ?? this.uuid,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        contactUuid: contactUuid.present ? contactUuid.value : this.contactUuid,
        orderUuid: orderUuid.present ? orderUuid.value : this.orderUuid,
        categoryUuid:
            categoryUuid.present ? categoryUuid.value : this.categoryUuid,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
        accountUuid: accountUuid.present ? accountUuid.value : this.accountUuid,
        processedDate:
            processedDate.present ? processedDate.value : this.processedDate,
        paymentMethod: paymentMethod ?? this.paymentMethod,
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
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      orderUuid: data.orderUuid.present ? data.orderUuid.value : this.orderUuid,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      accountUuid:
          data.accountUuid.present ? data.accountUuid.value : this.accountUuid,
      processedDate: data.processedDate.present
          ? data.processedDate.value
          : this.processedDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
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
          ..write('contactUuid: $contactUuid, ')
          ..write('orderUuid: $orderUuid, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('processedDate: $processedDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('linkedReceivableUuid: $linkedReceivableUuid, ')
          ..write('linkedPayableUuid: $linkedPayableUuid, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('isScheduled: $isScheduled, ')
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
      contactUuid,
      orderUuid,
      categoryUuid,
      description,
      date,
      accountUuid,
      processedDate,
      paymentMethod,
      linkedReceivableUuid,
      linkedPayableUuid,
      paidRelationship,
      isAutoGenerated,
      isScheduled,
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
          other.contactUuid == this.contactUuid &&
          other.orderUuid == this.orderUuid &&
          other.categoryUuid == this.categoryUuid &&
          other.description == this.description &&
          other.date == this.date &&
          other.accountUuid == this.accountUuid &&
          other.processedDate == this.processedDate &&
          other.paymentMethod == this.paymentMethod &&
          other.linkedReceivableUuid == this.linkedReceivableUuid &&
          other.linkedPayableUuid == this.linkedPayableUuid &&
          other.paidRelationship == this.paidRelationship &&
          other.isAutoGenerated == this.isAutoGenerated &&
          other.isScheduled == this.isScheduled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> uuid;
  final Value<double> amount;
  final Value<String> type;
  final Value<String?> contactUuid;
  final Value<String?> orderUuid;
  final Value<String?> categoryUuid;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<String?> accountUuid;
  final Value<DateTime?> processedDate;
  final Value<String> paymentMethod;
  final Value<String?> linkedReceivableUuid;
  final Value<String?> linkedPayableUuid;
  final Value<String?> paidRelationship;
  final Value<bool> isAutoGenerated;
  final Value<bool> isScheduled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.uuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.orderUuid = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.accountUuid = const Value.absent(),
    this.processedDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.linkedReceivableUuid = const Value.absent(),
    this.linkedPayableUuid = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.isScheduled = const Value.absent(),
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
    this.contactUuid = const Value.absent(),
    this.orderUuid = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime date,
    this.accountUuid = const Value.absent(),
    this.processedDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.linkedReceivableUuid = const Value.absent(),
    this.linkedPayableUuid = const Value.absent(),
    this.paidRelationship = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.isScheduled = const Value.absent(),
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
    Expression<String>? contactUuid,
    Expression<String>? orderUuid,
    Expression<String>? categoryUuid,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<String>? accountUuid,
    Expression<DateTime>? processedDate,
    Expression<String>? paymentMethod,
    Expression<String>? linkedReceivableUuid,
    Expression<String>? linkedPayableUuid,
    Expression<String>? paidRelationship,
    Expression<bool>? isAutoGenerated,
    Expression<bool>? isScheduled,
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
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (orderUuid != null) 'order_uuid': orderUuid,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (processedDate != null) 'processed_date': processedDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (linkedReceivableUuid != null)
        'linked_receivable_uuid': linkedReceivableUuid,
      if (linkedPayableUuid != null) 'linked_payable_uuid': linkedPayableUuid,
      if (paidRelationship != null) 'paid_relationship': paidRelationship,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (isScheduled != null) 'is_scheduled': isScheduled,
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
      Value<String?>? contactUuid,
      Value<String?>? orderUuid,
      Value<String?>? categoryUuid,
      Value<String?>? description,
      Value<DateTime>? date,
      Value<String?>? accountUuid,
      Value<DateTime?>? processedDate,
      Value<String>? paymentMethod,
      Value<String?>? linkedReceivableUuid,
      Value<String?>? linkedPayableUuid,
      Value<String?>? paidRelationship,
      Value<bool>? isAutoGenerated,
      Value<bool>? isScheduled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      uuid: uuid ?? this.uuid,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      contactUuid: contactUuid ?? this.contactUuid,
      orderUuid: orderUuid ?? this.orderUuid,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      description: description ?? this.description,
      date: date ?? this.date,
      accountUuid: accountUuid ?? this.accountUuid,
      processedDate: processedDate ?? this.processedDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      linkedReceivableUuid: linkedReceivableUuid ?? this.linkedReceivableUuid,
      linkedPayableUuid: linkedPayableUuid ?? this.linkedPayableUuid,
      paidRelationship: paidRelationship ?? this.paidRelationship,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      isScheduled: isScheduled ?? this.isScheduled,
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
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (orderUuid.present) {
      map['order_uuid'] = Variable<String>(orderUuid.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (processedDate.present) {
      map['processed_date'] = Variable<DateTime>(processedDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
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
          ..write('contactUuid: $contactUuid, ')
          ..write('orderUuid: $orderUuid, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('processedDate: $processedDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('linkedReceivableUuid: $linkedReceivableUuid, ')
          ..write('linkedPayableUuid: $linkedPayableUuid, ')
          ..write('paidRelationship: $paidRelationship, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('isScheduled: $isScheduled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountTransfersTable extends AccountTransfers
    with TableInfo<$AccountTransfersTable, AccountTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromAccountUuidMeta =
      const VerificationMeta('fromAccountUuid');
  @override
  late final GeneratedColumn<String> fromAccountUuid = GeneratedColumn<String>(
      'from_account_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (uuid)'));
  static const VerificationMeta _toAccountUuidMeta =
      const VerificationMeta('toAccountUuid');
  @override
  late final GeneratedColumn<String> toAccountUuid = GeneratedColumn<String>(
      'to_account_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (uuid)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
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
        fromAccountUuid,
        toAccountUuid,
        amount,
        date,
        description,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_transfers';
  @override
  VerificationContext validateIntegrity(Insertable<AccountTransfer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('from_account_uuid')) {
      context.handle(
          _fromAccountUuidMeta,
          fromAccountUuid.isAcceptableOrUnknown(
              data['from_account_uuid']!, _fromAccountUuidMeta));
    } else if (isInserting) {
      context.missing(_fromAccountUuidMeta);
    }
    if (data.containsKey('to_account_uuid')) {
      context.handle(
          _toAccountUuidMeta,
          toAccountUuid.isAcceptableOrUnknown(
              data['to_account_uuid']!, _toAccountUuidMeta));
    } else if (isInserting) {
      context.missing(_toAccountUuidMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
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
  AccountTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountTransfer(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      fromAccountUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}from_account_uuid'])!,
      toAccountUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}to_account_uuid'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
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
  $AccountTransfersTable createAlias(String alias) {
    return $AccountTransfersTable(attachedDatabase, alias);
  }
}

class AccountTransfer extends DataClass implements Insertable<AccountTransfer> {
  final String uuid;
  final String fromAccountUuid;
  final String toAccountUuid;
  final double amount;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const AccountTransfer(
      {required this.uuid,
      required this.fromAccountUuid,
      required this.toAccountUuid,
      required this.amount,
      required this.date,
      this.description,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['from_account_uuid'] = Variable<String>(fromAccountUuid);
    map['to_account_uuid'] = Variable<String>(toAccountUuid);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  AccountTransfersCompanion toCompanion(bool nullToAbsent) {
    return AccountTransfersCompanion(
      uuid: Value(uuid),
      fromAccountUuid: Value(fromAccountUuid),
      toAccountUuid: Value(toAccountUuid),
      amount: Value(amount),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory AccountTransfer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountTransfer(
      uuid: serializer.fromJson<String>(json['uuid']),
      fromAccountUuid: serializer.fromJson<String>(json['fromAccountUuid']),
      toAccountUuid: serializer.fromJson<String>(json['toAccountUuid']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
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
      'fromAccountUuid': serializer.toJson<String>(fromAccountUuid),
      'toAccountUuid': serializer.toJson<String>(toAccountUuid),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  AccountTransfer copyWith(
          {String? uuid,
          String? fromAccountUuid,
          String? toAccountUuid,
          double? amount,
          DateTime? date,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      AccountTransfer(
        uuid: uuid ?? this.uuid,
        fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
        toAccountUuid: toAccountUuid ?? this.toAccountUuid,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  AccountTransfer copyWithCompanion(AccountTransfersCompanion data) {
    return AccountTransfer(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      fromAccountUuid: data.fromAccountUuid.present
          ? data.fromAccountUuid.value
          : this.fromAccountUuid,
      toAccountUuid: data.toAccountUuid.present
          ? data.toAccountUuid.value
          : this.toAccountUuid,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountTransfer(')
          ..write('uuid: $uuid, ')
          ..write('fromAccountUuid: $fromAccountUuid, ')
          ..write('toAccountUuid: $toAccountUuid, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, fromAccountUuid, toAccountUuid, amount,
      date, description, createdAt, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountTransfer &&
          other.uuid == this.uuid &&
          other.fromAccountUuid == this.fromAccountUuid &&
          other.toAccountUuid == this.toAccountUuid &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class AccountTransfersCompanion extends UpdateCompanion<AccountTransfer> {
  final Value<String> uuid;
  final Value<String> fromAccountUuid;
  final Value<String> toAccountUuid;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const AccountTransfersCompanion({
    this.uuid = const Value.absent(),
    this.fromAccountUuid = const Value.absent(),
    this.toAccountUuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountTransfersCompanion.insert({
    required String uuid,
    required String fromAccountUuid,
    required String toAccountUuid,
    required double amount,
    required DateTime date,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        fromAccountUuid = Value(fromAccountUuid),
        toAccountUuid = Value(toAccountUuid),
        amount = Value(amount),
        date = Value(date);
  static Insertable<AccountTransfer> custom({
    Expression<String>? uuid,
    Expression<String>? fromAccountUuid,
    Expression<String>? toAccountUuid,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (fromAccountUuid != null) 'from_account_uuid': fromAccountUuid,
      if (toAccountUuid != null) 'to_account_uuid': toAccountUuid,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountTransfersCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? fromAccountUuid,
      Value<String>? toAccountUuid,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return AccountTransfersCompanion(
      uuid: uuid ?? this.uuid,
      fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
      toAccountUuid: toAccountUuid ?? this.toAccountUuid,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
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
    if (fromAccountUuid.present) {
      map['from_account_uuid'] = Variable<String>(fromAccountUuid.value);
    }
    if (toAccountUuid.present) {
      map['to_account_uuid'] = Variable<String>(toAccountUuid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
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
    return (StringBuffer('AccountTransfersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('fromAccountUuid: $fromAccountUuid, ')
          ..write('toAccountUuid: $toAccountUuid, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
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
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, key, value, updatedAt, isDeleted, isNotSynced];
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
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
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
  final bool isDeleted;
  final bool isNotSynced;
  const UserPreference(
      {required this.id,
      required this.key,
      required this.value,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
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
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
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
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  UserPreference copyWith(
          {int? id,
          String? key,
          String? value,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      UserPreference(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, key, value, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
    });
  }

  UserPreferencesCompanion copyWith(
      {Value<int>? id,
      Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced}) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isNotSynced: isNotSynced ?? this.isNotSynced,
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
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isNotSynced.present) {
      map['is_not_synced'] = Variable<bool>(isNotSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
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
  static const VerificationMeta _scaleFactorMeta =
      const VerificationMeta('scaleFactor');
  @override
  late final GeneratedColumn<double> scaleFactor = GeneratedColumn<double>(
      'scale_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
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
        scaleFactor,
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
    if (data.containsKey('scale_factor')) {
      context.handle(
          _scaleFactorMeta,
          scaleFactor.isAcceptableOrUnknown(
              data['scale_factor']!, _scaleFactorMeta));
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
      scaleFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scale_factor'])!,
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
  final double scaleFactor;
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
      required this.scaleFactor,
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
    map['scale_factor'] = Variable<double>(scaleFactor);
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
      scaleFactor: Value(scaleFactor),
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
      scaleFactor: serializer.fromJson<double>(json['scaleFactor']),
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
      'scaleFactor': serializer.toJson<double>(scaleFactor),
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
          double? scaleFactor,
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
        scaleFactor: scaleFactor ?? this.scaleFactor,
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
      scaleFactor:
          data.scaleFactor.present ? data.scaleFactor.value : this.scaleFactor,
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
          ..write('scaleFactor: $scaleFactor, ')
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
  int get hashCode => Object.hash(
      uuid,
      name,
      symbol,
      code,
      decimalPlaces,
      scaleFactor,
      isDefault,
      isActive,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppCurrency &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.code == this.code &&
          other.decimalPlaces == this.decimalPlaces &&
          other.scaleFactor == this.scaleFactor &&
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
  final Value<double> scaleFactor;
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
    this.scaleFactor = const Value.absent(),
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
    this.scaleFactor = const Value.absent(),
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
    Expression<double>? scaleFactor,
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
      if (scaleFactor != null) 'scale_factor': scaleFactor,
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
      Value<double>? scaleFactor,
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
      scaleFactor: scaleFactor ?? this.scaleFactor,
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
    if (scaleFactor.present) {
      map['scale_factor'] = Variable<double>(scaleFactor.value);
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
          ..write('scaleFactor: $scaleFactor, ')
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

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryUuidMeta =
      const VerificationMeta('categoryUuid');
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
      'category_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES product_categories (uuid)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pcs'));
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _retailPriceMeta =
      const VerificationMeta('retailPrice');
  @override
  late final GeneratedColumn<double> retailPrice = GeneratedColumn<double>(
      'retail_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _wholesalePriceMeta =
      const VerificationMeta('wholesalePrice');
  @override
  late final GeneratedColumn<double> wholesalePrice = GeneratedColumn<double>(
      'wholesale_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _stockQuantityMeta =
      const VerificationMeta('stockQuantity');
  @override
  late final GeneratedColumn<double> stockQuantity = GeneratedColumn<double>(
      'stock_quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _minStockAlertMeta =
      const VerificationMeta('minStockAlert');
  @override
  late final GeneratedColumn<double> minStockAlert = GeneratedColumn<double>(
      'min_stock_alert', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isServiceMeta =
      const VerificationMeta('isService');
  @override
  late final GeneratedColumn<bool> isService = GeneratedColumn<bool>(
      'is_service', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_service" IN (0, 1))'),
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
        categoryUuid,
        name,
        sku,
        description,
        unit,
        purchasePrice,
        retailPrice,
        wholesalePrice,
        stockQuantity,
        minStockAlert,
        isService,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
          _categoryUuidMeta,
          categoryUuid.isAcceptableOrUnknown(
              data['category_uuid']!, _categoryUuidMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    }
    if (data.containsKey('retail_price')) {
      context.handle(
          _retailPriceMeta,
          retailPrice.isAcceptableOrUnknown(
              data['retail_price']!, _retailPriceMeta));
    }
    if (data.containsKey('wholesale_price')) {
      context.handle(
          _wholesalePriceMeta,
          wholesalePrice.isAcceptableOrUnknown(
              data['wholesale_price']!, _wholesalePriceMeta));
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
          _stockQuantityMeta,
          stockQuantity.isAcceptableOrUnknown(
              data['stock_quantity']!, _stockQuantityMeta));
    }
    if (data.containsKey('min_stock_alert')) {
      context.handle(
          _minStockAlertMeta,
          minStockAlert.isAcceptableOrUnknown(
              data['min_stock_alert']!, _minStockAlertMeta));
    }
    if (data.containsKey('is_service')) {
      context.handle(_isServiceMeta,
          isService.isAcceptableOrUnknown(data['is_service']!, _isServiceMeta));
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
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      categoryUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_uuid']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price'])!,
      retailPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}retail_price'])!,
      wholesalePrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}wholesale_price'])!,
      stockQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stock_quantity'])!,
      minStockAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_stock_alert']),
      isService: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_service'])!,
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
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String uuid;
  final String? categoryUuid;
  final String name;
  final String? sku;
  final String? description;
  final String unit;
  final double purchasePrice;
  final double retailPrice;
  final double wholesalePrice;
  final double stockQuantity;
  final double? minStockAlert;
  final bool isService;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Product(
      {required this.uuid,
      this.categoryUuid,
      required this.name,
      this.sku,
      this.description,
      required this.unit,
      required this.purchasePrice,
      required this.retailPrice,
      required this.wholesalePrice,
      required this.stockQuantity,
      this.minStockAlert,
      required this.isService,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || categoryUuid != null) {
      map['category_uuid'] = Variable<String>(categoryUuid);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['unit'] = Variable<String>(unit);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['retail_price'] = Variable<double>(retailPrice);
    map['wholesale_price'] = Variable<double>(wholesalePrice);
    map['stock_quantity'] = Variable<double>(stockQuantity);
    if (!nullToAbsent || minStockAlert != null) {
      map['min_stock_alert'] = Variable<double>(minStockAlert);
    }
    map['is_service'] = Variable<bool>(isService);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      uuid: Value(uuid),
      categoryUuid: categoryUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryUuid),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      unit: Value(unit),
      purchasePrice: Value(purchasePrice),
      retailPrice: Value(retailPrice),
      wholesalePrice: Value(wholesalePrice),
      stockQuantity: Value(stockQuantity),
      minStockAlert: minStockAlert == null && nullToAbsent
          ? const Value.absent()
          : Value(minStockAlert),
      isService: Value(isService),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      uuid: serializer.fromJson<String>(json['uuid']),
      categoryUuid: serializer.fromJson<String?>(json['categoryUuid']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      description: serializer.fromJson<String?>(json['description']),
      unit: serializer.fromJson<String>(json['unit']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      retailPrice: serializer.fromJson<double>(json['retailPrice']),
      wholesalePrice: serializer.fromJson<double>(json['wholesalePrice']),
      stockQuantity: serializer.fromJson<double>(json['stockQuantity']),
      minStockAlert: serializer.fromJson<double?>(json['minStockAlert']),
      isService: serializer.fromJson<bool>(json['isService']),
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
      'categoryUuid': serializer.toJson<String?>(categoryUuid),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'description': serializer.toJson<String?>(description),
      'unit': serializer.toJson<String>(unit),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'retailPrice': serializer.toJson<double>(retailPrice),
      'wholesalePrice': serializer.toJson<double>(wholesalePrice),
      'stockQuantity': serializer.toJson<double>(stockQuantity),
      'minStockAlert': serializer.toJson<double?>(minStockAlert),
      'isService': serializer.toJson<bool>(isService),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Product copyWith(
          {String? uuid,
          Value<String?> categoryUuid = const Value.absent(),
          String? name,
          Value<String?> sku = const Value.absent(),
          Value<String?> description = const Value.absent(),
          String? unit,
          double? purchasePrice,
          double? retailPrice,
          double? wholesalePrice,
          double? stockQuantity,
          Value<double?> minStockAlert = const Value.absent(),
          bool? isService,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Product(
        uuid: uuid ?? this.uuid,
        categoryUuid:
            categoryUuid.present ? categoryUuid.value : this.categoryUuid,
        name: name ?? this.name,
        sku: sku.present ? sku.value : this.sku,
        description: description.present ? description.value : this.description,
        unit: unit ?? this.unit,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        retailPrice: retailPrice ?? this.retailPrice,
        wholesalePrice: wholesalePrice ?? this.wholesalePrice,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        minStockAlert:
            minStockAlert.present ? minStockAlert.value : this.minStockAlert,
        isService: isService ?? this.isService,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      description:
          data.description.present ? data.description.value : this.description,
      unit: data.unit.present ? data.unit.value : this.unit,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      retailPrice:
          data.retailPrice.present ? data.retailPrice.value : this.retailPrice,
      wholesalePrice: data.wholesalePrice.present
          ? data.wholesalePrice.value
          : this.wholesalePrice,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      minStockAlert: data.minStockAlert.present
          ? data.minStockAlert.value
          : this.minStockAlert,
      isService: data.isService.present ? data.isService.value : this.isService,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('uuid: $uuid, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('description: $description, ')
          ..write('unit: $unit, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('retailPrice: $retailPrice, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('minStockAlert: $minStockAlert, ')
          ..write('isService: $isService, ')
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
      categoryUuid,
      name,
      sku,
      description,
      unit,
      purchasePrice,
      retailPrice,
      wholesalePrice,
      stockQuantity,
      minStockAlert,
      isService,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.uuid == this.uuid &&
          other.categoryUuid == this.categoryUuid &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.description == this.description &&
          other.unit == this.unit &&
          other.purchasePrice == this.purchasePrice &&
          other.retailPrice == this.retailPrice &&
          other.wholesalePrice == this.wholesalePrice &&
          other.stockQuantity == this.stockQuantity &&
          other.minStockAlert == this.minStockAlert &&
          other.isService == this.isService &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> uuid;
  final Value<String?> categoryUuid;
  final Value<String> name;
  final Value<String?> sku;
  final Value<String?> description;
  final Value<String> unit;
  final Value<double> purchasePrice;
  final Value<double> retailPrice;
  final Value<double> wholesalePrice;
  final Value<double> stockQuantity;
  final Value<double?> minStockAlert;
  final Value<bool> isService;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const ProductsCompanion({
    this.uuid = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.description = const Value.absent(),
    this.unit = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.retailPrice = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.minStockAlert = const Value.absent(),
    this.isService = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String uuid,
    this.categoryUuid = const Value.absent(),
    required String name,
    this.sku = const Value.absent(),
    this.description = const Value.absent(),
    this.unit = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.retailPrice = const Value.absent(),
    this.wholesalePrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.minStockAlert = const Value.absent(),
    this.isService = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Product> custom({
    Expression<String>? uuid,
    Expression<String>? categoryUuid,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? description,
    Expression<String>? unit,
    Expression<double>? purchasePrice,
    Expression<double>? retailPrice,
    Expression<double>? wholesalePrice,
    Expression<double>? stockQuantity,
    Expression<double>? minStockAlert,
    Expression<bool>? isService,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (description != null) 'description': description,
      if (unit != null) 'unit': unit,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (retailPrice != null) 'retail_price': retailPrice,
      if (wholesalePrice != null) 'wholesale_price': wholesalePrice,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (minStockAlert != null) 'min_stock_alert': minStockAlert,
      if (isService != null) 'is_service': isService,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? uuid,
      Value<String?>? categoryUuid,
      Value<String>? name,
      Value<String?>? sku,
      Value<String?>? description,
      Value<String>? unit,
      Value<double>? purchasePrice,
      Value<double>? retailPrice,
      Value<double>? wholesalePrice,
      Value<double>? stockQuantity,
      Value<double?>? minStockAlert,
      Value<bool>? isService,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return ProductsCompanion(
      uuid: uuid ?? this.uuid,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      retailPrice: retailPrice ?? this.retailPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      isService: isService ?? this.isService,
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
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (retailPrice.present) {
      map['retail_price'] = Variable<double>(retailPrice.value);
    }
    if (wholesalePrice.present) {
      map['wholesale_price'] = Variable<double>(wholesalePrice.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<double>(stockQuantity.value);
    }
    if (minStockAlert.present) {
      map['min_stock_alert'] = Variable<double>(minStockAlert.value);
    }
    if (isService.present) {
      map['is_service'] = Variable<bool>(isService.value);
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
    return (StringBuffer('ProductsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('description: $description, ')
          ..write('unit: $unit, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('retailPrice: $retailPrice, ')
          ..write('wholesalePrice: $wholesalePrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('minStockAlert: $minStockAlert, ')
          ..write('isService: $isService, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductBatchesTable extends ProductBatches
    with TableInfo<$ProductBatchesTable, ProductBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productUuidMeta =
      const VerificationMeta('productUuid');
  @override
  late final GeneratedColumn<String> productUuid = GeneratedColumn<String>(
      'product_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (uuid)'));
  static const VerificationMeta _batchNumberMeta =
      const VerificationMeta('batchNumber');
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
      'batch_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _totalQuantityMeta =
      const VerificationMeta('totalQuantity');
  @override
  late final GeneratedColumn<double> totalQuantity = GeneratedColumn<double>(
      'total_quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _consumedQuantityMeta =
      const VerificationMeta('consumedQuantity');
  @override
  late final GeneratedColumn<double> consumedQuantity = GeneratedColumn<double>(
      'consumed_quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _effectiveCostMeta =
      const VerificationMeta('effectiveCost');
  @override
  late final GeneratedColumn<double> effectiveCost = GeneratedColumn<double>(
      'effective_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isManualMeta =
      const VerificationMeta('isManual');
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
      'is_manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_manual" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _manualTypeMeta =
      const VerificationMeta('manualType');
  @override
  late final GeneratedColumn<String> manualType = GeneratedColumn<String>(
      'manual_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _retailPriceOverrideMeta =
      const VerificationMeta('retailPriceOverride');
  @override
  late final GeneratedColumn<double> retailPriceOverride =
      GeneratedColumn<double>('retail_price_override', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _wholesalePriceOverrideMeta =
      const VerificationMeta('wholesalePriceOverride');
  @override
  late final GeneratedColumn<double> wholesalePriceOverride =
      GeneratedColumn<double>('wholesale_price_override', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _manufactureDateMeta =
      const VerificationMeta('manufactureDate');
  @override
  late final GeneratedColumn<DateTime> manufactureDate =
      GeneratedColumn<DateTime>('manufacture_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
      'expiry_date', aliasedName, true,
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
        productUuid,
        batchNumber,
        totalQuantity,
        consumedQuantity,
        effectiveCost,
        isManual,
        manualType,
        retailPriceOverride,
        wholesalePriceOverride,
        manufactureDate,
        expiryDate,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_batches';
  @override
  VerificationContext validateIntegrity(Insertable<ProductBatche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('product_uuid')) {
      context.handle(
          _productUuidMeta,
          productUuid.isAcceptableOrUnknown(
              data['product_uuid']!, _productUuidMeta));
    } else if (isInserting) {
      context.missing(_productUuidMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
          _batchNumberMeta,
          batchNumber.isAcceptableOrUnknown(
              data['batch_number']!, _batchNumberMeta));
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('total_quantity')) {
      context.handle(
          _totalQuantityMeta,
          totalQuantity.isAcceptableOrUnknown(
              data['total_quantity']!, _totalQuantityMeta));
    }
    if (data.containsKey('consumed_quantity')) {
      context.handle(
          _consumedQuantityMeta,
          consumedQuantity.isAcceptableOrUnknown(
              data['consumed_quantity']!, _consumedQuantityMeta));
    }
    if (data.containsKey('effective_cost')) {
      context.handle(
          _effectiveCostMeta,
          effectiveCost.isAcceptableOrUnknown(
              data['effective_cost']!, _effectiveCostMeta));
    }
    if (data.containsKey('is_manual')) {
      context.handle(_isManualMeta,
          isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta));
    }
    if (data.containsKey('manual_type')) {
      context.handle(
          _manualTypeMeta,
          manualType.isAcceptableOrUnknown(
              data['manual_type']!, _manualTypeMeta));
    }
    if (data.containsKey('retail_price_override')) {
      context.handle(
          _retailPriceOverrideMeta,
          retailPriceOverride.isAcceptableOrUnknown(
              data['retail_price_override']!, _retailPriceOverrideMeta));
    }
    if (data.containsKey('wholesale_price_override')) {
      context.handle(
          _wholesalePriceOverrideMeta,
          wholesalePriceOverride.isAcceptableOrUnknown(
              data['wholesale_price_override']!, _wholesalePriceOverrideMeta));
    }
    if (data.containsKey('manufacture_date')) {
      context.handle(
          _manufactureDateMeta,
          manufactureDate.isAcceptableOrUnknown(
              data['manufacture_date']!, _manufactureDateMeta));
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
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
  ProductBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductBatche(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      productUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_uuid'])!,
      batchNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_number'])!,
      totalQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_quantity'])!,
      consumedQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}consumed_quantity'])!,
      effectiveCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}effective_cost'])!,
      isManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_manual'])!,
      manualType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manual_type']),
      retailPriceOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}retail_price_override']),
      wholesalePriceOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}wholesale_price_override']),
      manufactureDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}manufacture_date']),
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expiry_date']),
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
  $ProductBatchesTable createAlias(String alias) {
    return $ProductBatchesTable(attachedDatabase, alias);
  }
}

class ProductBatche extends DataClass implements Insertable<ProductBatche> {
  final String uuid;
  final String productUuid;
  final String batchNumber;

  /// Qty received into this lot (purchase / opening / production / adjustment).
  final double totalQuantity;

  /// Qty consumed from this lot (sales, purchase returns, write-offs).
  final double consumedQuantity;

  /// Per-unit cost stamped at receive time; sales use this for COGS.
  final double effectiveCost;
  final bool isManual;

  /// When [isManual]: OPENING | PRODUCTION | ADJUSTMENT. Null for purchase lots.
  final String? manualType;
  final double? retailPriceOverride;
  final double? wholesalePriceOverride;
  final DateTime? manufactureDate;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const ProductBatche(
      {required this.uuid,
      required this.productUuid,
      required this.batchNumber,
      required this.totalQuantity,
      required this.consumedQuantity,
      required this.effectiveCost,
      required this.isManual,
      this.manualType,
      this.retailPriceOverride,
      this.wholesalePriceOverride,
      this.manufactureDate,
      this.expiryDate,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['product_uuid'] = Variable<String>(productUuid);
    map['batch_number'] = Variable<String>(batchNumber);
    map['total_quantity'] = Variable<double>(totalQuantity);
    map['consumed_quantity'] = Variable<double>(consumedQuantity);
    map['effective_cost'] = Variable<double>(effectiveCost);
    map['is_manual'] = Variable<bool>(isManual);
    if (!nullToAbsent || manualType != null) {
      map['manual_type'] = Variable<String>(manualType);
    }
    if (!nullToAbsent || retailPriceOverride != null) {
      map['retail_price_override'] = Variable<double>(retailPriceOverride);
    }
    if (!nullToAbsent || wholesalePriceOverride != null) {
      map['wholesale_price_override'] =
          Variable<double>(wholesalePriceOverride);
    }
    if (!nullToAbsent || manufactureDate != null) {
      map['manufacture_date'] = Variable<DateTime>(manufactureDate);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  ProductBatchesCompanion toCompanion(bool nullToAbsent) {
    return ProductBatchesCompanion(
      uuid: Value(uuid),
      productUuid: Value(productUuid),
      batchNumber: Value(batchNumber),
      totalQuantity: Value(totalQuantity),
      consumedQuantity: Value(consumedQuantity),
      effectiveCost: Value(effectiveCost),
      isManual: Value(isManual),
      manualType: manualType == null && nullToAbsent
          ? const Value.absent()
          : Value(manualType),
      retailPriceOverride: retailPriceOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(retailPriceOverride),
      wholesalePriceOverride: wholesalePriceOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(wholesalePriceOverride),
      manufactureDate: manufactureDate == null && nullToAbsent
          ? const Value.absent()
          : Value(manufactureDate),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory ProductBatche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductBatche(
      uuid: serializer.fromJson<String>(json['uuid']),
      productUuid: serializer.fromJson<String>(json['productUuid']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      totalQuantity: serializer.fromJson<double>(json['totalQuantity']),
      consumedQuantity: serializer.fromJson<double>(json['consumedQuantity']),
      effectiveCost: serializer.fromJson<double>(json['effectiveCost']),
      isManual: serializer.fromJson<bool>(json['isManual']),
      manualType: serializer.fromJson<String?>(json['manualType']),
      retailPriceOverride:
          serializer.fromJson<double?>(json['retailPriceOverride']),
      wholesalePriceOverride:
          serializer.fromJson<double?>(json['wholesalePriceOverride']),
      manufactureDate: serializer.fromJson<DateTime?>(json['manufactureDate']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
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
      'productUuid': serializer.toJson<String>(productUuid),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'totalQuantity': serializer.toJson<double>(totalQuantity),
      'consumedQuantity': serializer.toJson<double>(consumedQuantity),
      'effectiveCost': serializer.toJson<double>(effectiveCost),
      'isManual': serializer.toJson<bool>(isManual),
      'manualType': serializer.toJson<String?>(manualType),
      'retailPriceOverride': serializer.toJson<double?>(retailPriceOverride),
      'wholesalePriceOverride':
          serializer.toJson<double?>(wholesalePriceOverride),
      'manufactureDate': serializer.toJson<DateTime?>(manufactureDate),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  ProductBatche copyWith(
          {String? uuid,
          String? productUuid,
          String? batchNumber,
          double? totalQuantity,
          double? consumedQuantity,
          double? effectiveCost,
          bool? isManual,
          Value<String?> manualType = const Value.absent(),
          Value<double?> retailPriceOverride = const Value.absent(),
          Value<double?> wholesalePriceOverride = const Value.absent(),
          Value<DateTime?> manufactureDate = const Value.absent(),
          Value<DateTime?> expiryDate = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      ProductBatche(
        uuid: uuid ?? this.uuid,
        productUuid: productUuid ?? this.productUuid,
        batchNumber: batchNumber ?? this.batchNumber,
        totalQuantity: totalQuantity ?? this.totalQuantity,
        consumedQuantity: consumedQuantity ?? this.consumedQuantity,
        effectiveCost: effectiveCost ?? this.effectiveCost,
        isManual: isManual ?? this.isManual,
        manualType: manualType.present ? manualType.value : this.manualType,
        retailPriceOverride: retailPriceOverride.present
            ? retailPriceOverride.value
            : this.retailPriceOverride,
        wholesalePriceOverride: wholesalePriceOverride.present
            ? wholesalePriceOverride.value
            : this.wholesalePriceOverride,
        manufactureDate: manufactureDate.present
            ? manufactureDate.value
            : this.manufactureDate,
        expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  ProductBatche copyWithCompanion(ProductBatchesCompanion data) {
    return ProductBatche(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      productUuid:
          data.productUuid.present ? data.productUuid.value : this.productUuid,
      batchNumber:
          data.batchNumber.present ? data.batchNumber.value : this.batchNumber,
      totalQuantity: data.totalQuantity.present
          ? data.totalQuantity.value
          : this.totalQuantity,
      consumedQuantity: data.consumedQuantity.present
          ? data.consumedQuantity.value
          : this.consumedQuantity,
      effectiveCost: data.effectiveCost.present
          ? data.effectiveCost.value
          : this.effectiveCost,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
      manualType:
          data.manualType.present ? data.manualType.value : this.manualType,
      retailPriceOverride: data.retailPriceOverride.present
          ? data.retailPriceOverride.value
          : this.retailPriceOverride,
      wholesalePriceOverride: data.wholesalePriceOverride.present
          ? data.wholesalePriceOverride.value
          : this.wholesalePriceOverride,
      manufactureDate: data.manufactureDate.present
          ? data.manufactureDate.value
          : this.manufactureDate,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductBatche(')
          ..write('uuid: $uuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('consumedQuantity: $consumedQuantity, ')
          ..write('effectiveCost: $effectiveCost, ')
          ..write('isManual: $isManual, ')
          ..write('manualType: $manualType, ')
          ..write('retailPriceOverride: $retailPriceOverride, ')
          ..write('wholesalePriceOverride: $wholesalePriceOverride, ')
          ..write('manufactureDate: $manufactureDate, ')
          ..write('expiryDate: $expiryDate, ')
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
      productUuid,
      batchNumber,
      totalQuantity,
      consumedQuantity,
      effectiveCost,
      isManual,
      manualType,
      retailPriceOverride,
      wholesalePriceOverride,
      manufactureDate,
      expiryDate,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductBatche &&
          other.uuid == this.uuid &&
          other.productUuid == this.productUuid &&
          other.batchNumber == this.batchNumber &&
          other.totalQuantity == this.totalQuantity &&
          other.consumedQuantity == this.consumedQuantity &&
          other.effectiveCost == this.effectiveCost &&
          other.isManual == this.isManual &&
          other.manualType == this.manualType &&
          other.retailPriceOverride == this.retailPriceOverride &&
          other.wholesalePriceOverride == this.wholesalePriceOverride &&
          other.manufactureDate == this.manufactureDate &&
          other.expiryDate == this.expiryDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class ProductBatchesCompanion extends UpdateCompanion<ProductBatche> {
  final Value<String> uuid;
  final Value<String> productUuid;
  final Value<String> batchNumber;
  final Value<double> totalQuantity;
  final Value<double> consumedQuantity;
  final Value<double> effectiveCost;
  final Value<bool> isManual;
  final Value<String?> manualType;
  final Value<double?> retailPriceOverride;
  final Value<double?> wholesalePriceOverride;
  final Value<DateTime?> manufactureDate;
  final Value<DateTime?> expiryDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const ProductBatchesCompanion({
    this.uuid = const Value.absent(),
    this.productUuid = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.totalQuantity = const Value.absent(),
    this.consumedQuantity = const Value.absent(),
    this.effectiveCost = const Value.absent(),
    this.isManual = const Value.absent(),
    this.manualType = const Value.absent(),
    this.retailPriceOverride = const Value.absent(),
    this.wholesalePriceOverride = const Value.absent(),
    this.manufactureDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductBatchesCompanion.insert({
    required String uuid,
    required String productUuid,
    required String batchNumber,
    this.totalQuantity = const Value.absent(),
    this.consumedQuantity = const Value.absent(),
    this.effectiveCost = const Value.absent(),
    this.isManual = const Value.absent(),
    this.manualType = const Value.absent(),
    this.retailPriceOverride = const Value.absent(),
    this.wholesalePriceOverride = const Value.absent(),
    this.manufactureDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        productUuid = Value(productUuid),
        batchNumber = Value(batchNumber);
  static Insertable<ProductBatche> custom({
    Expression<String>? uuid,
    Expression<String>? productUuid,
    Expression<String>? batchNumber,
    Expression<double>? totalQuantity,
    Expression<double>? consumedQuantity,
    Expression<double>? effectiveCost,
    Expression<bool>? isManual,
    Expression<String>? manualType,
    Expression<double>? retailPriceOverride,
    Expression<double>? wholesalePriceOverride,
    Expression<DateTime>? manufactureDate,
    Expression<DateTime>? expiryDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (productUuid != null) 'product_uuid': productUuid,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (totalQuantity != null) 'total_quantity': totalQuantity,
      if (consumedQuantity != null) 'consumed_quantity': consumedQuantity,
      if (effectiveCost != null) 'effective_cost': effectiveCost,
      if (isManual != null) 'is_manual': isManual,
      if (manualType != null) 'manual_type': manualType,
      if (retailPriceOverride != null)
        'retail_price_override': retailPriceOverride,
      if (wholesalePriceOverride != null)
        'wholesale_price_override': wholesalePriceOverride,
      if (manufactureDate != null) 'manufacture_date': manufactureDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductBatchesCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? productUuid,
      Value<String>? batchNumber,
      Value<double>? totalQuantity,
      Value<double>? consumedQuantity,
      Value<double>? effectiveCost,
      Value<bool>? isManual,
      Value<String?>? manualType,
      Value<double?>? retailPriceOverride,
      Value<double?>? wholesalePriceOverride,
      Value<DateTime?>? manufactureDate,
      Value<DateTime?>? expiryDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return ProductBatchesCompanion(
      uuid: uuid ?? this.uuid,
      productUuid: productUuid ?? this.productUuid,
      batchNumber: batchNumber ?? this.batchNumber,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      consumedQuantity: consumedQuantity ?? this.consumedQuantity,
      effectiveCost: effectiveCost ?? this.effectiveCost,
      isManual: isManual ?? this.isManual,
      manualType: manualType ?? this.manualType,
      retailPriceOverride: retailPriceOverride ?? this.retailPriceOverride,
      wholesalePriceOverride:
          wholesalePriceOverride ?? this.wholesalePriceOverride,
      manufactureDate: manufactureDate ?? this.manufactureDate,
      expiryDate: expiryDate ?? this.expiryDate,
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
    if (productUuid.present) {
      map['product_uuid'] = Variable<String>(productUuid.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (totalQuantity.present) {
      map['total_quantity'] = Variable<double>(totalQuantity.value);
    }
    if (consumedQuantity.present) {
      map['consumed_quantity'] = Variable<double>(consumedQuantity.value);
    }
    if (effectiveCost.present) {
      map['effective_cost'] = Variable<double>(effectiveCost.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (manualType.present) {
      map['manual_type'] = Variable<String>(manualType.value);
    }
    if (retailPriceOverride.present) {
      map['retail_price_override'] =
          Variable<double>(retailPriceOverride.value);
    }
    if (wholesalePriceOverride.present) {
      map['wholesale_price_override'] =
          Variable<double>(wholesalePriceOverride.value);
    }
    if (manufactureDate.present) {
      map['manufacture_date'] = Variable<DateTime>(manufactureDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
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
    return (StringBuffer('ProductBatchesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('consumedQuantity: $consumedQuantity, ')
          ..write('effectiveCost: $effectiveCost, ')
          ..write('isManual: $isManual, ')
          ..write('manualType: $manualType, ')
          ..write('retailPriceOverride: $retailPriceOverride, ')
          ..write('wholesalePriceOverride: $wholesalePriceOverride, ')
          ..write('manufactureDate: $manufactureDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderUuidMeta =
      const VerificationMeta('orderUuid');
  @override
  late final GeneratedColumn<String> orderUuid = GeneratedColumn<String>(
      'order_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (uuid)'));
  static const VerificationMeta _productUuidMeta =
      const VerificationMeta('productUuid');
  @override
  late final GeneratedColumn<String> productUuid = GeneratedColumn<String>(
      'product_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (uuid)'));
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>('product_name_snapshot', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountAmountMeta =
      const VerificationMeta('discountAmount');
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
      'discount_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _taxRateMeta =
      const VerificationMeta('taxRate');
  @override
  late final GeneratedColumn<double> taxRate = GeneratedColumn<double>(
      'tax_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _batchUuidMeta =
      const VerificationMeta('batchUuid');
  @override
  late final GeneratedColumn<String> batchUuid = GeneratedColumn<String>(
      'batch_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES product_batches (uuid)'));
  static const VerificationMeta _purchasePriceSnapshotMeta =
      const VerificationMeta('purchasePriceSnapshot');
  @override
  late final GeneratedColumn<double> purchasePriceSnapshot =
      GeneratedColumn<double>('purchase_price_snapshot', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pcs'));
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
        orderUuid,
        productUuid,
        productNameSnapshot,
        quantity,
        unitPrice,
        discountAmount,
        taxRate,
        batchUuid,
        purchasePriceSnapshot,
        unit,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(Insertable<OrderItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('order_uuid')) {
      context.handle(_orderUuidMeta,
          orderUuid.isAcceptableOrUnknown(data['order_uuid']!, _orderUuidMeta));
    } else if (isInserting) {
      context.missing(_orderUuidMeta);
    }
    if (data.containsKey('product_uuid')) {
      context.handle(
          _productUuidMeta,
          productUuid.isAcceptableOrUnknown(
              data['product_uuid']!, _productUuidMeta));
    } else if (isInserting) {
      context.missing(_productUuidMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
          _productNameSnapshotMeta,
          productNameSnapshot.isAcceptableOrUnknown(
              data['product_name_snapshot']!, _productNameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
          _discountAmountMeta,
          discountAmount.isAcceptableOrUnknown(
              data['discount_amount']!, _discountAmountMeta));
    }
    if (data.containsKey('tax_rate')) {
      context.handle(_taxRateMeta,
          taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta));
    }
    if (data.containsKey('batch_uuid')) {
      context.handle(_batchUuidMeta,
          batchUuid.isAcceptableOrUnknown(data['batch_uuid']!, _batchUuidMeta));
    }
    if (data.containsKey('purchase_price_snapshot')) {
      context.handle(
          _purchasePriceSnapshotMeta,
          purchasePriceSnapshot.isAcceptableOrUnknown(
              data['purchase_price_snapshot']!, _purchasePriceSnapshotMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
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
  OrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItem(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      orderUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_uuid'])!,
      productUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_uuid'])!,
      productNameSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}product_name_snapshot'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      discountAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_amount'])!,
      taxRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_rate'])!,
      batchUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_uuid']),
      purchasePriceSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}purchase_price_snapshot'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
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
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItem extends DataClass implements Insertable<OrderItem> {
  final String uuid;
  final String orderUuid;
  final String productUuid;
  final String productNameSnapshot;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxRate;
  final String? batchUuid;
  final double purchasePriceSnapshot;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const OrderItem(
      {required this.uuid,
      required this.orderUuid,
      required this.productUuid,
      required this.productNameSnapshot,
      required this.quantity,
      required this.unitPrice,
      required this.discountAmount,
      required this.taxRate,
      this.batchUuid,
      required this.purchasePriceSnapshot,
      required this.unit,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['order_uuid'] = Variable<String>(orderUuid);
    map['product_uuid'] = Variable<String>(productUuid);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['tax_rate'] = Variable<double>(taxRate);
    if (!nullToAbsent || batchUuid != null) {
      map['batch_uuid'] = Variable<String>(batchUuid);
    }
    map['purchase_price_snapshot'] = Variable<double>(purchasePriceSnapshot);
    map['unit'] = Variable<String>(unit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      uuid: Value(uuid),
      orderUuid: Value(orderUuid),
      productUuid: Value(productUuid),
      productNameSnapshot: Value(productNameSnapshot),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      discountAmount: Value(discountAmount),
      taxRate: Value(taxRate),
      batchUuid: batchUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(batchUuid),
      purchasePriceSnapshot: Value(purchasePriceSnapshot),
      unit: Value(unit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItem(
      uuid: serializer.fromJson<String>(json['uuid']),
      orderUuid: serializer.fromJson<String>(json['orderUuid']),
      productUuid: serializer.fromJson<String>(json['productUuid']),
      productNameSnapshot:
          serializer.fromJson<String>(json['productNameSnapshot']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxRate: serializer.fromJson<double>(json['taxRate']),
      batchUuid: serializer.fromJson<String?>(json['batchUuid']),
      purchasePriceSnapshot:
          serializer.fromJson<double>(json['purchasePriceSnapshot']),
      unit: serializer.fromJson<String>(json['unit']),
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
      'orderUuid': serializer.toJson<String>(orderUuid),
      'productUuid': serializer.toJson<String>(productUuid),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxRate': serializer.toJson<double>(taxRate),
      'batchUuid': serializer.toJson<String?>(batchUuid),
      'purchasePriceSnapshot': serializer.toJson<double>(purchasePriceSnapshot),
      'unit': serializer.toJson<String>(unit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  OrderItem copyWith(
          {String? uuid,
          String? orderUuid,
          String? productUuid,
          String? productNameSnapshot,
          double? quantity,
          double? unitPrice,
          double? discountAmount,
          double? taxRate,
          Value<String?> batchUuid = const Value.absent(),
          double? purchasePriceSnapshot,
          String? unit,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      OrderItem(
        uuid: uuid ?? this.uuid,
        orderUuid: orderUuid ?? this.orderUuid,
        productUuid: productUuid ?? this.productUuid,
        productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        discountAmount: discountAmount ?? this.discountAmount,
        taxRate: taxRate ?? this.taxRate,
        batchUuid: batchUuid.present ? batchUuid.value : this.batchUuid,
        purchasePriceSnapshot:
            purchasePriceSnapshot ?? this.purchasePriceSnapshot,
        unit: unit ?? this.unit,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  OrderItem copyWithCompanion(OrderItemsCompanion data) {
    return OrderItem(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      orderUuid: data.orderUuid.present ? data.orderUuid.value : this.orderUuid,
      productUuid:
          data.productUuid.present ? data.productUuid.value : this.productUuid,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
      batchUuid: data.batchUuid.present ? data.batchUuid.value : this.batchUuid,
      purchasePriceSnapshot: data.purchasePriceSnapshot.present
          ? data.purchasePriceSnapshot.value
          : this.purchasePriceSnapshot,
      unit: data.unit.present ? data.unit.value : this.unit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItem(')
          ..write('uuid: $uuid, ')
          ..write('orderUuid: $orderUuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxRate: $taxRate, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('purchasePriceSnapshot: $purchasePriceSnapshot, ')
          ..write('unit: $unit, ')
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
      orderUuid,
      productUuid,
      productNameSnapshot,
      quantity,
      unitPrice,
      discountAmount,
      taxRate,
      batchUuid,
      purchasePriceSnapshot,
      unit,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItem &&
          other.uuid == this.uuid &&
          other.orderUuid == this.orderUuid &&
          other.productUuid == this.productUuid &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.discountAmount == this.discountAmount &&
          other.taxRate == this.taxRate &&
          other.batchUuid == this.batchUuid &&
          other.purchasePriceSnapshot == this.purchasePriceSnapshot &&
          other.unit == this.unit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItem> {
  final Value<String> uuid;
  final Value<String> orderUuid;
  final Value<String> productUuid;
  final Value<String> productNameSnapshot;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> discountAmount;
  final Value<double> taxRate;
  final Value<String?> batchUuid;
  final Value<double> purchasePriceSnapshot;
  final Value<String> unit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const OrderItemsCompanion({
    this.uuid = const Value.absent(),
    this.orderUuid = const Value.absent(),
    this.productUuid = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.batchUuid = const Value.absent(),
    this.purchasePriceSnapshot = const Value.absent(),
    this.unit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    required String uuid,
    required String orderUuid,
    required String productUuid,
    required String productNameSnapshot,
    required double quantity,
    required double unitPrice,
    this.discountAmount = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.batchUuid = const Value.absent(),
    this.purchasePriceSnapshot = const Value.absent(),
    this.unit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        orderUuid = Value(orderUuid),
        productUuid = Value(productUuid),
        productNameSnapshot = Value(productNameSnapshot),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice);
  static Insertable<OrderItem> custom({
    Expression<String>? uuid,
    Expression<String>? orderUuid,
    Expression<String>? productUuid,
    Expression<String>? productNameSnapshot,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? discountAmount,
    Expression<double>? taxRate,
    Expression<String>? batchUuid,
    Expression<double>? purchasePriceSnapshot,
    Expression<String>? unit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (orderUuid != null) 'order_uuid': orderUuid,
      if (productUuid != null) 'product_uuid': productUuid,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxRate != null) 'tax_rate': taxRate,
      if (batchUuid != null) 'batch_uuid': batchUuid,
      if (purchasePriceSnapshot != null)
        'purchase_price_snapshot': purchasePriceSnapshot,
      if (unit != null) 'unit': unit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? orderUuid,
      Value<String>? productUuid,
      Value<String>? productNameSnapshot,
      Value<double>? quantity,
      Value<double>? unitPrice,
      Value<double>? discountAmount,
      Value<double>? taxRate,
      Value<String?>? batchUuid,
      Value<double>? purchasePriceSnapshot,
      Value<String>? unit,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return OrderItemsCompanion(
      uuid: uuid ?? this.uuid,
      orderUuid: orderUuid ?? this.orderUuid,
      productUuid: productUuid ?? this.productUuid,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      batchUuid: batchUuid ?? this.batchUuid,
      purchasePriceSnapshot:
          purchasePriceSnapshot ?? this.purchasePriceSnapshot,
      unit: unit ?? this.unit,
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
    if (orderUuid.present) {
      map['order_uuid'] = Variable<String>(orderUuid.value);
    }
    if (productUuid.present) {
      map['product_uuid'] = Variable<String>(productUuid.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] =
          Variable<String>(productNameSnapshot.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxRate.present) {
      map['tax_rate'] = Variable<double>(taxRate.value);
    }
    if (batchUuid.present) {
      map['batch_uuid'] = Variable<String>(batchUuid.value);
    }
    if (purchasePriceSnapshot.present) {
      map['purchase_price_snapshot'] =
          Variable<double>(purchasePriceSnapshot.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
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
    return (StringBuffer('OrderItemsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('orderUuid: $orderUuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxRate: $taxRate, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('purchasePriceSnapshot: $purchasePriceSnapshot, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderReturnsTable extends OrderReturns
    with TableInfo<$OrderReturnsTable, OrderReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderUuidMeta =
      const VerificationMeta('orderUuid');
  @override
  late final GeneratedColumn<String> orderUuid = GeneratedColumn<String>(
      'order_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (uuid)'));
  static const VerificationMeta _returnNumberMeta =
      const VerificationMeta('returnNumber');
  @override
  late final GeneratedColumn<String> returnNumber = GeneratedColumn<String>(
      'return_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderTypeMeta =
      const VerificationMeta('orderType');
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
      'order_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalRefundAmountMeta =
      const VerificationMeta('totalRefundAmount');
  @override
  late final GeneratedColumn<double> totalRefundAmount =
      GeneratedColumn<double>('total_refund_amount', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
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
        orderUuid,
        returnNumber,
        orderType,
        contactUuid,
        date,
        totalRefundAmount,
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
  static const String $name = 'order_returns';
  @override
  VerificationContext validateIntegrity(Insertable<OrderReturn> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('order_uuid')) {
      context.handle(_orderUuidMeta,
          orderUuid.isAcceptableOrUnknown(data['order_uuid']!, _orderUuidMeta));
    } else if (isInserting) {
      context.missing(_orderUuidMeta);
    }
    if (data.containsKey('return_number')) {
      context.handle(
          _returnNumberMeta,
          returnNumber.isAcceptableOrUnknown(
              data['return_number']!, _returnNumberMeta));
    } else if (isInserting) {
      context.missing(_returnNumberMeta);
    }
    if (data.containsKey('order_type')) {
      context.handle(_orderTypeMeta,
          orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta));
    } else if (isInserting) {
      context.missing(_orderTypeMeta);
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_refund_amount')) {
      context.handle(
          _totalRefundAmountMeta,
          totalRefundAmount.isAcceptableOrUnknown(
              data['total_refund_amount']!, _totalRefundAmountMeta));
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
  OrderReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderReturn(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      orderUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_uuid'])!,
      returnNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}return_number'])!,
      orderType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_type'])!,
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      totalRefundAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_refund_amount'])!,
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
  $OrderReturnsTable createAlias(String alias) {
    return $OrderReturnsTable(attachedDatabase, alias);
  }
}

class OrderReturn extends DataClass implements Insertable<OrderReturn> {
  final String uuid;
  final String orderUuid;
  final String returnNumber;
  final String orderType;
  final String? contactUuid;
  final DateTime date;
  final double totalRefundAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const OrderReturn(
      {required this.uuid,
      required this.orderUuid,
      required this.returnNumber,
      required this.orderType,
      this.contactUuid,
      required this.date,
      required this.totalRefundAmount,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['order_uuid'] = Variable<String>(orderUuid);
    map['return_number'] = Variable<String>(returnNumber);
    map['order_type'] = Variable<String>(orderType);
    if (!nullToAbsent || contactUuid != null) {
      map['contact_uuid'] = Variable<String>(contactUuid);
    }
    map['date'] = Variable<DateTime>(date);
    map['total_refund_amount'] = Variable<double>(totalRefundAmount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  OrderReturnsCompanion toCompanion(bool nullToAbsent) {
    return OrderReturnsCompanion(
      uuid: Value(uuid),
      orderUuid: Value(orderUuid),
      returnNumber: Value(returnNumber),
      orderType: Value(orderType),
      contactUuid: contactUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(contactUuid),
      date: Value(date),
      totalRefundAmount: Value(totalRefundAmount),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory OrderReturn.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderReturn(
      uuid: serializer.fromJson<String>(json['uuid']),
      orderUuid: serializer.fromJson<String>(json['orderUuid']),
      returnNumber: serializer.fromJson<String>(json['returnNumber']),
      orderType: serializer.fromJson<String>(json['orderType']),
      contactUuid: serializer.fromJson<String?>(json['contactUuid']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalRefundAmount: serializer.fromJson<double>(json['totalRefundAmount']),
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
      'orderUuid': serializer.toJson<String>(orderUuid),
      'returnNumber': serializer.toJson<String>(returnNumber),
      'orderType': serializer.toJson<String>(orderType),
      'contactUuid': serializer.toJson<String?>(contactUuid),
      'date': serializer.toJson<DateTime>(date),
      'totalRefundAmount': serializer.toJson<double>(totalRefundAmount),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  OrderReturn copyWith(
          {String? uuid,
          String? orderUuid,
          String? returnNumber,
          String? orderType,
          Value<String?> contactUuid = const Value.absent(),
          DateTime? date,
          double? totalRefundAmount,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      OrderReturn(
        uuid: uuid ?? this.uuid,
        orderUuid: orderUuid ?? this.orderUuid,
        returnNumber: returnNumber ?? this.returnNumber,
        orderType: orderType ?? this.orderType,
        contactUuid: contactUuid.present ? contactUuid.value : this.contactUuid,
        date: date ?? this.date,
        totalRefundAmount: totalRefundAmount ?? this.totalRefundAmount,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  OrderReturn copyWithCompanion(OrderReturnsCompanion data) {
    return OrderReturn(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      orderUuid: data.orderUuid.present ? data.orderUuid.value : this.orderUuid,
      returnNumber: data.returnNumber.present
          ? data.returnNumber.value
          : this.returnNumber,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      date: data.date.present ? data.date.value : this.date,
      totalRefundAmount: data.totalRefundAmount.present
          ? data.totalRefundAmount.value
          : this.totalRefundAmount,
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
    return (StringBuffer('OrderReturn(')
          ..write('uuid: $uuid, ')
          ..write('orderUuid: $orderUuid, ')
          ..write('returnNumber: $returnNumber, ')
          ..write('orderType: $orderType, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('date: $date, ')
          ..write('totalRefundAmount: $totalRefundAmount, ')
          ..write('notes: $notes, ')
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
      orderUuid,
      returnNumber,
      orderType,
      contactUuid,
      date,
      totalRefundAmount,
      notes,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderReturn &&
          other.uuid == this.uuid &&
          other.orderUuid == this.orderUuid &&
          other.returnNumber == this.returnNumber &&
          other.orderType == this.orderType &&
          other.contactUuid == this.contactUuid &&
          other.date == this.date &&
          other.totalRefundAmount == this.totalRefundAmount &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class OrderReturnsCompanion extends UpdateCompanion<OrderReturn> {
  final Value<String> uuid;
  final Value<String> orderUuid;
  final Value<String> returnNumber;
  final Value<String> orderType;
  final Value<String?> contactUuid;
  final Value<DateTime> date;
  final Value<double> totalRefundAmount;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const OrderReturnsCompanion({
    this.uuid = const Value.absent(),
    this.orderUuid = const Value.absent(),
    this.returnNumber = const Value.absent(),
    this.orderType = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.date = const Value.absent(),
    this.totalRefundAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderReturnsCompanion.insert({
    required String uuid,
    required String orderUuid,
    required String returnNumber,
    required String orderType,
    this.contactUuid = const Value.absent(),
    required DateTime date,
    this.totalRefundAmount = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        orderUuid = Value(orderUuid),
        returnNumber = Value(returnNumber),
        orderType = Value(orderType),
        date = Value(date);
  static Insertable<OrderReturn> custom({
    Expression<String>? uuid,
    Expression<String>? orderUuid,
    Expression<String>? returnNumber,
    Expression<String>? orderType,
    Expression<String>? contactUuid,
    Expression<DateTime>? date,
    Expression<double>? totalRefundAmount,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (orderUuid != null) 'order_uuid': orderUuid,
      if (returnNumber != null) 'return_number': returnNumber,
      if (orderType != null) 'order_type': orderType,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (date != null) 'date': date,
      if (totalRefundAmount != null) 'total_refund_amount': totalRefundAmount,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderReturnsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? orderUuid,
      Value<String>? returnNumber,
      Value<String>? orderType,
      Value<String?>? contactUuid,
      Value<DateTime>? date,
      Value<double>? totalRefundAmount,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return OrderReturnsCompanion(
      uuid: uuid ?? this.uuid,
      orderUuid: orderUuid ?? this.orderUuid,
      returnNumber: returnNumber ?? this.returnNumber,
      orderType: orderType ?? this.orderType,
      contactUuid: contactUuid ?? this.contactUuid,
      date: date ?? this.date,
      totalRefundAmount: totalRefundAmount ?? this.totalRefundAmount,
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
    if (orderUuid.present) {
      map['order_uuid'] = Variable<String>(orderUuid.value);
    }
    if (returnNumber.present) {
      map['return_number'] = Variable<String>(returnNumber.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalRefundAmount.present) {
      map['total_refund_amount'] = Variable<double>(totalRefundAmount.value);
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
    return (StringBuffer('OrderReturnsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('orderUuid: $orderUuid, ')
          ..write('returnNumber: $returnNumber, ')
          ..write('orderType: $orderType, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('date: $date, ')
          ..write('totalRefundAmount: $totalRefundAmount, ')
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

class $OrderReturnItemsTable extends OrderReturnItems
    with TableInfo<$OrderReturnItemsTable, OrderReturnItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderReturnItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _returnUuidMeta =
      const VerificationMeta('returnUuid');
  @override
  late final GeneratedColumn<String> returnUuid = GeneratedColumn<String>(
      'return_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES order_returns (uuid)'));
  static const VerificationMeta _productUuidMeta =
      const VerificationMeta('productUuid');
  @override
  late final GeneratedColumn<String> productUuid = GeneratedColumn<String>(
      'product_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (uuid)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _refundUnitPriceMeta =
      const VerificationMeta('refundUnitPrice');
  @override
  late final GeneratedColumn<double> refundUnitPrice = GeneratedColumn<double>(
      'refund_unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _batchUuidMeta =
      const VerificationMeta('batchUuid');
  @override
  late final GeneratedColumn<String> batchUuid = GeneratedColumn<String>(
      'batch_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES product_batches (uuid)'));
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
        returnUuid,
        productUuid,
        quantity,
        refundUnitPrice,
        batchUuid,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_return_items';
  @override
  VerificationContext validateIntegrity(Insertable<OrderReturnItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('return_uuid')) {
      context.handle(
          _returnUuidMeta,
          returnUuid.isAcceptableOrUnknown(
              data['return_uuid']!, _returnUuidMeta));
    } else if (isInserting) {
      context.missing(_returnUuidMeta);
    }
    if (data.containsKey('product_uuid')) {
      context.handle(
          _productUuidMeta,
          productUuid.isAcceptableOrUnknown(
              data['product_uuid']!, _productUuidMeta));
    } else if (isInserting) {
      context.missing(_productUuidMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('refund_unit_price')) {
      context.handle(
          _refundUnitPriceMeta,
          refundUnitPrice.isAcceptableOrUnknown(
              data['refund_unit_price']!, _refundUnitPriceMeta));
    } else if (isInserting) {
      context.missing(_refundUnitPriceMeta);
    }
    if (data.containsKey('batch_uuid')) {
      context.handle(_batchUuidMeta,
          batchUuid.isAcceptableOrUnknown(data['batch_uuid']!, _batchUuidMeta));
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
  OrderReturnItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderReturnItem(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      returnUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}return_uuid'])!,
      productUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_uuid'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      refundUnitPrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}refund_unit_price'])!,
      batchUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_uuid']),
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
  $OrderReturnItemsTable createAlias(String alias) {
    return $OrderReturnItemsTable(attachedDatabase, alias);
  }
}

class OrderReturnItem extends DataClass implements Insertable<OrderReturnItem> {
  final String uuid;
  final String returnUuid;
  final String productUuid;
  final double quantity;
  final double refundUnitPrice;
  final String? batchUuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const OrderReturnItem(
      {required this.uuid,
      required this.returnUuid,
      required this.productUuid,
      required this.quantity,
      required this.refundUnitPrice,
      this.batchUuid,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['return_uuid'] = Variable<String>(returnUuid);
    map['product_uuid'] = Variable<String>(productUuid);
    map['quantity'] = Variable<double>(quantity);
    map['refund_unit_price'] = Variable<double>(refundUnitPrice);
    if (!nullToAbsent || batchUuid != null) {
      map['batch_uuid'] = Variable<String>(batchUuid);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  OrderReturnItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderReturnItemsCompanion(
      uuid: Value(uuid),
      returnUuid: Value(returnUuid),
      productUuid: Value(productUuid),
      quantity: Value(quantity),
      refundUnitPrice: Value(refundUnitPrice),
      batchUuid: batchUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(batchUuid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory OrderReturnItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderReturnItem(
      uuid: serializer.fromJson<String>(json['uuid']),
      returnUuid: serializer.fromJson<String>(json['returnUuid']),
      productUuid: serializer.fromJson<String>(json['productUuid']),
      quantity: serializer.fromJson<double>(json['quantity']),
      refundUnitPrice: serializer.fromJson<double>(json['refundUnitPrice']),
      batchUuid: serializer.fromJson<String?>(json['batchUuid']),
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
      'returnUuid': serializer.toJson<String>(returnUuid),
      'productUuid': serializer.toJson<String>(productUuid),
      'quantity': serializer.toJson<double>(quantity),
      'refundUnitPrice': serializer.toJson<double>(refundUnitPrice),
      'batchUuid': serializer.toJson<String?>(batchUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  OrderReturnItem copyWith(
          {String? uuid,
          String? returnUuid,
          String? productUuid,
          double? quantity,
          double? refundUnitPrice,
          Value<String?> batchUuid = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      OrderReturnItem(
        uuid: uuid ?? this.uuid,
        returnUuid: returnUuid ?? this.returnUuid,
        productUuid: productUuid ?? this.productUuid,
        quantity: quantity ?? this.quantity,
        refundUnitPrice: refundUnitPrice ?? this.refundUnitPrice,
        batchUuid: batchUuid.present ? batchUuid.value : this.batchUuid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  OrderReturnItem copyWithCompanion(OrderReturnItemsCompanion data) {
    return OrderReturnItem(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      returnUuid:
          data.returnUuid.present ? data.returnUuid.value : this.returnUuid,
      productUuid:
          data.productUuid.present ? data.productUuid.value : this.productUuid,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      refundUnitPrice: data.refundUnitPrice.present
          ? data.refundUnitPrice.value
          : this.refundUnitPrice,
      batchUuid: data.batchUuid.present ? data.batchUuid.value : this.batchUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderReturnItem(')
          ..write('uuid: $uuid, ')
          ..write('returnUuid: $returnUuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('quantity: $quantity, ')
          ..write('refundUnitPrice: $refundUnitPrice, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, returnUuid, productUuid, quantity,
      refundUnitPrice, batchUuid, createdAt, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderReturnItem &&
          other.uuid == this.uuid &&
          other.returnUuid == this.returnUuid &&
          other.productUuid == this.productUuid &&
          other.quantity == this.quantity &&
          other.refundUnitPrice == this.refundUnitPrice &&
          other.batchUuid == this.batchUuid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class OrderReturnItemsCompanion extends UpdateCompanion<OrderReturnItem> {
  final Value<String> uuid;
  final Value<String> returnUuid;
  final Value<String> productUuid;
  final Value<double> quantity;
  final Value<double> refundUnitPrice;
  final Value<String?> batchUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const OrderReturnItemsCompanion({
    this.uuid = const Value.absent(),
    this.returnUuid = const Value.absent(),
    this.productUuid = const Value.absent(),
    this.quantity = const Value.absent(),
    this.refundUnitPrice = const Value.absent(),
    this.batchUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderReturnItemsCompanion.insert({
    required String uuid,
    required String returnUuid,
    required String productUuid,
    required double quantity,
    required double refundUnitPrice,
    this.batchUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        returnUuid = Value(returnUuid),
        productUuid = Value(productUuid),
        quantity = Value(quantity),
        refundUnitPrice = Value(refundUnitPrice);
  static Insertable<OrderReturnItem> custom({
    Expression<String>? uuid,
    Expression<String>? returnUuid,
    Expression<String>? productUuid,
    Expression<double>? quantity,
    Expression<double>? refundUnitPrice,
    Expression<String>? batchUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (returnUuid != null) 'return_uuid': returnUuid,
      if (productUuid != null) 'product_uuid': productUuid,
      if (quantity != null) 'quantity': quantity,
      if (refundUnitPrice != null) 'refund_unit_price': refundUnitPrice,
      if (batchUuid != null) 'batch_uuid': batchUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderReturnItemsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? returnUuid,
      Value<String>? productUuid,
      Value<double>? quantity,
      Value<double>? refundUnitPrice,
      Value<String?>? batchUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return OrderReturnItemsCompanion(
      uuid: uuid ?? this.uuid,
      returnUuid: returnUuid ?? this.returnUuid,
      productUuid: productUuid ?? this.productUuid,
      quantity: quantity ?? this.quantity,
      refundUnitPrice: refundUnitPrice ?? this.refundUnitPrice,
      batchUuid: batchUuid ?? this.batchUuid,
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
    if (returnUuid.present) {
      map['return_uuid'] = Variable<String>(returnUuid.value);
    }
    if (productUuid.present) {
      map['product_uuid'] = Variable<String>(productUuid.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (refundUnitPrice.present) {
      map['refund_unit_price'] = Variable<double>(refundUnitPrice.value);
    }
    if (batchUuid.present) {
      map['batch_uuid'] = Variable<String>(batchUuid.value);
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
    return (StringBuffer('OrderReturnItemsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('returnUuid: $returnUuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('quantity: $quantity, ')
          ..write('refundUnitPrice: $refundUnitPrice, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogsTable extends Catalogs with TableInfo<$CatalogsTable, Catalog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _validUntilMeta =
      const VerificationMeta('validUntil');
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
      'valid_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        description,
        validUntil,
        isDefault,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalogs';
  @override
  VerificationContext validateIntegrity(Insertable<Catalog> instance,
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
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('valid_until')) {
      context.handle(
          _validUntilMeta,
          validUntil.isAcceptableOrUnknown(
              data['valid_until']!, _validUntilMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
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
  Catalog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Catalog(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      validUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_until']),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
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
  $CatalogsTable createAlias(String alias) {
    return $CatalogsTable(attachedDatabase, alias);
  }
}

class Catalog extends DataClass implements Insertable<Catalog> {
  final String uuid;
  final String name;
  final String? description;
  final DateTime? validUntil;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const Catalog(
      {required this.uuid,
      required this.name,
      this.description,
      this.validUntil,
      required this.isDefault,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<DateTime>(validUntil);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  CatalogsCompanion toCompanion(bool nullToAbsent) {
    return CatalogsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory Catalog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Catalog(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      validUntil: serializer.fromJson<DateTime?>(json['validUntil']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
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
      'description': serializer.toJson<String?>(description),
      'validUntil': serializer.toJson<DateTime?>(validUntil),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  Catalog copyWith(
          {String? uuid,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<DateTime?> validUntil = const Value.absent(),
          bool? isDefault,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      Catalog(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        validUntil: validUntil.present ? validUntil.value : this.validUntil,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  Catalog copyWithCompanion(CatalogsCompanion data) {
    return Catalog(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      validUntil:
          data.validUntil.present ? data.validUntil.value : this.validUntil,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Catalog(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('validUntil: $validUntil, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, description, validUntil,
      isDefault, createdAt, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Catalog &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.description == this.description &&
          other.validUntil == this.validUntil &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class CatalogsCompanion extends UpdateCompanion<Catalog> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime?> validUntil;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const CatalogsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogsCompanion.insert({
    required String uuid,
    required String name,
    this.description = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Catalog> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? validUntil,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (validUntil != null) 'valid_until': validUntil,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String?>? description,
      Value<DateTime?>? validUntil,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return CatalogsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      validUntil: validUntil ?? this.validUntil,
      isDefault: isDefault ?? this.isDefault,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<DateTime>(validUntil.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
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
    return (StringBuffer('CatalogsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('validUntil: $validUntil, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catalogUuidMeta =
      const VerificationMeta('catalogUuid');
  @override
  late final GeneratedColumn<String> catalogUuid = GeneratedColumn<String>(
      'catalog_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES catalogs (uuid)'));
  static const VerificationMeta _productUuidMeta =
      const VerificationMeta('productUuid');
  @override
  late final GeneratedColumn<String> productUuid = GeneratedColumn<String>(
      'product_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (uuid)'));
  static const VerificationMeta _customPriceMeta =
      const VerificationMeta('customPrice');
  @override
  late final GeneratedColumn<double> customPrice = GeneratedColumn<double>(
      'custom_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _batchUuidMeta =
      const VerificationMeta('batchUuid');
  @override
  late final GeneratedColumn<String> batchUuid = GeneratedColumn<String>(
      'batch_uuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES product_batches (uuid)'));
  static const VerificationMeta _validUntilMeta =
      const VerificationMeta('validUntil');
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
      'valid_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _batchSelectionStrategyMeta =
      const VerificationMeta('batchSelectionStrategy');
  @override
  late final GeneratedColumn<String> batchSelectionStrategy =
      GeneratedColumn<String>('batch_selection_strategy', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('FEFO_AUTO'));
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
        catalogUuid,
        productUuid,
        customPrice,
        batchUuid,
        validUntil,
        batchSelectionStrategy,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('catalog_uuid')) {
      context.handle(
          _catalogUuidMeta,
          catalogUuid.isAcceptableOrUnknown(
              data['catalog_uuid']!, _catalogUuidMeta));
    } else if (isInserting) {
      context.missing(_catalogUuidMeta);
    }
    if (data.containsKey('product_uuid')) {
      context.handle(
          _productUuidMeta,
          productUuid.isAcceptableOrUnknown(
              data['product_uuid']!, _productUuidMeta));
    } else if (isInserting) {
      context.missing(_productUuidMeta);
    }
    if (data.containsKey('custom_price')) {
      context.handle(
          _customPriceMeta,
          customPrice.isAcceptableOrUnknown(
              data['custom_price']!, _customPriceMeta));
    }
    if (data.containsKey('batch_uuid')) {
      context.handle(_batchUuidMeta,
          batchUuid.isAcceptableOrUnknown(data['batch_uuid']!, _batchUuidMeta));
    }
    if (data.containsKey('valid_until')) {
      context.handle(
          _validUntilMeta,
          validUntil.isAcceptableOrUnknown(
              data['valid_until']!, _validUntilMeta));
    }
    if (data.containsKey('batch_selection_strategy')) {
      context.handle(
          _batchSelectionStrategyMeta,
          batchSelectionStrategy.isAcceptableOrUnknown(
              data['batch_selection_strategy']!, _batchSelectionStrategyMeta));
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
  CatalogItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItem(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      catalogUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalog_uuid'])!,
      productUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_uuid'])!,
      customPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}custom_price']),
      batchUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_uuid']),
      validUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_until']),
      batchSelectionStrategy: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}batch_selection_strategy'])!,
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
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItem extends DataClass implements Insertable<CatalogItem> {
  final String uuid;
  final String catalogUuid;
  final String productUuid;
  final double? customPrice;
  final String? batchUuid;
  final DateTime? validUntil;
  final String batchSelectionStrategy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const CatalogItem(
      {required this.uuid,
      required this.catalogUuid,
      required this.productUuid,
      this.customPrice,
      this.batchUuid,
      this.validUntil,
      required this.batchSelectionStrategy,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['catalog_uuid'] = Variable<String>(catalogUuid);
    map['product_uuid'] = Variable<String>(productUuid);
    if (!nullToAbsent || customPrice != null) {
      map['custom_price'] = Variable<double>(customPrice);
    }
    if (!nullToAbsent || batchUuid != null) {
      map['batch_uuid'] = Variable<String>(batchUuid);
    }
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<DateTime>(validUntil);
    }
    map['batch_selection_strategy'] = Variable<String>(batchSelectionStrategy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      uuid: Value(uuid),
      catalogUuid: Value(catalogUuid),
      productUuid: Value(productUuid),
      customPrice: customPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(customPrice),
      batchUuid: batchUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(batchUuid),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      batchSelectionStrategy: Value(batchSelectionStrategy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItem(
      uuid: serializer.fromJson<String>(json['uuid']),
      catalogUuid: serializer.fromJson<String>(json['catalogUuid']),
      productUuid: serializer.fromJson<String>(json['productUuid']),
      customPrice: serializer.fromJson<double?>(json['customPrice']),
      batchUuid: serializer.fromJson<String?>(json['batchUuid']),
      validUntil: serializer.fromJson<DateTime?>(json['validUntil']),
      batchSelectionStrategy:
          serializer.fromJson<String>(json['batchSelectionStrategy']),
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
      'catalogUuid': serializer.toJson<String>(catalogUuid),
      'productUuid': serializer.toJson<String>(productUuid),
      'customPrice': serializer.toJson<double?>(customPrice),
      'batchUuid': serializer.toJson<String?>(batchUuid),
      'validUntil': serializer.toJson<DateTime?>(validUntil),
      'batchSelectionStrategy':
          serializer.toJson<String>(batchSelectionStrategy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  CatalogItem copyWith(
          {String? uuid,
          String? catalogUuid,
          String? productUuid,
          Value<double?> customPrice = const Value.absent(),
          Value<String?> batchUuid = const Value.absent(),
          Value<DateTime?> validUntil = const Value.absent(),
          String? batchSelectionStrategy,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      CatalogItem(
        uuid: uuid ?? this.uuid,
        catalogUuid: catalogUuid ?? this.catalogUuid,
        productUuid: productUuid ?? this.productUuid,
        customPrice: customPrice.present ? customPrice.value : this.customPrice,
        batchUuid: batchUuid.present ? batchUuid.value : this.batchUuid,
        validUntil: validUntil.present ? validUntil.value : this.validUntil,
        batchSelectionStrategy:
            batchSelectionStrategy ?? this.batchSelectionStrategy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  CatalogItem copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItem(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      catalogUuid:
          data.catalogUuid.present ? data.catalogUuid.value : this.catalogUuid,
      productUuid:
          data.productUuid.present ? data.productUuid.value : this.productUuid,
      customPrice:
          data.customPrice.present ? data.customPrice.value : this.customPrice,
      batchUuid: data.batchUuid.present ? data.batchUuid.value : this.batchUuid,
      validUntil:
          data.validUntil.present ? data.validUntil.value : this.validUntil,
      batchSelectionStrategy: data.batchSelectionStrategy.present
          ? data.batchSelectionStrategy.value
          : this.batchSelectionStrategy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItem(')
          ..write('uuid: $uuid, ')
          ..write('catalogUuid: $catalogUuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('customPrice: $customPrice, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('validUntil: $validUntil, ')
          ..write('batchSelectionStrategy: $batchSelectionStrategy, ')
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
      catalogUuid,
      productUuid,
      customPrice,
      batchUuid,
      validUntil,
      batchSelectionStrategy,
      createdAt,
      updatedAt,
      isDeleted,
      isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItem &&
          other.uuid == this.uuid &&
          other.catalogUuid == this.catalogUuid &&
          other.productUuid == this.productUuid &&
          other.customPrice == this.customPrice &&
          other.batchUuid == this.batchUuid &&
          other.validUntil == this.validUntil &&
          other.batchSelectionStrategy == this.batchSelectionStrategy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItem> {
  final Value<String> uuid;
  final Value<String> catalogUuid;
  final Value<String> productUuid;
  final Value<double?> customPrice;
  final Value<String?> batchUuid;
  final Value<DateTime?> validUntil;
  final Value<String> batchSelectionStrategy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.uuid = const Value.absent(),
    this.catalogUuid = const Value.absent(),
    this.productUuid = const Value.absent(),
    this.customPrice = const Value.absent(),
    this.batchUuid = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.batchSelectionStrategy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String uuid,
    required String catalogUuid,
    required String productUuid,
    this.customPrice = const Value.absent(),
    this.batchUuid = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.batchSelectionStrategy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        catalogUuid = Value(catalogUuid),
        productUuid = Value(productUuid);
  static Insertable<CatalogItem> custom({
    Expression<String>? uuid,
    Expression<String>? catalogUuid,
    Expression<String>? productUuid,
    Expression<double>? customPrice,
    Expression<String>? batchUuid,
    Expression<DateTime>? validUntil,
    Expression<String>? batchSelectionStrategy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (catalogUuid != null) 'catalog_uuid': catalogUuid,
      if (productUuid != null) 'product_uuid': productUuid,
      if (customPrice != null) 'custom_price': customPrice,
      if (batchUuid != null) 'batch_uuid': batchUuid,
      if (validUntil != null) 'valid_until': validUntil,
      if (batchSelectionStrategy != null)
        'batch_selection_strategy': batchSelectionStrategy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? catalogUuid,
      Value<String>? productUuid,
      Value<double?>? customPrice,
      Value<String?>? batchUuid,
      Value<DateTime?>? validUntil,
      Value<String>? batchSelectionStrategy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return CatalogItemsCompanion(
      uuid: uuid ?? this.uuid,
      catalogUuid: catalogUuid ?? this.catalogUuid,
      productUuid: productUuid ?? this.productUuid,
      customPrice: customPrice ?? this.customPrice,
      batchUuid: batchUuid ?? this.batchUuid,
      validUntil: validUntil ?? this.validUntil,
      batchSelectionStrategy:
          batchSelectionStrategy ?? this.batchSelectionStrategy,
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
    if (catalogUuid.present) {
      map['catalog_uuid'] = Variable<String>(catalogUuid.value);
    }
    if (productUuid.present) {
      map['product_uuid'] = Variable<String>(productUuid.value);
    }
    if (customPrice.present) {
      map['custom_price'] = Variable<double>(customPrice.value);
    }
    if (batchUuid.present) {
      map['batch_uuid'] = Variable<String>(batchUuid.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<DateTime>(validUntil.value);
    }
    if (batchSelectionStrategy.present) {
      map['batch_selection_strategy'] =
          Variable<String>(batchSelectionStrategy.value);
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
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('catalogUuid: $catalogUuid, ')
          ..write('productUuid: $productUuid, ')
          ..write('customPrice: $customPrice, ')
          ..write('batchUuid: $batchUuid, ')
          ..write('validUntil: $validUntil, ')
          ..write('batchSelectionStrategy: $batchSelectionStrategy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogAssignmentsTable extends CatalogAssignments
    with TableInfo<$CatalogAssignmentsTable, CatalogAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catalogUuidMeta =
      const VerificationMeta('catalogUuid');
  @override
  late final GeneratedColumn<String> catalogUuid = GeneratedColumn<String>(
      'catalog_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES catalogs (uuid)'));
  static const VerificationMeta _contactUuidMeta =
      const VerificationMeta('contactUuid');
  @override
  late final GeneratedColumn<String> contactUuid = GeneratedColumn<String>(
      'contact_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (uuid)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
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
  List<GeneratedColumn> get $columns =>
      [uuid, catalogUuid, contactUuid, createdAt, isDeleted, isNotSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_assignments';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogAssignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('catalog_uuid')) {
      context.handle(
          _catalogUuidMeta,
          catalogUuid.isAcceptableOrUnknown(
              data['catalog_uuid']!, _catalogUuidMeta));
    } else if (isInserting) {
      context.missing(_catalogUuidMeta);
    }
    if (data.containsKey('contact_uuid')) {
      context.handle(
          _contactUuidMeta,
          contactUuid.isAcceptableOrUnknown(
              data['contact_uuid']!, _contactUuidMeta));
    } else if (isInserting) {
      context.missing(_contactUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
  CatalogAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogAssignment(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      catalogUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalog_uuid'])!,
      contactUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      isNotSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_not_synced'])!,
    );
  }

  @override
  $CatalogAssignmentsTable createAlias(String alias) {
    return $CatalogAssignmentsTable(attachedDatabase, alias);
  }
}

class CatalogAssignment extends DataClass
    implements Insertable<CatalogAssignment> {
  final String uuid;
  final String catalogUuid;
  final String contactUuid;
  final DateTime createdAt;
  final bool isDeleted;
  final bool isNotSynced;
  const CatalogAssignment(
      {required this.uuid,
      required this.catalogUuid,
      required this.contactUuid,
      required this.createdAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['catalog_uuid'] = Variable<String>(catalogUuid);
    map['contact_uuid'] = Variable<String>(contactUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  CatalogAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return CatalogAssignmentsCompanion(
      uuid: Value(uuid),
      catalogUuid: Value(catalogUuid),
      contactUuid: Value(contactUuid),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory CatalogAssignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogAssignment(
      uuid: serializer.fromJson<String>(json['uuid']),
      catalogUuid: serializer.fromJson<String>(json['catalogUuid']),
      contactUuid: serializer.fromJson<String>(json['contactUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isNotSynced: serializer.fromJson<bool>(json['isNotSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'catalogUuid': serializer.toJson<String>(catalogUuid),
      'contactUuid': serializer.toJson<String>(contactUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  CatalogAssignment copyWith(
          {String? uuid,
          String? catalogUuid,
          String? contactUuid,
          DateTime? createdAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      CatalogAssignment(
        uuid: uuid ?? this.uuid,
        catalogUuid: catalogUuid ?? this.catalogUuid,
        contactUuid: contactUuid ?? this.contactUuid,
        createdAt: createdAt ?? this.createdAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  CatalogAssignment copyWithCompanion(CatalogAssignmentsCompanion data) {
    return CatalogAssignment(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      catalogUuid:
          data.catalogUuid.present ? data.catalogUuid.value : this.catalogUuid,
      contactUuid:
          data.contactUuid.present ? data.contactUuid.value : this.contactUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogAssignment(')
          ..write('uuid: $uuid, ')
          ..write('catalogUuid: $catalogUuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid, catalogUuid, contactUuid, createdAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogAssignment &&
          other.uuid == this.uuid &&
          other.catalogUuid == this.catalogUuid &&
          other.contactUuid == this.contactUuid &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class CatalogAssignmentsCompanion extends UpdateCompanion<CatalogAssignment> {
  final Value<String> uuid;
  final Value<String> catalogUuid;
  final Value<String> contactUuid;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const CatalogAssignmentsCompanion({
    this.uuid = const Value.absent(),
    this.catalogUuid = const Value.absent(),
    this.contactUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogAssignmentsCompanion.insert({
    required String uuid,
    required String catalogUuid,
    required String contactUuid,
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        catalogUuid = Value(catalogUuid),
        contactUuid = Value(contactUuid);
  static Insertable<CatalogAssignment> custom({
    Expression<String>? uuid,
    Expression<String>? catalogUuid,
    Expression<String>? contactUuid,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (catalogUuid != null) 'catalog_uuid': catalogUuid,
      if (contactUuid != null) 'contact_uuid': contactUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogAssignmentsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? catalogUuid,
      Value<String>? contactUuid,
      Value<DateTime>? createdAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return CatalogAssignmentsCompanion(
      uuid: uuid ?? this.uuid,
      catalogUuid: catalogUuid ?? this.catalogUuid,
      contactUuid: contactUuid ?? this.contactUuid,
      createdAt: createdAt ?? this.createdAt,
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
    if (catalogUuid.present) {
      map['catalog_uuid'] = Variable<String>(catalogUuid.value);
    }
    if (contactUuid.present) {
      map['contact_uuid'] = Variable<String>(contactUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CatalogAssignmentsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('catalogUuid: $catalogUuid, ')
          ..write('contactUuid: $contactUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogTieredDiscountsTable extends CatalogTieredDiscounts
    with TableInfo<$CatalogTieredDiscountsTable, CatalogTieredDiscount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogTieredDiscountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catalogItemUuidMeta =
      const VerificationMeta('catalogItemUuid');
  @override
  late final GeneratedColumn<String> catalogItemUuid = GeneratedColumn<String>(
      'catalog_item_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES catalog_items (uuid)'));
  static const VerificationMeta _minQuantityMeta =
      const VerificationMeta('minQuantity');
  @override
  late final GeneratedColumn<double> minQuantity = GeneratedColumn<double>(
      'min_quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountPercentageMeta =
      const VerificationMeta('discountPercentage');
  @override
  late final GeneratedColumn<double> discountPercentage =
      GeneratedColumn<double>('discount_percentage', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
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
        catalogItemUuid,
        minQuantity,
        discountPercentage,
        createdAt,
        updatedAt,
        isDeleted,
        isNotSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_tiered_discounts';
  @override
  VerificationContext validateIntegrity(
      Insertable<CatalogTieredDiscount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('catalog_item_uuid')) {
      context.handle(
          _catalogItemUuidMeta,
          catalogItemUuid.isAcceptableOrUnknown(
              data['catalog_item_uuid']!, _catalogItemUuidMeta));
    } else if (isInserting) {
      context.missing(_catalogItemUuidMeta);
    }
    if (data.containsKey('min_quantity')) {
      context.handle(
          _minQuantityMeta,
          minQuantity.isAcceptableOrUnknown(
              data['min_quantity']!, _minQuantityMeta));
    } else if (isInserting) {
      context.missing(_minQuantityMeta);
    }
    if (data.containsKey('discount_percentage')) {
      context.handle(
          _discountPercentageMeta,
          discountPercentage.isAcceptableOrUnknown(
              data['discount_percentage']!, _discountPercentageMeta));
    } else if (isInserting) {
      context.missing(_discountPercentageMeta);
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
  CatalogTieredDiscount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogTieredDiscount(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      catalogItemUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}catalog_item_uuid'])!,
      minQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_quantity'])!,
      discountPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}discount_percentage'])!,
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
  $CatalogTieredDiscountsTable createAlias(String alias) {
    return $CatalogTieredDiscountsTable(attachedDatabase, alias);
  }
}

class CatalogTieredDiscount extends DataClass
    implements Insertable<CatalogTieredDiscount> {
  final String uuid;
  final String catalogItemUuid;
  final double minQuantity;
  final double discountPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isNotSynced;
  const CatalogTieredDiscount(
      {required this.uuid,
      required this.catalogItemUuid,
      required this.minQuantity,
      required this.discountPercentage,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.isNotSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['catalog_item_uuid'] = Variable<String>(catalogItemUuid);
    map['min_quantity'] = Variable<double>(minQuantity);
    map['discount_percentage'] = Variable<double>(discountPercentage);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_not_synced'] = Variable<bool>(isNotSynced);
    return map;
  }

  CatalogTieredDiscountsCompanion toCompanion(bool nullToAbsent) {
    return CatalogTieredDiscountsCompanion(
      uuid: Value(uuid),
      catalogItemUuid: Value(catalogItemUuid),
      minQuantity: Value(minQuantity),
      discountPercentage: Value(discountPercentage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isNotSynced: Value(isNotSynced),
    );
  }

  factory CatalogTieredDiscount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogTieredDiscount(
      uuid: serializer.fromJson<String>(json['uuid']),
      catalogItemUuid: serializer.fromJson<String>(json['catalogItemUuid']),
      minQuantity: serializer.fromJson<double>(json['minQuantity']),
      discountPercentage:
          serializer.fromJson<double>(json['discountPercentage']),
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
      'catalogItemUuid': serializer.toJson<String>(catalogItemUuid),
      'minQuantity': serializer.toJson<double>(minQuantity),
      'discountPercentage': serializer.toJson<double>(discountPercentage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isNotSynced': serializer.toJson<bool>(isNotSynced),
    };
  }

  CatalogTieredDiscount copyWith(
          {String? uuid,
          String? catalogItemUuid,
          double? minQuantity,
          double? discountPercentage,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          bool? isNotSynced}) =>
      CatalogTieredDiscount(
        uuid: uuid ?? this.uuid,
        catalogItemUuid: catalogItemUuid ?? this.catalogItemUuid,
        minQuantity: minQuantity ?? this.minQuantity,
        discountPercentage: discountPercentage ?? this.discountPercentage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isNotSynced: isNotSynced ?? this.isNotSynced,
      );
  CatalogTieredDiscount copyWithCompanion(
      CatalogTieredDiscountsCompanion data) {
    return CatalogTieredDiscount(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      catalogItemUuid: data.catalogItemUuid.present
          ? data.catalogItemUuid.value
          : this.catalogItemUuid,
      minQuantity:
          data.minQuantity.present ? data.minQuantity.value : this.minQuantity,
      discountPercentage: data.discountPercentage.present
          ? data.discountPercentage.value
          : this.discountPercentage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isNotSynced:
          data.isNotSynced.present ? data.isNotSynced.value : this.isNotSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogTieredDiscount(')
          ..write('uuid: $uuid, ')
          ..write('catalogItemUuid: $catalogItemUuid, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('discountPercentage: $discountPercentage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, catalogItemUuid, minQuantity,
      discountPercentage, createdAt, updatedAt, isDeleted, isNotSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogTieredDiscount &&
          other.uuid == this.uuid &&
          other.catalogItemUuid == this.catalogItemUuid &&
          other.minQuantity == this.minQuantity &&
          other.discountPercentage == this.discountPercentage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isNotSynced == this.isNotSynced);
}

class CatalogTieredDiscountsCompanion
    extends UpdateCompanion<CatalogTieredDiscount> {
  final Value<String> uuid;
  final Value<String> catalogItemUuid;
  final Value<double> minQuantity;
  final Value<double> discountPercentage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isNotSynced;
  final Value<int> rowid;
  const CatalogTieredDiscountsCompanion({
    this.uuid = const Value.absent(),
    this.catalogItemUuid = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.discountPercentage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogTieredDiscountsCompanion.insert({
    required String uuid,
    required String catalogItemUuid,
    required double minQuantity,
    required double discountPercentage,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isNotSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        catalogItemUuid = Value(catalogItemUuid),
        minQuantity = Value(minQuantity),
        discountPercentage = Value(discountPercentage);
  static Insertable<CatalogTieredDiscount> custom({
    Expression<String>? uuid,
    Expression<String>? catalogItemUuid,
    Expression<double>? minQuantity,
    Expression<double>? discountPercentage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isNotSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (catalogItemUuid != null) 'catalog_item_uuid': catalogItemUuid,
      if (minQuantity != null) 'min_quantity': minQuantity,
      if (discountPercentage != null) 'discount_percentage': discountPercentage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isNotSynced != null) 'is_not_synced': isNotSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogTieredDiscountsCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? catalogItemUuid,
      Value<double>? minQuantity,
      Value<double>? discountPercentage,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<bool>? isNotSynced,
      Value<int>? rowid}) {
    return CatalogTieredDiscountsCompanion(
      uuid: uuid ?? this.uuid,
      catalogItemUuid: catalogItemUuid ?? this.catalogItemUuid,
      minQuantity: minQuantity ?? this.minQuantity,
      discountPercentage: discountPercentage ?? this.discountPercentage,
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
    if (catalogItemUuid.present) {
      map['catalog_item_uuid'] = Variable<String>(catalogItemUuid.value);
    }
    if (minQuantity.present) {
      map['min_quantity'] = Variable<double>(minQuantity.value);
    }
    if (discountPercentage.present) {
      map['discount_percentage'] = Variable<double>(discountPercentage.value);
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
    return (StringBuffer('CatalogTieredDiscountsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('catalogItemUuid: $catalogItemUuid, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('discountPercentage: $discountPercentage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isNotSynced: $isNotSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductCategoriesTable productCategories =
      $ProductCategoriesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AccountTransfersTable accountTransfers =
      $AccountTransfersTable(this);
  late final $UserPreferencesTable userPreferences =
      $UserPreferencesTable(this);
  late final $SyncLogTable syncLog = $SyncLogTable(this);
  late final $AppCurrenciesTable appCurrencies = $AppCurrenciesTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductBatchesTable productBatches = $ProductBatchesTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $OrderReturnsTable orderReturns = $OrderReturnsTable(this);
  late final $OrderReturnItemsTable orderReturnItems =
      $OrderReturnItemsTable(this);
  late final $CatalogsTable catalogs = $CatalogsTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $CatalogAssignmentsTable catalogAssignments =
      $CatalogAssignmentsTable(this);
  late final $CatalogTieredDiscountsTable catalogTieredDiscounts =
      $CatalogTieredDiscountsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        productCategories,
        contacts,
        accounts,
        orders,
        transactions,
        accountTransfers,
        userPreferences,
        syncLog,
        appCurrencies,
        syncMetadata,
        products,
        productBatches,
        orderItems,
        orderReturns,
        orderReturnItems,
        catalogs,
        catalogItems,
        catalogAssignments,
        catalogTieredDiscounts
      ];
}

typedef $$ProductCategoriesTableCreateCompanionBuilder
    = ProductCategoriesCompanion Function({
  required String uuid,
  required String name,
  Value<String?> icon,
  Value<String?> color,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$ProductCategoriesTableUpdateCompanionBuilder
    = ProductCategoriesCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String?> icon,
  Value<String?> color,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$ProductCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $ProductCategoriesTable, ProductCategory> {
  $$ProductCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<Product>> _productsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.products,
          aliasName: $_aliasNameGenerator(
              db.productCategories.uuid, db.products.categoryUuid));

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products).filter(
        (f) => f.categoryUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  Expression<bool> productsRefs(
      Expression<bool> Function($$ProductsTableFilterComposer f) f) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));
}

class $$ProductCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductCategoriesTable> {
  $$ProductCategoriesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
      Expression<T> Function($$ProductsTableAnnotationComposer a) f) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductCategoriesTable,
    ProductCategory,
    $$ProductCategoriesTableFilterComposer,
    $$ProductCategoriesTableOrderingComposer,
    $$ProductCategoriesTableAnnotationComposer,
    $$ProductCategoriesTableCreateCompanionBuilder,
    $$ProductCategoriesTableUpdateCompanionBuilder,
    (ProductCategory, $$ProductCategoriesTableReferences),
    ProductCategory,
    PrefetchHooks Function({bool productsRefs})> {
  $$ProductCategoriesTableTableManager(
      _$AppDatabase db, $ProductCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductCategoriesCompanion(
            uuid: uuid,
            name: name,
            icon: icon,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductCategoriesCompanion.insert(
            uuid: uuid,
            name: name,
            icon: icon,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<ProductCategory, $ProductCategoriesTable,
                            Product>(
                        currentTable: table,
                        referencedTable: $$ProductCategoriesTableReferences
                            ._productsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductCategoriesTableReferences(db, table, p0)
                                .productsRefs,
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

typedef $$ProductCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductCategoriesTable,
    ProductCategory,
    $$ProductCategoriesTableFilterComposer,
    $$ProductCategoriesTableOrderingComposer,
    $$ProductCategoriesTableAnnotationComposer,
    $$ProductCategoriesTableCreateCompanionBuilder,
    $$ProductCategoriesTableUpdateCompanionBuilder,
    (ProductCategory, $$ProductCategoriesTableReferences),
    ProductCategory,
    PrefetchHooks Function({bool productsRefs})>;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String uuid,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<String?> address,
  Value<bool> isCustomer,
  Value<bool> isSupplier,
  Value<double?> creditLimit,
  Value<String?> taxNumber,
  Value<String?> bankName,
  Value<String?> bankAccount,
  Value<String?> bankIfsc,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int?> addSeq,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> notes,
  Value<String?> address,
  Value<bool> isCustomer,
  Value<bool> isSupplier,
  Value<double?> creditLimit,
  Value<String?> taxNumber,
  Value<String?> bankName,
  Value<String?> bankAccount,
  Value<String?> bankIfsc,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int?> addSeq,
  Value<int> rowid,
});

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.orders,
          aliasName:
              $_aliasNameGenerator(db.contacts.uuid, db.orders.contactUuid));

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager($_db, $_db.orders).filter(
        (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

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

  static MultiTypedResultKey<$OrderReturnsTable, List<OrderReturn>>
      _orderReturnsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderReturns,
              aliasName: $_aliasNameGenerator(
                  db.contacts.uuid, db.orderReturns.contactUuid));

  $$OrderReturnsTableProcessedTableManager get orderReturnsRefs {
    final manager = $$OrderReturnsTableTableManager($_db, $_db.orderReturns)
        .filter(
            (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_orderReturnsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CatalogAssignmentsTable, List<CatalogAssignment>>
      _catalogAssignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogAssignments,
              aliasName: $_aliasNameGenerator(
                  db.contacts.uuid, db.catalogAssignments.contactUuid));

  $$CatalogAssignmentsTableProcessedTableManager get catalogAssignmentsRefs {
    final manager = $$CatalogAssignmentsTableTableManager(
            $_db, $_db.catalogAssignments)
        .filter(
            (f) => f.contactUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_catalogAssignmentsRefsTable($_db));
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

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustomer => $composableBuilder(
      column: $table.isCustomer, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSupplier => $composableBuilder(
      column: $table.isSupplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxNumber => $composableBuilder(
      column: $table.taxNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankAccount => $composableBuilder(
      column: $table.bankAccount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankIfsc => $composableBuilder(
      column: $table.bankIfsc, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addSeq => $composableBuilder(
      column: $table.addSeq, builder: (column) => ColumnFilters(column));

  Expression<bool> ordersRefs(
      Expression<bool> Function($$OrdersTableFilterComposer f) f) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

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

  Expression<bool> orderReturnsRefs(
      Expression<bool> Function($$OrderReturnsTableFilterComposer f) f) {
    final $$OrderReturnsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturns,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnsTableFilterComposer(
              $db: $db,
              $table: $db.orderReturns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> catalogAssignmentsRefs(
      Expression<bool> Function($$CatalogAssignmentsTableFilterComposer f) f) {
    final $$CatalogAssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogAssignments,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogAssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.catalogAssignments,
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

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustomer => $composableBuilder(
      column: $table.isCustomer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSupplier => $composableBuilder(
      column: $table.isSupplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxNumber => $composableBuilder(
      column: $table.taxNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankAccount => $composableBuilder(
      column: $table.bankAccount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankIfsc => $composableBuilder(
      column: $table.bankIfsc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addSeq => $composableBuilder(
      column: $table.addSeq, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<bool> get isCustomer => $composableBuilder(
      column: $table.isCustomer, builder: (column) => column);

  GeneratedColumn<bool> get isSupplier => $composableBuilder(
      column: $table.isSupplier, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => column);

  GeneratedColumn<String> get taxNumber =>
      $composableBuilder(column: $table.taxNumber, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get bankAccount => $composableBuilder(
      column: $table.bankAccount, builder: (column) => column);

  GeneratedColumn<String> get bankIfsc =>
      $composableBuilder(column: $table.bankIfsc, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  GeneratedColumn<int> get addSeq =>
      $composableBuilder(column: $table.addSeq, builder: (column) => column);

  Expression<T> ordersRefs<T extends Object>(
      Expression<T> Function($$OrdersTableAnnotationComposer a) f) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

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

  Expression<T> orderReturnsRefs<T extends Object>(
      Expression<T> Function($$OrderReturnsTableAnnotationComposer a) f) {
    final $$OrderReturnsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturns,
        getReferencedColumn: (t) => t.contactUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderReturns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> catalogAssignmentsRefs<T extends Object>(
      Expression<T> Function($$CatalogAssignmentsTableAnnotationComposer a) f) {
    final $$CatalogAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.catalogAssignments,
            getReferencedColumn: (t) => t.contactUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CatalogAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.catalogAssignments,
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
        {bool ordersRefs,
        bool transactionsRefs,
        bool orderReturnsRefs,
        bool catalogAssignmentsRefs})> {
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
            Value<String?> address = const Value.absent(),
            Value<bool> isCustomer = const Value.absent(),
            Value<bool> isSupplier = const Value.absent(),
            Value<double?> creditLimit = const Value.absent(),
            Value<String?> taxNumber = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> bankAccount = const Value.absent(),
            Value<String?> bankIfsc = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int?> addSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion(
            uuid: uuid,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            address: address,
            isCustomer: isCustomer,
            isSupplier: isSupplier,
            creditLimit: creditLimit,
            taxNumber: taxNumber,
            bankName: bankName,
            bankAccount: bankAccount,
            bankIfsc: bankIfsc,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            addSeq: addSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<bool> isCustomer = const Value.absent(),
            Value<bool> isSupplier = const Value.absent(),
            Value<double?> creditLimit = const Value.absent(),
            Value<String?> taxNumber = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> bankAccount = const Value.absent(),
            Value<String?> bankIfsc = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int?> addSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion.insert(
            uuid: uuid,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            address: address,
            isCustomer: isCustomer,
            isSupplier: isSupplier,
            creditLimit: creditLimit,
            taxNumber: taxNumber,
            bankName: bankName,
            bankAccount: bankAccount,
            bankIfsc: bankIfsc,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            addSeq: addSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ContactsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {ordersRefs = false,
              transactionsRefs = false,
              orderReturnsRefs = false,
              catalogAssignmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ordersRefs) db.orders,
                if (transactionsRefs) db.transactions,
                if (orderReturnsRefs) db.orderReturns,
                if (catalogAssignmentsRefs) db.catalogAssignments
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ordersRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable, Order>(
                        currentTable: table,
                        referencedTable:
                            $$ContactsTableReferences._ordersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0).ordersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items),
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
                  if (orderReturnsRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            OrderReturn>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._orderReturnsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .orderReturnsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactUuid == item.uuid),
                        typedResults: items),
                  if (catalogAssignmentsRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            CatalogAssignment>(
                        currentTable: table,
                        referencedTable: $$ContactsTableReferences
                            ._catalogAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .catalogAssignmentsRefs,
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
        {bool ordersRefs,
        bool transactionsRefs,
        bool orderReturnsRefs,
        bool catalogAssignmentsRefs})>;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String uuid,
  required String name,
  required String type,
  Value<String?> icon,
  Value<String?> color,
  Value<double> openingBalance,
  Value<DateTime> openingDate,
  Value<bool> isActive,
  Value<double?> creditLimit,
  Value<int?> billingCycleDay,
  Value<int?> paymentDueDays,
  Value<String?> linkedAccountUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int?> addSeq,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String> type,
  Value<String?> icon,
  Value<String?> color,
  Value<double> openingBalance,
  Value<DateTime> openingDate,
  Value<bool> isActive,
  Value<double?> creditLimit,
  Value<int?> billingCycleDay,
  Value<int?> paymentDueDays,
  Value<String?> linkedAccountUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int?> addSeq,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.accounts.uuid, db.transactions.accountUuid));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
            (f) => f.accountUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AccountTransfersTable, List<AccountTransfer>>
      _outgoingTransfersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.accountTransfers,
              aliasName: $_aliasNameGenerator(
                  db.accounts.uuid, db.accountTransfers.fromAccountUuid));

  $$AccountTransfersTableProcessedTableManager get outgoingTransfersRefs {
    final manager = $$AccountTransfersTableTableManager(
            $_db, $_db.accountTransfers)
        .filter((f) =>
            f.fromAccountUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_outgoingTransfersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AccountTransfersTable, List<AccountTransfer>>
      _incomingTransfersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.accountTransfers,
              aliasName: $_aliasNameGenerator(
                  db.accounts.uuid, db.accountTransfers.toAccountUuid));

  $$AccountTransfersTableProcessedTableManager get incomingTransfersRefs {
    final manager =
        $$AccountTransfersTableTableManager($_db, $_db.accountTransfers).filter(
            (f) =>
                f.toAccountUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_incomingTransfersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openingDate => $composableBuilder(
      column: $table.openingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get billingCycleDay => $composableBuilder(
      column: $table.billingCycleDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paymentDueDays => $composableBuilder(
      column: $table.paymentDueDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedAccountUuid => $composableBuilder(
      column: $table.linkedAccountUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addSeq => $composableBuilder(
      column: $table.addSeq, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.accountUuid,
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

  Expression<bool> outgoingTransfersRefs(
      Expression<bool> Function($$AccountTransfersTableFilterComposer f) f) {
    final $$AccountTransfersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.accountTransfers,
        getReferencedColumn: (t) => t.fromAccountUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTransfersTableFilterComposer(
              $db: $db,
              $table: $db.accountTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> incomingTransfersRefs(
      Expression<bool> Function($$AccountTransfersTableFilterComposer f) f) {
    final $$AccountTransfersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.accountTransfers,
        getReferencedColumn: (t) => t.toAccountUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTransfersTableFilterComposer(
              $db: $db,
              $table: $db.accountTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openingDate => $composableBuilder(
      column: $table.openingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get billingCycleDay => $composableBuilder(
      column: $table.billingCycleDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paymentDueDays => $composableBuilder(
      column: $table.paymentDueDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedAccountUuid => $composableBuilder(
      column: $table.linkedAccountUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addSeq => $composableBuilder(
      column: $table.addSeq, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<DateTime> get openingDate => $composableBuilder(
      column: $table.openingDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => column);

  GeneratedColumn<int> get billingCycleDay => $composableBuilder(
      column: $table.billingCycleDay, builder: (column) => column);

  GeneratedColumn<int> get paymentDueDays => $composableBuilder(
      column: $table.paymentDueDays, builder: (column) => column);

  GeneratedColumn<String> get linkedAccountUuid => $composableBuilder(
      column: $table.linkedAccountUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  GeneratedColumn<int> get addSeq =>
      $composableBuilder(column: $table.addSeq, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.accountUuid,
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

  Expression<T> outgoingTransfersRefs<T extends Object>(
      Expression<T> Function($$AccountTransfersTableAnnotationComposer a) f) {
    final $$AccountTransfersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.accountTransfers,
        getReferencedColumn: (t) => t.fromAccountUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTransfersTableAnnotationComposer(
              $db: $db,
              $table: $db.accountTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> incomingTransfersRefs<T extends Object>(
      Expression<T> Function($$AccountTransfersTableAnnotationComposer a) f) {
    final $$AccountTransfersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.accountTransfers,
        getReferencedColumn: (t) => t.toAccountUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountTransfersTableAnnotationComposer(
              $db: $db,
              $table: $db.accountTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool outgoingTransfersRefs,
        bool incomingTransfersRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<DateTime> openingDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<double?> creditLimit = const Value.absent(),
            Value<int?> billingCycleDay = const Value.absent(),
            Value<int?> paymentDueDays = const Value.absent(),
            Value<String?> linkedAccountUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int?> addSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            uuid: uuid,
            name: name,
            type: type,
            icon: icon,
            color: color,
            openingBalance: openingBalance,
            openingDate: openingDate,
            isActive: isActive,
            creditLimit: creditLimit,
            billingCycleDay: billingCycleDay,
            paymentDueDays: paymentDueDays,
            linkedAccountUuid: linkedAccountUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            addSeq: addSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            required String type,
            Value<String?> icon = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<DateTime> openingDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<double?> creditLimit = const Value.absent(),
            Value<int?> billingCycleDay = const Value.absent(),
            Value<int?> paymentDueDays = const Value.absent(),
            Value<String?> linkedAccountUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int?> addSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            uuid: uuid,
            name: name,
            type: type,
            icon: icon,
            color: color,
            openingBalance: openingBalance,
            openingDate: openingDate,
            isActive: isActive,
            creditLimit: creditLimit,
            billingCycleDay: billingCycleDay,
            paymentDueDays: paymentDueDays,
            linkedAccountUuid: linkedAccountUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            addSeq: addSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transactionsRefs = false,
              outgoingTransfersRefs = false,
              incomingTransfersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (outgoingTransfersRefs) db.accountTransfers,
                if (incomingTransfersRefs) db.accountTransfers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountUuid == item.uuid),
                        typedResults: items),
                  if (outgoingTransfersRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            AccountTransfer>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._outgoingTransfersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .outgoingTransfersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.fromAccountUuid == item.uuid),
                        typedResults: items),
                  if (incomingTransfersRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            AccountTransfer>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._incomingTransfersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .incomingTransfersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.toAccountUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool outgoingTransfersRefs,
        bool incomingTransfersRefs})>;
typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  required String uuid,
  Value<String?> contactUuid,
  required String orderNumber,
  required String orderType,
  required DateTime orderDate,
  Value<DateTime?> dueDate,
  required double subtotal,
  Value<double> discountAmount,
  Value<double> taxAmount,
  required double totalAmount,
  Value<String> paymentStatus,
  Value<String> deliveryStatus,
  Value<String?> shippingProvider,
  Value<String?> trackingNumber,
  Value<DateTime?> deliveredDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> uuid,
  Value<String?> contactUuid,
  Value<String> orderNumber,
  Value<String> orderType,
  Value<DateTime> orderDate,
  Value<DateTime?> dueDate,
  Value<double> subtotal,
  Value<double> discountAmount,
  Value<double> taxAmount,
  Value<double> totalAmount,
  Value<String> paymentStatus,
  Value<String> deliveryStatus,
  Value<String?> shippingProvider,
  Value<String?> trackingNumber,
  Value<DateTime?> deliveredDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, Order> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.orders.contactUuid, db.contacts.uuid));

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

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.transactions,
          aliasName:
              $_aliasNameGenerator(db.orders.uuid, db.transactions.orderUuid));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
            (f) => f.orderUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
      _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.orderItems,
          aliasName:
              $_aliasNameGenerator(db.orders.uuid, db.orderItems.orderUuid));

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager($_db, $_db.orderItems).filter(
        (f) => f.orderUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OrderReturnsTable, List<OrderReturn>>
      _orderReturnsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.orderReturns,
          aliasName:
              $_aliasNameGenerator(db.orders.uuid, db.orderReturns.orderUuid));

  $$OrderReturnsTableProcessedTableManager get orderReturnsRefs {
    final manager = $$OrderReturnsTableTableManager($_db, $_db.orderReturns)
        .filter(
            (f) => f.orderUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_orderReturnsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deliveryStatus => $composableBuilder(
      column: $table.deliveryStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shippingProvider => $composableBuilder(
      column: $table.shippingProvider,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackingNumber => $composableBuilder(
      column: $table.trackingNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate, builder: (column) => ColumnFilters(column));

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

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.orderUuid,
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

  Expression<bool> orderItemsRefs(
      Expression<bool> Function($$OrderItemsTableFilterComposer f) f) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.orderUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> orderReturnsRefs(
      Expression<bool> Function($$OrderReturnsTableFilterComposer f) f) {
    final $$OrderReturnsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturns,
        getReferencedColumn: (t) => t.orderUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnsTableFilterComposer(
              $db: $db,
              $table: $db.orderReturns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deliveryStatus => $composableBuilder(
      column: $table.deliveryStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shippingProvider => $composableBuilder(
      column: $table.shippingProvider,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackingNumber => $composableBuilder(
      column: $table.trackingNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate,
      builder: (column) => ColumnOrderings(column));

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

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<String> get deliveryStatus => $composableBuilder(
      column: $table.deliveryStatus, builder: (column) => column);

  GeneratedColumn<String> get shippingProvider => $composableBuilder(
      column: $table.shippingProvider, builder: (column) => column);

  GeneratedColumn<String> get trackingNumber => $composableBuilder(
      column: $table.trackingNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate, builder: (column) => column);

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

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.orderUuid,
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

  Expression<T> orderItemsRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableAnnotationComposer a) f) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.orderUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> orderReturnsRefs<T extends Object>(
      Expression<T> Function($$OrderReturnsTableAnnotationComposer a) f) {
    final $$OrderReturnsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturns,
        getReferencedColumn: (t) => t.orderUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderReturns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function(
        {bool contactUuid,
        bool transactionsRefs,
        bool orderItemsRefs,
        bool orderReturnsRefs})> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String?> contactUuid = const Value.absent(),
            Value<String> orderNumber = const Value.absent(),
            Value<String> orderType = const Value.absent(),
            Value<DateTime> orderDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String> deliveryStatus = const Value.absent(),
            Value<String?> shippingProvider = const Value.absent(),
            Value<String?> trackingNumber = const Value.absent(),
            Value<DateTime?> deliveredDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion(
            uuid: uuid,
            contactUuid: contactUuid,
            orderNumber: orderNumber,
            orderType: orderType,
            orderDate: orderDate,
            dueDate: dueDate,
            subtotal: subtotal,
            discountAmount: discountAmount,
            taxAmount: taxAmount,
            totalAmount: totalAmount,
            paymentStatus: paymentStatus,
            deliveryStatus: deliveryStatus,
            shippingProvider: shippingProvider,
            trackingNumber: trackingNumber,
            deliveredDate: deliveredDate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<String?> contactUuid = const Value.absent(),
            required String orderNumber,
            required String orderType,
            required DateTime orderDate,
            Value<DateTime?> dueDate = const Value.absent(),
            required double subtotal,
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            required double totalAmount,
            Value<String> paymentStatus = const Value.absent(),
            Value<String> deliveryStatus = const Value.absent(),
            Value<String?> shippingProvider = const Value.absent(),
            Value<String?> trackingNumber = const Value.absent(),
            Value<DateTime?> deliveredDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            uuid: uuid,
            contactUuid: contactUuid,
            orderNumber: orderNumber,
            orderType: orderType,
            orderDate: orderDate,
            dueDate: dueDate,
            subtotal: subtotal,
            discountAmount: discountAmount,
            taxAmount: taxAmount,
            totalAmount: totalAmount,
            paymentStatus: paymentStatus,
            deliveryStatus: deliveryStatus,
            shippingProvider: shippingProvider,
            trackingNumber: trackingNumber,
            deliveredDate: deliveredDate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$OrdersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {contactUuid = false,
              transactionsRefs = false,
              orderItemsRefs = false,
              orderReturnsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (orderItemsRefs) db.orderItems,
                if (orderReturnsRefs) db.orderReturns
              ],
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
                        $$OrdersTableReferences._contactUuidTable(db),
                    referencedColumn:
                        $$OrdersTableReferences._contactUuidTable(db).uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, Transaction>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.orderUuid == item.uuid),
                        typedResults: items),
                  if (orderItemsRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, OrderItem>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._orderItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .orderItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.orderUuid == item.uuid),
                        typedResults: items),
                  if (orderReturnsRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, OrderReturn>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._orderReturnsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .orderReturnsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.orderUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function(
        {bool contactUuid,
        bool transactionsRefs,
        bool orderItemsRefs,
        bool orderReturnsRefs})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String uuid,
  required double amount,
  required String type,
  Value<String?> contactUuid,
  Value<String?> orderUuid,
  Value<String?> categoryUuid,
  Value<String?> description,
  required DateTime date,
  Value<String?> accountUuid,
  Value<DateTime?> processedDate,
  Value<String> paymentMethod,
  Value<String?> linkedReceivableUuid,
  Value<String?> linkedPayableUuid,
  Value<String?> paidRelationship,
  Value<bool> isAutoGenerated,
  Value<bool> isScheduled,
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
  Value<String?> contactUuid,
  Value<String?> orderUuid,
  Value<String?> categoryUuid,
  Value<String?> description,
  Value<DateTime> date,
  Value<String?> accountUuid,
  Value<DateTime?> processedDate,
  Value<String> paymentMethod,
  Value<String?> linkedReceivableUuid,
  Value<String?> linkedPayableUuid,
  Value<String?> paidRelationship,
  Value<bool> isAutoGenerated,
  Value<bool> isScheduled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

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

  static $OrdersTable _orderUuidTable(_$AppDatabase db) =>
      db.orders.createAlias(
          $_aliasNameGenerator(db.transactions.orderUuid, db.orders.uuid));

  $$OrdersTableProcessedTableManager? get orderUuid {
    final $_column = $_itemColumn<String>('order_uuid');
    if ($_column == null) return null;
    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _accountUuidTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.transactions.accountUuid, db.accounts.uuid));

  $$AccountsTableProcessedTableManager? get accountUuid {
    final $_column = $_itemColumn<String>('account_uuid');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountUuidTable($_db));
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

  ColumnFilters<String> get categoryUuid => $composableBuilder(
      column: $table.categoryUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get processedDate => $composableBuilder(
      column: $table.processedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

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

  $$OrdersTableFilterComposer get orderUuid {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get accountUuid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
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

  ColumnOrderings<String> get categoryUuid => $composableBuilder(
      column: $table.categoryUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get processedDate => $composableBuilder(
      column: $table.processedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

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

  $$OrdersTableOrderingComposer get orderUuid {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get accountUuid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
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

  GeneratedColumn<String> get categoryUuid => $composableBuilder(
      column: $table.categoryUuid, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get processedDate => $composableBuilder(
      column: $table.processedDate, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

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

  $$OrdersTableAnnotationComposer get orderUuid {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountUuid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
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
    PrefetchHooks Function(
        {bool contactUuid, bool orderUuid, bool accountUuid})> {
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
            Value<String?> contactUuid = const Value.absent(),
            Value<String?> orderUuid = const Value.absent(),
            Value<String?> categoryUuid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> accountUuid = const Value.absent(),
            Value<DateTime?> processedDate = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String?> linkedReceivableUuid = const Value.absent(),
            Value<String?> linkedPayableUuid = const Value.absent(),
            Value<String?> paidRelationship = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
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
            contactUuid: contactUuid,
            orderUuid: orderUuid,
            categoryUuid: categoryUuid,
            description: description,
            date: date,
            accountUuid: accountUuid,
            processedDate: processedDate,
            paymentMethod: paymentMethod,
            linkedReceivableUuid: linkedReceivableUuid,
            linkedPayableUuid: linkedPayableUuid,
            paidRelationship: paidRelationship,
            isAutoGenerated: isAutoGenerated,
            isScheduled: isScheduled,
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
            Value<String?> contactUuid = const Value.absent(),
            Value<String?> orderUuid = const Value.absent(),
            Value<String?> categoryUuid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required DateTime date,
            Value<String?> accountUuid = const Value.absent(),
            Value<DateTime?> processedDate = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String?> linkedReceivableUuid = const Value.absent(),
            Value<String?> linkedPayableUuid = const Value.absent(),
            Value<String?> paidRelationship = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<bool> isScheduled = const Value.absent(),
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
            contactUuid: contactUuid,
            orderUuid: orderUuid,
            categoryUuid: categoryUuid,
            description: description,
            date: date,
            accountUuid: accountUuid,
            processedDate: processedDate,
            paymentMethod: paymentMethod,
            linkedReceivableUuid: linkedReceivableUuid,
            linkedPayableUuid: linkedPayableUuid,
            paidRelationship: paidRelationship,
            isAutoGenerated: isAutoGenerated,
            isScheduled: isScheduled,
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
          prefetchHooksCallback: (
              {contactUuid = false, orderUuid = false, accountUuid = false}) {
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
                        $$TransactionsTableReferences._contactUuidTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._contactUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (orderUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderUuid,
                    referencedTable:
                        $$TransactionsTableReferences._orderUuidTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._orderUuidTable(db).uuid,
                  ) as T;
                }
                if (accountUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountUuid,
                    referencedTable:
                        $$TransactionsTableReferences._accountUuidTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._accountUuidTable(db)
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
    PrefetchHooks Function(
        {bool contactUuid, bool orderUuid, bool accountUuid})>;
typedef $$AccountTransfersTableCreateCompanionBuilder
    = AccountTransfersCompanion Function({
  required String uuid,
  required String fromAccountUuid,
  required String toAccountUuid,
  required double amount,
  required DateTime date,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$AccountTransfersTableUpdateCompanionBuilder
    = AccountTransfersCompanion Function({
  Value<String> uuid,
  Value<String> fromAccountUuid,
  Value<String> toAccountUuid,
  Value<double> amount,
  Value<DateTime> date,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$AccountTransfersTableReferences extends BaseReferences<
    _$AppDatabase, $AccountTransfersTable, AccountTransfer> {
  $$AccountTransfersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _fromAccountUuidTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.accountTransfers.fromAccountUuid, db.accounts.uuid));

  $$AccountsTableProcessedTableManager get fromAccountUuid {
    final $_column = $_itemColumn<String>('from_account_uuid')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromAccountUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _toAccountUuidTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.accountTransfers.toAccountUuid, db.accounts.uuid));

  $$AccountsTableProcessedTableManager get toAccountUuid {
    final $_column = $_itemColumn<String>('to_account_uuid')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AccountTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $AccountTransfersTable> {
  $$AccountTransfersTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get fromAccountUuid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromAccountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountUuid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountTransfersTable> {
  $$AccountTransfersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get fromAccountUuid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromAccountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountUuid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountTransfersTable> {
  $$AccountTransfersTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$AccountsTableAnnotationComposer get fromAccountUuid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fromAccountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountUuid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountUuid,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountTransfersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountTransfersTable,
    AccountTransfer,
    $$AccountTransfersTableFilterComposer,
    $$AccountTransfersTableOrderingComposer,
    $$AccountTransfersTableAnnotationComposer,
    $$AccountTransfersTableCreateCompanionBuilder,
    $$AccountTransfersTableUpdateCompanionBuilder,
    (AccountTransfer, $$AccountTransfersTableReferences),
    AccountTransfer,
    PrefetchHooks Function({bool fromAccountUuid, bool toAccountUuid})> {
  $$AccountTransfersTableTableManager(
      _$AppDatabase db, $AccountTransfersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> fromAccountUuid = const Value.absent(),
            Value<String> toAccountUuid = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountTransfersCompanion(
            uuid: uuid,
            fromAccountUuid: fromAccountUuid,
            toAccountUuid: toAccountUuid,
            amount: amount,
            date: date,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String fromAccountUuid,
            required String toAccountUuid,
            required double amount,
            required DateTime date,
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountTransfersCompanion.insert(
            uuid: uuid,
            fromAccountUuid: fromAccountUuid,
            toAccountUuid: toAccountUuid,
            amount: amount,
            date: date,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AccountTransfersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {fromAccountUuid = false, toAccountUuid = false}) {
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
                if (fromAccountUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fromAccountUuid,
                    referencedTable: $$AccountTransfersTableReferences
                        ._fromAccountUuidTable(db),
                    referencedColumn: $$AccountTransfersTableReferences
                        ._fromAccountUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (toAccountUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toAccountUuid,
                    referencedTable: $$AccountTransfersTableReferences
                        ._toAccountUuidTable(db),
                    referencedColumn: $$AccountTransfersTableReferences
                        ._toAccountUuidTable(db)
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

typedef $$AccountTransfersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountTransfersTable,
    AccountTransfer,
    $$AccountTransfersTableFilterComposer,
    $$AccountTransfersTableOrderingComposer,
    $$AccountTransfersTableAnnotationComposer,
    $$AccountTransfersTableCreateCompanionBuilder,
    $$AccountTransfersTableUpdateCompanionBuilder,
    (AccountTransfer, $$AccountTransfersTableReferences),
    AccountTransfer,
    PrefetchHooks Function({bool fromAccountUuid, bool toAccountUuid})>;
typedef $$UserPreferencesTableCreateCompanionBuilder = UserPreferencesCompanion
    Function({
  Value<int> id,
  required String key,
  required String value,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
});
typedef $$UserPreferencesTableUpdateCompanionBuilder = UserPreferencesCompanion
    Function({
  Value<int> id,
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);
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
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
          }) =>
              UserPreferencesCompanion(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
          }) =>
              UserPreferencesCompanion.insert(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
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
  Value<double> scaleFactor,
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
  Value<double> scaleFactor,
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

  ColumnFilters<double> get scaleFactor => $composableBuilder(
      column: $table.scaleFactor, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<double> get scaleFactor => $composableBuilder(
      column: $table.scaleFactor, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<double> get scaleFactor => $composableBuilder(
      column: $table.scaleFactor, builder: (column) => column);

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
            Value<double> scaleFactor = const Value.absent(),
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
            scaleFactor: scaleFactor,
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
            Value<double> scaleFactor = const Value.absent(),
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
            scaleFactor: scaleFactor,
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
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String uuid,
  Value<String?> categoryUuid,
  required String name,
  Value<String?> sku,
  Value<String?> description,
  Value<String> unit,
  Value<double> purchasePrice,
  Value<double> retailPrice,
  Value<double> wholesalePrice,
  Value<double> stockQuantity,
  Value<double?> minStockAlert,
  Value<bool> isService,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> uuid,
  Value<String?> categoryUuid,
  Value<String> name,
  Value<String?> sku,
  Value<String?> description,
  Value<String> unit,
  Value<double> purchasePrice,
  Value<double> retailPrice,
  Value<double> wholesalePrice,
  Value<double> stockQuantity,
  Value<double?> minStockAlert,
  Value<bool> isService,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductCategoriesTable _categoryUuidTable(_$AppDatabase db) =>
      db.productCategories.createAlias($_aliasNameGenerator(
          db.products.categoryUuid, db.productCategories.uuid));

  $$ProductCategoriesTableProcessedTableManager? get categoryUuid {
    final $_column = $_itemColumn<String>('category_uuid');
    if ($_column == null) return null;
    final manager =
        $$ProductCategoriesTableTableManager($_db, $_db.productCategories)
            .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ProductBatchesTable, List<ProductBatche>>
      _productBatchesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.productBatches,
              aliasName: $_aliasNameGenerator(
                  db.products.uuid, db.productBatches.productUuid));

  $$ProductBatchesTableProcessedTableManager get productBatchesRefs {
    final manager = $$ProductBatchesTableTableManager($_db, $_db.productBatches)
        .filter(
            (f) => f.productUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_productBatchesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
      _orderItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderItems,
              aliasName: $_aliasNameGenerator(
                  db.products.uuid, db.orderItems.productUuid));

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager($_db, $_db.orderItems).filter(
        (f) => f.productUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OrderReturnItemsTable, List<OrderReturnItem>>
      _orderReturnItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderReturnItems,
              aliasName: $_aliasNameGenerator(
                  db.products.uuid, db.orderReturnItems.productUuid));

  $$OrderReturnItemsTableProcessedTableManager get orderReturnItemsRefs {
    final manager =
        $$OrderReturnItemsTableTableManager($_db, $_db.orderReturnItems).filter(
            (f) => f.productUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_orderReturnItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CatalogItemsTable, List<CatalogItem>>
      _catalogItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogItems,
              aliasName: $_aliasNameGenerator(
                  db.products.uuid, db.catalogItems.productUuid));

  $$CatalogItemsTableProcessedTableManager get catalogItemsRefs {
    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter(
            (f) => f.productUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_catalogItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retailPrice => $composableBuilder(
      column: $table.retailPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wholesalePrice => $composableBuilder(
      column: $table.wholesalePrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minStockAlert => $composableBuilder(
      column: $table.minStockAlert, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isService => $composableBuilder(
      column: $table.isService, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$ProductCategoriesTableFilterComposer get categoryUuid {
    final $$ProductCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.productCategories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.productCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> productBatchesRefs(
      Expression<bool> Function($$ProductBatchesTableFilterComposer f) f) {
    final $$ProductBatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableFilterComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> orderItemsRefs(
      Expression<bool> Function($$OrderItemsTableFilterComposer f) f) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> orderReturnItemsRefs(
      Expression<bool> Function($$OrderReturnItemsTableFilterComposer f) f) {
    final $$OrderReturnItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturnItems,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderReturnItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> catalogItemsRefs(
      Expression<bool> Function($$CatalogItemsTableFilterComposer f) f) {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retailPrice => $composableBuilder(
      column: $table.retailPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wholesalePrice => $composableBuilder(
      column: $table.wholesalePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minStockAlert => $composableBuilder(
      column: $table.minStockAlert,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isService => $composableBuilder(
      column: $table.isService, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$ProductCategoriesTableOrderingComposer get categoryUuid {
    final $$ProductCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryUuid,
        referencedTable: $db.productCategories,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.productCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
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

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<double> get retailPrice => $composableBuilder(
      column: $table.retailPrice, builder: (column) => column);

  GeneratedColumn<double> get wholesalePrice => $composableBuilder(
      column: $table.wholesalePrice, builder: (column) => column);

  GeneratedColumn<double> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => column);

  GeneratedColumn<double> get minStockAlert => $composableBuilder(
      column: $table.minStockAlert, builder: (column) => column);

  GeneratedColumn<bool> get isService =>
      $composableBuilder(column: $table.isService, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$ProductCategoriesTableAnnotationComposer get categoryUuid {
    final $$ProductCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryUuid,
            referencedTable: $db.productCategories,
            getReferencedColumn: (t) => t.uuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ProductCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.productCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> productBatchesRefs<T extends Object>(
      Expression<T> Function($$ProductBatchesTableAnnotationComposer a) f) {
    final $$ProductBatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> orderItemsRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableAnnotationComposer a) f) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> orderReturnItemsRefs<T extends Object>(
      Expression<T> Function($$OrderReturnItemsTableAnnotationComposer a) f) {
    final $$OrderReturnItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturnItems,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderReturnItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> catalogItemsRefs<T extends Object>(
      Expression<T> Function($$CatalogItemsTableAnnotationComposer a) f) {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.productUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool categoryUuid,
        bool productBatchesRefs,
        bool orderItemsRefs,
        bool orderReturnItemsRefs,
        bool catalogItemsRefs})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String?> categoryUuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<double> retailPrice = const Value.absent(),
            Value<double> wholesalePrice = const Value.absent(),
            Value<double> stockQuantity = const Value.absent(),
            Value<double?> minStockAlert = const Value.absent(),
            Value<bool> isService = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            uuid: uuid,
            categoryUuid: categoryUuid,
            name: name,
            sku: sku,
            description: description,
            unit: unit,
            purchasePrice: purchasePrice,
            retailPrice: retailPrice,
            wholesalePrice: wholesalePrice,
            stockQuantity: stockQuantity,
            minStockAlert: minStockAlert,
            isService: isService,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<String?> categoryUuid = const Value.absent(),
            required String name,
            Value<String?> sku = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> purchasePrice = const Value.absent(),
            Value<double> retailPrice = const Value.absent(),
            Value<double> wholesalePrice = const Value.absent(),
            Value<double> stockQuantity = const Value.absent(),
            Value<double?> minStockAlert = const Value.absent(),
            Value<bool> isService = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            uuid: uuid,
            categoryUuid: categoryUuid,
            name: name,
            sku: sku,
            description: description,
            unit: unit,
            purchasePrice: purchasePrice,
            retailPrice: retailPrice,
            wholesalePrice: wholesalePrice,
            stockQuantity: stockQuantity,
            minStockAlert: minStockAlert,
            isService: isService,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryUuid = false,
              productBatchesRefs = false,
              orderItemsRefs = false,
              orderReturnItemsRefs = false,
              catalogItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (productBatchesRefs) db.productBatches,
                if (orderItemsRefs) db.orderItems,
                if (orderReturnItemsRefs) db.orderReturnItems,
                if (catalogItemsRefs) db.catalogItems
              ],
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
                        $$ProductsTableReferences._categoryUuidTable(db),
                    referencedColumn:
                        $$ProductsTableReferences._categoryUuidTable(db).uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productBatchesRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            ProductBatche>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._productBatchesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .productBatchesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productUuid == item.uuid),
                        typedResults: items),
                  if (orderItemsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            OrderItem>(
                        currentTable: table,
                        referencedTable:
                            $$ProductsTableReferences._orderItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .orderItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productUuid == item.uuid),
                        typedResults: items),
                  if (orderReturnItemsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            OrderReturnItem>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._orderReturnItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .orderReturnItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productUuid == item.uuid),
                        typedResults: items),
                  if (catalogItemsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            CatalogItem>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._catalogItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .catalogItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool categoryUuid,
        bool productBatchesRefs,
        bool orderItemsRefs,
        bool orderReturnItemsRefs,
        bool catalogItemsRefs})>;
typedef $$ProductBatchesTableCreateCompanionBuilder = ProductBatchesCompanion
    Function({
  required String uuid,
  required String productUuid,
  required String batchNumber,
  Value<double> totalQuantity,
  Value<double> consumedQuantity,
  Value<double> effectiveCost,
  Value<bool> isManual,
  Value<String?> manualType,
  Value<double?> retailPriceOverride,
  Value<double?> wholesalePriceOverride,
  Value<DateTime?> manufactureDate,
  Value<DateTime?> expiryDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$ProductBatchesTableUpdateCompanionBuilder = ProductBatchesCompanion
    Function({
  Value<String> uuid,
  Value<String> productUuid,
  Value<String> batchNumber,
  Value<double> totalQuantity,
  Value<double> consumedQuantity,
  Value<double> effectiveCost,
  Value<bool> isManual,
  Value<String?> manualType,
  Value<double?> retailPriceOverride,
  Value<double?> wholesalePriceOverride,
  Value<DateTime?> manufactureDate,
  Value<DateTime?> expiryDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$ProductBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $ProductBatchesTable, ProductBatche> {
  $$ProductBatchesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productUuidTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.productBatches.productUuid, db.products.uuid));

  $$ProductsTableProcessedTableManager get productUuid {
    final $_column = $_itemColumn<String>('product_uuid')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
      _orderItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderItems,
              aliasName: $_aliasNameGenerator(
                  db.productBatches.uuid, db.orderItems.batchUuid));

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager($_db, $_db.orderItems).filter(
        (f) => f.batchUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OrderReturnItemsTable, List<OrderReturnItem>>
      _orderReturnItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderReturnItems,
              aliasName: $_aliasNameGenerator(
                  db.productBatches.uuid, db.orderReturnItems.batchUuid));

  $$OrderReturnItemsTableProcessedTableManager get orderReturnItemsRefs {
    final manager =
        $$OrderReturnItemsTableTableManager($_db, $_db.orderReturnItems).filter(
            (f) => f.batchUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_orderReturnItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CatalogItemsTable, List<CatalogItem>>
      _catalogItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogItems,
              aliasName: $_aliasNameGenerator(
                  db.productBatches.uuid, db.catalogItems.batchUuid));

  $$CatalogItemsTableProcessedTableManager get catalogItemsRefs {
    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter(
            (f) => f.batchUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_catalogItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductBatchesTable> {
  $$ProductBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get consumedQuantity => $composableBuilder(
      column: $table.consumedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get effectiveCost => $composableBuilder(
      column: $table.effectiveCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manualType => $composableBuilder(
      column: $table.manualType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retailPriceOverride => $composableBuilder(
      column: $table.retailPriceOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wholesalePriceOverride => $composableBuilder(
      column: $table.wholesalePriceOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get manufactureDate => $composableBuilder(
      column: $table.manufactureDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productUuid {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> orderItemsRefs(
      Expression<bool> Function($$OrderItemsTableFilterComposer f) f) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.batchUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> orderReturnItemsRefs(
      Expression<bool> Function($$OrderReturnItemsTableFilterComposer f) f) {
    final $$OrderReturnItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturnItems,
        getReferencedColumn: (t) => t.batchUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderReturnItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> catalogItemsRefs(
      Expression<bool> Function($$CatalogItemsTableFilterComposer f) f) {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.batchUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductBatchesTable> {
  $$ProductBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get consumedQuantity => $composableBuilder(
      column: $table.consumedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get effectiveCost => $composableBuilder(
      column: $table.effectiveCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manualType => $composableBuilder(
      column: $table.manualType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retailPriceOverride => $composableBuilder(
      column: $table.retailPriceOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wholesalePriceOverride => $composableBuilder(
      column: $table.wholesalePriceOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get manufactureDate => $composableBuilder(
      column: $table.manufactureDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productUuid {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductBatchesTable> {
  $$ProductBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => column);

  GeneratedColumn<double> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity, builder: (column) => column);

  GeneratedColumn<double> get consumedQuantity => $composableBuilder(
      column: $table.consumedQuantity, builder: (column) => column);

  GeneratedColumn<double> get effectiveCost => $composableBuilder(
      column: $table.effectiveCost, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumn<String> get manualType => $composableBuilder(
      column: $table.manualType, builder: (column) => column);

  GeneratedColumn<double> get retailPriceOverride => $composableBuilder(
      column: $table.retailPriceOverride, builder: (column) => column);

  GeneratedColumn<double> get wholesalePriceOverride => $composableBuilder(
      column: $table.wholesalePriceOverride, builder: (column) => column);

  GeneratedColumn<DateTime> get manufactureDate => $composableBuilder(
      column: $table.manufactureDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productUuid {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> orderItemsRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableAnnotationComposer a) f) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.batchUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> orderReturnItemsRefs<T extends Object>(
      Expression<T> Function($$OrderReturnItemsTableAnnotationComposer a) f) {
    final $$OrderReturnItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturnItems,
        getReferencedColumn: (t) => t.batchUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderReturnItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> catalogItemsRefs<T extends Object>(
      Expression<T> Function($$CatalogItemsTableAnnotationComposer a) f) {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.batchUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductBatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductBatchesTable,
    ProductBatche,
    $$ProductBatchesTableFilterComposer,
    $$ProductBatchesTableOrderingComposer,
    $$ProductBatchesTableAnnotationComposer,
    $$ProductBatchesTableCreateCompanionBuilder,
    $$ProductBatchesTableUpdateCompanionBuilder,
    (ProductBatche, $$ProductBatchesTableReferences),
    ProductBatche,
    PrefetchHooks Function(
        {bool productUuid,
        bool orderItemsRefs,
        bool orderReturnItemsRefs,
        bool catalogItemsRefs})> {
  $$ProductBatchesTableTableManager(
      _$AppDatabase db, $ProductBatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> productUuid = const Value.absent(),
            Value<String> batchNumber = const Value.absent(),
            Value<double> totalQuantity = const Value.absent(),
            Value<double> consumedQuantity = const Value.absent(),
            Value<double> effectiveCost = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<String?> manualType = const Value.absent(),
            Value<double?> retailPriceOverride = const Value.absent(),
            Value<double?> wholesalePriceOverride = const Value.absent(),
            Value<DateTime?> manufactureDate = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductBatchesCompanion(
            uuid: uuid,
            productUuid: productUuid,
            batchNumber: batchNumber,
            totalQuantity: totalQuantity,
            consumedQuantity: consumedQuantity,
            effectiveCost: effectiveCost,
            isManual: isManual,
            manualType: manualType,
            retailPriceOverride: retailPriceOverride,
            wholesalePriceOverride: wholesalePriceOverride,
            manufactureDate: manufactureDate,
            expiryDate: expiryDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String productUuid,
            required String batchNumber,
            Value<double> totalQuantity = const Value.absent(),
            Value<double> consumedQuantity = const Value.absent(),
            Value<double> effectiveCost = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<String?> manualType = const Value.absent(),
            Value<double?> retailPriceOverride = const Value.absent(),
            Value<double?> wholesalePriceOverride = const Value.absent(),
            Value<DateTime?> manufactureDate = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductBatchesCompanion.insert(
            uuid: uuid,
            productUuid: productUuid,
            batchNumber: batchNumber,
            totalQuantity: totalQuantity,
            consumedQuantity: consumedQuantity,
            effectiveCost: effectiveCost,
            isManual: isManual,
            manualType: manualType,
            retailPriceOverride: retailPriceOverride,
            wholesalePriceOverride: wholesalePriceOverride,
            manufactureDate: manufactureDate,
            expiryDate: expiryDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductBatchesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {productUuid = false,
              orderItemsRefs = false,
              orderReturnItemsRefs = false,
              catalogItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderItemsRefs) db.orderItems,
                if (orderReturnItemsRefs) db.orderReturnItems,
                if (catalogItemsRefs) db.catalogItems
              ],
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
                if (productUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productUuid,
                    referencedTable:
                        $$ProductBatchesTableReferences._productUuidTable(db),
                    referencedColumn: $$ProductBatchesTableReferences
                        ._productUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsRefs)
                    await $_getPrefetchedData<ProductBatche,
                            $ProductBatchesTable, OrderItem>(
                        currentTable: table,
                        referencedTable: $$ProductBatchesTableReferences
                            ._orderItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductBatchesTableReferences(db, table, p0)
                                .orderItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batchUuid == item.uuid),
                        typedResults: items),
                  if (orderReturnItemsRefs)
                    await $_getPrefetchedData<ProductBatche,
                            $ProductBatchesTable, OrderReturnItem>(
                        currentTable: table,
                        referencedTable: $$ProductBatchesTableReferences
                            ._orderReturnItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductBatchesTableReferences(db, table, p0)
                                .orderReturnItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batchUuid == item.uuid),
                        typedResults: items),
                  if (catalogItemsRefs)
                    await $_getPrefetchedData<ProductBatche,
                            $ProductBatchesTable, CatalogItem>(
                        currentTable: table,
                        referencedTable: $$ProductBatchesTableReferences
                            ._catalogItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductBatchesTableReferences(db, table, p0)
                                .catalogItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batchUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductBatchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductBatchesTable,
    ProductBatche,
    $$ProductBatchesTableFilterComposer,
    $$ProductBatchesTableOrderingComposer,
    $$ProductBatchesTableAnnotationComposer,
    $$ProductBatchesTableCreateCompanionBuilder,
    $$ProductBatchesTableUpdateCompanionBuilder,
    (ProductBatche, $$ProductBatchesTableReferences),
    ProductBatche,
    PrefetchHooks Function(
        {bool productUuid,
        bool orderItemsRefs,
        bool orderReturnItemsRefs,
        bool catalogItemsRefs})>;
typedef $$OrderItemsTableCreateCompanionBuilder = OrderItemsCompanion Function({
  required String uuid,
  required String orderUuid,
  required String productUuid,
  required String productNameSnapshot,
  required double quantity,
  required double unitPrice,
  Value<double> discountAmount,
  Value<double> taxRate,
  Value<String?> batchUuid,
  Value<double> purchasePriceSnapshot,
  Value<String> unit,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$OrderItemsTableUpdateCompanionBuilder = OrderItemsCompanion Function({
  Value<String> uuid,
  Value<String> orderUuid,
  Value<String> productUuid,
  Value<String> productNameSnapshot,
  Value<double> quantity,
  Value<double> unitPrice,
  Value<double> discountAmount,
  Value<double> taxRate,
  Value<String?> batchUuid,
  Value<double> purchasePriceSnapshot,
  Value<String> unit,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$OrderItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem> {
  $$OrderItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderUuidTable(_$AppDatabase db) =>
      db.orders.createAlias(
          $_aliasNameGenerator(db.orderItems.orderUuid, db.orders.uuid));

  $$OrdersTableProcessedTableManager get orderUuid {
    final $_column = $_itemColumn<String>('order_uuid')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productUuidTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.orderItems.productUuid, db.products.uuid));

  $$ProductsTableProcessedTableManager get productUuid {
    final $_column = $_itemColumn<String>('product_uuid')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductBatchesTable _batchUuidTable(_$AppDatabase db) =>
      db.productBatches.createAlias($_aliasNameGenerator(
          db.orderItems.batchUuid, db.productBatches.uuid));

  $$ProductBatchesTableProcessedTableManager? get batchUuid {
    final $_column = $_itemColumn<String>('batch_uuid');
    if ($_column == null) return null;
    final manager = $$ProductBatchesTableTableManager($_db, $_db.productBatches)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
      column: $table.productNameSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxRate => $composableBuilder(
      column: $table.taxRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePriceSnapshot => $composableBuilder(
      column: $table.purchasePriceSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$OrdersTableFilterComposer get orderUuid {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productUuid {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableFilterComposer get batchUuid {
    final $$ProductBatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableFilterComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
      column: $table.productNameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxRate => $composableBuilder(
      column: $table.taxRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePriceSnapshot => $composableBuilder(
      column: $table.purchasePriceSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$OrdersTableOrderingComposer get orderUuid {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productUuid {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableOrderingComposer get batchUuid {
    final $$ProductBatchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableOrderingComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
      column: $table.productNameSnapshot, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
      column: $table.discountAmount, builder: (column) => column);

  GeneratedColumn<double> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

  GeneratedColumn<double> get purchasePriceSnapshot => $composableBuilder(
      column: $table.purchasePriceSnapshot, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderUuid {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productUuid {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableAnnotationComposer get batchUuid {
    final $$ProductBatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, $$OrderItemsTableReferences),
    OrderItem,
    PrefetchHooks Function(
        {bool orderUuid, bool productUuid, bool batchUuid})> {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> orderUuid = const Value.absent(),
            Value<String> productUuid = const Value.absent(),
            Value<String> productNameSnapshot = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxRate = const Value.absent(),
            Value<String?> batchUuid = const Value.absent(),
            Value<double> purchasePriceSnapshot = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderItemsCompanion(
            uuid: uuid,
            orderUuid: orderUuid,
            productUuid: productUuid,
            productNameSnapshot: productNameSnapshot,
            quantity: quantity,
            unitPrice: unitPrice,
            discountAmount: discountAmount,
            taxRate: taxRate,
            batchUuid: batchUuid,
            purchasePriceSnapshot: purchasePriceSnapshot,
            unit: unit,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String orderUuid,
            required String productUuid,
            required String productNameSnapshot,
            required double quantity,
            required double unitPrice,
            Value<double> discountAmount = const Value.absent(),
            Value<double> taxRate = const Value.absent(),
            Value<String?> batchUuid = const Value.absent(),
            Value<double> purchasePriceSnapshot = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderItemsCompanion.insert(
            uuid: uuid,
            orderUuid: orderUuid,
            productUuid: productUuid,
            productNameSnapshot: productNameSnapshot,
            quantity: quantity,
            unitPrice: unitPrice,
            discountAmount: discountAmount,
            taxRate: taxRate,
            batchUuid: batchUuid,
            purchasePriceSnapshot: purchasePriceSnapshot,
            unit: unit,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OrderItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {orderUuid = false, productUuid = false, batchUuid = false}) {
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
                if (orderUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderUuid,
                    referencedTable:
                        $$OrderItemsTableReferences._orderUuidTable(db),
                    referencedColumn:
                        $$OrderItemsTableReferences._orderUuidTable(db).uuid,
                  ) as T;
                }
                if (productUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productUuid,
                    referencedTable:
                        $$OrderItemsTableReferences._productUuidTable(db),
                    referencedColumn:
                        $$OrderItemsTableReferences._productUuidTable(db).uuid,
                  ) as T;
                }
                if (batchUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batchUuid,
                    referencedTable:
                        $$OrderItemsTableReferences._batchUuidTable(db),
                    referencedColumn:
                        $$OrderItemsTableReferences._batchUuidTable(db).uuid,
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

typedef $$OrderItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, $$OrderItemsTableReferences),
    OrderItem,
    PrefetchHooks Function({bool orderUuid, bool productUuid, bool batchUuid})>;
typedef $$OrderReturnsTableCreateCompanionBuilder = OrderReturnsCompanion
    Function({
  required String uuid,
  required String orderUuid,
  required String returnNumber,
  required String orderType,
  Value<String?> contactUuid,
  required DateTime date,
  Value<double> totalRefundAmount,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$OrderReturnsTableUpdateCompanionBuilder = OrderReturnsCompanion
    Function({
  Value<String> uuid,
  Value<String> orderUuid,
  Value<String> returnNumber,
  Value<String> orderType,
  Value<String?> contactUuid,
  Value<DateTime> date,
  Value<double> totalRefundAmount,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$OrderReturnsTableReferences
    extends BaseReferences<_$AppDatabase, $OrderReturnsTable, OrderReturn> {
  $$OrderReturnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderUuidTable(_$AppDatabase db) =>
      db.orders.createAlias(
          $_aliasNameGenerator(db.orderReturns.orderUuid, db.orders.uuid));

  $$OrdersTableProcessedTableManager get orderUuid {
    final $_column = $_itemColumn<String>('order_uuid')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias(
          $_aliasNameGenerator(db.orderReturns.contactUuid, db.contacts.uuid));

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

  static MultiTypedResultKey<$OrderReturnItemsTable, List<OrderReturnItem>>
      _orderReturnItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderReturnItems,
              aliasName: $_aliasNameGenerator(
                  db.orderReturns.uuid, db.orderReturnItems.returnUuid));

  $$OrderReturnItemsTableProcessedTableManager get orderReturnItemsRefs {
    final manager =
        $$OrderReturnItemsTableTableManager($_db, $_db.orderReturnItems).filter(
            (f) => f.returnUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_orderReturnItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OrderReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderReturnsTable> {
  $$OrderReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get returnNumber => $composableBuilder(
      column: $table.returnNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalRefundAmount => $composableBuilder(
      column: $table.totalRefundAmount,
      builder: (column) => ColumnFilters(column));

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

  $$OrdersTableFilterComposer get orderUuid {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
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

  Expression<bool> orderReturnItemsRefs(
      Expression<bool> Function($$OrderReturnItemsTableFilterComposer f) f) {
    final $$OrderReturnItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturnItems,
        getReferencedColumn: (t) => t.returnUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderReturnItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrderReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderReturnsTable> {
  $$OrderReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get returnNumber => $composableBuilder(
      column: $table.returnNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalRefundAmount => $composableBuilder(
      column: $table.totalRefundAmount,
      builder: (column) => ColumnOrderings(column));

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

  $$OrdersTableOrderingComposer get orderUuid {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
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

class $$OrderReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderReturnsTable> {
  $$OrderReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get returnNumber => $composableBuilder(
      column: $table.returnNumber, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get totalRefundAmount => $composableBuilder(
      column: $table.totalRefundAmount, builder: (column) => column);

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

  $$OrdersTableAnnotationComposer get orderUuid {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderUuid,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
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

  Expression<T> orderReturnItemsRefs<T extends Object>(
      Expression<T> Function($$OrderReturnItemsTableAnnotationComposer a) f) {
    final $$OrderReturnItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.orderReturnItems,
        getReferencedColumn: (t) => t.returnUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderReturnItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrderReturnsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderReturnsTable,
    OrderReturn,
    $$OrderReturnsTableFilterComposer,
    $$OrderReturnsTableOrderingComposer,
    $$OrderReturnsTableAnnotationComposer,
    $$OrderReturnsTableCreateCompanionBuilder,
    $$OrderReturnsTableUpdateCompanionBuilder,
    (OrderReturn, $$OrderReturnsTableReferences),
    OrderReturn,
    PrefetchHooks Function(
        {bool orderUuid, bool contactUuid, bool orderReturnItemsRefs})> {
  $$OrderReturnsTableTableManager(_$AppDatabase db, $OrderReturnsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> orderUuid = const Value.absent(),
            Value<String> returnNumber = const Value.absent(),
            Value<String> orderType = const Value.absent(),
            Value<String?> contactUuid = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> totalRefundAmount = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderReturnsCompanion(
            uuid: uuid,
            orderUuid: orderUuid,
            returnNumber: returnNumber,
            orderType: orderType,
            contactUuid: contactUuid,
            date: date,
            totalRefundAmount: totalRefundAmount,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String orderUuid,
            required String returnNumber,
            required String orderType,
            Value<String?> contactUuid = const Value.absent(),
            required DateTime date,
            Value<double> totalRefundAmount = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderReturnsCompanion.insert(
            uuid: uuid,
            orderUuid: orderUuid,
            returnNumber: returnNumber,
            orderType: orderType,
            contactUuid: contactUuid,
            date: date,
            totalRefundAmount: totalRefundAmount,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OrderReturnsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {orderUuid = false,
              contactUuid = false,
              orderReturnItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderReturnItemsRefs) db.orderReturnItems
              ],
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
                if (orderUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderUuid,
                    referencedTable:
                        $$OrderReturnsTableReferences._orderUuidTable(db),
                    referencedColumn:
                        $$OrderReturnsTableReferences._orderUuidTable(db).uuid,
                  ) as T;
                }
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable:
                        $$OrderReturnsTableReferences._contactUuidTable(db),
                    referencedColumn: $$OrderReturnsTableReferences
                        ._contactUuidTable(db)
                        .uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderReturnItemsRefs)
                    await $_getPrefetchedData<OrderReturn, $OrderReturnsTable,
                            OrderReturnItem>(
                        currentTable: table,
                        referencedTable: $$OrderReturnsTableReferences
                            ._orderReturnItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrderReturnsTableReferences(db, table, p0)
                                .orderReturnItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.returnUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OrderReturnsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderReturnsTable,
    OrderReturn,
    $$OrderReturnsTableFilterComposer,
    $$OrderReturnsTableOrderingComposer,
    $$OrderReturnsTableAnnotationComposer,
    $$OrderReturnsTableCreateCompanionBuilder,
    $$OrderReturnsTableUpdateCompanionBuilder,
    (OrderReturn, $$OrderReturnsTableReferences),
    OrderReturn,
    PrefetchHooks Function(
        {bool orderUuid, bool contactUuid, bool orderReturnItemsRefs})>;
typedef $$OrderReturnItemsTableCreateCompanionBuilder
    = OrderReturnItemsCompanion Function({
  required String uuid,
  required String returnUuid,
  required String productUuid,
  required double quantity,
  required double refundUnitPrice,
  Value<String?> batchUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$OrderReturnItemsTableUpdateCompanionBuilder
    = OrderReturnItemsCompanion Function({
  Value<String> uuid,
  Value<String> returnUuid,
  Value<String> productUuid,
  Value<double> quantity,
  Value<double> refundUnitPrice,
  Value<String?> batchUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$OrderReturnItemsTableReferences extends BaseReferences<
    _$AppDatabase, $OrderReturnItemsTable, OrderReturnItem> {
  $$OrderReturnItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $OrderReturnsTable _returnUuidTable(_$AppDatabase db) =>
      db.orderReturns.createAlias($_aliasNameGenerator(
          db.orderReturnItems.returnUuid, db.orderReturns.uuid));

  $$OrderReturnsTableProcessedTableManager get returnUuid {
    final $_column = $_itemColumn<String>('return_uuid')!;

    final manager = $$OrderReturnsTableTableManager($_db, $_db.orderReturns)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_returnUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productUuidTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.orderReturnItems.productUuid, db.products.uuid));

  $$ProductsTableProcessedTableManager get productUuid {
    final $_column = $_itemColumn<String>('product_uuid')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductBatchesTable _batchUuidTable(_$AppDatabase db) =>
      db.productBatches.createAlias($_aliasNameGenerator(
          db.orderReturnItems.batchUuid, db.productBatches.uuid));

  $$ProductBatchesTableProcessedTableManager? get batchUuid {
    final $_column = $_itemColumn<String>('batch_uuid');
    if ($_column == null) return null;
    final manager = $$ProductBatchesTableTableManager($_db, $_db.productBatches)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OrderReturnItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderReturnItemsTable> {
  $$OrderReturnItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get refundUnitPrice => $composableBuilder(
      column: $table.refundUnitPrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$OrderReturnsTableFilterComposer get returnUuid {
    final $$OrderReturnsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.returnUuid,
        referencedTable: $db.orderReturns,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnsTableFilterComposer(
              $db: $db,
              $table: $db.orderReturns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productUuid {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableFilterComposer get batchUuid {
    final $$ProductBatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableFilterComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderReturnItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderReturnItemsTable> {
  $$OrderReturnItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get refundUnitPrice => $composableBuilder(
      column: $table.refundUnitPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$OrderReturnsTableOrderingComposer get returnUuid {
    final $$OrderReturnsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.returnUuid,
        referencedTable: $db.orderReturns,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnsTableOrderingComposer(
              $db: $db,
              $table: $db.orderReturns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productUuid {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableOrderingComposer get batchUuid {
    final $$ProductBatchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableOrderingComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderReturnItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderReturnItemsTable> {
  $$OrderReturnItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get refundUnitPrice => $composableBuilder(
      column: $table.refundUnitPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$OrderReturnsTableAnnotationComposer get returnUuid {
    final $$OrderReturnsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.returnUuid,
        referencedTable: $db.orderReturns,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderReturnsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderReturns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productUuid {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableAnnotationComposer get batchUuid {
    final $$ProductBatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderReturnItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderReturnItemsTable,
    OrderReturnItem,
    $$OrderReturnItemsTableFilterComposer,
    $$OrderReturnItemsTableOrderingComposer,
    $$OrderReturnItemsTableAnnotationComposer,
    $$OrderReturnItemsTableCreateCompanionBuilder,
    $$OrderReturnItemsTableUpdateCompanionBuilder,
    (OrderReturnItem, $$OrderReturnItemsTableReferences),
    OrderReturnItem,
    PrefetchHooks Function(
        {bool returnUuid, bool productUuid, bool batchUuid})> {
  $$OrderReturnItemsTableTableManager(
      _$AppDatabase db, $OrderReturnItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderReturnItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderReturnItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderReturnItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> returnUuid = const Value.absent(),
            Value<String> productUuid = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> refundUnitPrice = const Value.absent(),
            Value<String?> batchUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderReturnItemsCompanion(
            uuid: uuid,
            returnUuid: returnUuid,
            productUuid: productUuid,
            quantity: quantity,
            refundUnitPrice: refundUnitPrice,
            batchUuid: batchUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String returnUuid,
            required String productUuid,
            required double quantity,
            required double refundUnitPrice,
            Value<String?> batchUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderReturnItemsCompanion.insert(
            uuid: uuid,
            returnUuid: returnUuid,
            productUuid: productUuid,
            quantity: quantity,
            refundUnitPrice: refundUnitPrice,
            batchUuid: batchUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OrderReturnItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {returnUuid = false, productUuid = false, batchUuid = false}) {
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
                if (returnUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.returnUuid,
                    referencedTable:
                        $$OrderReturnItemsTableReferences._returnUuidTable(db),
                    referencedColumn: $$OrderReturnItemsTableReferences
                        ._returnUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (productUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productUuid,
                    referencedTable:
                        $$OrderReturnItemsTableReferences._productUuidTable(db),
                    referencedColumn: $$OrderReturnItemsTableReferences
                        ._productUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (batchUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batchUuid,
                    referencedTable:
                        $$OrderReturnItemsTableReferences._batchUuidTable(db),
                    referencedColumn: $$OrderReturnItemsTableReferences
                        ._batchUuidTable(db)
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

typedef $$OrderReturnItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderReturnItemsTable,
    OrderReturnItem,
    $$OrderReturnItemsTableFilterComposer,
    $$OrderReturnItemsTableOrderingComposer,
    $$OrderReturnItemsTableAnnotationComposer,
    $$OrderReturnItemsTableCreateCompanionBuilder,
    $$OrderReturnItemsTableUpdateCompanionBuilder,
    (OrderReturnItem, $$OrderReturnItemsTableReferences),
    OrderReturnItem,
    PrefetchHooks Function(
        {bool returnUuid, bool productUuid, bool batchUuid})>;
typedef $$CatalogsTableCreateCompanionBuilder = CatalogsCompanion Function({
  required String uuid,
  required String name,
  Value<String?> description,
  Value<DateTime?> validUntil,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$CatalogsTableUpdateCompanionBuilder = CatalogsCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String?> description,
  Value<DateTime?> validUntil,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$CatalogsTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogsTable, Catalog> {
  $$CatalogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CatalogItemsTable, List<CatalogItem>>
      _catalogItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogItems,
              aliasName: $_aliasNameGenerator(
                  db.catalogs.uuid, db.catalogItems.catalogUuid));

  $$CatalogItemsTableProcessedTableManager get catalogItemsRefs {
    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter(
            (f) => f.catalogUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_catalogItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CatalogAssignmentsTable, List<CatalogAssignment>>
      _catalogAssignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.catalogAssignments,
              aliasName: $_aliasNameGenerator(
                  db.catalogs.uuid, db.catalogAssignments.catalogUuid));

  $$CatalogAssignmentsTableProcessedTableManager get catalogAssignmentsRefs {
    final manager = $$CatalogAssignmentsTableTableManager(
            $_db, $_db.catalogAssignments)
        .filter(
            (f) => f.catalogUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_catalogAssignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CatalogsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogsTable> {
  $$CatalogsTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  Expression<bool> catalogItemsRefs(
      Expression<bool> Function($$CatalogItemsTableFilterComposer f) f) {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.catalogUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> catalogAssignmentsRefs(
      Expression<bool> Function($$CatalogAssignmentsTableFilterComposer f) f) {
    final $$CatalogAssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogAssignments,
        getReferencedColumn: (t) => t.catalogUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogAssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.catalogAssignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CatalogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogsTable> {
  $$CatalogsTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));
}

class $$CatalogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogsTable> {
  $$CatalogsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  Expression<T> catalogItemsRefs<T extends Object>(
      Expression<T> Function($$CatalogItemsTableAnnotationComposer a) f) {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.catalogUuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> catalogAssignmentsRefs<T extends Object>(
      Expression<T> Function($$CatalogAssignmentsTableAnnotationComposer a) f) {
    final $$CatalogAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.catalogAssignments,
            getReferencedColumn: (t) => t.catalogUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CatalogAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.catalogAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CatalogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogsTable,
    Catalog,
    $$CatalogsTableFilterComposer,
    $$CatalogsTableOrderingComposer,
    $$CatalogsTableAnnotationComposer,
    $$CatalogsTableCreateCompanionBuilder,
    $$CatalogsTableUpdateCompanionBuilder,
    (Catalog, $$CatalogsTableReferences),
    Catalog,
    PrefetchHooks Function(
        {bool catalogItemsRefs, bool catalogAssignmentsRefs})> {
  $$CatalogsTableTableManager(_$AppDatabase db, $CatalogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime?> validUntil = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogsCompanion(
            uuid: uuid,
            name: name,
            description: description,
            validUntil: validUntil,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<DateTime?> validUntil = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogsCompanion.insert(
            uuid: uuid,
            name: name,
            description: description,
            validUntil: validUntil,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CatalogsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {catalogItemsRefs = false, catalogAssignmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (catalogItemsRefs) db.catalogItems,
                if (catalogAssignmentsRefs) db.catalogAssignments
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (catalogItemsRefs)
                    await $_getPrefetchedData<Catalog, $CatalogsTable,
                            CatalogItem>(
                        currentTable: table,
                        referencedTable: $$CatalogsTableReferences
                            ._catalogItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CatalogsTableReferences(db, table, p0)
                                .catalogItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.catalogUuid == item.uuid),
                        typedResults: items),
                  if (catalogAssignmentsRefs)
                    await $_getPrefetchedData<Catalog, $CatalogsTable,
                            CatalogAssignment>(
                        currentTable: table,
                        referencedTable: $$CatalogsTableReferences
                            ._catalogAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CatalogsTableReferences(db, table, p0)
                                .catalogAssignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.catalogUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CatalogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogsTable,
    Catalog,
    $$CatalogsTableFilterComposer,
    $$CatalogsTableOrderingComposer,
    $$CatalogsTableAnnotationComposer,
    $$CatalogsTableCreateCompanionBuilder,
    $$CatalogsTableUpdateCompanionBuilder,
    (Catalog, $$CatalogsTableReferences),
    Catalog,
    PrefetchHooks Function(
        {bool catalogItemsRefs, bool catalogAssignmentsRefs})>;
typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion
    Function({
  required String uuid,
  required String catalogUuid,
  required String productUuid,
  Value<double?> customPrice,
  Value<String?> batchUuid,
  Value<DateTime?> validUntil,
  Value<String> batchSelectionStrategy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<String> uuid,
  Value<String> catalogUuid,
  Value<String> productUuid,
  Value<double?> customPrice,
  Value<String?> batchUuid,
  Value<DateTime?> validUntil,
  Value<String> batchSelectionStrategy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$CatalogItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem> {
  $$CatalogItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogsTable _catalogUuidTable(_$AppDatabase db) =>
      db.catalogs.createAlias(
          $_aliasNameGenerator(db.catalogItems.catalogUuid, db.catalogs.uuid));

  $$CatalogsTableProcessedTableManager get catalogUuid {
    final $_column = $_itemColumn<String>('catalog_uuid')!;

    final manager = $$CatalogsTableTableManager($_db, $_db.catalogs)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productUuidTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.catalogItems.productUuid, db.products.uuid));

  $$ProductsTableProcessedTableManager get productUuid {
    final $_column = $_itemColumn<String>('product_uuid')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductBatchesTable _batchUuidTable(_$AppDatabase db) =>
      db.productBatches.createAlias($_aliasNameGenerator(
          db.catalogItems.batchUuid, db.productBatches.uuid));

  $$ProductBatchesTableProcessedTableManager? get batchUuid {
    final $_column = $_itemColumn<String>('batch_uuid');
    if ($_column == null) return null;
    final manager = $$ProductBatchesTableTableManager($_db, $_db.productBatches)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CatalogTieredDiscountsTable,
      List<CatalogTieredDiscount>> _catalogTieredDiscountsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.catalogTieredDiscounts,
          aliasName: $_aliasNameGenerator(
              db.catalogItems.uuid, db.catalogTieredDiscounts.catalogItemUuid));

  $$CatalogTieredDiscountsTableProcessedTableManager
      get catalogTieredDiscountsRefs {
    final manager = $$CatalogTieredDiscountsTableTableManager(
            $_db, $_db.catalogTieredDiscounts)
        .filter((f) =>
            f.catalogItemUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache =
        $_typedResult.readTableOrNull(_catalogTieredDiscountsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CatalogItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get customPrice => $composableBuilder(
      column: $table.customPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchSelectionStrategy => $composableBuilder(
      column: $table.batchSelectionStrategy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$CatalogsTableFilterComposer get catalogUuid {
    final $$CatalogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogUuid,
        referencedTable: $db.catalogs,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogsTableFilterComposer(
              $db: $db,
              $table: $db.catalogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productUuid {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableFilterComposer get batchUuid {
    final $$ProductBatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableFilterComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> catalogTieredDiscountsRefs(
      Expression<bool> Function($$CatalogTieredDiscountsTableFilterComposer f)
          f) {
    final $$CatalogTieredDiscountsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.catalogTieredDiscounts,
            getReferencedColumn: (t) => t.catalogItemUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CatalogTieredDiscountsTableFilterComposer(
                  $db: $db,
                  $table: $db.catalogTieredDiscounts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get customPrice => $composableBuilder(
      column: $table.customPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchSelectionStrategy => $composableBuilder(
      column: $table.batchSelectionStrategy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$CatalogsTableOrderingComposer get catalogUuid {
    final $$CatalogsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogUuid,
        referencedTable: $db.catalogs,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogsTableOrderingComposer(
              $db: $db,
              $table: $db.catalogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productUuid {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableOrderingComposer get batchUuid {
    final $$ProductBatchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableOrderingComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get customPrice => $composableBuilder(
      column: $table.customPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get validUntil => $composableBuilder(
      column: $table.validUntil, builder: (column) => column);

  GeneratedColumn<String> get batchSelectionStrategy => $composableBuilder(
      column: $table.batchSelectionStrategy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$CatalogsTableAnnotationComposer get catalogUuid {
    final $$CatalogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogUuid,
        referencedTable: $db.catalogs,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productUuid {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productUuid,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductBatchesTableAnnotationComposer get batchUuid {
    final $$ProductBatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchUuid,
        referencedTable: $db.productBatches,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductBatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.productBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> catalogTieredDiscountsRefs<T extends Object>(
      Expression<T> Function($$CatalogTieredDiscountsTableAnnotationComposer a)
          f) {
    final $$CatalogTieredDiscountsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.uuid,
            referencedTable: $db.catalogTieredDiscounts,
            getReferencedColumn: (t) => t.catalogItemUuid,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CatalogTieredDiscountsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.catalogTieredDiscounts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CatalogItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItem,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (CatalogItem, $$CatalogItemsTableReferences),
    CatalogItem,
    PrefetchHooks Function(
        {bool catalogUuid,
        bool productUuid,
        bool batchUuid,
        bool catalogTieredDiscountsRefs})> {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> catalogUuid = const Value.absent(),
            Value<String> productUuid = const Value.absent(),
            Value<double?> customPrice = const Value.absent(),
            Value<String?> batchUuid = const Value.absent(),
            Value<DateTime?> validUntil = const Value.absent(),
            Value<String> batchSelectionStrategy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion(
            uuid: uuid,
            catalogUuid: catalogUuid,
            productUuid: productUuid,
            customPrice: customPrice,
            batchUuid: batchUuid,
            validUntil: validUntil,
            batchSelectionStrategy: batchSelectionStrategy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String catalogUuid,
            required String productUuid,
            Value<double?> customPrice = const Value.absent(),
            Value<String?> batchUuid = const Value.absent(),
            Value<DateTime?> validUntil = const Value.absent(),
            Value<String> batchSelectionStrategy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogItemsCompanion.insert(
            uuid: uuid,
            catalogUuid: catalogUuid,
            productUuid: productUuid,
            customPrice: customPrice,
            batchUuid: batchUuid,
            validUntil: validUntil,
            batchSelectionStrategy: batchSelectionStrategy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CatalogItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {catalogUuid = false,
              productUuid = false,
              batchUuid = false,
              catalogTieredDiscountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (catalogTieredDiscountsRefs) db.catalogTieredDiscounts
              ],
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
                if (catalogUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.catalogUuid,
                    referencedTable:
                        $$CatalogItemsTableReferences._catalogUuidTable(db),
                    referencedColumn: $$CatalogItemsTableReferences
                        ._catalogUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (productUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productUuid,
                    referencedTable:
                        $$CatalogItemsTableReferences._productUuidTable(db),
                    referencedColumn: $$CatalogItemsTableReferences
                        ._productUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (batchUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batchUuid,
                    referencedTable:
                        $$CatalogItemsTableReferences._batchUuidTable(db),
                    referencedColumn:
                        $$CatalogItemsTableReferences._batchUuidTable(db).uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (catalogTieredDiscountsRefs)
                    await $_getPrefetchedData<CatalogItem, $CatalogItemsTable,
                            CatalogTieredDiscount>(
                        currentTable: table,
                        referencedTable: $$CatalogItemsTableReferences
                            ._catalogTieredDiscountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CatalogItemsTableReferences(db, table, p0)
                                .catalogTieredDiscountsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.catalogItemUuid == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CatalogItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItem,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (CatalogItem, $$CatalogItemsTableReferences),
    CatalogItem,
    PrefetchHooks Function(
        {bool catalogUuid,
        bool productUuid,
        bool batchUuid,
        bool catalogTieredDiscountsRefs})>;
typedef $$CatalogAssignmentsTableCreateCompanionBuilder
    = CatalogAssignmentsCompanion Function({
  required String uuid,
  required String catalogUuid,
  required String contactUuid,
  Value<DateTime> createdAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$CatalogAssignmentsTableUpdateCompanionBuilder
    = CatalogAssignmentsCompanion Function({
  Value<String> uuid,
  Value<String> catalogUuid,
  Value<String> contactUuid,
  Value<DateTime> createdAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$CatalogAssignmentsTableReferences extends BaseReferences<
    _$AppDatabase, $CatalogAssignmentsTable, CatalogAssignment> {
  $$CatalogAssignmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CatalogsTable _catalogUuidTable(_$AppDatabase db) =>
      db.catalogs.createAlias($_aliasNameGenerator(
          db.catalogAssignments.catalogUuid, db.catalogs.uuid));

  $$CatalogsTableProcessedTableManager get catalogUuid {
    final $_column = $_itemColumn<String>('catalog_uuid')!;

    final manager = $$CatalogsTableTableManager($_db, $_db.catalogs)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ContactsTable _contactUuidTable(_$AppDatabase db) =>
      db.contacts.createAlias($_aliasNameGenerator(
          db.catalogAssignments.contactUuid, db.contacts.uuid));

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

class $$CatalogAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogAssignmentsTable> {
  $$CatalogAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$CatalogsTableFilterComposer get catalogUuid {
    final $$CatalogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogUuid,
        referencedTable: $db.catalogs,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogsTableFilterComposer(
              $db: $db,
              $table: $db.catalogs,
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

class $$CatalogAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogAssignmentsTable> {
  $$CatalogAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$CatalogsTableOrderingComposer get catalogUuid {
    final $$CatalogsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogUuid,
        referencedTable: $db.catalogs,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogsTableOrderingComposer(
              $db: $db,
              $table: $db.catalogs,
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

class $$CatalogAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogAssignmentsTable> {
  $$CatalogAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$CatalogsTableAnnotationComposer get catalogUuid {
    final $$CatalogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogUuid,
        referencedTable: $db.catalogs,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogs,
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

class $$CatalogAssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogAssignmentsTable,
    CatalogAssignment,
    $$CatalogAssignmentsTableFilterComposer,
    $$CatalogAssignmentsTableOrderingComposer,
    $$CatalogAssignmentsTableAnnotationComposer,
    $$CatalogAssignmentsTableCreateCompanionBuilder,
    $$CatalogAssignmentsTableUpdateCompanionBuilder,
    (CatalogAssignment, $$CatalogAssignmentsTableReferences),
    CatalogAssignment,
    PrefetchHooks Function({bool catalogUuid, bool contactUuid})> {
  $$CatalogAssignmentsTableTableManager(
      _$AppDatabase db, $CatalogAssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogAssignmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> catalogUuid = const Value.absent(),
            Value<String> contactUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogAssignmentsCompanion(
            uuid: uuid,
            catalogUuid: catalogUuid,
            contactUuid: contactUuid,
            createdAt: createdAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String catalogUuid,
            required String contactUuid,
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogAssignmentsCompanion.insert(
            uuid: uuid,
            catalogUuid: catalogUuid,
            contactUuid: contactUuid,
            createdAt: createdAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CatalogAssignmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({catalogUuid = false, contactUuid = false}) {
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
                if (catalogUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.catalogUuid,
                    referencedTable: $$CatalogAssignmentsTableReferences
                        ._catalogUuidTable(db),
                    referencedColumn: $$CatalogAssignmentsTableReferences
                        ._catalogUuidTable(db)
                        .uuid,
                  ) as T;
                }
                if (contactUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactUuid,
                    referencedTable: $$CatalogAssignmentsTableReferences
                        ._contactUuidTable(db),
                    referencedColumn: $$CatalogAssignmentsTableReferences
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

typedef $$CatalogAssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogAssignmentsTable,
    CatalogAssignment,
    $$CatalogAssignmentsTableFilterComposer,
    $$CatalogAssignmentsTableOrderingComposer,
    $$CatalogAssignmentsTableAnnotationComposer,
    $$CatalogAssignmentsTableCreateCompanionBuilder,
    $$CatalogAssignmentsTableUpdateCompanionBuilder,
    (CatalogAssignment, $$CatalogAssignmentsTableReferences),
    CatalogAssignment,
    PrefetchHooks Function({bool catalogUuid, bool contactUuid})>;
typedef $$CatalogTieredDiscountsTableCreateCompanionBuilder
    = CatalogTieredDiscountsCompanion Function({
  required String uuid,
  required String catalogItemUuid,
  required double minQuantity,
  required double discountPercentage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});
typedef $$CatalogTieredDiscountsTableUpdateCompanionBuilder
    = CatalogTieredDiscountsCompanion Function({
  Value<String> uuid,
  Value<String> catalogItemUuid,
  Value<double> minQuantity,
  Value<double> discountPercentage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<bool> isNotSynced,
  Value<int> rowid,
});

final class $$CatalogTieredDiscountsTableReferences extends BaseReferences<
    _$AppDatabase, $CatalogTieredDiscountsTable, CatalogTieredDiscount> {
  $$CatalogTieredDiscountsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _catalogItemUuidTable(_$AppDatabase db) =>
      db.catalogItems.createAlias($_aliasNameGenerator(
          db.catalogTieredDiscounts.catalogItemUuid, db.catalogItems.uuid));

  $$CatalogItemsTableProcessedTableManager get catalogItemUuid {
    final $_column = $_itemColumn<String>('catalog_item_uuid')!;

    final manager = $$CatalogItemsTableTableManager($_db, $_db.catalogItems)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogItemUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CatalogTieredDiscountsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogTieredDiscountsTable> {
  $$CatalogTieredDiscountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountPercentage => $composableBuilder(
      column: $table.discountPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnFilters(column));

  $$CatalogItemsTableFilterComposer get catalogItemUuid {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogItemUuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableFilterComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogTieredDiscountsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogTieredDiscountsTable> {
  $$CatalogTieredDiscountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountPercentage => $composableBuilder(
      column: $table.discountPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => ColumnOrderings(column));

  $$CatalogItemsTableOrderingComposer get catalogItemUuid {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogItemUuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableOrderingComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogTieredDiscountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogTieredDiscountsTable> {
  $$CatalogTieredDiscountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<double> get minQuantity => $composableBuilder(
      column: $table.minQuantity, builder: (column) => column);

  GeneratedColumn<double> get discountPercentage => $composableBuilder(
      column: $table.discountPercentage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isNotSynced => $composableBuilder(
      column: $table.isNotSynced, builder: (column) => column);

  $$CatalogItemsTableAnnotationComposer get catalogItemUuid {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.catalogItemUuid,
        referencedTable: $db.catalogItems,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CatalogItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.catalogItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CatalogTieredDiscountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogTieredDiscountsTable,
    CatalogTieredDiscount,
    $$CatalogTieredDiscountsTableFilterComposer,
    $$CatalogTieredDiscountsTableOrderingComposer,
    $$CatalogTieredDiscountsTableAnnotationComposer,
    $$CatalogTieredDiscountsTableCreateCompanionBuilder,
    $$CatalogTieredDiscountsTableUpdateCompanionBuilder,
    (CatalogTieredDiscount, $$CatalogTieredDiscountsTableReferences),
    CatalogTieredDiscount,
    PrefetchHooks Function({bool catalogItemUuid})> {
  $$CatalogTieredDiscountsTableTableManager(
      _$AppDatabase db, $CatalogTieredDiscountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogTieredDiscountsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogTieredDiscountsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogTieredDiscountsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> catalogItemUuid = const Value.absent(),
            Value<double> minQuantity = const Value.absent(),
            Value<double> discountPercentage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogTieredDiscountsCompanion(
            uuid: uuid,
            catalogItemUuid: catalogItemUuid,
            minQuantity: minQuantity,
            discountPercentage: discountPercentage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String catalogItemUuid,
            required double minQuantity,
            required double discountPercentage,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<bool> isNotSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogTieredDiscountsCompanion.insert(
            uuid: uuid,
            catalogItemUuid: catalogItemUuid,
            minQuantity: minQuantity,
            discountPercentage: discountPercentage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            isNotSynced: isNotSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CatalogTieredDiscountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({catalogItemUuid = false}) {
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
                if (catalogItemUuid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.catalogItemUuid,
                    referencedTable: $$CatalogTieredDiscountsTableReferences
                        ._catalogItemUuidTable(db),
                    referencedColumn: $$CatalogTieredDiscountsTableReferences
                        ._catalogItemUuidTable(db)
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

typedef $$CatalogTieredDiscountsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CatalogTieredDiscountsTable,
        CatalogTieredDiscount,
        $$CatalogTieredDiscountsTableFilterComposer,
        $$CatalogTieredDiscountsTableOrderingComposer,
        $$CatalogTieredDiscountsTableAnnotationComposer,
        $$CatalogTieredDiscountsTableCreateCompanionBuilder,
        $$CatalogTieredDiscountsTableUpdateCompanionBuilder,
        (CatalogTieredDiscount, $$CatalogTieredDiscountsTableReferences),
        CatalogTieredDiscount,
        PrefetchHooks Function({bool catalogItemUuid})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductCategoriesTableTableManager get productCategories =>
      $$ProductCategoriesTableTableManager(_db, _db.productCategories);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AccountTransfersTableTableManager get accountTransfers =>
      $$AccountTransfersTableTableManager(_db, _db.accountTransfers);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$SyncLogTableTableManager get syncLog =>
      $$SyncLogTableTableManager(_db, _db.syncLog);
  $$AppCurrenciesTableTableManager get appCurrencies =>
      $$AppCurrenciesTableTableManager(_db, _db.appCurrencies);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductBatchesTableTableManager get productBatches =>
      $$ProductBatchesTableTableManager(_db, _db.productBatches);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$OrderReturnsTableTableManager get orderReturns =>
      $$OrderReturnsTableTableManager(_db, _db.orderReturns);
  $$OrderReturnItemsTableTableManager get orderReturnItems =>
      $$OrderReturnItemsTableTableManager(_db, _db.orderReturnItems);
  $$CatalogsTableTableManager get catalogs =>
      $$CatalogsTableTableManager(_db, _db.catalogs);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$CatalogAssignmentsTableTableManager get catalogAssignments =>
      $$CatalogAssignmentsTableTableManager(_db, _db.catalogAssignments);
  $$CatalogTieredDiscountsTableTableManager get catalogTieredDiscounts =>
      $$CatalogTieredDiscountsTableTableManager(
          _db, _db.catalogTieredDiscounts);
}
