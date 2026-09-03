// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'interest_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    phone,
    address,
    notes,
    interestRate,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['interest_rate']!,
          _interestRateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String name;
  final String type;
  final String? phone;
  final String? address;
  final String? notes;
  final double? interestRate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Party({
    required this.id,
    required this.name,
    required this.type,
    this.phone,
    this.address,
    this.notes,
    this.interestRate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || interestRate != null) {
      map['interest_rate'] = Variable<double>(interestRate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      interestRate: interestRate == null && nullToAbsent
          ? const Value.absent()
          : Value(interestRate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      interestRate: serializer.fromJson<double?>(json['interestRate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'interestRate': serializer.toJson<double?>(interestRate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Party copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<double?> interestRate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Party(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    interestRate: interestRate.present ? interestRate.value : this.interestRate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('interestRate: $interestRate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    phone,
    address,
    notes,
    interestRate,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.interestRate == this.interestRate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<double?> interestRate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<double>? interestRate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (interestRate != null) 'interest_rate': interestRate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? notes,
    Value<double?>? interestRate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      interestRate: interestRate ?? this.interestRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('interestRate: $interestRate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionNoMeta = const VerificationMeta(
    'transactionNo',
  );
  @override
  late final GeneratedColumn<String> transactionNo = GeneratedColumn<String>(
    'transaction_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debitMeta = const VerificationMeta('debit');
  @override
  late final GeneratedColumn<double> debit = GeneratedColumn<double>(
    'debit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  @override
  late final GeneratedColumn<double> credit = GeneratedColumn<double>(
    'credit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'interest_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNoMeta = const VerificationMeta(
    'referenceNo',
  );
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
    'reference_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedTransactionIdMeta =
      const VerificationMeta('linkedTransactionId');
  @override
  late final GeneratedColumn<String> linkedTransactionId =
      GeneratedColumn<String>(
        'linked_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id)',
        ),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionNo,
    partyId,
    date,
    type,
    amount,
    debit,
    credit,
    interestRate,
    paymentMode,
    referenceNo,
    description,
    linkedTransactionId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_no')) {
      context.handle(
        _transactionNoMeta,
        transactionNo.isAcceptableOrUnknown(
          data['transaction_no']!,
          _transactionNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionNoMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('debit')) {
      context.handle(
        _debitMeta,
        debit.isAcceptableOrUnknown(data['debit']!, _debitMeta),
      );
    }
    if (data.containsKey('credit')) {
      context.handle(
        _creditMeta,
        credit.isAcceptableOrUnknown(data['credit']!, _creditMeta),
      );
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['interest_rate']!,
          _interestRateMeta,
        ),
      );
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    }
    if (data.containsKey('reference_no')) {
      context.handle(
        _referenceNoMeta,
        referenceNo.isAcceptableOrUnknown(
          data['reference_no']!,
          _referenceNoMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('linked_transaction_id')) {
      context.handle(
        _linkedTransactionIdMeta,
        linkedTransactionId.isAcceptableOrUnknown(
          data['linked_transaction_id']!,
          _linkedTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_no'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      debit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debit'],
      )!,
      credit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit'],
      )!,
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate'],
      ),
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      ),
      referenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_no'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      linkedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_transaction_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionEntry extends DataClass
    implements Insertable<TransactionEntry> {
  final String id;
  final String transactionNo;
  final String partyId;
  final DateTime date;
  final String type;
  final double amount;
  final double debit;
  final double credit;
  final double? interestRate;
  final String? paymentMode;
  final String? referenceNo;
  final String? description;
  final String? linkedTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TransactionEntry({
    required this.id,
    required this.transactionNo,
    required this.partyId,
    required this.date,
    required this.type,
    required this.amount,
    required this.debit,
    required this.credit,
    this.interestRate,
    this.paymentMode,
    this.referenceNo,
    this.description,
    this.linkedTransactionId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_no'] = Variable<String>(transactionNo);
    map['party_id'] = Variable<String>(partyId);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['debit'] = Variable<double>(debit);
    map['credit'] = Variable<double>(credit);
    if (!nullToAbsent || interestRate != null) {
      map['interest_rate'] = Variable<double>(interestRate);
    }
    if (!nullToAbsent || paymentMode != null) {
      map['payment_mode'] = Variable<String>(paymentMode);
    }
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || linkedTransactionId != null) {
      map['linked_transaction_id'] = Variable<String>(linkedTransactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      transactionNo: Value(transactionNo),
      partyId: Value(partyId),
      date: Value(date),
      type: Value(type),
      amount: Value(amount),
      debit: Value(debit),
      credit: Value(credit),
      interestRate: interestRate == null && nullToAbsent
          ? const Value.absent()
          : Value(interestRate),
      paymentMode: paymentMode == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMode),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      linkedTransactionId: linkedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTransactionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TransactionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEntry(
      id: serializer.fromJson<String>(json['id']),
      transactionNo: serializer.fromJson<String>(json['transactionNo']),
      partyId: serializer.fromJson<String>(json['partyId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      debit: serializer.fromJson<double>(json['debit']),
      credit: serializer.fromJson<double>(json['credit']),
      interestRate: serializer.fromJson<double?>(json['interestRate']),
      paymentMode: serializer.fromJson<String?>(json['paymentMode']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      description: serializer.fromJson<String?>(json['description']),
      linkedTransactionId: serializer.fromJson<String?>(
        json['linkedTransactionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionNo': serializer.toJson<String>(transactionNo),
      'partyId': serializer.toJson<String>(partyId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'debit': serializer.toJson<double>(debit),
      'credit': serializer.toJson<double>(credit),
      'interestRate': serializer.toJson<double?>(interestRate),
      'paymentMode': serializer.toJson<String?>(paymentMode),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'description': serializer.toJson<String?>(description),
      'linkedTransactionId': serializer.toJson<String?>(linkedTransactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TransactionEntry copyWith({
    String? id,
    String? transactionNo,
    String? partyId,
    DateTime? date,
    String? type,
    double? amount,
    double? debit,
    double? credit,
    Value<double?> interestRate = const Value.absent(),
    Value<String?> paymentMode = const Value.absent(),
    Value<String?> referenceNo = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> linkedTransactionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TransactionEntry(
    id: id ?? this.id,
    transactionNo: transactionNo ?? this.transactionNo,
    partyId: partyId ?? this.partyId,
    date: date ?? this.date,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    debit: debit ?? this.debit,
    credit: credit ?? this.credit,
    interestRate: interestRate.present ? interestRate.value : this.interestRate,
    paymentMode: paymentMode.present ? paymentMode.value : this.paymentMode,
    referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
    description: description.present ? description.value : this.description,
    linkedTransactionId: linkedTransactionId.present
        ? linkedTransactionId.value
        : this.linkedTransactionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TransactionEntry copyWithCompanion(TransactionsCompanion data) {
    return TransactionEntry(
      id: data.id.present ? data.id.value : this.id,
      transactionNo: data.transactionNo.present
          ? data.transactionNo.value
          : this.transactionNo,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      debit: data.debit.present ? data.debit.value : this.debit,
      credit: data.credit.present ? data.credit.value : this.credit,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      referenceNo: data.referenceNo.present
          ? data.referenceNo.value
          : this.referenceNo,
      description: data.description.present
          ? data.description.value
          : this.description,
      linkedTransactionId: data.linkedTransactionId.present
          ? data.linkedTransactionId.value
          : this.linkedTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntry(')
          ..write('id: $id, ')
          ..write('transactionNo: $transactionNo, ')
          ..write('partyId: $partyId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('interestRate: $interestRate, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('description: $description, ')
          ..write('linkedTransactionId: $linkedTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionNo,
    partyId,
    date,
    type,
    amount,
    debit,
    credit,
    interestRate,
    paymentMode,
    referenceNo,
    description,
    linkedTransactionId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEntry &&
          other.id == this.id &&
          other.transactionNo == this.transactionNo &&
          other.partyId == this.partyId &&
          other.date == this.date &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.debit == this.debit &&
          other.credit == this.credit &&
          other.interestRate == this.interestRate &&
          other.paymentMode == this.paymentMode &&
          other.referenceNo == this.referenceNo &&
          other.description == this.description &&
          other.linkedTransactionId == this.linkedTransactionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionEntry> {
  final Value<String> id;
  final Value<String> transactionNo;
  final Value<String> partyId;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<double> amount;
  final Value<double> debit;
  final Value<double> credit;
  final Value<double?> interestRate;
  final Value<String?> paymentMode;
  final Value<String?> referenceNo;
  final Value<String?> description;
  final Value<String?> linkedTransactionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.transactionNo = const Value.absent(),
    this.partyId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.description = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String transactionNo,
    required String partyId,
    required DateTime date,
    required String type,
    required double amount,
    this.debit = const Value.absent(),
    this.credit = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.description = const Value.absent(),
    this.linkedTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionNo = Value(transactionNo),
       partyId = Value(partyId),
       date = Value(date),
       type = Value(type),
       amount = Value(amount);
  static Insertable<TransactionEntry> custom({
    Expression<String>? id,
    Expression<String>? transactionNo,
    Expression<String>? partyId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<double>? debit,
    Expression<double>? credit,
    Expression<double>? interestRate,
    Expression<String>? paymentMode,
    Expression<String>? referenceNo,
    Expression<String>? description,
    Expression<String>? linkedTransactionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionNo != null) 'transaction_no': transactionNo,
      if (partyId != null) 'party_id': partyId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (debit != null) 'debit': debit,
      if (credit != null) 'credit': credit,
      if (interestRate != null) 'interest_rate': interestRate,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (description != null) 'description': description,
      if (linkedTransactionId != null)
        'linked_transaction_id': linkedTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionNo,
    Value<String>? partyId,
    Value<DateTime>? date,
    Value<String>? type,
    Value<double>? amount,
    Value<double>? debit,
    Value<double>? credit,
    Value<double?>? interestRate,
    Value<String?>? paymentMode,
    Value<String?>? referenceNo,
    Value<String?>? description,
    Value<String?>? linkedTransactionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      transactionNo: transactionNo ?? this.transactionNo,
      partyId: partyId ?? this.partyId,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      interestRate: interestRate ?? this.interestRate,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNo: referenceNo ?? this.referenceNo,
      description: description ?? this.description,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionNo.present) {
      map['transaction_no'] = Variable<String>(transactionNo.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (debit.present) {
      map['debit'] = Variable<double>(debit.value);
    }
    if (credit.present) {
      map['credit'] = Variable<double>(credit.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (linkedTransactionId.present) {
      map['linked_transaction_id'] = Variable<String>(
        linkedTransactionId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionNo: $transactionNo, ')
          ..write('partyId: $partyId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('debit: $debit, ')
          ..write('credit: $credit, ')
          ..write('interestRate: $interestRate, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('description: $description, ')
          ..write('linkedTransactionId: $linkedTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionLineItemsTable extends TransactionLineItems
    with TableInfo<$TransactionLineItemsTable, TransactionLineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionLineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    description,
    quantity,
    unit,
    rate,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_line_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionLineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionLineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionLineItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $TransactionLineItemsTable createAlias(String alias) {
    return $TransactionLineItemsTable(attachedDatabase, alias);
  }
}

class TransactionLineItem extends DataClass
    implements Insertable<TransactionLineItem> {
  final String id;
  final String transactionId;
  final String description;
  final double quantity;
  final String? unit;
  final double rate;
  final double amount;
  const TransactionLineItem({
    required this.id,
    required this.transactionId,
    required this.description,
    required this.quantity,
    this.unit,
    required this.rate,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['rate'] = Variable<double>(rate);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  TransactionLineItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionLineItemsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      description: Value(description),
      quantity: Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      rate: Value(rate),
      amount: Value(amount),
    );
  }

  factory TransactionLineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionLineItem(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      rate: serializer.fromJson<double>(json['rate']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'rate': serializer.toJson<double>(rate),
      'amount': serializer.toJson<double>(amount),
    };
  }

  TransactionLineItem copyWith({
    String? id,
    String? transactionId,
    String? description,
    double? quantity,
    Value<String?> unit = const Value.absent(),
    double? rate,
    double? amount,
  }) => TransactionLineItem(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unit: unit.present ? unit.value : this.unit,
    rate: rate ?? this.rate,
    amount: amount ?? this.amount,
  );
  TransactionLineItem copyWithCompanion(TransactionLineItemsCompanion data) {
    return TransactionLineItem(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      rate: data.rate.present ? data.rate.value : this.rate,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionLineItem(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('rate: $rate, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, transactionId, description, quantity, unit, rate, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionLineItem &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.rate == this.rate &&
          other.amount == this.amount);
}

class TransactionLineItemsCompanion
    extends UpdateCompanion<TransactionLineItem> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> description;
  final Value<double> quantity;
  final Value<String?> unit;
  final Value<double> rate;
  final Value<double> amount;
  final Value<int> rowid;
  const TransactionLineItemsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.rate = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionLineItemsCompanion.insert({
    required String id,
    required String transactionId,
    required String description,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.rate = const Value.absent(),
    required double amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       description = Value(description),
       amount = Value(amount);
  static Insertable<TransactionLineItem> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? description,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? rate,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (rate != null) 'rate': rate,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionLineItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? description,
    Value<double>? quantity,
    Value<String?>? unit,
    Value<double>? rate,
    Value<double>? amount,
    Value<int>? rowid,
  }) {
    return TransactionLineItemsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionLineItemsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('rate: $rate, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentDetailsTable extends PaymentDetails
    with TableInfo<$PaymentDetailsTable, PaymentDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNoMeta = const VerificationMeta(
    'referenceNo',
  );
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
    'reference_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _utrNoMeta = const VerificationMeta('utrNo');
  @override
  late final GeneratedColumn<String> utrNo = GeneratedColumn<String>(
    'utr_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chequeNoMeta = const VerificationMeta(
    'chequeNo',
  );
  @override
  late final GeneratedColumn<String> chequeNo = GeneratedColumn<String>(
    'cheque_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    paymentMode,
    referenceNo,
    utrNo,
    bankName,
    chequeNo,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentDetail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    }
    if (data.containsKey('reference_no')) {
      context.handle(
        _referenceNoMeta,
        referenceNo.isAcceptableOrUnknown(
          data['reference_no']!,
          _referenceNoMeta,
        ),
      );
    }
    if (data.containsKey('utr_no')) {
      context.handle(
        _utrNoMeta,
        utrNo.isAcceptableOrUnknown(data['utr_no']!, _utrNoMeta),
      );
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    }
    if (data.containsKey('cheque_no')) {
      context.handle(
        _chequeNoMeta,
        chequeNo.isAcceptableOrUnknown(data['cheque_no']!, _chequeNoMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentDetail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      ),
      referenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_no'],
      ),
      utrNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utr_no'],
      ),
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      ),
      chequeNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cheque_no'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PaymentDetailsTable createAlias(String alias) {
    return $PaymentDetailsTable(attachedDatabase, alias);
  }
}

class PaymentDetail extends DataClass implements Insertable<PaymentDetail> {
  final String id;
  final String transactionId;
  final String? paymentMode;
  final String? referenceNo;
  final String? utrNo;
  final String? bankName;
  final String? chequeNo;
  final String? notes;
  const PaymentDetail({
    required this.id,
    required this.transactionId,
    this.paymentMode,
    this.referenceNo,
    this.utrNo,
    this.bankName,
    this.chequeNo,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    if (!nullToAbsent || paymentMode != null) {
      map['payment_mode'] = Variable<String>(paymentMode);
    }
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    if (!nullToAbsent || utrNo != null) {
      map['utr_no'] = Variable<String>(utrNo);
    }
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || chequeNo != null) {
      map['cheque_no'] = Variable<String>(chequeNo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PaymentDetailsCompanion toCompanion(bool nullToAbsent) {
    return PaymentDetailsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      paymentMode: paymentMode == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMode),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      utrNo: utrNo == null && nullToAbsent
          ? const Value.absent()
          : Value(utrNo),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      chequeNo: chequeNo == null && nullToAbsent
          ? const Value.absent()
          : Value(chequeNo),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PaymentDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentDetail(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      paymentMode: serializer.fromJson<String?>(json['paymentMode']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      utrNo: serializer.fromJson<String?>(json['utrNo']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      chequeNo: serializer.fromJson<String?>(json['chequeNo']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'paymentMode': serializer.toJson<String?>(paymentMode),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'utrNo': serializer.toJson<String?>(utrNo),
      'bankName': serializer.toJson<String?>(bankName),
      'chequeNo': serializer.toJson<String?>(chequeNo),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PaymentDetail copyWith({
    String? id,
    String? transactionId,
    Value<String?> paymentMode = const Value.absent(),
    Value<String?> referenceNo = const Value.absent(),
    Value<String?> utrNo = const Value.absent(),
    Value<String?> bankName = const Value.absent(),
    Value<String?> chequeNo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => PaymentDetail(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    paymentMode: paymentMode.present ? paymentMode.value : this.paymentMode,
    referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
    utrNo: utrNo.present ? utrNo.value : this.utrNo,
    bankName: bankName.present ? bankName.value : this.bankName,
    chequeNo: chequeNo.present ? chequeNo.value : this.chequeNo,
    notes: notes.present ? notes.value : this.notes,
  );
  PaymentDetail copyWithCompanion(PaymentDetailsCompanion data) {
    return PaymentDetail(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      referenceNo: data.referenceNo.present
          ? data.referenceNo.value
          : this.referenceNo,
      utrNo: data.utrNo.present ? data.utrNo.value : this.utrNo,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      chequeNo: data.chequeNo.present ? data.chequeNo.value : this.chequeNo,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentDetail(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('utrNo: $utrNo, ')
          ..write('bankName: $bankName, ')
          ..write('chequeNo: $chequeNo, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    paymentMode,
    referenceNo,
    utrNo,
    bankName,
    chequeNo,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentDetail &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.paymentMode == this.paymentMode &&
          other.referenceNo == this.referenceNo &&
          other.utrNo == this.utrNo &&
          other.bankName == this.bankName &&
          other.chequeNo == this.chequeNo &&
          other.notes == this.notes);
}

class PaymentDetailsCompanion extends UpdateCompanion<PaymentDetail> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String?> paymentMode;
  final Value<String?> referenceNo;
  final Value<String?> utrNo;
  final Value<String?> bankName;
  final Value<String?> chequeNo;
  final Value<String?> notes;
  final Value<int> rowid;
  const PaymentDetailsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.utrNo = const Value.absent(),
    this.bankName = const Value.absent(),
    this.chequeNo = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentDetailsCompanion.insert({
    required String id,
    required String transactionId,
    this.paymentMode = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.utrNo = const Value.absent(),
    this.bankName = const Value.absent(),
    this.chequeNo = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId);
  static Insertable<PaymentDetail> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? paymentMode,
    Expression<String>? referenceNo,
    Expression<String>? utrNo,
    Expression<String>? bankName,
    Expression<String>? chequeNo,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (utrNo != null) 'utr_no': utrNo,
      if (bankName != null) 'bank_name': bankName,
      if (chequeNo != null) 'cheque_no': chequeNo,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentDetailsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String?>? paymentMode,
    Value<String?>? referenceNo,
    Value<String?>? utrNo,
    Value<String?>? bankName,
    Value<String?>? chequeNo,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return PaymentDetailsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNo: referenceNo ?? this.referenceNo,
      utrNo: utrNo ?? this.utrNo,
      bankName: bankName ?? this.bankName,
      chequeNo: chequeNo ?? this.chequeNo,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (utrNo.present) {
      map['utr_no'] = Variable<String>(utrNo.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (chequeNo.present) {
      map['cheque_no'] = Variable<String>(chequeNo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentDetailsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('utrNo: $utrNo, ')
          ..write('bankName: $bankName, ')
          ..write('chequeNo: $chequeNo, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShopSettingsTable extends ShopSettings
    with TableInfo<$ShopSettingsTable, ShopSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _shopNameMeta = const VerificationMeta(
    'shopName',
  );
  @override
  late final GeneratedColumn<String> shopName = GeneratedColumn<String>(
    'shop_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Rukmini Jewellers'),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Main Market, Jewelry Bazaar'),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('+91 98765 43210'),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoicePrefixMeta = const VerificationMeta(
    'invoicePrefix',
  );
  @override
  late final GeneratedColumn<String> invoicePrefix = GeneratedColumn<String>(
    'invoice_prefix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INV-'),
  );
  static const VerificationMeta _receiptPrefixMeta = const VerificationMeta(
    'receiptPrefix',
  );
  @override
  late final GeneratedColumn<String> receiptPrefix = GeneratedColumn<String>(
    'receipt_prefix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('REC-'),
  );
  static const VerificationMeta _txnPrefixMeta = const VerificationMeta(
    'txnPrefix',
  );
  @override
  late final GeneratedColumn<String> txnPrefix = GeneratedColumn<String>(
    'txn_prefix',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TXN-'),
  );
  static const VerificationMeta _nextSeqMeta = const VerificationMeta(
    'nextSeq',
  );
  @override
  late final GeneratedColumn<int> nextSeq = GeneratedColumn<int>(
    'next_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1001),
  );
  static const VerificationMeta _termsMeta = const VerificationMeta('terms');
  @override
  late final GeneratedColumn<String> terms = GeneratedColumn<String>(
    'terms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(
      '1. Goods once sold will not be taken back.\n2. Subject to local jurisdiction.',
    ),
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Rs'),
  );
  static const VerificationMeta _backupDirectoryMeta = const VerificationMeta(
    'backupDirectory',
  );
  @override
  late final GeneratedColumn<String> backupDirectory = GeneratedColumn<String>(
    'backup_directory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoicesDirectoryMeta = const VerificationMeta(
    'invoicesDirectory',
  );
  @override
  late final GeneratedColumn<String> invoicesDirectory =
      GeneratedColumn<String>(
        'invoices_directory',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastAutoBackupDateMeta =
      const VerificationMeta('lastAutoBackupDate');
  @override
  late final GeneratedColumn<String> lastAutoBackupDate =
      GeneratedColumn<String>(
        'last_auto_backup_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isFirstRunCompletedMeta =
      const VerificationMeta('isFirstRunCompleted');
  @override
  late final GeneratedColumn<bool> isFirstRunCompleted = GeneratedColumn<bool>(
    'is_first_run_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_first_run_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appPinMeta = const VerificationMeta('appPin');
  @override
  late final GeneratedColumn<String> appPin = GeneratedColumn<String>(
    'app_pin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopName,
    address,
    phone,
    email,
    invoicePrefix,
    receiptPrefix,
    txnPrefix,
    nextSeq,
    terms,
    currencySymbol,
    backupDirectory,
    invoicesDirectory,
    lastAutoBackupDate,
    isFirstRunCompleted,
    appPin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShopSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shop_name')) {
      context.handle(
        _shopNameMeta,
        shopName.isAcceptableOrUnknown(data['shop_name']!, _shopNameMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('invoice_prefix')) {
      context.handle(
        _invoicePrefixMeta,
        invoicePrefix.isAcceptableOrUnknown(
          data['invoice_prefix']!,
          _invoicePrefixMeta,
        ),
      );
    }
    if (data.containsKey('receipt_prefix')) {
      context.handle(
        _receiptPrefixMeta,
        receiptPrefix.isAcceptableOrUnknown(
          data['receipt_prefix']!,
          _receiptPrefixMeta,
        ),
      );
    }
    if (data.containsKey('txn_prefix')) {
      context.handle(
        _txnPrefixMeta,
        txnPrefix.isAcceptableOrUnknown(data['txn_prefix']!, _txnPrefixMeta),
      );
    }
    if (data.containsKey('next_seq')) {
      context.handle(
        _nextSeqMeta,
        nextSeq.isAcceptableOrUnknown(data['next_seq']!, _nextSeqMeta),
      );
    }
    if (data.containsKey('terms')) {
      context.handle(
        _termsMeta,
        terms.isAcceptableOrUnknown(data['terms']!, _termsMeta),
      );
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
        ),
      );
    }
    if (data.containsKey('backup_directory')) {
      context.handle(
        _backupDirectoryMeta,
        backupDirectory.isAcceptableOrUnknown(
          data['backup_directory']!,
          _backupDirectoryMeta,
        ),
      );
    }
    if (data.containsKey('invoices_directory')) {
      context.handle(
        _invoicesDirectoryMeta,
        invoicesDirectory.isAcceptableOrUnknown(
          data['invoices_directory']!,
          _invoicesDirectoryMeta,
        ),
      );
    }
    if (data.containsKey('last_auto_backup_date')) {
      context.handle(
        _lastAutoBackupDateMeta,
        lastAutoBackupDate.isAcceptableOrUnknown(
          data['last_auto_backup_date']!,
          _lastAutoBackupDateMeta,
        ),
      );
    }
    if (data.containsKey('is_first_run_completed')) {
      context.handle(
        _isFirstRunCompletedMeta,
        isFirstRunCompleted.isAcceptableOrUnknown(
          data['is_first_run_completed']!,
          _isFirstRunCompletedMeta,
        ),
      );
    }
    if (data.containsKey('app_pin')) {
      context.handle(
        _appPinMeta,
        appPin.isAcceptableOrUnknown(data['app_pin']!, _appPinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      shopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      invoicePrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_prefix'],
      )!,
      receiptPrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_prefix'],
      )!,
      txnPrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}txn_prefix'],
      )!,
      nextSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_seq'],
      )!,
      terms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terms'],
      )!,
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
      )!,
      backupDirectory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_directory'],
      ),
      invoicesDirectory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoices_directory'],
      ),
      lastAutoBackupDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_auto_backup_date'],
      ),
      isFirstRunCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_first_run_completed'],
      )!,
      appPin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_pin'],
      ),
    );
  }

  @override
  $ShopSettingsTable createAlias(String alias) {
    return $ShopSettingsTable(attachedDatabase, alias);
  }
}

class ShopSetting extends DataClass implements Insertable<ShopSetting> {
  final int id;
  final String shopName;
  final String address;
  final String phone;
  final String? email;
  final String invoicePrefix;
  final String receiptPrefix;
  final String txnPrefix;
  final int nextSeq;
  final String terms;
  final String currencySymbol;
  final String? backupDirectory;
  final String? invoicesDirectory;
  final String? lastAutoBackupDate;
  final bool isFirstRunCompleted;
  final String? appPin;
  const ShopSetting({
    required this.id,
    required this.shopName,
    required this.address,
    required this.phone,
    this.email,
    required this.invoicePrefix,
    required this.receiptPrefix,
    required this.txnPrefix,
    required this.nextSeq,
    required this.terms,
    required this.currencySymbol,
    this.backupDirectory,
    this.invoicesDirectory,
    this.lastAutoBackupDate,
    required this.isFirstRunCompleted,
    this.appPin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shop_name'] = Variable<String>(shopName);
    map['address'] = Variable<String>(address);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['invoice_prefix'] = Variable<String>(invoicePrefix);
    map['receipt_prefix'] = Variable<String>(receiptPrefix);
    map['txn_prefix'] = Variable<String>(txnPrefix);
    map['next_seq'] = Variable<int>(nextSeq);
    map['terms'] = Variable<String>(terms);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    if (!nullToAbsent || backupDirectory != null) {
      map['backup_directory'] = Variable<String>(backupDirectory);
    }
    if (!nullToAbsent || invoicesDirectory != null) {
      map['invoices_directory'] = Variable<String>(invoicesDirectory);
    }
    if (!nullToAbsent || lastAutoBackupDate != null) {
      map['last_auto_backup_date'] = Variable<String>(lastAutoBackupDate);
    }
    map['is_first_run_completed'] = Variable<bool>(isFirstRunCompleted);
    if (!nullToAbsent || appPin != null) {
      map['app_pin'] = Variable<String>(appPin);
    }
    return map;
  }

  ShopSettingsCompanion toCompanion(bool nullToAbsent) {
    return ShopSettingsCompanion(
      id: Value(id),
      shopName: Value(shopName),
      address: Value(address),
      phone: Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      invoicePrefix: Value(invoicePrefix),
      receiptPrefix: Value(receiptPrefix),
      txnPrefix: Value(txnPrefix),
      nextSeq: Value(nextSeq),
      terms: Value(terms),
      currencySymbol: Value(currencySymbol),
      backupDirectory: backupDirectory == null && nullToAbsent
          ? const Value.absent()
          : Value(backupDirectory),
      invoicesDirectory: invoicesDirectory == null && nullToAbsent
          ? const Value.absent()
          : Value(invoicesDirectory),
      lastAutoBackupDate: lastAutoBackupDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAutoBackupDate),
      isFirstRunCompleted: Value(isFirstRunCompleted),
      appPin: appPin == null && nullToAbsent
          ? const Value.absent()
          : Value(appPin),
    );
  }

  factory ShopSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopSetting(
      id: serializer.fromJson<int>(json['id']),
      shopName: serializer.fromJson<String>(json['shopName']),
      address: serializer.fromJson<String>(json['address']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      invoicePrefix: serializer.fromJson<String>(json['invoicePrefix']),
      receiptPrefix: serializer.fromJson<String>(json['receiptPrefix']),
      txnPrefix: serializer.fromJson<String>(json['txnPrefix']),
      nextSeq: serializer.fromJson<int>(json['nextSeq']),
      terms: serializer.fromJson<String>(json['terms']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      backupDirectory: serializer.fromJson<String?>(json['backupDirectory']),
      invoicesDirectory: serializer.fromJson<String?>(
        json['invoicesDirectory'],
      ),
      lastAutoBackupDate: serializer.fromJson<String?>(
        json['lastAutoBackupDate'],
      ),
      isFirstRunCompleted: serializer.fromJson<bool>(
        json['isFirstRunCompleted'],
      ),
      appPin: serializer.fromJson<String?>(json['appPin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shopName': serializer.toJson<String>(shopName),
      'address': serializer.toJson<String>(address),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'invoicePrefix': serializer.toJson<String>(invoicePrefix),
      'receiptPrefix': serializer.toJson<String>(receiptPrefix),
      'txnPrefix': serializer.toJson<String>(txnPrefix),
      'nextSeq': serializer.toJson<int>(nextSeq),
      'terms': serializer.toJson<String>(terms),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'backupDirectory': serializer.toJson<String?>(backupDirectory),
      'invoicesDirectory': serializer.toJson<String?>(invoicesDirectory),
      'lastAutoBackupDate': serializer.toJson<String?>(lastAutoBackupDate),
      'isFirstRunCompleted': serializer.toJson<bool>(isFirstRunCompleted),
      'appPin': serializer.toJson<String?>(appPin),
    };
  }

  ShopSetting copyWith({
    int? id,
    String? shopName,
    String? address,
    String? phone,
    Value<String?> email = const Value.absent(),
    String? invoicePrefix,
    String? receiptPrefix,
    String? txnPrefix,
    int? nextSeq,
    String? terms,
    String? currencySymbol,
    Value<String?> backupDirectory = const Value.absent(),
    Value<String?> invoicesDirectory = const Value.absent(),
    Value<String?> lastAutoBackupDate = const Value.absent(),
    bool? isFirstRunCompleted,
    Value<String?> appPin = const Value.absent(),
  }) => ShopSetting(
    id: id ?? this.id,
    shopName: shopName ?? this.shopName,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    email: email.present ? email.value : this.email,
    invoicePrefix: invoicePrefix ?? this.invoicePrefix,
    receiptPrefix: receiptPrefix ?? this.receiptPrefix,
    txnPrefix: txnPrefix ?? this.txnPrefix,
    nextSeq: nextSeq ?? this.nextSeq,
    terms: terms ?? this.terms,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    backupDirectory: backupDirectory.present
        ? backupDirectory.value
        : this.backupDirectory,
    invoicesDirectory: invoicesDirectory.present
        ? invoicesDirectory.value
        : this.invoicesDirectory,
    lastAutoBackupDate: lastAutoBackupDate.present
        ? lastAutoBackupDate.value
        : this.lastAutoBackupDate,
    isFirstRunCompleted: isFirstRunCompleted ?? this.isFirstRunCompleted,
    appPin: appPin.present ? appPin.value : this.appPin,
  );
  ShopSetting copyWithCompanion(ShopSettingsCompanion data) {
    return ShopSetting(
      id: data.id.present ? data.id.value : this.id,
      shopName: data.shopName.present ? data.shopName.value : this.shopName,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      invoicePrefix: data.invoicePrefix.present
          ? data.invoicePrefix.value
          : this.invoicePrefix,
      receiptPrefix: data.receiptPrefix.present
          ? data.receiptPrefix.value
          : this.receiptPrefix,
      txnPrefix: data.txnPrefix.present ? data.txnPrefix.value : this.txnPrefix,
      nextSeq: data.nextSeq.present ? data.nextSeq.value : this.nextSeq,
      terms: data.terms.present ? data.terms.value : this.terms,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      backupDirectory: data.backupDirectory.present
          ? data.backupDirectory.value
          : this.backupDirectory,
      invoicesDirectory: data.invoicesDirectory.present
          ? data.invoicesDirectory.value
          : this.invoicesDirectory,
      lastAutoBackupDate: data.lastAutoBackupDate.present
          ? data.lastAutoBackupDate.value
          : this.lastAutoBackupDate,
      isFirstRunCompleted: data.isFirstRunCompleted.present
          ? data.isFirstRunCompleted.value
          : this.isFirstRunCompleted,
      appPin: data.appPin.present ? data.appPin.value : this.appPin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopSetting(')
          ..write('id: $id, ')
          ..write('shopName: $shopName, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('invoicePrefix: $invoicePrefix, ')
          ..write('receiptPrefix: $receiptPrefix, ')
          ..write('txnPrefix: $txnPrefix, ')
          ..write('nextSeq: $nextSeq, ')
          ..write('terms: $terms, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('backupDirectory: $backupDirectory, ')
          ..write('invoicesDirectory: $invoicesDirectory, ')
          ..write('lastAutoBackupDate: $lastAutoBackupDate, ')
          ..write('isFirstRunCompleted: $isFirstRunCompleted, ')
          ..write('appPin: $appPin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopName,
    address,
    phone,
    email,
    invoicePrefix,
    receiptPrefix,
    txnPrefix,
    nextSeq,
    terms,
    currencySymbol,
    backupDirectory,
    invoicesDirectory,
    lastAutoBackupDate,
    isFirstRunCompleted,
    appPin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopSetting &&
          other.id == this.id &&
          other.shopName == this.shopName &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.invoicePrefix == this.invoicePrefix &&
          other.receiptPrefix == this.receiptPrefix &&
          other.txnPrefix == this.txnPrefix &&
          other.nextSeq == this.nextSeq &&
          other.terms == this.terms &&
          other.currencySymbol == this.currencySymbol &&
          other.backupDirectory == this.backupDirectory &&
          other.invoicesDirectory == this.invoicesDirectory &&
          other.lastAutoBackupDate == this.lastAutoBackupDate &&
          other.isFirstRunCompleted == this.isFirstRunCompleted &&
          other.appPin == this.appPin);
}

class ShopSettingsCompanion extends UpdateCompanion<ShopSetting> {
  final Value<int> id;
  final Value<String> shopName;
  final Value<String> address;
  final Value<String> phone;
  final Value<String?> email;
  final Value<String> invoicePrefix;
  final Value<String> receiptPrefix;
  final Value<String> txnPrefix;
  final Value<int> nextSeq;
  final Value<String> terms;
  final Value<String> currencySymbol;
  final Value<String?> backupDirectory;
  final Value<String?> invoicesDirectory;
  final Value<String?> lastAutoBackupDate;
  final Value<bool> isFirstRunCompleted;
  final Value<String?> appPin;
  const ShopSettingsCompanion({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.invoicePrefix = const Value.absent(),
    this.receiptPrefix = const Value.absent(),
    this.txnPrefix = const Value.absent(),
    this.nextSeq = const Value.absent(),
    this.terms = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.backupDirectory = const Value.absent(),
    this.invoicesDirectory = const Value.absent(),
    this.lastAutoBackupDate = const Value.absent(),
    this.isFirstRunCompleted = const Value.absent(),
    this.appPin = const Value.absent(),
  });
  ShopSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.invoicePrefix = const Value.absent(),
    this.receiptPrefix = const Value.absent(),
    this.txnPrefix = const Value.absent(),
    this.nextSeq = const Value.absent(),
    this.terms = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.backupDirectory = const Value.absent(),
    this.invoicesDirectory = const Value.absent(),
    this.lastAutoBackupDate = const Value.absent(),
    this.isFirstRunCompleted = const Value.absent(),
    this.appPin = const Value.absent(),
  });
  static Insertable<ShopSetting> custom({
    Expression<int>? id,
    Expression<String>? shopName,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? invoicePrefix,
    Expression<String>? receiptPrefix,
    Expression<String>? txnPrefix,
    Expression<int>? nextSeq,
    Expression<String>? terms,
    Expression<String>? currencySymbol,
    Expression<String>? backupDirectory,
    Expression<String>? invoicesDirectory,
    Expression<String>? lastAutoBackupDate,
    Expression<bool>? isFirstRunCompleted,
    Expression<String>? appPin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopName != null) 'shop_name': shopName,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (invoicePrefix != null) 'invoice_prefix': invoicePrefix,
      if (receiptPrefix != null) 'receipt_prefix': receiptPrefix,
      if (txnPrefix != null) 'txn_prefix': txnPrefix,
      if (nextSeq != null) 'next_seq': nextSeq,
      if (terms != null) 'terms': terms,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (backupDirectory != null) 'backup_directory': backupDirectory,
      if (invoicesDirectory != null) 'invoices_directory': invoicesDirectory,
      if (lastAutoBackupDate != null)
        'last_auto_backup_date': lastAutoBackupDate,
      if (isFirstRunCompleted != null)
        'is_first_run_completed': isFirstRunCompleted,
      if (appPin != null) 'app_pin': appPin,
    });
  }

  ShopSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? shopName,
    Value<String>? address,
    Value<String>? phone,
    Value<String?>? email,
    Value<String>? invoicePrefix,
    Value<String>? receiptPrefix,
    Value<String>? txnPrefix,
    Value<int>? nextSeq,
    Value<String>? terms,
    Value<String>? currencySymbol,
    Value<String?>? backupDirectory,
    Value<String?>? invoicesDirectory,
    Value<String?>? lastAutoBackupDate,
    Value<bool>? isFirstRunCompleted,
    Value<String?>? appPin,
  }) {
    return ShopSettingsCompanion(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      receiptPrefix: receiptPrefix ?? this.receiptPrefix,
      txnPrefix: txnPrefix ?? this.txnPrefix,
      nextSeq: nextSeq ?? this.nextSeq,
      terms: terms ?? this.terms,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      backupDirectory: backupDirectory ?? this.backupDirectory,
      invoicesDirectory: invoicesDirectory ?? this.invoicesDirectory,
      lastAutoBackupDate: lastAutoBackupDate ?? this.lastAutoBackupDate,
      isFirstRunCompleted: isFirstRunCompleted ?? this.isFirstRunCompleted,
      appPin: appPin ?? this.appPin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shopName.present) {
      map['shop_name'] = Variable<String>(shopName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (invoicePrefix.present) {
      map['invoice_prefix'] = Variable<String>(invoicePrefix.value);
    }
    if (receiptPrefix.present) {
      map['receipt_prefix'] = Variable<String>(receiptPrefix.value);
    }
    if (txnPrefix.present) {
      map['txn_prefix'] = Variable<String>(txnPrefix.value);
    }
    if (nextSeq.present) {
      map['next_seq'] = Variable<int>(nextSeq.value);
    }
    if (terms.present) {
      map['terms'] = Variable<String>(terms.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (backupDirectory.present) {
      map['backup_directory'] = Variable<String>(backupDirectory.value);
    }
    if (invoicesDirectory.present) {
      map['invoices_directory'] = Variable<String>(invoicesDirectory.value);
    }
    if (lastAutoBackupDate.present) {
      map['last_auto_backup_date'] = Variable<String>(lastAutoBackupDate.value);
    }
    if (isFirstRunCompleted.present) {
      map['is_first_run_completed'] = Variable<bool>(isFirstRunCompleted.value);
    }
    if (appPin.present) {
      map['app_pin'] = Variable<String>(appPin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopSettingsCompanion(')
          ..write('id: $id, ')
          ..write('shopName: $shopName, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('invoicePrefix: $invoicePrefix, ')
          ..write('receiptPrefix: $receiptPrefix, ')
          ..write('txnPrefix: $txnPrefix, ')
          ..write('nextSeq: $nextSeq, ')
          ..write('terms: $terms, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('backupDirectory: $backupDirectory, ')
          ..write('invoicesDirectory: $invoicesDirectory, ')
          ..write('lastAutoBackupDate: $lastAutoBackupDate, ')
          ..write('isFirstRunCompleted: $isFirstRunCompleted, ')
          ..write('appPin: $appPin')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionLineItemsTable transactionLineItems =
      $TransactionLineItemsTable(this);
  late final $PaymentDetailsTable paymentDetails = $PaymentDetailsTable(this);
  late final $ShopSettingsTable shopSettings = $ShopSettingsTable(this);
  late final Index idxTxParty = Index(
    'idx_tx_party',
    'CREATE INDEX idx_tx_party ON transactions (party_id)',
  );
  late final Index idxTxDate = Index(
    'idx_tx_date',
    'CREATE INDEX idx_tx_date ON transactions (date)',
  );
  late final Index idxTxDeleted = Index(
    'idx_tx_deleted',
    'CREATE INDEX idx_tx_deleted ON transactions (deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    parties,
    transactions,
    transactionLineItems,
    paymentDetails,
    shopSettings,
    idxTxParty,
    idxTxDate,
    idxTxDeleted,
  ];
}

typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> notes,
      Value<double?> interestRate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> notes,
      Value<double?> interestRate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PartiesTableReferences
    extends BaseReferences<_$AppDatabase, $PartiesTable, Party> {
  $$PartiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<TransactionEntry>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'parties__id__transactions__party_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, $$PartiesTableReferences),
          Party,
          PrefetchHooks Function({bool transactionsRefs})
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> interestRate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                name: name,
                type: type,
                phone: phone,
                address: address,
                notes: notes,
                interestRate: interestRate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double?> interestRate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                name: name,
                type: type,
                phone: phone,
                address: address,
                notes: notes,
                interestRate: interestRate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<
                      Party,
                      $PartiesTable,
                      TransactionEntry
                    >(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences
                          ._transactionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PartiesTableReferences(
                        db,
                        table,
                        p0,
                      ).transactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.partyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, $$PartiesTableReferences),
      Party,
      PrefetchHooks Function({bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String transactionNo,
      required String partyId,
      required DateTime date,
      required String type,
      required double amount,
      Value<double> debit,
      Value<double> credit,
      Value<double?> interestRate,
      Value<String?> paymentMode,
      Value<String?> referenceNo,
      Value<String?> description,
      Value<String?> linkedTransactionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> transactionNo,
      Value<String> partyId,
      Value<DateTime> date,
      Value<String> type,
      Value<double> amount,
      Value<double> debit,
      Value<double> credit,
      Value<double?> interestRate,
      Value<String?> paymentMode,
      Value<String?> referenceNo,
      Value<String?> description,
      Value<String?> linkedTransactionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionEntry> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartiesTable _partyIdTable(_$AppDatabase db) =>
      db.parties.createAlias('transactions__party_id__parties__id');

  $$PartiesTableProcessedTableManager get partyId {
    final $_column = $_itemColumn<String>('party_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransactionsTable _linkedTransactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('transactions__linked_transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager? get linkedTransactionId {
    final $_column = $_itemColumn<String>('linked_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TransactionLineItemsTable,
    List<TransactionLineItem>
  >
  _transactionLineItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionLineItems,
        aliasName: 'transactions__id__transaction_line_items__transaction_id',
      );

  $$TransactionLineItemsTableProcessedTableManager
  get transactionLineItemsRefs {
    final manager = $$TransactionLineItemsTableTableManager(
      $_db,
      $_db.transactionLineItems,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionLineItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentDetailsTable, List<PaymentDetail>>
  _paymentDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentDetails,
    aliasName: 'transactions__id__payment_details__transaction_id',
  );

  $$PaymentDetailsTableProcessedTableManager get paymentDetailsRefs {
    final manager = $$PaymentDetailsTableTableManager(
      $_db,
      $_db.paymentDetails,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentDetailsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableFilterComposer get linkedTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionLineItemsRefs(
    Expression<bool> Function($$TransactionLineItemsTableFilterComposer f) f,
  ) {
    final $$TransactionLineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionLineItems,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionLineItemsTableFilterComposer(
            $db: $db,
            $table: $db.transactionLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentDetailsRefs(
    Expression<bool> Function($$PaymentDetailsTableFilterComposer f) f,
  ) {
    final $$PaymentDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentDetails,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentDetailsTableFilterComposer(
            $db: $db,
            $table: $db.paymentDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableOrderingComposer get linkedTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionNo => $composableBuilder(
    column: $table.transactionNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get debit =>
      $composableBuilder(column: $table.debit, builder: (column) => column);

  GeneratedColumn<double> get credit =>
      $composableBuilder(column: $table.credit, builder: (column) => column);

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransactionsTableAnnotationComposer get linkedTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedTransactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionLineItemsRefs<T extends Object>(
    Expression<T> Function($$TransactionLineItemsTableAnnotationComposer a) f,
  ) {
    final $$TransactionLineItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionLineItems,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionLineItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionLineItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> paymentDetailsRefs<T extends Object>(
    Expression<T> Function($$PaymentDetailsTableAnnotationComposer a) f,
  ) {
    final $$PaymentDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentDetails,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionEntry,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionEntry, $$TransactionsTableReferences),
          TransactionEntry,
          PrefetchHooks Function({
            bool partyId,
            bool linkedTransactionId,
            bool transactionLineItemsRefs,
            bool paymentDetailsRefs,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionNo = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> debit = const Value.absent(),
                Value<double> credit = const Value.absent(),
                Value<double?> interestRate = const Value.absent(),
                Value<String?> paymentMode = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> linkedTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                transactionNo: transactionNo,
                partyId: partyId,
                date: date,
                type: type,
                amount: amount,
                debit: debit,
                credit: credit,
                interestRate: interestRate,
                paymentMode: paymentMode,
                referenceNo: referenceNo,
                description: description,
                linkedTransactionId: linkedTransactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionNo,
                required String partyId,
                required DateTime date,
                required String type,
                required double amount,
                Value<double> debit = const Value.absent(),
                Value<double> credit = const Value.absent(),
                Value<double?> interestRate = const Value.absent(),
                Value<String?> paymentMode = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> linkedTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                transactionNo: transactionNo,
                partyId: partyId,
                date: date,
                type: type,
                amount: amount,
                debit: debit,
                credit: credit,
                interestRate: interestRate,
                paymentMode: paymentMode,
                referenceNo: referenceNo,
                description: description,
                linkedTransactionId: linkedTransactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                partyId = false,
                linkedTransactionId = false,
                transactionLineItemsRefs = false,
                paymentDetailsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionLineItemsRefs) db.transactionLineItems,
                    if (paymentDetailsRefs) db.paymentDetails,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (partyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._partyIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._partyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (linkedTransactionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.linkedTransactionId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._linkedTransactionIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._linkedTransactionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionLineItemsRefs)
                        await $_getPrefetchedData<
                          TransactionEntry,
                          $TransactionsTable,
                          TransactionLineItem
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionLineItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionLineItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentDetailsRefs)
                        await $_getPrefetchedData<
                          TransactionEntry,
                          $TransactionsTable,
                          PaymentDetail
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._paymentDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentDetailsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionEntry,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionEntry, $$TransactionsTableReferences),
      TransactionEntry,
      PrefetchHooks Function({
        bool partyId,
        bool linkedTransactionId,
        bool transactionLineItemsRefs,
        bool paymentDetailsRefs,
      })
    >;
typedef $$TransactionLineItemsTableCreateCompanionBuilder =
    TransactionLineItemsCompanion Function({
      required String id,
      required String transactionId,
      required String description,
      Value<double> quantity,
      Value<String?> unit,
      Value<double> rate,
      required double amount,
      Value<int> rowid,
    });
typedef $$TransactionLineItemsTableUpdateCompanionBuilder =
    TransactionLineItemsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> description,
      Value<double> quantity,
      Value<String?> unit,
      Value<double> rate,
      Value<double> amount,
      Value<int> rowid,
    });

final class $$TransactionLineItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionLineItemsTable,
          TransactionLineItem
        > {
  $$TransactionLineItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('transaction_line_items__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionLineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionLineItemsTable> {
  $$TransactionLineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionLineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionLineItemsTable> {
  $$TransactionLineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionLineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionLineItemsTable> {
  $$TransactionLineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionLineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionLineItemsTable,
          TransactionLineItem,
          $$TransactionLineItemsTableFilterComposer,
          $$TransactionLineItemsTableOrderingComposer,
          $$TransactionLineItemsTableAnnotationComposer,
          $$TransactionLineItemsTableCreateCompanionBuilder,
          $$TransactionLineItemsTableUpdateCompanionBuilder,
          (TransactionLineItem, $$TransactionLineItemsTableReferences),
          TransactionLineItem,
          PrefetchHooks Function({bool transactionId})
        > {
  $$TransactionLineItemsTableTableManager(
    _$AppDatabase db,
    $TransactionLineItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionLineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionLineItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TransactionLineItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionLineItemsCompanion(
                id: id,
                transactionId: transactionId,
                description: description,
                quantity: quantity,
                unit: unit,
                rate: rate,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String description,
                Value<double> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double> rate = const Value.absent(),
                required double amount,
                Value<int> rowid = const Value.absent(),
              }) => TransactionLineItemsCompanion.insert(
                id: id,
                transactionId: transactionId,
                description: description,
                quantity: quantity,
                unit: unit,
                rate: rate,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionLineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionLineItemsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionLineItemsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionLineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionLineItemsTable,
      TransactionLineItem,
      $$TransactionLineItemsTableFilterComposer,
      $$TransactionLineItemsTableOrderingComposer,
      $$TransactionLineItemsTableAnnotationComposer,
      $$TransactionLineItemsTableCreateCompanionBuilder,
      $$TransactionLineItemsTableUpdateCompanionBuilder,
      (TransactionLineItem, $$TransactionLineItemsTableReferences),
      TransactionLineItem,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$PaymentDetailsTableCreateCompanionBuilder =
    PaymentDetailsCompanion Function({
      required String id,
      required String transactionId,
      Value<String?> paymentMode,
      Value<String?> referenceNo,
      Value<String?> utrNo,
      Value<String?> bankName,
      Value<String?> chequeNo,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$PaymentDetailsTableUpdateCompanionBuilder =
    PaymentDetailsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String?> paymentMode,
      Value<String?> referenceNo,
      Value<String?> utrNo,
      Value<String?> bankName,
      Value<String?> chequeNo,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$PaymentDetailsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentDetailsTable, PaymentDetail> {
  $$PaymentDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) => db
      .transactions
      .createAlias('payment_details__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentDetailsTable> {
  $$PaymentDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utrNo => $composableBuilder(
    column: $table.utrNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chequeNo => $composableBuilder(
    column: $table.chequeNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentDetailsTable> {
  $$PaymentDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utrNo => $composableBuilder(
    column: $table.utrNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chequeNo => $composableBuilder(
    column: $table.chequeNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentDetailsTable> {
  $$PaymentDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get utrNo =>
      $composableBuilder(column: $table.utrNo, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get chequeNo =>
      $composableBuilder(column: $table.chequeNo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentDetailsTable,
          PaymentDetail,
          $$PaymentDetailsTableFilterComposer,
          $$PaymentDetailsTableOrderingComposer,
          $$PaymentDetailsTableAnnotationComposer,
          $$PaymentDetailsTableCreateCompanionBuilder,
          $$PaymentDetailsTableUpdateCompanionBuilder,
          (PaymentDetail, $$PaymentDetailsTableReferences),
          PaymentDetail,
          PrefetchHooks Function({bool transactionId})
        > {
  $$PaymentDetailsTableTableManager(
    _$AppDatabase db,
    $PaymentDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String?> paymentMode = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<String?> utrNo = const Value.absent(),
                Value<String?> bankName = const Value.absent(),
                Value<String?> chequeNo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentDetailsCompanion(
                id: id,
                transactionId: transactionId,
                paymentMode: paymentMode,
                referenceNo: referenceNo,
                utrNo: utrNo,
                bankName: bankName,
                chequeNo: chequeNo,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                Value<String?> paymentMode = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<String?> utrNo = const Value.absent(),
                Value<String?> bankName = const Value.absent(),
                Value<String?> chequeNo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentDetailsCompanion.insert(
                id: id,
                transactionId: transactionId,
                paymentMode: paymentMode,
                referenceNo: referenceNo,
                utrNo: utrNo,
                bankName: bankName,
                chequeNo: chequeNo,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable: $$PaymentDetailsTableReferences
                                    ._transactionIdTable(db),
                                referencedColumn:
                                    $$PaymentDetailsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentDetailsTable,
      PaymentDetail,
      $$PaymentDetailsTableFilterComposer,
      $$PaymentDetailsTableOrderingComposer,
      $$PaymentDetailsTableAnnotationComposer,
      $$PaymentDetailsTableCreateCompanionBuilder,
      $$PaymentDetailsTableUpdateCompanionBuilder,
      (PaymentDetail, $$PaymentDetailsTableReferences),
      PaymentDetail,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$ShopSettingsTableCreateCompanionBuilder =
    ShopSettingsCompanion Function({
      Value<int> id,
      Value<String> shopName,
      Value<String> address,
      Value<String> phone,
      Value<String?> email,
      Value<String> invoicePrefix,
      Value<String> receiptPrefix,
      Value<String> txnPrefix,
      Value<int> nextSeq,
      Value<String> terms,
      Value<String> currencySymbol,
      Value<String?> backupDirectory,
      Value<String?> invoicesDirectory,
      Value<String?> lastAutoBackupDate,
      Value<bool> isFirstRunCompleted,
      Value<String?> appPin,
    });
typedef $$ShopSettingsTableUpdateCompanionBuilder =
    ShopSettingsCompanion Function({
      Value<int> id,
      Value<String> shopName,
      Value<String> address,
      Value<String> phone,
      Value<String?> email,
      Value<String> invoicePrefix,
      Value<String> receiptPrefix,
      Value<String> txnPrefix,
      Value<int> nextSeq,
      Value<String> terms,
      Value<String> currencySymbol,
      Value<String?> backupDirectory,
      Value<String?> invoicesDirectory,
      Value<String?> lastAutoBackupDate,
      Value<bool> isFirstRunCompleted,
      Value<String?> appPin,
    });

class $$ShopSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopSettingsTable> {
  $$ShopSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPrefix => $composableBuilder(
    column: $table.receiptPrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txnPrefix => $composableBuilder(
    column: $table.txnPrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextSeq => $composableBuilder(
    column: $table.nextSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupDirectory => $composableBuilder(
    column: $table.backupDirectory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoicesDirectory => $composableBuilder(
    column: $table.invoicesDirectory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAutoBackupDate => $composableBuilder(
    column: $table.lastAutoBackupDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFirstRunCompleted => $composableBuilder(
    column: $table.isFirstRunCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appPin => $composableBuilder(
    column: $table.appPin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShopSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopSettingsTable> {
  $$ShopSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPrefix => $composableBuilder(
    column: $table.receiptPrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txnPrefix => $composableBuilder(
    column: $table.txnPrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextSeq => $composableBuilder(
    column: $table.nextSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupDirectory => $composableBuilder(
    column: $table.backupDirectory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoicesDirectory => $composableBuilder(
    column: $table.invoicesDirectory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAutoBackupDate => $composableBuilder(
    column: $table.lastAutoBackupDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFirstRunCompleted => $composableBuilder(
    column: $table.isFirstRunCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appPin => $composableBuilder(
    column: $table.appPin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShopSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopSettingsTable> {
  $$ShopSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopName =>
      $composableBuilder(column: $table.shopName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptPrefix => $composableBuilder(
    column: $table.receiptPrefix,
    builder: (column) => column,
  );

  GeneratedColumn<String> get txnPrefix =>
      $composableBuilder(column: $table.txnPrefix, builder: (column) => column);

  GeneratedColumn<int> get nextSeq =>
      $composableBuilder(column: $table.nextSeq, builder: (column) => column);

  GeneratedColumn<String> get terms =>
      $composableBuilder(column: $table.terms, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backupDirectory => $composableBuilder(
    column: $table.backupDirectory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoicesDirectory => $composableBuilder(
    column: $table.invoicesDirectory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastAutoBackupDate => $composableBuilder(
    column: $table.lastAutoBackupDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFirstRunCompleted => $composableBuilder(
    column: $table.isFirstRunCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appPin =>
      $composableBuilder(column: $table.appPin, builder: (column) => column);
}

class $$ShopSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopSettingsTable,
          ShopSetting,
          $$ShopSettingsTableFilterComposer,
          $$ShopSettingsTableOrderingComposer,
          $$ShopSettingsTableAnnotationComposer,
          $$ShopSettingsTableCreateCompanionBuilder,
          $$ShopSettingsTableUpdateCompanionBuilder,
          (
            ShopSetting,
            BaseReferences<_$AppDatabase, $ShopSettingsTable, ShopSetting>,
          ),
          ShopSetting,
          PrefetchHooks Function()
        > {
  $$ShopSettingsTableTableManager(_$AppDatabase db, $ShopSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> shopName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> invoicePrefix = const Value.absent(),
                Value<String> receiptPrefix = const Value.absent(),
                Value<String> txnPrefix = const Value.absent(),
                Value<int> nextSeq = const Value.absent(),
                Value<String> terms = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<String?> backupDirectory = const Value.absent(),
                Value<String?> invoicesDirectory = const Value.absent(),
                Value<String?> lastAutoBackupDate = const Value.absent(),
                Value<bool> isFirstRunCompleted = const Value.absent(),
                Value<String?> appPin = const Value.absent(),
              }) => ShopSettingsCompanion(
                id: id,
                shopName: shopName,
                address: address,
                phone: phone,
                email: email,
                invoicePrefix: invoicePrefix,
                receiptPrefix: receiptPrefix,
                txnPrefix: txnPrefix,
                nextSeq: nextSeq,
                terms: terms,
                currencySymbol: currencySymbol,
                backupDirectory: backupDirectory,
                invoicesDirectory: invoicesDirectory,
                lastAutoBackupDate: lastAutoBackupDate,
                isFirstRunCompleted: isFirstRunCompleted,
                appPin: appPin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> shopName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> invoicePrefix = const Value.absent(),
                Value<String> receiptPrefix = const Value.absent(),
                Value<String> txnPrefix = const Value.absent(),
                Value<int> nextSeq = const Value.absent(),
                Value<String> terms = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<String?> backupDirectory = const Value.absent(),
                Value<String?> invoicesDirectory = const Value.absent(),
                Value<String?> lastAutoBackupDate = const Value.absent(),
                Value<bool> isFirstRunCompleted = const Value.absent(),
                Value<String?> appPin = const Value.absent(),
              }) => ShopSettingsCompanion.insert(
                id: id,
                shopName: shopName,
                address: address,
                phone: phone,
                email: email,
                invoicePrefix: invoicePrefix,
                receiptPrefix: receiptPrefix,
                txnPrefix: txnPrefix,
                nextSeq: nextSeq,
                terms: terms,
                currencySymbol: currencySymbol,
                backupDirectory: backupDirectory,
                invoicesDirectory: invoicesDirectory,
                lastAutoBackupDate: lastAutoBackupDate,
                isFirstRunCompleted: isFirstRunCompleted,
                appPin: appPin,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShopSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopSettingsTable,
      ShopSetting,
      $$ShopSettingsTableFilterComposer,
      $$ShopSettingsTableOrderingComposer,
      $$ShopSettingsTableAnnotationComposer,
      $$ShopSettingsTableCreateCompanionBuilder,
      $$ShopSettingsTableUpdateCompanionBuilder,
      (
        ShopSetting,
        BaseReferences<_$AppDatabase, $ShopSettingsTable, ShopSetting>,
      ),
      ShopSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionLineItemsTableTableManager get transactionLineItems =>
      $$TransactionLineItemsTableTableManager(_db, _db.transactionLineItems);
  $$PaymentDetailsTableTableManager get paymentDetails =>
      $$PaymentDetailsTableTableManager(_db, _db.paymentDetails);
  $$ShopSettingsTableTableManager get shopSettings =>
      $$ShopSettingsTableTableManager(_db, _db.shopSettings);
}
