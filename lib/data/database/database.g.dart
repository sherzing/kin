// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarLocalPathMeta = const VerificationMeta(
    'avatarLocalPath',
  );
  @override
  late final GeneratedColumn<String> avatarLocalPath = GeneratedColumn<String>(
    'avatar_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<int> birthday = GeneratedColumn<int>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jobTitleMeta = const VerificationMeta(
    'jobTitle',
  );
  @override
  late final GeneratedColumn<String> jobTitle = GeneratedColumn<String>(
    'job_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceDaysMeta = const VerificationMeta(
    'cadenceDays',
  );
  @override
  late final GeneratedColumn<int> cadenceDays = GeneratedColumn<int>(
    'cadence_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _lastContactedAtMeta = const VerificationMeta(
    'lastContactedAt',
  );
  @override
  late final GeneratedColumn<int> lastContactedAt = GeneratedColumn<int>(
    'last_contacted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<int> snoozedUntil = GeneratedColumn<int>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatarLocalPath,
    phone,
    email,
    birthday,
    jobTitle,
    cadenceDays,
    lastContactedAt,
    snoozedUntil,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contact> instance, {
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
    if (data.containsKey('avatar_local_path')) {
      context.handle(
        _avatarLocalPathMeta,
        avatarLocalPath.isAcceptableOrUnknown(
          data['avatar_local_path']!,
          _avatarLocalPathMeta,
        ),
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
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('job_title')) {
      context.handle(
        _jobTitleMeta,
        jobTitle.isAcceptableOrUnknown(data['job_title']!, _jobTitleMeta),
      );
    }
    if (data.containsKey('cadence_days')) {
      context.handle(
        _cadenceDaysMeta,
        cadenceDays.isAcceptableOrUnknown(
          data['cadence_days']!,
          _cadenceDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_contacted_at')) {
      context.handle(
        _lastContactedAtMeta,
        lastContactedAt.isAcceptableOrUnknown(
          data['last_contacted_at']!,
          _lastContactedAtMeta,
        ),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_local_path'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birthday'],
      ),
      jobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_title'],
      ),
      cadenceDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence_days'],
      )!,
      lastContactedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_contacted_at'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozed_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  /// UUID v4 primary key.
  final String id;

  /// Contact's display name.
  final String name;

  /// Local file path to avatar image.
  final String? avatarLocalPath;

  /// Phone number.
  final String? phone;

  /// Email address.
  final String? email;

  /// Birthday as Unix timestamp.
  final int? birthday;

  /// Job title.
  final String? jobTitle;

  /// Desired contact frequency in days.
  final int cadenceDays;

  /// Last time user interacted with this contact (Unix timestamp).
  final int? lastContactedAt;

  /// Hides contact from Daily Deck until this date (Unix timestamp).
  final int? snoozedUntil;

  /// Row creation timestamp (Unix).
  final int createdAt;

  /// Row last update timestamp (Unix).
  final int updatedAt;

  /// Soft delete timestamp (Unix). NULL means not deleted.
  final int? deletedAt;

  /// Dirty flag for sync - true if changed locally since last sync.
  final bool isDirty;
  const Contact({
    required this.id,
    required this.name,
    this.avatarLocalPath,
    this.phone,
    this.email,
    this.birthday,
    this.jobTitle,
    required this.cadenceDays,
    this.lastContactedAt,
    this.snoozedUntil,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarLocalPath != null) {
      map['avatar_local_path'] = Variable<String>(avatarLocalPath);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<int>(birthday);
    }
    if (!nullToAbsent || jobTitle != null) {
      map['job_title'] = Variable<String>(jobTitle);
    }
    map['cadence_days'] = Variable<int>(cadenceDays);
    if (!nullToAbsent || lastContactedAt != null) {
      map['last_contacted_at'] = Variable<int>(lastContactedAt);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<int>(snoozedUntil);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      name: Value(name),
      avatarLocalPath: avatarLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarLocalPath),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      jobTitle: jobTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(jobTitle),
      cadenceDays: Value(cadenceDays),
      lastContactedAt: lastContactedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastContactedAt),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarLocalPath: serializer.fromJson<String?>(json['avatarLocalPath']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      birthday: serializer.fromJson<int?>(json['birthday']),
      jobTitle: serializer.fromJson<String?>(json['jobTitle']),
      cadenceDays: serializer.fromJson<int>(json['cadenceDays']),
      lastContactedAt: serializer.fromJson<int?>(json['lastContactedAt']),
      snoozedUntil: serializer.fromJson<int?>(json['snoozedUntil']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatarLocalPath': serializer.toJson<String?>(avatarLocalPath),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'birthday': serializer.toJson<int?>(birthday),
      'jobTitle': serializer.toJson<String?>(jobTitle),
      'cadenceDays': serializer.toJson<int>(cadenceDays),
      'lastContactedAt': serializer.toJson<int?>(lastContactedAt),
      'snoozedUntil': serializer.toJson<int?>(snoozedUntil),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Contact copyWith({
    String? id,
    String? name,
    Value<String?> avatarLocalPath = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<int?> birthday = const Value.absent(),
    Value<String?> jobTitle = const Value.absent(),
    int? cadenceDays,
    Value<int?> lastContactedAt = const Value.absent(),
    Value<int?> snoozedUntil = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
  }) => Contact(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarLocalPath: avatarLocalPath.present
        ? avatarLocalPath.value
        : this.avatarLocalPath,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    birthday: birthday.present ? birthday.value : this.birthday,
    jobTitle: jobTitle.present ? jobTitle.value : this.jobTitle,
    cadenceDays: cadenceDays ?? this.cadenceDays,
    lastContactedAt: lastContactedAt.present
        ? lastContactedAt.value
        : this.lastContactedAt,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarLocalPath: data.avatarLocalPath.present
          ? data.avatarLocalPath.value
          : this.avatarLocalPath,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      jobTitle: data.jobTitle.present ? data.jobTitle.value : this.jobTitle,
      cadenceDays: data.cadenceDays.present
          ? data.cadenceDays.value
          : this.cadenceDays,
      lastContactedAt: data.lastContactedAt.present
          ? data.lastContactedAt.value
          : this.lastContactedAt,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarLocalPath: $avatarLocalPath, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('birthday: $birthday, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('cadenceDays: $cadenceDays, ')
          ..write('lastContactedAt: $lastContactedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    avatarLocalPath,
    phone,
    email,
    birthday,
    jobTitle,
    cadenceDays,
    lastContactedAt,
    snoozedUntil,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarLocalPath == this.avatarLocalPath &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.birthday == this.birthday &&
          other.jobTitle == this.jobTitle &&
          other.cadenceDays == this.cadenceDays &&
          other.lastContactedAt == this.lastContactedAt &&
          other.snoozedUntil == this.snoozedUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> avatarLocalPath;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<int?> birthday;
  final Value<String?> jobTitle;
  final Value<int> cadenceDays;
  final Value<int?> lastContactedAt;
  final Value<int?> snoozedUntil;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarLocalPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.birthday = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.cadenceDays = const Value.absent(),
    this.lastContactedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    required String name,
    this.avatarLocalPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.birthday = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.cadenceDays = const Value.absent(),
    this.lastContactedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Contact> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? avatarLocalPath,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<int>? birthday,
    Expression<String>? jobTitle,
    Expression<int>? cadenceDays,
    Expression<int>? lastContactedAt,
    Expression<int>? snoozedUntil,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarLocalPath != null) 'avatar_local_path': avatarLocalPath,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (birthday != null) 'birthday': birthday,
      if (jobTitle != null) 'job_title': jobTitle,
      if (cadenceDays != null) 'cadence_days': cadenceDays,
      if (lastContactedAt != null) 'last_contacted_at': lastContactedAt,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? avatarLocalPath,
    Value<String?>? phone,
    Value<String?>? email,
    Value<int?>? birthday,
    Value<String?>? jobTitle,
    Value<int>? cadenceDays,
    Value<int?>? lastContactedAt,
    Value<int?>? snoozedUntil,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      jobTitle: jobTitle ?? this.jobTitle,
      cadenceDays: cadenceDays ?? this.cadenceDays,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
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
    if (avatarLocalPath.present) {
      map['avatar_local_path'] = Variable<String>(avatarLocalPath.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<int>(birthday.value);
    }
    if (jobTitle.present) {
      map['job_title'] = Variable<String>(jobTitle.value);
    }
    if (cadenceDays.present) {
      map['cadence_days'] = Variable<int>(cadenceDays.value);
    }
    if (lastContactedAt.present) {
      map['last_contacted_at'] = Variable<int>(lastContactedAt.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<int>(snoozedUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarLocalPath: $avatarLocalPath, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('birthday: $birthday, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('cadenceDays: $cadenceDays, ')
          ..write('lastContactedAt: $lastContactedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CirclesTable extends Circles with TableInfo<$CirclesTable, Circle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CirclesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorHex,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Circle> instance, {
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
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Circle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Circle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $CirclesTable createAlias(String alias) {
    return $CirclesTable(attachedDatabase, alias);
  }
}

class Circle extends DataClass implements Insertable<Circle> {
  /// UUID v4 primary key.
  final String id;

  /// Circle display name.
  final String name;

  /// Optional hex color code (e.g., "#FF5733").
  final String? colorHex;

  /// Row creation timestamp (Unix).
  final int createdAt;

  /// Row last update timestamp (Unix).
  final int updatedAt;

  /// Soft delete timestamp (Unix). NULL means not deleted.
  final int? deletedAt;

  /// Dirty flag for sync - true if changed locally since last sync.
  final bool isDirty;
  const Circle({
    required this.id,
    required this.name,
    this.colorHex,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  CirclesCompanion toCompanion(bool nullToAbsent) {
    return CirclesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory Circle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Circle(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String?>(colorHex),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Circle copyWith({
    String? id,
    String? name,
    Value<String?> colorHex = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
  }) => Circle(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  Circle copyWithCompanion(CirclesCompanion data) {
    return Circle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Circle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorHex, createdAt, updatedAt, deletedAt, isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Circle &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class CirclesCompanion extends UpdateCompanion<Circle> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> colorHex;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const CirclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CirclesCompanion.insert({
    required String id,
    required String name,
    this.colorHex = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Circle> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CirclesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? colorHex,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return CirclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
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
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CirclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactCirclesTable extends ContactCircles
    with TableInfo<$ContactCirclesTable, ContactCircle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactCirclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id)',
    ),
  );
  static const VerificationMeta _circleIdMeta = const VerificationMeta(
    'circleId',
  );
  @override
  late final GeneratedColumn<String> circleId = GeneratedColumn<String>(
    'circle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circles (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    contactId,
    circleId,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_circles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactCircle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('circle_id')) {
      context.handle(
        _circleIdMeta,
        circleId.isAcceptableOrUnknown(data['circle_id']!, _circleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circleIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contactId, circleId};
  @override
  ContactCircle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactCircle(
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      circleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circle_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $ContactCirclesTable createAlias(String alias) {
    return $ContactCirclesTable(attachedDatabase, alias);
  }
}

class ContactCircle extends DataClass implements Insertable<ContactCircle> {
  /// Reference to contact ID.
  final String contactId;

  /// Reference to circle ID.
  final String circleId;

  /// Row creation timestamp (Unix).
  final int createdAt;

  /// Row last update timestamp (Unix).
  final int updatedAt;

  /// Soft delete timestamp (Unix). NULL means not deleted.
  final int? deletedAt;

  /// Dirty flag for sync - true if changed locally since last sync.
  final bool isDirty;
  const ContactCircle({
    required this.contactId,
    required this.circleId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['contact_id'] = Variable<String>(contactId);
    map['circle_id'] = Variable<String>(circleId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ContactCirclesCompanion toCompanion(bool nullToAbsent) {
    return ContactCirclesCompanion(
      contactId: Value(contactId),
      circleId: Value(circleId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory ContactCircle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactCircle(
      contactId: serializer.fromJson<String>(json['contactId']),
      circleId: serializer.fromJson<String>(json['circleId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contactId': serializer.toJson<String>(contactId),
      'circleId': serializer.toJson<String>(circleId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  ContactCircle copyWith({
    String? contactId,
    String? circleId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
  }) => ContactCircle(
    contactId: contactId ?? this.contactId,
    circleId: circleId ?? this.circleId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  ContactCircle copyWithCompanion(ContactCirclesCompanion data) {
    return ContactCircle(
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      circleId: data.circleId.present ? data.circleId.value : this.circleId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactCircle(')
          ..write('contactId: $contactId, ')
          ..write('circleId: $circleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    contactId,
    circleId,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactCircle &&
          other.contactId == this.contactId &&
          other.circleId == this.circleId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class ContactCirclesCompanion extends UpdateCompanion<ContactCircle> {
  final Value<String> contactId;
  final Value<String> circleId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ContactCirclesCompanion({
    this.contactId = const Value.absent(),
    this.circleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactCirclesCompanion.insert({
    required String contactId,
    required String circleId,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contactId = Value(contactId),
       circleId = Value(circleId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ContactCircle> custom({
    Expression<String>? contactId,
    Expression<String>? circleId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contactId != null) 'contact_id': contactId,
      if (circleId != null) 'circle_id': circleId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactCirclesCompanion copyWith({
    Value<String>? contactId,
    Value<String>? circleId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return ContactCirclesCompanion(
      contactId: contactId ?? this.contactId,
      circleId: circleId ?? this.circleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (circleId.present) {
      map['circle_id'] = Variable<String>(circleId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactCirclesCompanion(')
          ..write('contactId: $contactId, ')
          ..write('circleId: $circleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InteractionsTable extends Interactions
    with TableInfo<$InteractionsTable, Interaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InteractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<String> contactId = GeneratedColumn<String>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id)',
    ),
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
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPreparationMeta = const VerificationMeta(
    'isPreparation',
  );
  @override
  late final GeneratedColumn<bool> isPreparation = GeneratedColumn<bool>(
    'is_preparation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preparation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _happenedAtMeta = const VerificationMeta(
    'happenedAt',
  );
  @override
  late final GeneratedColumn<int> happenedAt = GeneratedColumn<int>(
    'happened_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    type,
    content,
    isPreparation,
    happenedAt,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Interaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('is_preparation')) {
      context.handle(
        _isPreparationMeta,
        isPreparation.isAcceptableOrUnknown(
          data['is_preparation']!,
          _isPreparationMeta,
        ),
      );
    }
    if (data.containsKey('happened_at')) {
      context.handle(
        _happenedAtMeta,
        happenedAt.isAcceptableOrUnknown(data['happened_at']!, _happenedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Interaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Interaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      isPreparation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preparation'],
      )!,
      happenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}happened_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $InteractionsTable createAlias(String alias) {
    return $InteractionsTable(attachedDatabase, alias);
  }
}

class Interaction extends DataClass implements Insertable<Interaction> {
  /// UUID v4 primary key.
  final String id;

  /// Reference to the contact this interaction is with.
  final String contactId;

  /// Type of interaction: call, meetup, message, email, gift.
  final String type;

  /// Markdown content/notes for this interaction.
  final String? content;

  /// True = preparation note (before interaction), False = reflection (after).
  final bool isPreparation;

  /// When the interaction occurred (Unix timestamp).
  final int happenedAt;

  /// Row creation timestamp (Unix).
  final int createdAt;

  /// Row last update timestamp (Unix).
  final int updatedAt;

  /// Soft delete timestamp (Unix). NULL means not deleted.
  final int? deletedAt;

  /// Dirty flag for sync - true if changed locally since last sync.
  final bool isDirty;
  const Interaction({
    required this.id,
    required this.contactId,
    required this.type,
    this.content,
    required this.isPreparation,
    required this.happenedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contact_id'] = Variable<String>(contactId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['is_preparation'] = Variable<bool>(isPreparation);
    map['happened_at'] = Variable<int>(happenedAt);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  InteractionsCompanion toCompanion(bool nullToAbsent) {
    return InteractionsCompanion(
      id: Value(id),
      contactId: Value(contactId),
      type: Value(type),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      isPreparation: Value(isPreparation),
      happenedAt: Value(happenedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory Interaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Interaction(
      id: serializer.fromJson<String>(json['id']),
      contactId: serializer.fromJson<String>(json['contactId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String?>(json['content']),
      isPreparation: serializer.fromJson<bool>(json['isPreparation']),
      happenedAt: serializer.fromJson<int>(json['happenedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contactId': serializer.toJson<String>(contactId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String?>(content),
      'isPreparation': serializer.toJson<bool>(isPreparation),
      'happenedAt': serializer.toJson<int>(happenedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Interaction copyWith({
    String? id,
    String? contactId,
    String? type,
    Value<String?> content = const Value.absent(),
    bool? isPreparation,
    int? happenedAt,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    bool? isDirty,
  }) => Interaction(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    type: type ?? this.type,
    content: content.present ? content.value : this.content,
    isPreparation: isPreparation ?? this.isPreparation,
    happenedAt: happenedAt ?? this.happenedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  Interaction copyWithCompanion(InteractionsCompanion data) {
    return Interaction(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      isPreparation: data.isPreparation.present
          ? data.isPreparation.value
          : this.isPreparation,
      happenedAt: data.happenedAt.present
          ? data.happenedAt.value
          : this.happenedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Interaction(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('isPreparation: $isPreparation, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    type,
    content,
    isPreparation,
    happenedAt,
    createdAt,
    updatedAt,
    deletedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Interaction &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.type == this.type &&
          other.content == this.content &&
          other.isPreparation == this.isPreparation &&
          other.happenedAt == this.happenedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class InteractionsCompanion extends UpdateCompanion<Interaction> {
  final Value<String> id;
  final Value<String> contactId;
  final Value<String> type;
  final Value<String?> content;
  final Value<bool> isPreparation;
  final Value<int> happenedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const InteractionsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.isPreparation = const Value.absent(),
    this.happenedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InteractionsCompanion.insert({
    required String id,
    required String contactId,
    required String type,
    this.content = const Value.absent(),
    this.isPreparation = const Value.absent(),
    required int happenedAt,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contactId = Value(contactId),
       type = Value(type),
       happenedAt = Value(happenedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Interaction> custom({
    Expression<String>? id,
    Expression<String>? contactId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<bool>? isPreparation,
    Expression<int>? happenedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (isPreparation != null) 'is_preparation': isPreparation,
      if (happenedAt != null) 'happened_at': happenedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InteractionsCompanion copyWith({
    Value<String>? id,
    Value<String>? contactId,
    Value<String>? type,
    Value<String?>? content,
    Value<bool>? isPreparation,
    Value<int>? happenedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return InteractionsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      type: type ?? this.type,
      content: content ?? this.content,
      isPreparation: isPreparation ?? this.isPreparation,
      happenedAt: happenedAt ?? this.happenedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<String>(contactId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isPreparation.present) {
      map['is_preparation'] = Variable<bool>(isPreparation.value);
    }
    if (happenedAt.present) {
      map['happened_at'] = Variable<int>(happenedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InteractionsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('isPreparation: $isPreparation, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $CirclesTable circles = $CirclesTable(this);
  late final $ContactCirclesTable contactCircles = $ContactCirclesTable(this);
  late final $InteractionsTable interactions = $InteractionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contacts,
    circles,
    contactCircles,
    interactions,
  ];
}

typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      required String id,
      required String name,
      Value<String?> avatarLocalPath,
      Value<String?> phone,
      Value<String?> email,
      Value<int?> birthday,
      Value<String?> jobTitle,
      Value<int> cadenceDays,
      Value<int?> lastContactedAt,
      Value<int?> snoozedUntil,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> avatarLocalPath,
      Value<String?> phone,
      Value<String?> email,
      Value<int?> birthday,
      Value<String?> jobTitle,
      Value<int> cadenceDays,
      Value<int?> lastContactedAt,
      Value<int?> snoozedUntil,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContactCirclesTable, List<ContactCircle>>
  _contactCirclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contactCircles,
    aliasName: $_aliasNameGenerator(
      db.contacts.id,
      db.contactCircles.contactId,
    ),
  );

  $$ContactCirclesTableProcessedTableManager get contactCirclesRefs {
    final manager = $$ContactCirclesTableTableManager(
      $_db,
      $_db.contactCircles,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactCirclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InteractionsTable, List<Interaction>>
  _interactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.interactions,
    aliasName: $_aliasNameGenerator(db.contacts.id, db.interactions.contactId),
  );

  $$InteractionsTableProcessedTableManager get interactionsRefs {
    final manager = $$InteractionsTableTableManager(
      $_db,
      $_db.interactions,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_interactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarLocalPath => $composableBuilder(
    column: $table.avatarLocalPath,
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

  ColumnFilters<int> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastContactedAt => $composableBuilder(
    column: $table.lastContactedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contactCirclesRefs(
    Expression<bool> Function($$ContactCirclesTableFilterComposer f) f,
  ) {
    final $$ContactCirclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactCircles,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactCirclesTableFilterComposer(
            $db: $db,
            $table: $db.contactCircles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> interactionsRefs(
    Expression<bool> Function($$InteractionsTableFilterComposer f) f,
  ) {
    final $$InteractionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.interactions,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InteractionsTableFilterComposer(
            $db: $db,
            $table: $db.interactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarLocalPath => $composableBuilder(
    column: $table.avatarLocalPath,
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

  ColumnOrderings<int> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastContactedAt => $composableBuilder(
    column: $table.lastContactedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarLocalPath => $composableBuilder(
    column: $table.avatarLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<int> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<String> get jobTitle =>
      $composableBuilder(column: $table.jobTitle, builder: (column) => column);

  GeneratedColumn<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastContactedAt => $composableBuilder(
    column: $table.lastContactedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> contactCirclesRefs<T extends Object>(
    Expression<T> Function($$ContactCirclesTableAnnotationComposer a) f,
  ) {
    final $$ContactCirclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactCircles,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactCirclesTableAnnotationComposer(
            $db: $db,
            $table: $db.contactCircles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> interactionsRefs<T extends Object>(
    Expression<T> Function($$InteractionsTableAnnotationComposer a) f,
  ) {
    final $$InteractionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.interactions,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InteractionsTableAnnotationComposer(
            $db: $db,
            $table: $db.interactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function({
            bool contactCirclesRefs,
            bool interactionsRefs,
          })
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarLocalPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<int?> birthday = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                Value<int> cadenceDays = const Value.absent(),
                Value<int?> lastContactedAt = const Value.absent(),
                Value<int?> snoozedUntil = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                name: name,
                avatarLocalPath: avatarLocalPath,
                phone: phone,
                email: email,
                birthday: birthday,
                jobTitle: jobTitle,
                cadenceDays: cadenceDays,
                lastContactedAt: lastContactedAt,
                snoozedUntil: snoozedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> avatarLocalPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<int?> birthday = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                Value<int> cadenceDays = const Value.absent(),
                Value<int?> lastContactedAt = const Value.absent(),
                Value<int?> snoozedUntil = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                name: name,
                avatarLocalPath: avatarLocalPath,
                phone: phone,
                email: email,
                birthday: birthday,
                jobTitle: jobTitle,
                cadenceDays: cadenceDays,
                lastContactedAt: lastContactedAt,
                snoozedUntil: snoozedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({contactCirclesRefs = false, interactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (contactCirclesRefs) db.contactCircles,
                    if (interactionsRefs) db.interactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (contactCirclesRefs)
                        await $_getPrefetchedData<
                          Contact,
                          $ContactsTable,
                          ContactCircle
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._contactCirclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactCirclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contactId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (interactionsRefs)
                        await $_getPrefetchedData<
                          Contact,
                          $ContactsTable,
                          Interaction
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._interactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).interactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contactId == item.id,
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

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function({bool contactCirclesRefs, bool interactionsRefs})
    >;
typedef $$CirclesTableCreateCompanionBuilder =
    CirclesCompanion Function({
      required String id,
      required String name,
      Value<String?> colorHex,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$CirclesTableUpdateCompanionBuilder =
    CirclesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> colorHex,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$CirclesTableReferences
    extends BaseReferences<_$AppDatabase, $CirclesTable, Circle> {
  $$CirclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContactCirclesTable, List<ContactCircle>>
  _contactCirclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contactCircles,
    aliasName: $_aliasNameGenerator(db.circles.id, db.contactCircles.circleId),
  );

  $$ContactCirclesTableProcessedTableManager get contactCirclesRefs {
    final manager = $$ContactCirclesTableTableManager(
      $_db,
      $_db.contactCircles,
    ).filter((f) => f.circleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactCirclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CirclesTableFilterComposer
    extends Composer<_$AppDatabase, $CirclesTable> {
  $$CirclesTableFilterComposer({
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

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contactCirclesRefs(
    Expression<bool> Function($$ContactCirclesTableFilterComposer f) f,
  ) {
    final $$ContactCirclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactCircles,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactCirclesTableFilterComposer(
            $db: $db,
            $table: $db.contactCircles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CirclesTableOrderingComposer
    extends Composer<_$AppDatabase, $CirclesTable> {
  $$CirclesTableOrderingComposer({
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

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CirclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CirclesTable> {
  $$CirclesTableAnnotationComposer({
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

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> contactCirclesRefs<T extends Object>(
    Expression<T> Function($$ContactCirclesTableAnnotationComposer a) f,
  ) {
    final $$ContactCirclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactCircles,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactCirclesTableAnnotationComposer(
            $db: $db,
            $table: $db.contactCircles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CirclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CirclesTable,
          Circle,
          $$CirclesTableFilterComposer,
          $$CirclesTableOrderingComposer,
          $$CirclesTableAnnotationComposer,
          $$CirclesTableCreateCompanionBuilder,
          $$CirclesTableUpdateCompanionBuilder,
          (Circle, $$CirclesTableReferences),
          Circle,
          PrefetchHooks Function({bool contactCirclesRefs})
        > {
  $$CirclesTableTableManager(_$AppDatabase db, $CirclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CirclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CirclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CirclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CirclesCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> colorHex = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CirclesCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CirclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactCirclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (contactCirclesRefs) db.contactCircles,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contactCirclesRefs)
                    await $_getPrefetchedData<
                      Circle,
                      $CirclesTable,
                      ContactCircle
                    >(
                      currentTable: table,
                      referencedTable: $$CirclesTableReferences
                          ._contactCirclesRefsTable(db),
                      managerFromTypedResult: (p0) => $$CirclesTableReferences(
                        db,
                        table,
                        p0,
                      ).contactCirclesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.circleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CirclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CirclesTable,
      Circle,
      $$CirclesTableFilterComposer,
      $$CirclesTableOrderingComposer,
      $$CirclesTableAnnotationComposer,
      $$CirclesTableCreateCompanionBuilder,
      $$CirclesTableUpdateCompanionBuilder,
      (Circle, $$CirclesTableReferences),
      Circle,
      PrefetchHooks Function({bool contactCirclesRefs})
    >;
typedef $$ContactCirclesTableCreateCompanionBuilder =
    ContactCirclesCompanion Function({
      required String contactId,
      required String circleId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$ContactCirclesTableUpdateCompanionBuilder =
    ContactCirclesCompanion Function({
      Value<String> contactId,
      Value<String> circleId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$ContactCirclesTableReferences
    extends BaseReferences<_$AppDatabase, $ContactCirclesTable, ContactCircle> {
  $$ContactCirclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias(
        $_aliasNameGenerator(db.contactCircles.contactId, db.contacts.id),
      );

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<String>('contact_id')!;

    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CirclesTable _circleIdTable(_$AppDatabase db) =>
      db.circles.createAlias(
        $_aliasNameGenerator(db.contactCircles.circleId, db.circles.id),
      );

  $$CirclesTableProcessedTableManager get circleId {
    final $_column = $_itemColumn<String>('circle_id')!;

    final manager = $$CirclesTableTableManager(
      $_db,
      $_db.circles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactCirclesTableFilterComposer
    extends Composer<_$AppDatabase, $ContactCirclesTable> {
  $$ContactCirclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CirclesTableFilterComposer get circleId {
    final $$CirclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableFilterComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactCirclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactCirclesTable> {
  $$ContactCirclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CirclesTableOrderingComposer get circleId {
    final $$CirclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableOrderingComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactCirclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactCirclesTable> {
  $$ContactCirclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CirclesTableAnnotationComposer get circleId {
    final $$CirclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableAnnotationComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactCirclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactCirclesTable,
          ContactCircle,
          $$ContactCirclesTableFilterComposer,
          $$ContactCirclesTableOrderingComposer,
          $$ContactCirclesTableAnnotationComposer,
          $$ContactCirclesTableCreateCompanionBuilder,
          $$ContactCirclesTableUpdateCompanionBuilder,
          (ContactCircle, $$ContactCirclesTableReferences),
          ContactCircle,
          PrefetchHooks Function({bool contactId, bool circleId})
        > {
  $$ContactCirclesTableTableManager(
    _$AppDatabase db,
    $ContactCirclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactCirclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactCirclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactCirclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> contactId = const Value.absent(),
                Value<String> circleId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactCirclesCompanion(
                contactId: contactId,
                circleId: circleId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contactId,
                required String circleId,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactCirclesCompanion.insert(
                contactId: contactId,
                circleId: circleId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactCirclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false, circleId = false}) {
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
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable: $$ContactCirclesTableReferences
                                    ._contactIdTable(db),
                                referencedColumn:
                                    $$ContactCirclesTableReferences
                                        ._contactIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (circleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.circleId,
                                referencedTable: $$ContactCirclesTableReferences
                                    ._circleIdTable(db),
                                referencedColumn:
                                    $$ContactCirclesTableReferences
                                        ._circleIdTable(db)
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

typedef $$ContactCirclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactCirclesTable,
      ContactCircle,
      $$ContactCirclesTableFilterComposer,
      $$ContactCirclesTableOrderingComposer,
      $$ContactCirclesTableAnnotationComposer,
      $$ContactCirclesTableCreateCompanionBuilder,
      $$ContactCirclesTableUpdateCompanionBuilder,
      (ContactCircle, $$ContactCirclesTableReferences),
      ContactCircle,
      PrefetchHooks Function({bool contactId, bool circleId})
    >;
typedef $$InteractionsTableCreateCompanionBuilder =
    InteractionsCompanion Function({
      required String id,
      required String contactId,
      required String type,
      Value<String?> content,
      Value<bool> isPreparation,
      required int happenedAt,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$InteractionsTableUpdateCompanionBuilder =
    InteractionsCompanion Function({
      Value<String> id,
      Value<String> contactId,
      Value<String> type,
      Value<String?> content,
      Value<bool> isPreparation,
      Value<int> happenedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<bool> isDirty,
      Value<int> rowid,
    });

final class $$InteractionsTableReferences
    extends BaseReferences<_$AppDatabase, $InteractionsTable, Interaction> {
  $$InteractionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias(
        $_aliasNameGenerator(db.interactions.contactId, db.contacts.id),
      );

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<String>('contact_id')!;

    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InteractionsTableFilterComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreparation => $composableBuilder(
    column: $table.isPreparation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InteractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreparation => $composableBuilder(
    column: $table.isPreparation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InteractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InteractionsTable> {
  $$InteractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isPreparation => $composableBuilder(
    column: $table.isPreparation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InteractionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InteractionsTable,
          Interaction,
          $$InteractionsTableFilterComposer,
          $$InteractionsTableOrderingComposer,
          $$InteractionsTableAnnotationComposer,
          $$InteractionsTableCreateCompanionBuilder,
          $$InteractionsTableUpdateCompanionBuilder,
          (Interaction, $$InteractionsTableReferences),
          Interaction,
          PrefetchHooks Function({bool contactId})
        > {
  $$InteractionsTableTableManager(_$AppDatabase db, $InteractionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InteractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InteractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InteractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contactId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<bool> isPreparation = const Value.absent(),
                Value<int> happenedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionsCompanion(
                id: id,
                contactId: contactId,
                type: type,
                content: content,
                isPreparation: isPreparation,
                happenedAt: happenedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contactId,
                required String type,
                Value<String?> content = const Value.absent(),
                Value<bool> isPreparation = const Value.absent(),
                required int happenedAt,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InteractionsCompanion.insert(
                id: id,
                contactId: contactId,
                type: type,
                content: content,
                isPreparation: isPreparation,
                happenedAt: happenedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InteractionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
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
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable: $$InteractionsTableReferences
                                    ._contactIdTable(db),
                                referencedColumn: $$InteractionsTableReferences
                                    ._contactIdTable(db)
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

typedef $$InteractionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InteractionsTable,
      Interaction,
      $$InteractionsTableFilterComposer,
      $$InteractionsTableOrderingComposer,
      $$InteractionsTableAnnotationComposer,
      $$InteractionsTableCreateCompanionBuilder,
      $$InteractionsTableUpdateCompanionBuilder,
      (Interaction, $$InteractionsTableReferences),
      Interaction,
      PrefetchHooks Function({bool contactId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$CirclesTableTableManager get circles =>
      $$CirclesTableTableManager(_db, _db.circles);
  $$ContactCirclesTableTableManager get contactCircles =>
      $$ContactCirclesTableTableManager(_db, _db.contactCircles);
  $$InteractionsTableTableManager get interactions =>
      $$InteractionsTableTableManager(_db, _db.interactions);
}
