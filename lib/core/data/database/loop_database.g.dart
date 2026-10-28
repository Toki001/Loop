// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loop_database.dart';

// ignore_for_file: type=lint
class Settings extends Table with TableInfo<Settings, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY CHECK (length("key") BETWEEN 1 AND 128)',
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (json_valid(value_json))',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Settings.$converterupdatedAtUtc);
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, updatedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAtUtc: Settings.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
    );
  }

  @override
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcDateTimeConverter();
  @override
  bool get dontWriteConstraints => true;
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String valueJson;
  final DateTime updatedAtUtc;
  const Setting({
    required this.key,
    required this.valueJson,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    {
      map['updated_at_utc'] = Variable<DateTime>(
        Settings.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['value_json']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updated_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value_json': serializer.toJson<String>(valueJson),
      'updated_at_utc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  Setting copyWith({String? key, String? valueJson, DateTime? updatedAtUtc}) =>
      Setting(
        key: key ?? this.key,
        valueJson: valueJson ?? this.valueJson,
        updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String valueJson,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        Settings.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Skills extends Table with TableInfo<Skills, Skill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Skills(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (length(id) = 36)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 4096)',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'music\', \'drawing\', \'language\', \'programming\', \'voice\', \'typing\', \'movement\', \'custom\'))',
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _accentKeyMeta = const VerificationMeta(
    'accentKey',
  );
  late final GeneratedColumn<String> accentKey = GeneratedColumn<String>(
    'accent_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Skills.$convertercreatedAtUtc);
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Skills.$converterupdatedAtUtc);
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  archivedAtUtc = GeneratedColumn<DateTime>(
    'archived_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<DateTime?>(Skills.$converterarchivedAtUtcn);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _defaultPracticeMinutesMeta =
      const VerificationMeta('defaultPracticeMinutes');
  late final GeneratedColumn<int> defaultPracticeMinutes = GeneratedColumn<int>(
    'default_practice_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (default_practice_minutes BETWEEN 1 AND 1440)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    iconKey,
    accentKey,
    description,
    createdAtUtc,
    updatedAtUtc,
    archivedAtUtc,
    sortOrder,
    defaultPracticeMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skills';
  @override
  VerificationContext validateIntegrity(
    Insertable<Skill> instance, {
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
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('accent_key')) {
      context.handle(
        _accentKeyMeta,
        accentKey.isAcceptableOrUnknown(data['accent_key']!, _accentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_accentKeyMeta);
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('default_practice_minutes')) {
      context.handle(
        _defaultPracticeMinutesMeta,
        defaultPracticeMinutes.isAcceptableOrUnknown(
          data['default_practice_minutes']!,
          _defaultPracticeMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Skill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      accentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_key'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAtUtc: Skills.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      updatedAtUtc: Skills.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
      archivedAtUtc: Skills.$converterarchivedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}archived_at_utc'],
        ),
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      defaultPracticeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_practice_minutes'],
      ),
    );
  }

  @override
  Skills createAlias(String alias) {
    return Skills(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterarchivedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $converterarchivedAtUtcn =
      NullAwareTypeConverter.wrap($converterarchivedAtUtc);
  @override
  bool get dontWriteConstraints => true;
}

class Skill extends DataClass implements Insertable<Skill> {
  final String id;
  final String name;
  final String kind;
  final String iconKey;
  final String accentKey;
  final String? description;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? archivedAtUtc;
  final int sortOrder;
  final int? defaultPracticeMinutes;
  const Skill({
    required this.id,
    required this.name,
    required this.kind,
    required this.iconKey,
    required this.accentKey,
    this.description,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.archivedAtUtc,
    required this.sortOrder,
    this.defaultPracticeMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['icon_key'] = Variable<String>(iconKey);
    map['accent_key'] = Variable<String>(accentKey);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['created_at_utc'] = Variable<DateTime>(
        Skills.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    {
      map['updated_at_utc'] = Variable<DateTime>(
        Skills.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    if (!nullToAbsent || archivedAtUtc != null) {
      map['archived_at_utc'] = Variable<DateTime>(
        Skills.$converterarchivedAtUtcn.toSql(archivedAtUtc),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || defaultPracticeMinutes != null) {
      map['default_practice_minutes'] = Variable<int>(defaultPracticeMinutes);
    }
    return map;
  }

  SkillsCompanion toCompanion(bool nullToAbsent) {
    return SkillsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      iconKey: Value(iconKey),
      accentKey: Value(accentKey),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      archivedAtUtc: archivedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtUtc),
      sortOrder: Value(sortOrder),
      defaultPracticeMinutes: defaultPracticeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultPracticeMinutes),
    );
  }

  factory Skill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skill(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      iconKey: serializer.fromJson<String>(json['icon_key']),
      accentKey: serializer.fromJson<String>(json['accent_key']),
      description: serializer.fromJson<String?>(json['description']),
      createdAtUtc: serializer.fromJson<DateTime>(json['created_at_utc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updated_at_utc']),
      archivedAtUtc: serializer.fromJson<DateTime?>(json['archived_at_utc']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      defaultPracticeMinutes: serializer.fromJson<int?>(
        json['default_practice_minutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'icon_key': serializer.toJson<String>(iconKey),
      'accent_key': serializer.toJson<String>(accentKey),
      'description': serializer.toJson<String?>(description),
      'created_at_utc': serializer.toJson<DateTime>(createdAtUtc),
      'updated_at_utc': serializer.toJson<DateTime>(updatedAtUtc),
      'archived_at_utc': serializer.toJson<DateTime?>(archivedAtUtc),
      'sort_order': serializer.toJson<int>(sortOrder),
      'default_practice_minutes': serializer.toJson<int?>(
        defaultPracticeMinutes,
      ),
    };
  }

  Skill copyWith({
    String? id,
    String? name,
    String? kind,
    String? iconKey,
    String? accentKey,
    Value<String?> description = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> archivedAtUtc = const Value.absent(),
    int? sortOrder,
    Value<int?> defaultPracticeMinutes = const Value.absent(),
  }) => Skill(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    iconKey: iconKey ?? this.iconKey,
    accentKey: accentKey ?? this.accentKey,
    description: description.present ? description.value : this.description,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    archivedAtUtc: archivedAtUtc.present
        ? archivedAtUtc.value
        : this.archivedAtUtc,
    sortOrder: sortOrder ?? this.sortOrder,
    defaultPracticeMinutes: defaultPracticeMinutes.present
        ? defaultPracticeMinutes.value
        : this.defaultPracticeMinutes,
  );
  Skill copyWithCompanion(SkillsCompanion data) {
    return Skill(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      accentKey: data.accentKey.present ? data.accentKey.value : this.accentKey,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      archivedAtUtc: data.archivedAtUtc.present
          ? data.archivedAtUtc.value
          : this.archivedAtUtc,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      defaultPracticeMinutes: data.defaultPracticeMinutes.present
          ? data.defaultPracticeMinutes.value
          : this.defaultPracticeMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Skill(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('iconKey: $iconKey, ')
          ..write('accentKey: $accentKey, ')
          ..write('description: $description, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('archivedAtUtc: $archivedAtUtc, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('defaultPracticeMinutes: $defaultPracticeMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    iconKey,
    accentKey,
    description,
    createdAtUtc,
    updatedAtUtc,
    archivedAtUtc,
    sortOrder,
    defaultPracticeMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skill &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.iconKey == this.iconKey &&
          other.accentKey == this.accentKey &&
          other.description == this.description &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.archivedAtUtc == this.archivedAtUtc &&
          other.sortOrder == this.sortOrder &&
          other.defaultPracticeMinutes == this.defaultPracticeMinutes);
}

class SkillsCompanion extends UpdateCompanion<Skill> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> iconKey;
  final Value<String> accentKey;
  final Value<String?> description;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> archivedAtUtc;
  final Value<int> sortOrder;
  final Value<int?> defaultPracticeMinutes;
  final Value<int> rowid;
  const SkillsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.accentKey = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.archivedAtUtc = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.defaultPracticeMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkillsCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required String iconKey,
    required String accentKey,
    this.description = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.archivedAtUtc = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.defaultPracticeMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       iconKey = Value(iconKey),
       accentKey = Value(accentKey),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Skill> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? iconKey,
    Expression<String>? accentKey,
    Expression<String>? description,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? archivedAtUtc,
    Expression<int>? sortOrder,
    Expression<int>? defaultPracticeMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (iconKey != null) 'icon_key': iconKey,
      if (accentKey != null) 'accent_key': accentKey,
      if (description != null) 'description': description,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (archivedAtUtc != null) 'archived_at_utc': archivedAtUtc,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (defaultPracticeMinutes != null)
        'default_practice_minutes': defaultPracticeMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkillsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? iconKey,
    Value<String>? accentKey,
    Value<String?>? description,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? archivedAtUtc,
    Value<int>? sortOrder,
    Value<int?>? defaultPracticeMinutes,
    Value<int>? rowid,
  }) {
    return SkillsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      iconKey: iconKey ?? this.iconKey,
      accentKey: accentKey ?? this.accentKey,
      description: description ?? this.description,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      archivedAtUtc: archivedAtUtc ?? this.archivedAtUtc,
      sortOrder: sortOrder ?? this.sortOrder,
      defaultPracticeMinutes:
          defaultPracticeMinutes ?? this.defaultPracticeMinutes,
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (accentKey.present) {
      map['accent_key'] = Variable<String>(accentKey.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        Skills.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        Skills.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (archivedAtUtc.present) {
      map['archived_at_utc'] = Variable<DateTime>(
        Skills.$converterarchivedAtUtcn.toSql(archivedAtUtc.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (defaultPracticeMinutes.present) {
      map['default_practice_minutes'] = Variable<int>(
        defaultPracticeMinutes.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('iconKey: $iconKey, ')
          ..write('accentKey: $accentKey, ')
          ..write('description: $description, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('archivedAtUtc: $archivedAtUtc, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('defaultPracticeMinutes: $defaultPracticeMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MetricDefinitions extends Table
    with TableInfo<MetricDefinitions, MetricDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MetricDefinitions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(id) = 36)',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (version >= 1)',
  );
  static const VerificationMeta _skillIdMeta = const VerificationMeta(
    'skillId',
  );
  late final GeneratedColumn<String> skillId = GeneratedColumn<String>(
    'skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES skills(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (length(trim(label)) BETWEEN 1 AND 4096)',
  );
  static const VerificationMeta _unitKeyMeta = const VerificationMeta(
    'unitKey',
  );
  late final GeneratedColumn<String> unitKey = GeneratedColumn<String>(
    'unit_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (value_type IN (\'numeric\', \'checklist\', \'text\'))',
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (direction IN (\'up\', \'down\', \'toward_target\', \'none\'))',
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (abs(target_value) <= CAST(\'1.7976931348623157e308\' AS REAL))',
  );
  static const VerificationMeta _scaleMinMeta = const VerificationMeta(
    'scaleMin',
  );
  late final GeneratedColumn<double> scaleMin = GeneratedColumn<double>(
    'scale_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (abs(scale_min) <= CAST(\'1.7976931348623157e308\' AS REAL))',
  );
  static const VerificationMeta _scaleMaxMeta = const VerificationMeta(
    'scaleMax',
  );
  late final GeneratedColumn<double> scaleMax = GeneratedColumn<double>(
    'scale_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (abs(scale_max) <= CAST(\'1.7976931348623157e308\' AS REAL))',
  );
  static const VerificationMeta _sourceHintMeta = const VerificationMeta(
    'sourceHint',
  );
  late final GeneratedColumn<String> sourceHint = GeneratedColumn<String>(
    'source_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (source_hint IN (\'manual\', \'instrument\', \'self_rating\'))',
  );
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  archivedAtUtc = GeneratedColumn<DateTime>(
    'archived_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<DateTime?>(MetricDefinitions.$converterarchivedAtUtcn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    skillId,
    label,
    unitKey,
    valueType,
    direction,
    targetValue,
    scaleMin,
    scaleMax,
    sourceHint,
    archivedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metric_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetricDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(
        _skillIdMeta,
        skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('unit_key')) {
      context.handle(
        _unitKeyMeta,
        unitKey.isAcceptableOrUnknown(data['unit_key']!, _unitKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_unitKeyMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_valueTypeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    if (data.containsKey('scale_min')) {
      context.handle(
        _scaleMinMeta,
        scaleMin.isAcceptableOrUnknown(data['scale_min']!, _scaleMinMeta),
      );
    }
    if (data.containsKey('scale_max')) {
      context.handle(
        _scaleMaxMeta,
        scaleMax.isAcceptableOrUnknown(data['scale_max']!, _scaleMaxMeta),
      );
    }
    if (data.containsKey('source_hint')) {
      context.handle(
        _sourceHintMeta,
        sourceHint.isAcceptableOrUnknown(data['source_hint']!, _sourceHintMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceHintMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, version};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, version, skillId},
  ];
  @override
  MetricDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetricDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      skillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      unitKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_key'],
      )!,
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      ),
      scaleMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scale_min'],
      ),
      scaleMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scale_max'],
      ),
      sourceHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hint'],
      )!,
      archivedAtUtc: MetricDefinitions.$converterarchivedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}archived_at_utc'],
        ),
      ),
    );
  }

  @override
  MetricDefinitions createAlias(String alias) {
    return MetricDefinitions(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterarchivedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $converterarchivedAtUtcn =
      NullAwareTypeConverter.wrap($converterarchivedAtUtc);
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id, version)',
    'UNIQUE(id, version, skill_id)',
    'CHECK(scale_min IS NULL OR scale_max IS NULL OR scale_min <= scale_max)',
    'CHECK(direction != \'toward_target\' OR target_value IS NOT NULL)',
    'CHECK(target_value IS NULL OR((scale_min IS NULL OR target_value >= scale_min)AND(scale_max IS NULL OR target_value <= scale_max)))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MetricDefinition extends DataClass
    implements Insertable<MetricDefinition> {
  final String id;
  final int version;
  final String skillId;
  final String label;
  final String unitKey;
  final String valueType;
  final String direction;
  final double? targetValue;
  final double? scaleMin;
  final double? scaleMax;
  final String sourceHint;
  final DateTime? archivedAtUtc;
  const MetricDefinition({
    required this.id,
    required this.version,
    required this.skillId,
    required this.label,
    required this.unitKey,
    required this.valueType,
    required this.direction,
    this.targetValue,
    this.scaleMin,
    this.scaleMax,
    required this.sourceHint,
    this.archivedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['skill_id'] = Variable<String>(skillId);
    map['label'] = Variable<String>(label);
    map['unit_key'] = Variable<String>(unitKey);
    map['value_type'] = Variable<String>(valueType);
    map['direction'] = Variable<String>(direction);
    if (!nullToAbsent || targetValue != null) {
      map['target_value'] = Variable<double>(targetValue);
    }
    if (!nullToAbsent || scaleMin != null) {
      map['scale_min'] = Variable<double>(scaleMin);
    }
    if (!nullToAbsent || scaleMax != null) {
      map['scale_max'] = Variable<double>(scaleMax);
    }
    map['source_hint'] = Variable<String>(sourceHint);
    if (!nullToAbsent || archivedAtUtc != null) {
      map['archived_at_utc'] = Variable<DateTime>(
        MetricDefinitions.$converterarchivedAtUtcn.toSql(archivedAtUtc),
      );
    }
    return map;
  }

  MetricDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return MetricDefinitionsCompanion(
      id: Value(id),
      version: Value(version),
      skillId: Value(skillId),
      label: Value(label),
      unitKey: Value(unitKey),
      valueType: Value(valueType),
      direction: Value(direction),
      targetValue: targetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetValue),
      scaleMin: scaleMin == null && nullToAbsent
          ? const Value.absent()
          : Value(scaleMin),
      scaleMax: scaleMax == null && nullToAbsent
          ? const Value.absent()
          : Value(scaleMax),
      sourceHint: Value(sourceHint),
      archivedAtUtc: archivedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAtUtc),
    );
  }

  factory MetricDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetricDefinition(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      skillId: serializer.fromJson<String>(json['skill_id']),
      label: serializer.fromJson<String>(json['label']),
      unitKey: serializer.fromJson<String>(json['unit_key']),
      valueType: serializer.fromJson<String>(json['value_type']),
      direction: serializer.fromJson<String>(json['direction']),
      targetValue: serializer.fromJson<double?>(json['target_value']),
      scaleMin: serializer.fromJson<double?>(json['scale_min']),
      scaleMax: serializer.fromJson<double?>(json['scale_max']),
      sourceHint: serializer.fromJson<String>(json['source_hint']),
      archivedAtUtc: serializer.fromJson<DateTime?>(json['archived_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'skill_id': serializer.toJson<String>(skillId),
      'label': serializer.toJson<String>(label),
      'unit_key': serializer.toJson<String>(unitKey),
      'value_type': serializer.toJson<String>(valueType),
      'direction': serializer.toJson<String>(direction),
      'target_value': serializer.toJson<double?>(targetValue),
      'scale_min': serializer.toJson<double?>(scaleMin),
      'scale_max': serializer.toJson<double?>(scaleMax),
      'source_hint': serializer.toJson<String>(sourceHint),
      'archived_at_utc': serializer.toJson<DateTime?>(archivedAtUtc),
    };
  }

  MetricDefinition copyWith({
    String? id,
    int? version,
    String? skillId,
    String? label,
    String? unitKey,
    String? valueType,
    String? direction,
    Value<double?> targetValue = const Value.absent(),
    Value<double?> scaleMin = const Value.absent(),
    Value<double?> scaleMax = const Value.absent(),
    String? sourceHint,
    Value<DateTime?> archivedAtUtc = const Value.absent(),
  }) => MetricDefinition(
    id: id ?? this.id,
    version: version ?? this.version,
    skillId: skillId ?? this.skillId,
    label: label ?? this.label,
    unitKey: unitKey ?? this.unitKey,
    valueType: valueType ?? this.valueType,
    direction: direction ?? this.direction,
    targetValue: targetValue.present ? targetValue.value : this.targetValue,
    scaleMin: scaleMin.present ? scaleMin.value : this.scaleMin,
    scaleMax: scaleMax.present ? scaleMax.value : this.scaleMax,
    sourceHint: sourceHint ?? this.sourceHint,
    archivedAtUtc: archivedAtUtc.present
        ? archivedAtUtc.value
        : this.archivedAtUtc,
  );
  MetricDefinition copyWithCompanion(MetricDefinitionsCompanion data) {
    return MetricDefinition(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      label: data.label.present ? data.label.value : this.label,
      unitKey: data.unitKey.present ? data.unitKey.value : this.unitKey,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      direction: data.direction.present ? data.direction.value : this.direction,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      scaleMin: data.scaleMin.present ? data.scaleMin.value : this.scaleMin,
      scaleMax: data.scaleMax.present ? data.scaleMax.value : this.scaleMax,
      sourceHint: data.sourceHint.present
          ? data.sourceHint.value
          : this.sourceHint,
      archivedAtUtc: data.archivedAtUtc.present
          ? data.archivedAtUtc.value
          : this.archivedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetricDefinition(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('skillId: $skillId, ')
          ..write('label: $label, ')
          ..write('unitKey: $unitKey, ')
          ..write('valueType: $valueType, ')
          ..write('direction: $direction, ')
          ..write('targetValue: $targetValue, ')
          ..write('scaleMin: $scaleMin, ')
          ..write('scaleMax: $scaleMax, ')
          ..write('sourceHint: $sourceHint, ')
          ..write('archivedAtUtc: $archivedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    skillId,
    label,
    unitKey,
    valueType,
    direction,
    targetValue,
    scaleMin,
    scaleMax,
    sourceHint,
    archivedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetricDefinition &&
          other.id == this.id &&
          other.version == this.version &&
          other.skillId == this.skillId &&
          other.label == this.label &&
          other.unitKey == this.unitKey &&
          other.valueType == this.valueType &&
          other.direction == this.direction &&
          other.targetValue == this.targetValue &&
          other.scaleMin == this.scaleMin &&
          other.scaleMax == this.scaleMax &&
          other.sourceHint == this.sourceHint &&
          other.archivedAtUtc == this.archivedAtUtc);
}

class MetricDefinitionsCompanion extends UpdateCompanion<MetricDefinition> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> skillId;
  final Value<String> label;
  final Value<String> unitKey;
  final Value<String> valueType;
  final Value<String> direction;
  final Value<double?> targetValue;
  final Value<double?> scaleMin;
  final Value<double?> scaleMax;
  final Value<String> sourceHint;
  final Value<DateTime?> archivedAtUtc;
  final Value<int> rowid;
  const MetricDefinitionsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.skillId = const Value.absent(),
    this.label = const Value.absent(),
    this.unitKey = const Value.absent(),
    this.valueType = const Value.absent(),
    this.direction = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.scaleMin = const Value.absent(),
    this.scaleMax = const Value.absent(),
    this.sourceHint = const Value.absent(),
    this.archivedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetricDefinitionsCompanion.insert({
    required String id,
    required int version,
    required String skillId,
    required String label,
    required String unitKey,
    required String valueType,
    required String direction,
    this.targetValue = const Value.absent(),
    this.scaleMin = const Value.absent(),
    this.scaleMax = const Value.absent(),
    required String sourceHint,
    this.archivedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       version = Value(version),
       skillId = Value(skillId),
       label = Value(label),
       unitKey = Value(unitKey),
       valueType = Value(valueType),
       direction = Value(direction),
       sourceHint = Value(sourceHint);
  static Insertable<MetricDefinition> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? skillId,
    Expression<String>? label,
    Expression<String>? unitKey,
    Expression<String>? valueType,
    Expression<String>? direction,
    Expression<double>? targetValue,
    Expression<double>? scaleMin,
    Expression<double>? scaleMax,
    Expression<String>? sourceHint,
    Expression<DateTime>? archivedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (skillId != null) 'skill_id': skillId,
      if (label != null) 'label': label,
      if (unitKey != null) 'unit_key': unitKey,
      if (valueType != null) 'value_type': valueType,
      if (direction != null) 'direction': direction,
      if (targetValue != null) 'target_value': targetValue,
      if (scaleMin != null) 'scale_min': scaleMin,
      if (scaleMax != null) 'scale_max': scaleMax,
      if (sourceHint != null) 'source_hint': sourceHint,
      if (archivedAtUtc != null) 'archived_at_utc': archivedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetricDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? skillId,
    Value<String>? label,
    Value<String>? unitKey,
    Value<String>? valueType,
    Value<String>? direction,
    Value<double?>? targetValue,
    Value<double?>? scaleMin,
    Value<double?>? scaleMax,
    Value<String>? sourceHint,
    Value<DateTime?>? archivedAtUtc,
    Value<int>? rowid,
  }) {
    return MetricDefinitionsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      skillId: skillId ?? this.skillId,
      label: label ?? this.label,
      unitKey: unitKey ?? this.unitKey,
      valueType: valueType ?? this.valueType,
      direction: direction ?? this.direction,
      targetValue: targetValue ?? this.targetValue,
      scaleMin: scaleMin ?? this.scaleMin,
      scaleMax: scaleMax ?? this.scaleMax,
      sourceHint: sourceHint ?? this.sourceHint,
      archivedAtUtc: archivedAtUtc ?? this.archivedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<String>(skillId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (unitKey.present) {
      map['unit_key'] = Variable<String>(unitKey.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (scaleMin.present) {
      map['scale_min'] = Variable<double>(scaleMin.value);
    }
    if (scaleMax.present) {
      map['scale_max'] = Variable<double>(scaleMax.value);
    }
    if (sourceHint.present) {
      map['source_hint'] = Variable<String>(sourceHint.value);
    }
    if (archivedAtUtc.present) {
      map['archived_at_utc'] = Variable<DateTime>(
        MetricDefinitions.$converterarchivedAtUtcn.toSql(archivedAtUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('skillId: $skillId, ')
          ..write('label: $label, ')
          ..write('unitKey: $unitKey, ')
          ..write('valueType: $valueType, ')
          ..write('direction: $direction, ')
          ..write('targetValue: $targetValue, ')
          ..write('scaleMin: $scaleMin, ')
          ..write('scaleMax: $scaleMax, ')
          ..write('sourceHint: $sourceHint, ')
          ..write('archivedAtUtc: $archivedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Goals extends Table with TableInfo<Goals, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Goals(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (length(id) = 36)',
  );
  static const VerificationMeta _skillIdMeta = const VerificationMeta(
    'skillId',
  );
  late final GeneratedColumn<String> skillId = GeneratedColumn<String>(
    'skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES skills(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 4096)',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (type IN (\'cumulative\', \'threshold\', \'weekly_target\', \'deliverable\', \'qualitative\'))',
  );
  static const VerificationMeta _metricDefinitionIdMeta =
      const VerificationMeta('metricDefinitionId');
  late final GeneratedColumn<String> metricDefinitionId =
      GeneratedColumn<String>(
        'metric_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _definitionVersionMeta = const VerificationMeta(
    'definitionVersion',
  );
  late final GeneratedColumn<int> definitionVersion = GeneratedColumn<int>(
    'definition_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (abs(target_value) <= CAST(\'1.7976931348623157e308\' AS REAL))',
  );
  static const VerificationMeta _targetUnitMeta = const VerificationMeta(
    'targetUnit',
  );
  late final GeneratedColumn<String> targetUnit = GeneratedColumn<String>(
    'target_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _targetDateLocalMeta = const VerificationMeta(
    'targetDateLocal',
  );
  late final GeneratedColumn<String> targetDateLocal = GeneratedColumn<String>(
    'target_date_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'active\', \'completed\', \'paused\', \'archived\'))',
  );
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  completedAtUtc = GeneratedColumn<DateTime>(
    'completed_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<DateTime?>(Goals.$convertercompletedAtUtcn);
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Goals.$convertercreatedAtUtc);
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Goals.$converterupdatedAtUtc);
  static const VerificationMeta _motivationMeta = const VerificationMeta(
    'motivation',
  );
  late final GeneratedColumn<String> motivation = GeneratedColumn<String>(
    'motivation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (length(motivation) <= 4000)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    skillId,
    title,
    type,
    metricDefinitionId,
    definitionVersion,
    targetValue,
    targetUnit,
    targetDateLocal,
    status,
    completedAtUtc,
    createdAtUtc,
    updatedAtUtc,
    motivation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(
        _skillIdMeta,
        skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('metric_definition_id')) {
      context.handle(
        _metricDefinitionIdMeta,
        metricDefinitionId.isAcceptableOrUnknown(
          data['metric_definition_id']!,
          _metricDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('definition_version')) {
      context.handle(
        _definitionVersionMeta,
        definitionVersion.isAcceptableOrUnknown(
          data['definition_version']!,
          _definitionVersionMeta,
        ),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    if (data.containsKey('target_unit')) {
      context.handle(
        _targetUnitMeta,
        targetUnit.isAcceptableOrUnknown(data['target_unit']!, _targetUnitMeta),
      );
    }
    if (data.containsKey('target_date_local')) {
      context.handle(
        _targetDateLocalMeta,
        targetDateLocal.isAcceptableOrUnknown(
          data['target_date_local']!,
          _targetDateLocalMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('motivation')) {
      context.handle(
        _motivationMeta,
        motivation.isAcceptableOrUnknown(data['motivation']!, _motivationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      skillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      metricDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_definition_id'],
      ),
      definitionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}definition_version'],
      ),
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      ),
      targetUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_unit'],
      ),
      targetDateLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_date_local'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAtUtc: Goals.$convertercompletedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}completed_at_utc'],
        ),
      ),
      createdAtUtc: Goals.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      updatedAtUtc: Goals.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
      motivation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivation'],
      ),
    );
  }

  @override
  Goals createAlias(String alias) {
    return Goals(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercompletedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $convertercompletedAtUtcn =
      NullAwareTypeConverter.wrap($convertercompletedAtUtc);
  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcDateTimeConverter();
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(metric_definition_id, definition_version, skill_id)REFERENCES metric_definitions(id, version, skill_id)',
    'CHECK((metric_definition_id IS NULL)=(definition_version IS NULL))',
    'CHECK((status != \'completed\' OR completed_at_utc IS NOT NULL)AND(status IN (\'completed\', \'archived\') OR completed_at_utc IS NULL))',
    'CHECK(type NOT IN (\'cumulative\', \'weekly_target\') OR(target_value IS NOT NULL AND target_value > 0))',
    'CHECK(type != \'threshold\' OR(target_value IS NOT NULL AND metric_definition_id IS NOT NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String skillId;
  final String title;
  final String type;
  final String? metricDefinitionId;
  final int? definitionVersion;
  final double? targetValue;
  final String? targetUnit;
  final String? targetDateLocal;
  final String status;
  final DateTime? completedAtUtc;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final String? motivation;
  const Goal({
    required this.id,
    required this.skillId,
    required this.title,
    required this.type,
    this.metricDefinitionId,
    this.definitionVersion,
    this.targetValue,
    this.targetUnit,
    this.targetDateLocal,
    required this.status,
    this.completedAtUtc,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.motivation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['skill_id'] = Variable<String>(skillId);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || metricDefinitionId != null) {
      map['metric_definition_id'] = Variable<String>(metricDefinitionId);
    }
    if (!nullToAbsent || definitionVersion != null) {
      map['definition_version'] = Variable<int>(definitionVersion);
    }
    if (!nullToAbsent || targetValue != null) {
      map['target_value'] = Variable<double>(targetValue);
    }
    if (!nullToAbsent || targetUnit != null) {
      map['target_unit'] = Variable<String>(targetUnit);
    }
    if (!nullToAbsent || targetDateLocal != null) {
      map['target_date_local'] = Variable<String>(targetDateLocal);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(
        Goals.$convertercompletedAtUtcn.toSql(completedAtUtc),
      );
    }
    {
      map['created_at_utc'] = Variable<DateTime>(
        Goals.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    {
      map['updated_at_utc'] = Variable<DateTime>(
        Goals.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    if (!nullToAbsent || motivation != null) {
      map['motivation'] = Variable<String>(motivation);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      skillId: Value(skillId),
      title: Value(title),
      type: Value(type),
      metricDefinitionId: metricDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(metricDefinitionId),
      definitionVersion: definitionVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(definitionVersion),
      targetValue: targetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetValue),
      targetUnit: targetUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(targetUnit),
      targetDateLocal: targetDateLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDateLocal),
      status: Value(status),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      motivation: motivation == null && nullToAbsent
          ? const Value.absent()
          : Value(motivation),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      skillId: serializer.fromJson<String>(json['skill_id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      metricDefinitionId: serializer.fromJson<String?>(
        json['metric_definition_id'],
      ),
      definitionVersion: serializer.fromJson<int?>(json['definition_version']),
      targetValue: serializer.fromJson<double?>(json['target_value']),
      targetUnit: serializer.fromJson<String?>(json['target_unit']),
      targetDateLocal: serializer.fromJson<String?>(json['target_date_local']),
      status: serializer.fromJson<String>(json['status']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completed_at_utc']),
      createdAtUtc: serializer.fromJson<DateTime>(json['created_at_utc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updated_at_utc']),
      motivation: serializer.fromJson<String?>(json['motivation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'skill_id': serializer.toJson<String>(skillId),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'metric_definition_id': serializer.toJson<String?>(metricDefinitionId),
      'definition_version': serializer.toJson<int?>(definitionVersion),
      'target_value': serializer.toJson<double?>(targetValue),
      'target_unit': serializer.toJson<String?>(targetUnit),
      'target_date_local': serializer.toJson<String?>(targetDateLocal),
      'status': serializer.toJson<String>(status),
      'completed_at_utc': serializer.toJson<DateTime?>(completedAtUtc),
      'created_at_utc': serializer.toJson<DateTime>(createdAtUtc),
      'updated_at_utc': serializer.toJson<DateTime>(updatedAtUtc),
      'motivation': serializer.toJson<String?>(motivation),
    };
  }

  Goal copyWith({
    String? id,
    String? skillId,
    String? title,
    String? type,
    Value<String?> metricDefinitionId = const Value.absent(),
    Value<int?> definitionVersion = const Value.absent(),
    Value<double?> targetValue = const Value.absent(),
    Value<String?> targetUnit = const Value.absent(),
    Value<String?> targetDateLocal = const Value.absent(),
    String? status,
    Value<DateTime?> completedAtUtc = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<String?> motivation = const Value.absent(),
  }) => Goal(
    id: id ?? this.id,
    skillId: skillId ?? this.skillId,
    title: title ?? this.title,
    type: type ?? this.type,
    metricDefinitionId: metricDefinitionId.present
        ? metricDefinitionId.value
        : this.metricDefinitionId,
    definitionVersion: definitionVersion.present
        ? definitionVersion.value
        : this.definitionVersion,
    targetValue: targetValue.present ? targetValue.value : this.targetValue,
    targetUnit: targetUnit.present ? targetUnit.value : this.targetUnit,
    targetDateLocal: targetDateLocal.present
        ? targetDateLocal.value
        : this.targetDateLocal,
    status: status ?? this.status,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    motivation: motivation.present ? motivation.value : this.motivation,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      metricDefinitionId: data.metricDefinitionId.present
          ? data.metricDefinitionId.value
          : this.metricDefinitionId,
      definitionVersion: data.definitionVersion.present
          ? data.definitionVersion.value
          : this.definitionVersion,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      targetUnit: data.targetUnit.present
          ? data.targetUnit.value
          : this.targetUnit,
      targetDateLocal: data.targetDateLocal.present
          ? data.targetDateLocal.value
          : this.targetDateLocal,
      status: data.status.present ? data.status.value : this.status,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      motivation: data.motivation.present
          ? data.motivation.value
          : this.motivation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('metricDefinitionId: $metricDefinitionId, ')
          ..write('definitionVersion: $definitionVersion, ')
          ..write('targetValue: $targetValue, ')
          ..write('targetUnit: $targetUnit, ')
          ..write('targetDateLocal: $targetDateLocal, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('motivation: $motivation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    skillId,
    title,
    type,
    metricDefinitionId,
    definitionVersion,
    targetValue,
    targetUnit,
    targetDateLocal,
    status,
    completedAtUtc,
    createdAtUtc,
    updatedAtUtc,
    motivation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.skillId == this.skillId &&
          other.title == this.title &&
          other.type == this.type &&
          other.metricDefinitionId == this.metricDefinitionId &&
          other.definitionVersion == this.definitionVersion &&
          other.targetValue == this.targetValue &&
          other.targetUnit == this.targetUnit &&
          other.targetDateLocal == this.targetDateLocal &&
          other.status == this.status &&
          other.completedAtUtc == this.completedAtUtc &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.motivation == this.motivation);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> skillId;
  final Value<String> title;
  final Value<String> type;
  final Value<String?> metricDefinitionId;
  final Value<int?> definitionVersion;
  final Value<double?> targetValue;
  final Value<String?> targetUnit;
  final Value<String?> targetDateLocal;
  final Value<String> status;
  final Value<DateTime?> completedAtUtc;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<String?> motivation;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.skillId = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.metricDefinitionId = const Value.absent(),
    this.definitionVersion = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.targetUnit = const Value.absent(),
    this.targetDateLocal = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.motivation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String skillId,
    required String title,
    required String type,
    this.metricDefinitionId = const Value.absent(),
    this.definitionVersion = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.targetUnit = const Value.absent(),
    this.targetDateLocal = const Value.absent(),
    required String status,
    this.completedAtUtc = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.motivation = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       skillId = Value(skillId),
       title = Value(title),
       type = Value(type),
       status = Value(status),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? skillId,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? metricDefinitionId,
    Expression<int>? definitionVersion,
    Expression<double>? targetValue,
    Expression<String>? targetUnit,
    Expression<String>? targetDateLocal,
    Expression<String>? status,
    Expression<DateTime>? completedAtUtc,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<String>? motivation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillId != null) 'skill_id': skillId,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (metricDefinitionId != null)
        'metric_definition_id': metricDefinitionId,
      if (definitionVersion != null) 'definition_version': definitionVersion,
      if (targetValue != null) 'target_value': targetValue,
      if (targetUnit != null) 'target_unit': targetUnit,
      if (targetDateLocal != null) 'target_date_local': targetDateLocal,
      if (status != null) 'status': status,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (motivation != null) 'motivation': motivation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? skillId,
    Value<String>? title,
    Value<String>? type,
    Value<String?>? metricDefinitionId,
    Value<int?>? definitionVersion,
    Value<double?>? targetValue,
    Value<String?>? targetUnit,
    Value<String?>? targetDateLocal,
    Value<String>? status,
    Value<DateTime?>? completedAtUtc,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<String?>? motivation,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      title: title ?? this.title,
      type: type ?? this.type,
      metricDefinitionId: metricDefinitionId ?? this.metricDefinitionId,
      definitionVersion: definitionVersion ?? this.definitionVersion,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      targetDateLocal: targetDateLocal ?? this.targetDateLocal,
      status: status ?? this.status,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      motivation: motivation ?? this.motivation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<String>(skillId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (metricDefinitionId.present) {
      map['metric_definition_id'] = Variable<String>(metricDefinitionId.value);
    }
    if (definitionVersion.present) {
      map['definition_version'] = Variable<int>(definitionVersion.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (targetUnit.present) {
      map['target_unit'] = Variable<String>(targetUnit.value);
    }
    if (targetDateLocal.present) {
      map['target_date_local'] = Variable<String>(targetDateLocal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(
        Goals.$convertercompletedAtUtcn.toSql(completedAtUtc.value),
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        Goals.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        Goals.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (motivation.present) {
      map['motivation'] = Variable<String>(motivation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('metricDefinitionId: $metricDefinitionId, ')
          ..write('definitionVersion: $definitionVersion, ')
          ..write('targetValue: $targetValue, ')
          ..write('targetUnit: $targetUnit, ')
          ..write('targetDateLocal: $targetDateLocal, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('motivation: $motivation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Exercises extends Table with TableInfo<Exercises, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Exercises(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (length(id) = 36)',
  );
  static const VerificationMeta _skillIdMeta = const VerificationMeta(
    'skillId',
  );
  late final GeneratedColumn<String> skillId = GeneratedColumn<String>(
    'skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES skills(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 4096)',
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _defaultSecondsMeta = const VerificationMeta(
    'defaultSeconds',
  );
  late final GeneratedColumn<int> defaultSeconds = GeneratedColumn<int>(
    'default_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (default_seconds BETWEEN 0 AND 86400)',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE CHECK (is_archived IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Exercises.$convertercreatedAtUtc);
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Exercises.$converterupdatedAtUtc);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    skillId,
    templateId,
    title,
    instructions,
    defaultSeconds,
    sortOrder,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(
        _skillIdMeta,
        skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('default_seconds')) {
      context.handle(
        _defaultSecondsMeta,
        defaultSeconds.isAcceptableOrUnknown(
          data['default_seconds']!,
          _defaultSecondsMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {skillId, templateId},
  ];
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      skillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      )!,
      defaultSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_seconds'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAtUtc: Exercises.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      updatedAtUtc: Exercises.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
    );
  }

  @override
  Exercises createAlias(String alias) {
    return Exercises(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcDateTimeConverter();
  @override
  List<String> get customConstraints => const ['UNIQUE(skill_id, template_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final String skillId;
  final String? templateId;
  final String title;
  final String instructions;
  final int? defaultSeconds;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const Exercise({
    required this.id,
    required this.skillId,
    this.templateId,
    required this.title,
    required this.instructions,
    this.defaultSeconds,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['skill_id'] = Variable<String>(skillId);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['title'] = Variable<String>(title);
    map['instructions'] = Variable<String>(instructions);
    if (!nullToAbsent || defaultSeconds != null) {
      map['default_seconds'] = Variable<int>(defaultSeconds);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    {
      map['created_at_utc'] = Variable<DateTime>(
        Exercises.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    {
      map['updated_at_utc'] = Variable<DateTime>(
        Exercises.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      skillId: Value(skillId),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      title: Value(title),
      instructions: Value(instructions),
      defaultSeconds: defaultSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultSeconds),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      skillId: serializer.fromJson<String>(json['skill_id']),
      templateId: serializer.fromJson<String?>(json['template_id']),
      title: serializer.fromJson<String>(json['title']),
      instructions: serializer.fromJson<String>(json['instructions']),
      defaultSeconds: serializer.fromJson<int?>(json['default_seconds']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      isArchived: serializer.fromJson<bool>(json['is_archived']),
      createdAtUtc: serializer.fromJson<DateTime>(json['created_at_utc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updated_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'skill_id': serializer.toJson<String>(skillId),
      'template_id': serializer.toJson<String?>(templateId),
      'title': serializer.toJson<String>(title),
      'instructions': serializer.toJson<String>(instructions),
      'default_seconds': serializer.toJson<int?>(defaultSeconds),
      'sort_order': serializer.toJson<int>(sortOrder),
      'is_archived': serializer.toJson<bool>(isArchived),
      'created_at_utc': serializer.toJson<DateTime>(createdAtUtc),
      'updated_at_utc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  Exercise copyWith({
    String? id,
    String? skillId,
    Value<String?> templateId = const Value.absent(),
    String? title,
    String? instructions,
    Value<int?> defaultSeconds = const Value.absent(),
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => Exercise(
    id: id ?? this.id,
    skillId: skillId ?? this.skillId,
    templateId: templateId.present ? templateId.value : this.templateId,
    title: title ?? this.title,
    instructions: instructions ?? this.instructions,
    defaultSeconds: defaultSeconds.present
        ? defaultSeconds.value
        : this.defaultSeconds,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      title: data.title.present ? data.title.value : this.title,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      defaultSeconds: data.defaultSeconds.present
          ? data.defaultSeconds.value
          : this.defaultSeconds,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('instructions: $instructions, ')
          ..write('defaultSeconds: $defaultSeconds, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    skillId,
    templateId,
    title,
    instructions,
    defaultSeconds,
    sortOrder,
    isArchived,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.skillId == this.skillId &&
          other.templateId == this.templateId &&
          other.title == this.title &&
          other.instructions == this.instructions &&
          other.defaultSeconds == this.defaultSeconds &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> skillId;
  final Value<String?> templateId;
  final Value<String> title;
  final Value<String> instructions;
  final Value<int?> defaultSeconds;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.skillId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.title = const Value.absent(),
    this.instructions = const Value.absent(),
    this.defaultSeconds = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String skillId,
    this.templateId = const Value.absent(),
    required String title,
    this.instructions = const Value.absent(),
    this.defaultSeconds = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       skillId = Value(skillId),
       title = Value(title),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? skillId,
    Expression<String>? templateId,
    Expression<String>? title,
    Expression<String>? instructions,
    Expression<int>? defaultSeconds,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillId != null) 'skill_id': skillId,
      if (templateId != null) 'template_id': templateId,
      if (title != null) 'title': title,
      if (instructions != null) 'instructions': instructions,
      if (defaultSeconds != null) 'default_seconds': defaultSeconds,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? skillId,
    Value<String?>? templateId,
    Value<String>? title,
    Value<String>? instructions,
    Value<int?>? defaultSeconds,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      defaultSeconds: defaultSeconds ?? this.defaultSeconds,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<String>(skillId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (defaultSeconds.present) {
      map['default_seconds'] = Variable<int>(defaultSeconds.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        Exercises.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        Exercises.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('instructions: $instructions, ')
          ..write('defaultSeconds: $defaultSeconds, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Sessions extends Table with TableInfo<Sessions, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Sessions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (length(id) = 36)',
  );
  static const VerificationMeta _skillIdMeta = const VerificationMeta(
    'skillId',
  );
  late final GeneratedColumn<String> skillId = GeneratedColumn<String>(
    'skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES skills(id)ON DELETE CASCADE',
  );
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<DateTime?>(Sessions.$converterstartedAtUtcn);
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime> endedAtUtc =
      GeneratedColumn<DateTime>(
        'ended_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<DateTime?>(Sessions.$converterendedAtUtcn);
  static const VerificationMeta _activeSecondsMeta = const VerificationMeta(
    'activeSeconds',
  );
  late final GeneratedColumn<int> activeSeconds = GeneratedColumn<int>(
    'active_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (active_seconds >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _entryModeMeta = const VerificationMeta(
    'entryMode',
  );
  late final GeneratedColumn<String> entryMode = GeneratedColumn<String>(
    'entry_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (entry_mode IN (\'timed\', \'manual\'))',
  );
  static const VerificationMeta _manualIntentMeta = const VerificationMeta(
    'manualIntent',
  );
  late final GeneratedColumn<String> manualIntent = GeneratedColumn<String>(
    'manual_intent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (manual_intent IN (\'duration\', \'evidence_only\'))',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'draft\', \'running\', \'paused\', \'completed\', \'discarded\'))',
  );
  static const VerificationMeta _interruptionReasonMeta =
      const VerificationMeta('interruptionReason');
  late final GeneratedColumn<String> interruptionReason =
      GeneratedColumn<String>(
        'interruption_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Sessions.$convertercreatedAtUtc);
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Sessions.$converterupdatedAtUtc);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (revision >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _whatGotEasierMeta = const VerificationMeta(
    'whatGotEasier',
  );
  late final GeneratedColumn<String> whatGotEasier = GeneratedColumn<String>(
    'what_got_easier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (length(what_got_easier) <= 100000)',
  );
  static const VerificationMeta _nextStepMeta = const VerificationMeta(
    'nextStep',
  );
  late final GeneratedColumn<String> nextStep = GeneratedColumn<String>(
    'next_step',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _effortRatingMeta = const VerificationMeta(
    'effortRating',
  );
  late final GeneratedColumn<int> effortRating = GeneratedColumn<int>(
    'effort_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (effort_rating BETWEEN 1 AND 5)',
  );
  static const VerificationMeta _localDisplayZoneMeta = const VerificationMeta(
    'localDisplayZone',
  );
  late final GeneratedColumn<String> localDisplayZone = GeneratedColumn<String>(
    'local_display_zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sourceDeviceIdMeta = const VerificationMeta(
    'sourceDeviceId',
  );
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
    'source_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    skillId,
    startedAtUtc,
    endedAtUtc,
    activeSeconds,
    entryMode,
    manualIntent,
    status,
    interruptionReason,
    createdAtUtc,
    updatedAtUtc,
    revision,
    note,
    whatGotEasier,
    nextStep,
    effortRating,
    localDisplayZone,
    sourceDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(
        _skillIdMeta,
        skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta),
      );
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('active_seconds')) {
      context.handle(
        _activeSecondsMeta,
        activeSeconds.isAcceptableOrUnknown(
          data['active_seconds']!,
          _activeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('entry_mode')) {
      context.handle(
        _entryModeMeta,
        entryMode.isAcceptableOrUnknown(data['entry_mode']!, _entryModeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryModeMeta);
    }
    if (data.containsKey('manual_intent')) {
      context.handle(
        _manualIntentMeta,
        manualIntent.isAcceptableOrUnknown(
          data['manual_intent']!,
          _manualIntentMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('interruption_reason')) {
      context.handle(
        _interruptionReasonMeta,
        interruptionReason.isAcceptableOrUnknown(
          data['interruption_reason']!,
          _interruptionReasonMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('what_got_easier')) {
      context.handle(
        _whatGotEasierMeta,
        whatGotEasier.isAcceptableOrUnknown(
          data['what_got_easier']!,
          _whatGotEasierMeta,
        ),
      );
    }
    if (data.containsKey('next_step')) {
      context.handle(
        _nextStepMeta,
        nextStep.isAcceptableOrUnknown(data['next_step']!, _nextStepMeta),
      );
    }
    if (data.containsKey('effort_rating')) {
      context.handle(
        _effortRatingMeta,
        effortRating.isAcceptableOrUnknown(
          data['effort_rating']!,
          _effortRatingMeta,
        ),
      );
    }
    if (data.containsKey('local_display_zone')) {
      context.handle(
        _localDisplayZoneMeta,
        localDisplayZone.isAcceptableOrUnknown(
          data['local_display_zone']!,
          _localDisplayZoneMeta,
        ),
      );
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
        _sourceDeviceIdMeta,
        sourceDeviceId.isAcceptableOrUnknown(
          data['source_device_id']!,
          _sourceDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      skillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_id'],
      )!,
      startedAtUtc: Sessions.$converterstartedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}started_at_utc'],
        ),
      ),
      endedAtUtc: Sessions.$converterendedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}ended_at_utc'],
        ),
      ),
      activeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_seconds'],
      )!,
      entryMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_mode'],
      )!,
      manualIntent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_intent'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      interruptionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interruption_reason'],
      ),
      createdAtUtc: Sessions.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      updatedAtUtc: Sessions.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      whatGotEasier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_got_easier'],
      ),
      nextStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_step'],
      ),
      effortRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effort_rating'],
      ),
      localDisplayZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_display_zone'],
      ),
      sourceDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device_id'],
      ),
    );
  }

  @override
  Sessions createAlias(String alias) {
    return Sessions(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterstartedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $converterstartedAtUtcn =
      NullAwareTypeConverter.wrap($converterstartedAtUtc);
  static TypeConverter<DateTime, DateTime> $converterendedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $converterendedAtUtcn =
      NullAwareTypeConverter.wrap($converterendedAtUtc);
  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcDateTimeConverter();
  @override
  List<String> get customConstraints => const [
    'CHECK((entry_mode = \'manual\')=(manual_intent IS NOT NULL))',
    'CHECK(entry_mode != \'manual\' OR status NOT IN (\'running\', \'paused\'))',
    'CHECK(status != \'running\' OR started_at_utc IS NOT NULL)',
    'CHECK(status != \'completed\' OR ended_at_utc IS NOT NULL)',
    'CHECK(ended_at_utc IS NULL OR started_at_utc IS NULL OR ended_at_utc >= started_at_utc)',
    'CHECK(entry_mode != \'manual\' OR status != \'completed\' OR active_seconds > 0 OR manual_intent = \'evidence_only\')',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String skillId;
  final DateTime? startedAtUtc;
  final DateTime? endedAtUtc;
  final int activeSeconds;
  final String entryMode;
  final String? manualIntent;
  final String status;
  final String? interruptionReason;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final int revision;
  final String? note;
  final String? whatGotEasier;
  final String? nextStep;
  final int? effortRating;
  final String? localDisplayZone;
  final String? sourceDeviceId;
  const Session({
    required this.id,
    required this.skillId,
    this.startedAtUtc,
    this.endedAtUtc,
    required this.activeSeconds,
    required this.entryMode,
    this.manualIntent,
    required this.status,
    this.interruptionReason,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.revision,
    this.note,
    this.whatGotEasier,
    this.nextStep,
    this.effortRating,
    this.localDisplayZone,
    this.sourceDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['skill_id'] = Variable<String>(skillId);
    if (!nullToAbsent || startedAtUtc != null) {
      map['started_at_utc'] = Variable<DateTime>(
        Sessions.$converterstartedAtUtcn.toSql(startedAtUtc),
      );
    }
    if (!nullToAbsent || endedAtUtc != null) {
      map['ended_at_utc'] = Variable<DateTime>(
        Sessions.$converterendedAtUtcn.toSql(endedAtUtc),
      );
    }
    map['active_seconds'] = Variable<int>(activeSeconds);
    map['entry_mode'] = Variable<String>(entryMode);
    if (!nullToAbsent || manualIntent != null) {
      map['manual_intent'] = Variable<String>(manualIntent);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || interruptionReason != null) {
      map['interruption_reason'] = Variable<String>(interruptionReason);
    }
    {
      map['created_at_utc'] = Variable<DateTime>(
        Sessions.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    {
      map['updated_at_utc'] = Variable<DateTime>(
        Sessions.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || whatGotEasier != null) {
      map['what_got_easier'] = Variable<String>(whatGotEasier);
    }
    if (!nullToAbsent || nextStep != null) {
      map['next_step'] = Variable<String>(nextStep);
    }
    if (!nullToAbsent || effortRating != null) {
      map['effort_rating'] = Variable<int>(effortRating);
    }
    if (!nullToAbsent || localDisplayZone != null) {
      map['local_display_zone'] = Variable<String>(localDisplayZone);
    }
    if (!nullToAbsent || sourceDeviceId != null) {
      map['source_device_id'] = Variable<String>(sourceDeviceId);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      skillId: Value(skillId),
      startedAtUtc: startedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAtUtc),
      endedAtUtc: endedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtUtc),
      activeSeconds: Value(activeSeconds),
      entryMode: Value(entryMode),
      manualIntent: manualIntent == null && nullToAbsent
          ? const Value.absent()
          : Value(manualIntent),
      status: Value(status),
      interruptionReason: interruptionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(interruptionReason),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      revision: Value(revision),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      whatGotEasier: whatGotEasier == null && nullToAbsent
          ? const Value.absent()
          : Value(whatGotEasier),
      nextStep: nextStep == null && nullToAbsent
          ? const Value.absent()
          : Value(nextStep),
      effortRating: effortRating == null && nullToAbsent
          ? const Value.absent()
          : Value(effortRating),
      localDisplayZone: localDisplayZone == null && nullToAbsent
          ? const Value.absent()
          : Value(localDisplayZone),
      sourceDeviceId: sourceDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDeviceId),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      skillId: serializer.fromJson<String>(json['skill_id']),
      startedAtUtc: serializer.fromJson<DateTime?>(json['started_at_utc']),
      endedAtUtc: serializer.fromJson<DateTime?>(json['ended_at_utc']),
      activeSeconds: serializer.fromJson<int>(json['active_seconds']),
      entryMode: serializer.fromJson<String>(json['entry_mode']),
      manualIntent: serializer.fromJson<String?>(json['manual_intent']),
      status: serializer.fromJson<String>(json['status']),
      interruptionReason: serializer.fromJson<String?>(
        json['interruption_reason'],
      ),
      createdAtUtc: serializer.fromJson<DateTime>(json['created_at_utc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updated_at_utc']),
      revision: serializer.fromJson<int>(json['revision']),
      note: serializer.fromJson<String?>(json['note']),
      whatGotEasier: serializer.fromJson<String?>(json['what_got_easier']),
      nextStep: serializer.fromJson<String?>(json['next_step']),
      effortRating: serializer.fromJson<int?>(json['effort_rating']),
      localDisplayZone: serializer.fromJson<String?>(
        json['local_display_zone'],
      ),
      sourceDeviceId: serializer.fromJson<String?>(json['source_device_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'skill_id': serializer.toJson<String>(skillId),
      'started_at_utc': serializer.toJson<DateTime?>(startedAtUtc),
      'ended_at_utc': serializer.toJson<DateTime?>(endedAtUtc),
      'active_seconds': serializer.toJson<int>(activeSeconds),
      'entry_mode': serializer.toJson<String>(entryMode),
      'manual_intent': serializer.toJson<String?>(manualIntent),
      'status': serializer.toJson<String>(status),
      'interruption_reason': serializer.toJson<String?>(interruptionReason),
      'created_at_utc': serializer.toJson<DateTime>(createdAtUtc),
      'updated_at_utc': serializer.toJson<DateTime>(updatedAtUtc),
      'revision': serializer.toJson<int>(revision),
      'note': serializer.toJson<String?>(note),
      'what_got_easier': serializer.toJson<String?>(whatGotEasier),
      'next_step': serializer.toJson<String?>(nextStep),
      'effort_rating': serializer.toJson<int?>(effortRating),
      'local_display_zone': serializer.toJson<String?>(localDisplayZone),
      'source_device_id': serializer.toJson<String?>(sourceDeviceId),
    };
  }

  Session copyWith({
    String? id,
    String? skillId,
    Value<DateTime?> startedAtUtc = const Value.absent(),
    Value<DateTime?> endedAtUtc = const Value.absent(),
    int? activeSeconds,
    String? entryMode,
    Value<String?> manualIntent = const Value.absent(),
    String? status,
    Value<String?> interruptionReason = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    int? revision,
    Value<String?> note = const Value.absent(),
    Value<String?> whatGotEasier = const Value.absent(),
    Value<String?> nextStep = const Value.absent(),
    Value<int?> effortRating = const Value.absent(),
    Value<String?> localDisplayZone = const Value.absent(),
    Value<String?> sourceDeviceId = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    skillId: skillId ?? this.skillId,
    startedAtUtc: startedAtUtc.present ? startedAtUtc.value : this.startedAtUtc,
    endedAtUtc: endedAtUtc.present ? endedAtUtc.value : this.endedAtUtc,
    activeSeconds: activeSeconds ?? this.activeSeconds,
    entryMode: entryMode ?? this.entryMode,
    manualIntent: manualIntent.present ? manualIntent.value : this.manualIntent,
    status: status ?? this.status,
    interruptionReason: interruptionReason.present
        ? interruptionReason.value
        : this.interruptionReason,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    revision: revision ?? this.revision,
    note: note.present ? note.value : this.note,
    whatGotEasier: whatGotEasier.present
        ? whatGotEasier.value
        : this.whatGotEasier,
    nextStep: nextStep.present ? nextStep.value : this.nextStep,
    effortRating: effortRating.present ? effortRating.value : this.effortRating,
    localDisplayZone: localDisplayZone.present
        ? localDisplayZone.value
        : this.localDisplayZone,
    sourceDeviceId: sourceDeviceId.present
        ? sourceDeviceId.value
        : this.sourceDeviceId,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      endedAtUtc: data.endedAtUtc.present
          ? data.endedAtUtc.value
          : this.endedAtUtc,
      activeSeconds: data.activeSeconds.present
          ? data.activeSeconds.value
          : this.activeSeconds,
      entryMode: data.entryMode.present ? data.entryMode.value : this.entryMode,
      manualIntent: data.manualIntent.present
          ? data.manualIntent.value
          : this.manualIntent,
      status: data.status.present ? data.status.value : this.status,
      interruptionReason: data.interruptionReason.present
          ? data.interruptionReason.value
          : this.interruptionReason,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      revision: data.revision.present ? data.revision.value : this.revision,
      note: data.note.present ? data.note.value : this.note,
      whatGotEasier: data.whatGotEasier.present
          ? data.whatGotEasier.value
          : this.whatGotEasier,
      nextStep: data.nextStep.present ? data.nextStep.value : this.nextStep,
      effortRating: data.effortRating.present
          ? data.effortRating.value
          : this.effortRating,
      localDisplayZone: data.localDisplayZone.present
          ? data.localDisplayZone.value
          : this.localDisplayZone,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('entryMode: $entryMode, ')
          ..write('manualIntent: $manualIntent, ')
          ..write('status: $status, ')
          ..write('interruptionReason: $interruptionReason, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('revision: $revision, ')
          ..write('note: $note, ')
          ..write('whatGotEasier: $whatGotEasier, ')
          ..write('nextStep: $nextStep, ')
          ..write('effortRating: $effortRating, ')
          ..write('localDisplayZone: $localDisplayZone, ')
          ..write('sourceDeviceId: $sourceDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    skillId,
    startedAtUtc,
    endedAtUtc,
    activeSeconds,
    entryMode,
    manualIntent,
    status,
    interruptionReason,
    createdAtUtc,
    updatedAtUtc,
    revision,
    note,
    whatGotEasier,
    nextStep,
    effortRating,
    localDisplayZone,
    sourceDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.skillId == this.skillId &&
          other.startedAtUtc == this.startedAtUtc &&
          other.endedAtUtc == this.endedAtUtc &&
          other.activeSeconds == this.activeSeconds &&
          other.entryMode == this.entryMode &&
          other.manualIntent == this.manualIntent &&
          other.status == this.status &&
          other.interruptionReason == this.interruptionReason &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.revision == this.revision &&
          other.note == this.note &&
          other.whatGotEasier == this.whatGotEasier &&
          other.nextStep == this.nextStep &&
          other.effortRating == this.effortRating &&
          other.localDisplayZone == this.localDisplayZone &&
          other.sourceDeviceId == this.sourceDeviceId);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> skillId;
  final Value<DateTime?> startedAtUtc;
  final Value<DateTime?> endedAtUtc;
  final Value<int> activeSeconds;
  final Value<String> entryMode;
  final Value<String?> manualIntent;
  final Value<String> status;
  final Value<String?> interruptionReason;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> revision;
  final Value<String?> note;
  final Value<String?> whatGotEasier;
  final Value<String?> nextStep;
  final Value<int?> effortRating;
  final Value<String?> localDisplayZone;
  final Value<String?> sourceDeviceId;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.skillId = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.endedAtUtc = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.entryMode = const Value.absent(),
    this.manualIntent = const Value.absent(),
    this.status = const Value.absent(),
    this.interruptionReason = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.revision = const Value.absent(),
    this.note = const Value.absent(),
    this.whatGotEasier = const Value.absent(),
    this.nextStep = const Value.absent(),
    this.effortRating = const Value.absent(),
    this.localDisplayZone = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String skillId,
    this.startedAtUtc = const Value.absent(),
    this.endedAtUtc = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    required String entryMode,
    this.manualIntent = const Value.absent(),
    required String status,
    this.interruptionReason = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.revision = const Value.absent(),
    this.note = const Value.absent(),
    this.whatGotEasier = const Value.absent(),
    this.nextStep = const Value.absent(),
    this.effortRating = const Value.absent(),
    this.localDisplayZone = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       skillId = Value(skillId),
       entryMode = Value(entryMode),
       status = Value(status),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? skillId,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? endedAtUtc,
    Expression<int>? activeSeconds,
    Expression<String>? entryMode,
    Expression<String>? manualIntent,
    Expression<String>? status,
    Expression<String>? interruptionReason,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? revision,
    Expression<String>? note,
    Expression<String>? whatGotEasier,
    Expression<String>? nextStep,
    Expression<int>? effortRating,
    Expression<String>? localDisplayZone,
    Expression<String>? sourceDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillId != null) 'skill_id': skillId,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (endedAtUtc != null) 'ended_at_utc': endedAtUtc,
      if (activeSeconds != null) 'active_seconds': activeSeconds,
      if (entryMode != null) 'entry_mode': entryMode,
      if (manualIntent != null) 'manual_intent': manualIntent,
      if (status != null) 'status': status,
      if (interruptionReason != null) 'interruption_reason': interruptionReason,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (revision != null) 'revision': revision,
      if (note != null) 'note': note,
      if (whatGotEasier != null) 'what_got_easier': whatGotEasier,
      if (nextStep != null) 'next_step': nextStep,
      if (effortRating != null) 'effort_rating': effortRating,
      if (localDisplayZone != null) 'local_display_zone': localDisplayZone,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? skillId,
    Value<DateTime?>? startedAtUtc,
    Value<DateTime?>? endedAtUtc,
    Value<int>? activeSeconds,
    Value<String>? entryMode,
    Value<String?>? manualIntent,
    Value<String>? status,
    Value<String?>? interruptionReason,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? revision,
    Value<String?>? note,
    Value<String?>? whatGotEasier,
    Value<String?>? nextStep,
    Value<int?>? effortRating,
    Value<String?>? localDisplayZone,
    Value<String?>? sourceDeviceId,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      activeSeconds: activeSeconds ?? this.activeSeconds,
      entryMode: entryMode ?? this.entryMode,
      manualIntent: manualIntent ?? this.manualIntent,
      status: status ?? this.status,
      interruptionReason: interruptionReason ?? this.interruptionReason,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      revision: revision ?? this.revision,
      note: note ?? this.note,
      whatGotEasier: whatGotEasier ?? this.whatGotEasier,
      nextStep: nextStep ?? this.nextStep,
      effortRating: effortRating ?? this.effortRating,
      localDisplayZone: localDisplayZone ?? this.localDisplayZone,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<String>(skillId.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(
        Sessions.$converterstartedAtUtcn.toSql(startedAtUtc.value),
      );
    }
    if (endedAtUtc.present) {
      map['ended_at_utc'] = Variable<DateTime>(
        Sessions.$converterendedAtUtcn.toSql(endedAtUtc.value),
      );
    }
    if (activeSeconds.present) {
      map['active_seconds'] = Variable<int>(activeSeconds.value);
    }
    if (entryMode.present) {
      map['entry_mode'] = Variable<String>(entryMode.value);
    }
    if (manualIntent.present) {
      map['manual_intent'] = Variable<String>(manualIntent.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (interruptionReason.present) {
      map['interruption_reason'] = Variable<String>(interruptionReason.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        Sessions.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        Sessions.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (whatGotEasier.present) {
      map['what_got_easier'] = Variable<String>(whatGotEasier.value);
    }
    if (nextStep.present) {
      map['next_step'] = Variable<String>(nextStep.value);
    }
    if (effortRating.present) {
      map['effort_rating'] = Variable<int>(effortRating.value);
    }
    if (localDisplayZone.present) {
      map['local_display_zone'] = Variable<String>(localDisplayZone.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('entryMode: $entryMode, ')
          ..write('manualIntent: $manualIntent, ')
          ..write('status: $status, ')
          ..write('interruptionReason: $interruptionReason, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('revision: $revision, ')
          ..write('note: $note, ')
          ..write('whatGotEasier: $whatGotEasier, ')
          ..write('nextStep: $nextStep, ')
          ..write('effortRating: $effortRating, ')
          ..write('localDisplayZone: $localDisplayZone, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class JournalDrafts extends Table with TableInfo<JournalDrafts, JournalDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  JournalDrafts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sessions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (purpose IN (\'finish\', \'edit\'))',
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (base_revision >= 0)',
  );
  static const VerificationMeta _formJsonMeta = const VerificationMeta(
    'formJson',
  );
  late final GeneratedColumn<String> formJson = GeneratedColumn<String>(
    'form_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(form_json) <= 500000 AND json_valid(form_json))',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(JournalDrafts.$converterupdatedAtUtc);
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    purpose,
    baseRevision,
    formJson,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseRevisionMeta);
    }
    if (data.containsKey('form_json')) {
      context.handle(
        _formJsonMeta,
        formJson.isAcceptableOrUnknown(data['form_json']!, _formJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_formJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, purpose};
  @override
  JournalDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalDraft(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      )!,
      formJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_json'],
      )!,
      updatedAtUtc: JournalDrafts.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
    );
  }

  @override
  JournalDrafts createAlias(String alias) {
    return JournalDrafts(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcDateTimeConverter();
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(session_id, purpose)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class JournalDraft extends DataClass implements Insertable<JournalDraft> {
  final String sessionId;
  final String purpose;
  final int baseRevision;
  final String formJson;
  final DateTime updatedAtUtc;
  const JournalDraft({
    required this.sessionId,
    required this.purpose,
    required this.baseRevision,
    required this.formJson,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['purpose'] = Variable<String>(purpose);
    map['base_revision'] = Variable<int>(baseRevision);
    map['form_json'] = Variable<String>(formJson);
    {
      map['updated_at_utc'] = Variable<DateTime>(
        JournalDrafts.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    return map;
  }

  JournalDraftsCompanion toCompanion(bool nullToAbsent) {
    return JournalDraftsCompanion(
      sessionId: Value(sessionId),
      purpose: Value(purpose),
      baseRevision: Value(baseRevision),
      formJson: Value(formJson),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory JournalDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalDraft(
      sessionId: serializer.fromJson<String>(json['session_id']),
      purpose: serializer.fromJson<String>(json['purpose']),
      baseRevision: serializer.fromJson<int>(json['base_revision']),
      formJson: serializer.fromJson<String>(json['form_json']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updated_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'session_id': serializer.toJson<String>(sessionId),
      'purpose': serializer.toJson<String>(purpose),
      'base_revision': serializer.toJson<int>(baseRevision),
      'form_json': serializer.toJson<String>(formJson),
      'updated_at_utc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  JournalDraft copyWith({
    String? sessionId,
    String? purpose,
    int? baseRevision,
    String? formJson,
    DateTime? updatedAtUtc,
  }) => JournalDraft(
    sessionId: sessionId ?? this.sessionId,
    purpose: purpose ?? this.purpose,
    baseRevision: baseRevision ?? this.baseRevision,
    formJson: formJson ?? this.formJson,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  JournalDraft copyWithCompanion(JournalDraftsCompanion data) {
    return JournalDraft(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      formJson: data.formJson.present ? data.formJson.value : this.formJson,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalDraft(')
          ..write('sessionId: $sessionId, ')
          ..write('purpose: $purpose, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('formJson: $formJson, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, purpose, baseRevision, formJson, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalDraft &&
          other.sessionId == this.sessionId &&
          other.purpose == this.purpose &&
          other.baseRevision == this.baseRevision &&
          other.formJson == this.formJson &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class JournalDraftsCompanion extends UpdateCompanion<JournalDraft> {
  final Value<String> sessionId;
  final Value<String> purpose;
  final Value<int> baseRevision;
  final Value<String> formJson;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const JournalDraftsCompanion({
    this.sessionId = const Value.absent(),
    this.purpose = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.formJson = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalDraftsCompanion.insert({
    required String sessionId,
    required String purpose,
    required int baseRevision,
    required String formJson,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       purpose = Value(purpose),
       baseRevision = Value(baseRevision),
       formJson = Value(formJson),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<JournalDraft> custom({
    Expression<String>? sessionId,
    Expression<String>? purpose,
    Expression<int>? baseRevision,
    Expression<String>? formJson,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (purpose != null) 'purpose': purpose,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (formJson != null) 'form_json': formJson,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalDraftsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? purpose,
    Value<int>? baseRevision,
    Value<String>? formJson,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return JournalDraftsCompanion(
      sessionId: sessionId ?? this.sessionId,
      purpose: purpose ?? this.purpose,
      baseRevision: baseRevision ?? this.baseRevision,
      formJson: formJson ?? this.formJson,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (formJson.present) {
      map['form_json'] = Variable<String>(formJson.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        JournalDrafts.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalDraftsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('purpose: $purpose, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('formJson: $formJson, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PracticeCheckpoints extends Table
    with TableInfo<PracticeCheckpoints, PracticeCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PracticeCheckpoints(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES sessions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _activeMillisecondsMeta =
      const VerificationMeta('activeMilliseconds');
  late final GeneratedColumn<int> activeMilliseconds = GeneratedColumn<int>(
    'active_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (active_milliseconds >= 0)',
  );
  static const VerificationMeta _plannedSecondsMeta = const VerificationMeta(
    'plannedSeconds',
  );
  late final GeneratedColumn<int> plannedSeconds = GeneratedColumn<int>(
    'planned_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (planned_seconds BETWEEN 60 AND 10800)',
  );
  static const VerificationMeta _manualSecondsMeta = const VerificationMeta(
    'manualSeconds',
  );
  late final GeneratedColumn<int> manualSeconds = GeneratedColumn<int>(
    'manual_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT 0 CHECK (manual_seconds BETWEEN 0 AND 604800)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _manualDateLocalMeta = const VerificationMeta(
    'manualDateLocal',
  );
  late final GeneratedColumn<String> manualDateLocal = GeneratedColumn<String>(
    'manual_date_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime>
  checkpointAtUtc = GeneratedColumn<DateTime>(
    'checkpoint_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  ).withConverter<DateTime>(PracticeCheckpoints.$convertercheckpointAtUtc);
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    activeMilliseconds,
    plannedSeconds,
    manualSeconds,
    manualDateLocal,
    checkpointAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeCheckpoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('active_milliseconds')) {
      context.handle(
        _activeMillisecondsMeta,
        activeMilliseconds.isAcceptableOrUnknown(
          data['active_milliseconds']!,
          _activeMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeMillisecondsMeta);
    }
    if (data.containsKey('planned_seconds')) {
      context.handle(
        _plannedSecondsMeta,
        plannedSeconds.isAcceptableOrUnknown(
          data['planned_seconds']!,
          _plannedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('manual_seconds')) {
      context.handle(
        _manualSecondsMeta,
        manualSeconds.isAcceptableOrUnknown(
          data['manual_seconds']!,
          _manualSecondsMeta,
        ),
      );
    }
    if (data.containsKey('manual_date_local')) {
      context.handle(
        _manualDateLocalMeta,
        manualDateLocal.isAcceptableOrUnknown(
          data['manual_date_local']!,
          _manualDateLocalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  PracticeCheckpoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeCheckpoint(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      activeMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_milliseconds'],
      )!,
      plannedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_seconds'],
      ),
      manualSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_seconds'],
      )!,
      manualDateLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manual_date_local'],
      ),
      checkpointAtUtc: PracticeCheckpoints.$convertercheckpointAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}checkpoint_at_utc'],
        )!,
      ),
    );
  }

  @override
  PracticeCheckpoints createAlias(String alias) {
    return PracticeCheckpoints(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercheckpointAtUtc =
      const UtcDateTimeConverter();
  @override
  bool get dontWriteConstraints => true;
}

class PracticeCheckpoint extends DataClass
    implements Insertable<PracticeCheckpoint> {
  final String sessionId;
  final int activeMilliseconds;
  final int? plannedSeconds;
  final int manualSeconds;
  final String? manualDateLocal;
  final DateTime checkpointAtUtc;
  const PracticeCheckpoint({
    required this.sessionId,
    required this.activeMilliseconds,
    this.plannedSeconds,
    required this.manualSeconds,
    this.manualDateLocal,
    required this.checkpointAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['active_milliseconds'] = Variable<int>(activeMilliseconds);
    if (!nullToAbsent || plannedSeconds != null) {
      map['planned_seconds'] = Variable<int>(plannedSeconds);
    }
    map['manual_seconds'] = Variable<int>(manualSeconds);
    if (!nullToAbsent || manualDateLocal != null) {
      map['manual_date_local'] = Variable<String>(manualDateLocal);
    }
    {
      map['checkpoint_at_utc'] = Variable<DateTime>(
        PracticeCheckpoints.$convertercheckpointAtUtc.toSql(checkpointAtUtc),
      );
    }
    return map;
  }

  PracticeCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return PracticeCheckpointsCompanion(
      sessionId: Value(sessionId),
      activeMilliseconds: Value(activeMilliseconds),
      plannedSeconds: plannedSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedSeconds),
      manualSeconds: Value(manualSeconds),
      manualDateLocal: manualDateLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(manualDateLocal),
      checkpointAtUtc: Value(checkpointAtUtc),
    );
  }

  factory PracticeCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeCheckpoint(
      sessionId: serializer.fromJson<String>(json['session_id']),
      activeMilliseconds: serializer.fromJson<int>(json['active_milliseconds']),
      plannedSeconds: serializer.fromJson<int?>(json['planned_seconds']),
      manualSeconds: serializer.fromJson<int>(json['manual_seconds']),
      manualDateLocal: serializer.fromJson<String?>(json['manual_date_local']),
      checkpointAtUtc: serializer.fromJson<DateTime>(json['checkpoint_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'session_id': serializer.toJson<String>(sessionId),
      'active_milliseconds': serializer.toJson<int>(activeMilliseconds),
      'planned_seconds': serializer.toJson<int?>(plannedSeconds),
      'manual_seconds': serializer.toJson<int>(manualSeconds),
      'manual_date_local': serializer.toJson<String?>(manualDateLocal),
      'checkpoint_at_utc': serializer.toJson<DateTime>(checkpointAtUtc),
    };
  }

  PracticeCheckpoint copyWith({
    String? sessionId,
    int? activeMilliseconds,
    Value<int?> plannedSeconds = const Value.absent(),
    int? manualSeconds,
    Value<String?> manualDateLocal = const Value.absent(),
    DateTime? checkpointAtUtc,
  }) => PracticeCheckpoint(
    sessionId: sessionId ?? this.sessionId,
    activeMilliseconds: activeMilliseconds ?? this.activeMilliseconds,
    plannedSeconds: plannedSeconds.present
        ? plannedSeconds.value
        : this.plannedSeconds,
    manualSeconds: manualSeconds ?? this.manualSeconds,
    manualDateLocal: manualDateLocal.present
        ? manualDateLocal.value
        : this.manualDateLocal,
    checkpointAtUtc: checkpointAtUtc ?? this.checkpointAtUtc,
  );
  PracticeCheckpoint copyWithCompanion(PracticeCheckpointsCompanion data) {
    return PracticeCheckpoint(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      activeMilliseconds: data.activeMilliseconds.present
          ? data.activeMilliseconds.value
          : this.activeMilliseconds,
      plannedSeconds: data.plannedSeconds.present
          ? data.plannedSeconds.value
          : this.plannedSeconds,
      manualSeconds: data.manualSeconds.present
          ? data.manualSeconds.value
          : this.manualSeconds,
      manualDateLocal: data.manualDateLocal.present
          ? data.manualDateLocal.value
          : this.manualDateLocal,
      checkpointAtUtc: data.checkpointAtUtc.present
          ? data.checkpointAtUtc.value
          : this.checkpointAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeCheckpoint(')
          ..write('sessionId: $sessionId, ')
          ..write('activeMilliseconds: $activeMilliseconds, ')
          ..write('plannedSeconds: $plannedSeconds, ')
          ..write('manualSeconds: $manualSeconds, ')
          ..write('manualDateLocal: $manualDateLocal, ')
          ..write('checkpointAtUtc: $checkpointAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    activeMilliseconds,
    plannedSeconds,
    manualSeconds,
    manualDateLocal,
    checkpointAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeCheckpoint &&
          other.sessionId == this.sessionId &&
          other.activeMilliseconds == this.activeMilliseconds &&
          other.plannedSeconds == this.plannedSeconds &&
          other.manualSeconds == this.manualSeconds &&
          other.manualDateLocal == this.manualDateLocal &&
          other.checkpointAtUtc == this.checkpointAtUtc);
}

class PracticeCheckpointsCompanion extends UpdateCompanion<PracticeCheckpoint> {
  final Value<String> sessionId;
  final Value<int> activeMilliseconds;
  final Value<int?> plannedSeconds;
  final Value<int> manualSeconds;
  final Value<String?> manualDateLocal;
  final Value<DateTime> checkpointAtUtc;
  final Value<int> rowid;
  const PracticeCheckpointsCompanion({
    this.sessionId = const Value.absent(),
    this.activeMilliseconds = const Value.absent(),
    this.plannedSeconds = const Value.absent(),
    this.manualSeconds = const Value.absent(),
    this.manualDateLocal = const Value.absent(),
    this.checkpointAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeCheckpointsCompanion.insert({
    required String sessionId,
    required int activeMilliseconds,
    this.plannedSeconds = const Value.absent(),
    this.manualSeconds = const Value.absent(),
    this.manualDateLocal = const Value.absent(),
    required DateTime checkpointAtUtc,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       activeMilliseconds = Value(activeMilliseconds),
       checkpointAtUtc = Value(checkpointAtUtc);
  static Insertable<PracticeCheckpoint> custom({
    Expression<String>? sessionId,
    Expression<int>? activeMilliseconds,
    Expression<int>? plannedSeconds,
    Expression<int>? manualSeconds,
    Expression<String>? manualDateLocal,
    Expression<DateTime>? checkpointAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (activeMilliseconds != null) 'active_milliseconds': activeMilliseconds,
      if (plannedSeconds != null) 'planned_seconds': plannedSeconds,
      if (manualSeconds != null) 'manual_seconds': manualSeconds,
      if (manualDateLocal != null) 'manual_date_local': manualDateLocal,
      if (checkpointAtUtc != null) 'checkpoint_at_utc': checkpointAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeCheckpointsCompanion copyWith({
    Value<String>? sessionId,
    Value<int>? activeMilliseconds,
    Value<int?>? plannedSeconds,
    Value<int>? manualSeconds,
    Value<String?>? manualDateLocal,
    Value<DateTime>? checkpointAtUtc,
    Value<int>? rowid,
  }) {
    return PracticeCheckpointsCompanion(
      sessionId: sessionId ?? this.sessionId,
      activeMilliseconds: activeMilliseconds ?? this.activeMilliseconds,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      manualSeconds: manualSeconds ?? this.manualSeconds,
      manualDateLocal: manualDateLocal ?? this.manualDateLocal,
      checkpointAtUtc: checkpointAtUtc ?? this.checkpointAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (activeMilliseconds.present) {
      map['active_milliseconds'] = Variable<int>(activeMilliseconds.value);
    }
    if (plannedSeconds.present) {
      map['planned_seconds'] = Variable<int>(plannedSeconds.value);
    }
    if (manualSeconds.present) {
      map['manual_seconds'] = Variable<int>(manualSeconds.value);
    }
    if (manualDateLocal.present) {
      map['manual_date_local'] = Variable<String>(manualDateLocal.value);
    }
    if (checkpointAtUtc.present) {
      map['checkpoint_at_utc'] = Variable<DateTime>(
        PracticeCheckpoints.$convertercheckpointAtUtc.toSql(
          checkpointAtUtc.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeCheckpointsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('activeMilliseconds: $activeMilliseconds, ')
          ..write('plannedSeconds: $plannedSeconds, ')
          ..write('manualSeconds: $manualSeconds, ')
          ..write('manualDateLocal: $manualDateLocal, ')
          ..write('checkpointAtUtc: $checkpointAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SessionExercises extends Table
    with TableInfo<SessionExercises, SessionExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SessionExercises(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sessions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES exercises(id)ON DELETE SET NULL',
  );
  static const VerificationMeta _exerciseTitleSnapshotMeta =
      const VerificationMeta('exerciseTitleSnapshot');
  late final GeneratedColumn<String> exerciseTitleSnapshot =
      GeneratedColumn<String>(
        'exercise_title_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (ordinal >= 0)',
  );
  static const VerificationMeta _allocatedSecondsMeta = const VerificationMeta(
    'allocatedSeconds',
  );
  late final GeneratedColumn<int> allocatedSeconds = GeneratedColumn<int>(
    'allocated_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (allocated_seconds >= 0)',
  );
  static const VerificationMeta _resultNoteMeta = const VerificationMeta(
    'resultNote',
  );
  late final GeneratedColumn<String> resultNote = GeneratedColumn<String>(
    'result_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    exerciseId,
    exerciseTitleSnapshot,
    ordinal,
    allocatedSeconds,
    resultNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('exercise_title_snapshot')) {
      context.handle(
        _exerciseTitleSnapshotMeta,
        exerciseTitleSnapshot.isAcceptableOrUnknown(
          data['exercise_title_snapshot']!,
          _exerciseTitleSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseTitleSnapshotMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('allocated_seconds')) {
      context.handle(
        _allocatedSecondsMeta,
        allocatedSeconds.isAcceptableOrUnknown(
          data['allocated_seconds']!,
          _allocatedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('result_note')) {
      context.handle(
        _resultNoteMeta,
        resultNote.isAcceptableOrUnknown(data['result_note']!, _resultNoteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, ordinal};
  @override
  SessionExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExercise(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
      exerciseTitleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_title_snapshot'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      allocatedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allocated_seconds'],
      ),
      resultNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_note'],
      ),
    );
  }

  @override
  SessionExercises createAlias(String alias) {
    return SessionExercises(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(session_id, ordinal)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SessionExercise extends DataClass implements Insertable<SessionExercise> {
  final String sessionId;
  final String? exerciseId;
  final String exerciseTitleSnapshot;
  final int ordinal;
  final int? allocatedSeconds;
  final String? resultNote;
  const SessionExercise({
    required this.sessionId,
    this.exerciseId,
    required this.exerciseTitleSnapshot,
    required this.ordinal,
    this.allocatedSeconds,
    this.resultNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    map['exercise_title_snapshot'] = Variable<String>(exerciseTitleSnapshot);
    map['ordinal'] = Variable<int>(ordinal);
    if (!nullToAbsent || allocatedSeconds != null) {
      map['allocated_seconds'] = Variable<int>(allocatedSeconds);
    }
    if (!nullToAbsent || resultNote != null) {
      map['result_note'] = Variable<String>(resultNote);
    }
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      sessionId: Value(sessionId),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
      exerciseTitleSnapshot: Value(exerciseTitleSnapshot),
      ordinal: Value(ordinal),
      allocatedSeconds: allocatedSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(allocatedSeconds),
      resultNote: resultNote == null && nullToAbsent
          ? const Value.absent()
          : Value(resultNote),
    );
  }

  factory SessionExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExercise(
      sessionId: serializer.fromJson<String>(json['session_id']),
      exerciseId: serializer.fromJson<String?>(json['exercise_id']),
      exerciseTitleSnapshot: serializer.fromJson<String>(
        json['exercise_title_snapshot'],
      ),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      allocatedSeconds: serializer.fromJson<int?>(json['allocated_seconds']),
      resultNote: serializer.fromJson<String?>(json['result_note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'session_id': serializer.toJson<String>(sessionId),
      'exercise_id': serializer.toJson<String?>(exerciseId),
      'exercise_title_snapshot': serializer.toJson<String>(
        exerciseTitleSnapshot,
      ),
      'ordinal': serializer.toJson<int>(ordinal),
      'allocated_seconds': serializer.toJson<int?>(allocatedSeconds),
      'result_note': serializer.toJson<String?>(resultNote),
    };
  }

  SessionExercise copyWith({
    String? sessionId,
    Value<String?> exerciseId = const Value.absent(),
    String? exerciseTitleSnapshot,
    int? ordinal,
    Value<int?> allocatedSeconds = const Value.absent(),
    Value<String?> resultNote = const Value.absent(),
  }) => SessionExercise(
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    exerciseTitleSnapshot: exerciseTitleSnapshot ?? this.exerciseTitleSnapshot,
    ordinal: ordinal ?? this.ordinal,
    allocatedSeconds: allocatedSeconds.present
        ? allocatedSeconds.value
        : this.allocatedSeconds,
    resultNote: resultNote.present ? resultNote.value : this.resultNote,
  );
  SessionExercise copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExercise(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseTitleSnapshot: data.exerciseTitleSnapshot.present
          ? data.exerciseTitleSnapshot.value
          : this.exerciseTitleSnapshot,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      allocatedSeconds: data.allocatedSeconds.present
          ? data.allocatedSeconds.value
          : this.allocatedSeconds,
      resultNote: data.resultNote.present
          ? data.resultNote.value
          : this.resultNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercise(')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseTitleSnapshot: $exerciseTitleSnapshot, ')
          ..write('ordinal: $ordinal, ')
          ..write('allocatedSeconds: $allocatedSeconds, ')
          ..write('resultNote: $resultNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    exerciseId,
    exerciseTitleSnapshot,
    ordinal,
    allocatedSeconds,
    resultNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExercise &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.exerciseTitleSnapshot == this.exerciseTitleSnapshot &&
          other.ordinal == this.ordinal &&
          other.allocatedSeconds == this.allocatedSeconds &&
          other.resultNote == this.resultNote);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExercise> {
  final Value<String> sessionId;
  final Value<String?> exerciseId;
  final Value<String> exerciseTitleSnapshot;
  final Value<int> ordinal;
  final Value<int?> allocatedSeconds;
  final Value<String?> resultNote;
  final Value<int> rowid;
  const SessionExercisesCompanion({
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseTitleSnapshot = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.allocatedSeconds = const Value.absent(),
    this.resultNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    required String sessionId,
    this.exerciseId = const Value.absent(),
    required String exerciseTitleSnapshot,
    required int ordinal,
    this.allocatedSeconds = const Value.absent(),
    this.resultNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseTitleSnapshot = Value(exerciseTitleSnapshot),
       ordinal = Value(ordinal);
  static Insertable<SessionExercise> custom({
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<String>? exerciseTitleSnapshot,
    Expression<int>? ordinal,
    Expression<int>? allocatedSeconds,
    Expression<String>? resultNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseTitleSnapshot != null)
        'exercise_title_snapshot': exerciseTitleSnapshot,
      if (ordinal != null) 'ordinal': ordinal,
      if (allocatedSeconds != null) 'allocated_seconds': allocatedSeconds,
      if (resultNote != null) 'result_note': resultNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<String>? sessionId,
    Value<String?>? exerciseId,
    Value<String>? exerciseTitleSnapshot,
    Value<int>? ordinal,
    Value<int?>? allocatedSeconds,
    Value<String?>? resultNote,
    Value<int>? rowid,
  }) {
    return SessionExercisesCompanion(
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseTitleSnapshot:
          exerciseTitleSnapshot ?? this.exerciseTitleSnapshot,
      ordinal: ordinal ?? this.ordinal,
      allocatedSeconds: allocatedSeconds ?? this.allocatedSeconds,
      resultNote: resultNote ?? this.resultNote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseTitleSnapshot.present) {
      map['exercise_title_snapshot'] = Variable<String>(
        exerciseTitleSnapshot.value,
      );
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (allocatedSeconds.present) {
      map['allocated_seconds'] = Variable<int>(allocatedSeconds.value);
    }
    if (resultNote.present) {
      map['result_note'] = Variable<String>(resultNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseTitleSnapshot: $exerciseTitleSnapshot, ')
          ..write('ordinal: $ordinal, ')
          ..write('allocatedSeconds: $allocatedSeconds, ')
          ..write('resultNote: $resultNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MetricReadings extends Table
    with TableInfo<MetricReadings, MetricReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MetricReadings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (length(id) = 36)',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sessions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _metricDefinitionIdMeta =
      const VerificationMeta('metricDefinitionId');
  late final GeneratedColumn<String> metricDefinitionId =
      GeneratedColumn<String>(
        'metric_definition_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  static const VerificationMeta _definitionVersionMeta = const VerificationMeta(
    'definitionVersion',
  );
  late final GeneratedColumn<int> definitionVersion = GeneratedColumn<int>(
    'definition_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _numericValueMeta = const VerificationMeta(
    'numericValue',
  );
  late final GeneratedColumn<double> numericValue = GeneratedColumn<double>(
    'numeric_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (abs(numeric_value) <= CAST(\'1.7976931348623157e308\' AS REAL))',
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _boolValueMeta = const VerificationMeta(
    'boolValue',
  );
  late final GeneratedColumn<bool> boolValue = GeneratedColumn<bool>(
    'bool_value',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (bool_value IN (0, 1))',
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (source_type IN (\'self_reported\', \'instrument_import\', \'derived\'))',
  );
  static const VerificationMeta _sourceNoteMeta = const VerificationMeta(
    'sourceNote',
  );
  late final GeneratedColumn<String> sourceNote = GeneratedColumn<String>(
    'source_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime>
  measuredAtUtc = GeneratedColumn<DateTime>(
    'measured_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  ).withConverter<DateTime>(MetricReadings.$convertermeasuredAtUtc);
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(MetricReadings.$convertercreatedAtUtc);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    metricDefinitionId,
    definitionVersion,
    numericValue,
    textValue,
    boolValue,
    sourceType,
    sourceNote,
    measuredAtUtc,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metric_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetricReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('metric_definition_id')) {
      context.handle(
        _metricDefinitionIdMeta,
        metricDefinitionId.isAcceptableOrUnknown(
          data['metric_definition_id']!,
          _metricDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metricDefinitionIdMeta);
    }
    if (data.containsKey('definition_version')) {
      context.handle(
        _definitionVersionMeta,
        definitionVersion.isAcceptableOrUnknown(
          data['definition_version']!,
          _definitionVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionVersionMeta);
    }
    if (data.containsKey('numeric_value')) {
      context.handle(
        _numericValueMeta,
        numericValue.isAcceptableOrUnknown(
          data['numeric_value']!,
          _numericValueMeta,
        ),
      );
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    if (data.containsKey('bool_value')) {
      context.handle(
        _boolValueMeta,
        boolValue.isAcceptableOrUnknown(data['bool_value']!, _boolValueMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_note')) {
      context.handle(
        _sourceNoteMeta,
        sourceNote.isAcceptableOrUnknown(data['source_note']!, _sourceNoteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, metricDefinitionId},
  ];
  @override
  MetricReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetricReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      metricDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_definition_id'],
      )!,
      definitionVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}definition_version'],
      )!,
      numericValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}numeric_value'],
      ),
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
      boolValue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bool_value'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_note'],
      ),
      measuredAtUtc: MetricReadings.$convertermeasuredAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}measured_at_utc'],
        )!,
      ),
      createdAtUtc: MetricReadings.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
    );
  }

  @override
  MetricReadings createAlias(String alias) {
    return MetricReadings(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertermeasuredAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcDateTimeConverter();
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(metric_definition_id, definition_version)REFERENCES metric_definitions(id, version)',
    'UNIQUE(session_id, metric_definition_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MetricReading extends DataClass implements Insertable<MetricReading> {
  final String id;
  final String sessionId;
  final String metricDefinitionId;
  final int definitionVersion;
  final double? numericValue;
  final String? textValue;
  final bool? boolValue;
  final String sourceType;
  final String? sourceNote;
  final DateTime measuredAtUtc;
  final DateTime createdAtUtc;
  const MetricReading({
    required this.id,
    required this.sessionId,
    required this.metricDefinitionId,
    required this.definitionVersion,
    this.numericValue,
    this.textValue,
    this.boolValue,
    required this.sourceType,
    this.sourceNote,
    required this.measuredAtUtc,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['metric_definition_id'] = Variable<String>(metricDefinitionId);
    map['definition_version'] = Variable<int>(definitionVersion);
    if (!nullToAbsent || numericValue != null) {
      map['numeric_value'] = Variable<double>(numericValue);
    }
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    if (!nullToAbsent || boolValue != null) {
      map['bool_value'] = Variable<bool>(boolValue);
    }
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || sourceNote != null) {
      map['source_note'] = Variable<String>(sourceNote);
    }
    {
      map['measured_at_utc'] = Variable<DateTime>(
        MetricReadings.$convertermeasuredAtUtc.toSql(measuredAtUtc),
      );
    }
    {
      map['created_at_utc'] = Variable<DateTime>(
        MetricReadings.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    return map;
  }

  MetricReadingsCompanion toCompanion(bool nullToAbsent) {
    return MetricReadingsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      metricDefinitionId: Value(metricDefinitionId),
      definitionVersion: Value(definitionVersion),
      numericValue: numericValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numericValue),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
      boolValue: boolValue == null && nullToAbsent
          ? const Value.absent()
          : Value(boolValue),
      sourceType: Value(sourceType),
      sourceNote: sourceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceNote),
      measuredAtUtc: Value(measuredAtUtc),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory MetricReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetricReading(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      metricDefinitionId: serializer.fromJson<String>(
        json['metric_definition_id'],
      ),
      definitionVersion: serializer.fromJson<int>(json['definition_version']),
      numericValue: serializer.fromJson<double?>(json['numeric_value']),
      textValue: serializer.fromJson<String?>(json['text_value']),
      boolValue: serializer.fromJson<bool?>(json['bool_value']),
      sourceType: serializer.fromJson<String>(json['source_type']),
      sourceNote: serializer.fromJson<String?>(json['source_note']),
      measuredAtUtc: serializer.fromJson<DateTime>(json['measured_at_utc']),
      createdAtUtc: serializer.fromJson<DateTime>(json['created_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'metric_definition_id': serializer.toJson<String>(metricDefinitionId),
      'definition_version': serializer.toJson<int>(definitionVersion),
      'numeric_value': serializer.toJson<double?>(numericValue),
      'text_value': serializer.toJson<String?>(textValue),
      'bool_value': serializer.toJson<bool?>(boolValue),
      'source_type': serializer.toJson<String>(sourceType),
      'source_note': serializer.toJson<String?>(sourceNote),
      'measured_at_utc': serializer.toJson<DateTime>(measuredAtUtc),
      'created_at_utc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  MetricReading copyWith({
    String? id,
    String? sessionId,
    String? metricDefinitionId,
    int? definitionVersion,
    Value<double?> numericValue = const Value.absent(),
    Value<String?> textValue = const Value.absent(),
    Value<bool?> boolValue = const Value.absent(),
    String? sourceType,
    Value<String?> sourceNote = const Value.absent(),
    DateTime? measuredAtUtc,
    DateTime? createdAtUtc,
  }) => MetricReading(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    metricDefinitionId: metricDefinitionId ?? this.metricDefinitionId,
    definitionVersion: definitionVersion ?? this.definitionVersion,
    numericValue: numericValue.present ? numericValue.value : this.numericValue,
    textValue: textValue.present ? textValue.value : this.textValue,
    boolValue: boolValue.present ? boolValue.value : this.boolValue,
    sourceType: sourceType ?? this.sourceType,
    sourceNote: sourceNote.present ? sourceNote.value : this.sourceNote,
    measuredAtUtc: measuredAtUtc ?? this.measuredAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  MetricReading copyWithCompanion(MetricReadingsCompanion data) {
    return MetricReading(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      metricDefinitionId: data.metricDefinitionId.present
          ? data.metricDefinitionId.value
          : this.metricDefinitionId,
      definitionVersion: data.definitionVersion.present
          ? data.definitionVersion.value
          : this.definitionVersion,
      numericValue: data.numericValue.present
          ? data.numericValue.value
          : this.numericValue,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      boolValue: data.boolValue.present ? data.boolValue.value : this.boolValue,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceNote: data.sourceNote.present
          ? data.sourceNote.value
          : this.sourceNote,
      measuredAtUtc: data.measuredAtUtc.present
          ? data.measuredAtUtc.value
          : this.measuredAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetricReading(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('metricDefinitionId: $metricDefinitionId, ')
          ..write('definitionVersion: $definitionVersion, ')
          ..write('numericValue: $numericValue, ')
          ..write('textValue: $textValue, ')
          ..write('boolValue: $boolValue, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceNote: $sourceNote, ')
          ..write('measuredAtUtc: $measuredAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    metricDefinitionId,
    definitionVersion,
    numericValue,
    textValue,
    boolValue,
    sourceType,
    sourceNote,
    measuredAtUtc,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetricReading &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.metricDefinitionId == this.metricDefinitionId &&
          other.definitionVersion == this.definitionVersion &&
          other.numericValue == this.numericValue &&
          other.textValue == this.textValue &&
          other.boolValue == this.boolValue &&
          other.sourceType == this.sourceType &&
          other.sourceNote == this.sourceNote &&
          other.measuredAtUtc == this.measuredAtUtc &&
          other.createdAtUtc == this.createdAtUtc);
}

class MetricReadingsCompanion extends UpdateCompanion<MetricReading> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> metricDefinitionId;
  final Value<int> definitionVersion;
  final Value<double?> numericValue;
  final Value<String?> textValue;
  final Value<bool?> boolValue;
  final Value<String> sourceType;
  final Value<String?> sourceNote;
  final Value<DateTime> measuredAtUtc;
  final Value<DateTime> createdAtUtc;
  final Value<int> rowid;
  const MetricReadingsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.metricDefinitionId = const Value.absent(),
    this.definitionVersion = const Value.absent(),
    this.numericValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.boolValue = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceNote = const Value.absent(),
    this.measuredAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetricReadingsCompanion.insert({
    required String id,
    required String sessionId,
    required String metricDefinitionId,
    required int definitionVersion,
    this.numericValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.boolValue = const Value.absent(),
    required String sourceType,
    this.sourceNote = const Value.absent(),
    required DateTime measuredAtUtc,
    required DateTime createdAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       metricDefinitionId = Value(metricDefinitionId),
       definitionVersion = Value(definitionVersion),
       sourceType = Value(sourceType),
       measuredAtUtc = Value(measuredAtUtc),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<MetricReading> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? metricDefinitionId,
    Expression<int>? definitionVersion,
    Expression<double>? numericValue,
    Expression<String>? textValue,
    Expression<bool>? boolValue,
    Expression<String>? sourceType,
    Expression<String>? sourceNote,
    Expression<DateTime>? measuredAtUtc,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (metricDefinitionId != null)
        'metric_definition_id': metricDefinitionId,
      if (definitionVersion != null) 'definition_version': definitionVersion,
      if (numericValue != null) 'numeric_value': numericValue,
      if (textValue != null) 'text_value': textValue,
      if (boolValue != null) 'bool_value': boolValue,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceNote != null) 'source_note': sourceNote,
      if (measuredAtUtc != null) 'measured_at_utc': measuredAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetricReadingsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? metricDefinitionId,
    Value<int>? definitionVersion,
    Value<double?>? numericValue,
    Value<String?>? textValue,
    Value<bool?>? boolValue,
    Value<String>? sourceType,
    Value<String?>? sourceNote,
    Value<DateTime>? measuredAtUtc,
    Value<DateTime>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return MetricReadingsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      metricDefinitionId: metricDefinitionId ?? this.metricDefinitionId,
      definitionVersion: definitionVersion ?? this.definitionVersion,
      numericValue: numericValue ?? this.numericValue,
      textValue: textValue ?? this.textValue,
      boolValue: boolValue ?? this.boolValue,
      sourceType: sourceType ?? this.sourceType,
      sourceNote: sourceNote ?? this.sourceNote,
      measuredAtUtc: measuredAtUtc ?? this.measuredAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (metricDefinitionId.present) {
      map['metric_definition_id'] = Variable<String>(metricDefinitionId.value);
    }
    if (definitionVersion.present) {
      map['definition_version'] = Variable<int>(definitionVersion.value);
    }
    if (numericValue.present) {
      map['numeric_value'] = Variable<double>(numericValue.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (boolValue.present) {
      map['bool_value'] = Variable<bool>(boolValue.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceNote.present) {
      map['source_note'] = Variable<String>(sourceNote.value);
    }
    if (measuredAtUtc.present) {
      map['measured_at_utc'] = Variable<DateTime>(
        MetricReadings.$convertermeasuredAtUtc.toSql(measuredAtUtc.value),
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        MetricReadings.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricReadingsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('metricDefinitionId: $metricDefinitionId, ')
          ..write('definitionVersion: $definitionVersion, ')
          ..write('numericValue: $numericValue, ')
          ..write('textValue: $textValue, ')
          ..write('boolValue: $boolValue, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceNote: $sourceNote, ')
          ..write('measuredAtUtc: $measuredAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MediaAssets extends Table with TableInfo<MediaAssets, MediaAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MediaAssets(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (length(id) = 36)',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sessions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'image\', \'audio\'))',
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (byte_length > 0)',
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(sha256) = 64 AND sha256 NOT GLOB \'*[^0-9a-f]*\')',
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _thumbnailRelativePathMeta =
      const VerificationMeta('thumbnailRelativePath');
  late final GeneratedColumn<String> thumbnailRelativePath =
      GeneratedColumn<String>(
        'thumbnail_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'UNIQUE',
      );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (duration_ms >= 0)',
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (width > 0)',
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (height > 0)',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isBaselineMeta = const VerificationMeta(
    'isBaseline',
  );
  late final GeneratedColumn<bool> isBaseline = GeneratedColumn<bool>(
    'is_baseline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE CHECK (is_baseline IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _captureSourceMeta = const VerificationMeta(
    'captureSource',
  );
  late final GeneratedColumn<String> captureSource = GeneratedColumn<String>(
    'capture_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (capture_source IN (\'camera\', \'microphone\', \'file_import\'))',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(MediaAssets.$convertercreatedAtUtc);
  static const VerificationMeta _storageStateMeta = const VerificationMeta(
    'storageState',
  );
  late final GeneratedColumn<String> storageState = GeneratedColumn<String>(
    'storage_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (storage_state IN (\'pending\', \'ready\', \'cleanup_pending\', \'missing\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    kind,
    mime,
    byteLength,
    sha256,
    relativePath,
    thumbnailRelativePath,
    durationMs,
    width,
    height,
    label,
    isBaseline,
    captureSource,
    createdAtUtc,
    storageState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    } else if (isInserting) {
      context.missing(_byteLengthMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('thumbnail_relative_path')) {
      context.handle(
        _thumbnailRelativePathMeta,
        thumbnailRelativePath.isAcceptableOrUnknown(
          data['thumbnail_relative_path']!,
          _thumbnailRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('is_baseline')) {
      context.handle(
        _isBaselineMeta,
        isBaseline.isAcceptableOrUnknown(data['is_baseline']!, _isBaselineMeta),
      );
    }
    if (data.containsKey('capture_source')) {
      context.handle(
        _captureSourceMeta,
        captureSource.isAcceptableOrUnknown(
          data['capture_source']!,
          _captureSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_captureSourceMeta);
    }
    if (data.containsKey('storage_state')) {
      context.handle(
        _storageStateMeta,
        storageState.isAcceptableOrUnknown(
          data['storage_state']!,
          _storageStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storageStateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      thumbnailRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_relative_path'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      isBaseline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_baseline'],
      )!,
      captureSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_source'],
      )!,
      createdAtUtc: MediaAssets.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      storageState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_state'],
      )!,
    );
  }

  @override
  MediaAssets createAlias(String alias) {
    return MediaAssets(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcDateTimeConverter();
  @override
  List<String> get customConstraints => const [
    'CHECK(relative_path GLOB \'media/*\' AND relative_path NOT LIKE \'%..%\' AND relative_path NOT LIKE \'%\\%\' AND instr(relative_path, \':\') = 0)',
    'CHECK(thumbnail_relative_path IS NULL OR(thumbnail_relative_path GLOB \'media/*\' AND thumbnail_relative_path NOT LIKE \'%..%\' AND thumbnail_relative_path NOT LIKE \'%\\%\' AND instr(thumbnail_relative_path, \':\') = 0))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MediaAsset extends DataClass implements Insertable<MediaAsset> {
  final String id;
  final String sessionId;
  final String kind;
  final String mime;
  final int byteLength;
  final String sha256;
  final String relativePath;
  final String? thumbnailRelativePath;
  final int? durationMs;
  final int? width;
  final int? height;
  final String? label;
  final bool isBaseline;
  final String captureSource;
  final DateTime createdAtUtc;
  final String storageState;
  const MediaAsset({
    required this.id,
    required this.sessionId,
    required this.kind,
    required this.mime,
    required this.byteLength,
    required this.sha256,
    required this.relativePath,
    this.thumbnailRelativePath,
    this.durationMs,
    this.width,
    this.height,
    this.label,
    required this.isBaseline,
    required this.captureSource,
    required this.createdAtUtc,
    required this.storageState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['kind'] = Variable<String>(kind);
    map['mime'] = Variable<String>(mime);
    map['byte_length'] = Variable<int>(byteLength);
    map['sha256'] = Variable<String>(sha256);
    map['relative_path'] = Variable<String>(relativePath);
    if (!nullToAbsent || thumbnailRelativePath != null) {
      map['thumbnail_relative_path'] = Variable<String>(thumbnailRelativePath);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['is_baseline'] = Variable<bool>(isBaseline);
    map['capture_source'] = Variable<String>(captureSource);
    {
      map['created_at_utc'] = Variable<DateTime>(
        MediaAssets.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    map['storage_state'] = Variable<String>(storageState);
    return map;
  }

  MediaAssetsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      kind: Value(kind),
      mime: Value(mime),
      byteLength: Value(byteLength),
      sha256: Value(sha256),
      relativePath: Value(relativePath),
      thumbnailRelativePath: thumbnailRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailRelativePath),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      isBaseline: Value(isBaseline),
      captureSource: Value(captureSource),
      createdAtUtc: Value(createdAtUtc),
      storageState: Value(storageState),
    );
  }

  factory MediaAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAsset(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      kind: serializer.fromJson<String>(json['kind']),
      mime: serializer.fromJson<String>(json['mime']),
      byteLength: serializer.fromJson<int>(json['byte_length']),
      sha256: serializer.fromJson<String>(json['sha256']),
      relativePath: serializer.fromJson<String>(json['relative_path']),
      thumbnailRelativePath: serializer.fromJson<String?>(
        json['thumbnail_relative_path'],
      ),
      durationMs: serializer.fromJson<int?>(json['duration_ms']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      label: serializer.fromJson<String?>(json['label']),
      isBaseline: serializer.fromJson<bool>(json['is_baseline']),
      captureSource: serializer.fromJson<String>(json['capture_source']),
      createdAtUtc: serializer.fromJson<DateTime>(json['created_at_utc']),
      storageState: serializer.fromJson<String>(json['storage_state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'kind': serializer.toJson<String>(kind),
      'mime': serializer.toJson<String>(mime),
      'byte_length': serializer.toJson<int>(byteLength),
      'sha256': serializer.toJson<String>(sha256),
      'relative_path': serializer.toJson<String>(relativePath),
      'thumbnail_relative_path': serializer.toJson<String?>(
        thumbnailRelativePath,
      ),
      'duration_ms': serializer.toJson<int?>(durationMs),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'label': serializer.toJson<String?>(label),
      'is_baseline': serializer.toJson<bool>(isBaseline),
      'capture_source': serializer.toJson<String>(captureSource),
      'created_at_utc': serializer.toJson<DateTime>(createdAtUtc),
      'storage_state': serializer.toJson<String>(storageState),
    };
  }

  MediaAsset copyWith({
    String? id,
    String? sessionId,
    String? kind,
    String? mime,
    int? byteLength,
    String? sha256,
    String? relativePath,
    Value<String?> thumbnailRelativePath = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<String?> label = const Value.absent(),
    bool? isBaseline,
    String? captureSource,
    DateTime? createdAtUtc,
    String? storageState,
  }) => MediaAsset(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    kind: kind ?? this.kind,
    mime: mime ?? this.mime,
    byteLength: byteLength ?? this.byteLength,
    sha256: sha256 ?? this.sha256,
    relativePath: relativePath ?? this.relativePath,
    thumbnailRelativePath: thumbnailRelativePath.present
        ? thumbnailRelativePath.value
        : this.thumbnailRelativePath,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    label: label.present ? label.value : this.label,
    isBaseline: isBaseline ?? this.isBaseline,
    captureSource: captureSource ?? this.captureSource,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    storageState: storageState ?? this.storageState,
  );
  MediaAsset copyWithCompanion(MediaAssetsCompanion data) {
    return MediaAsset(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      kind: data.kind.present ? data.kind.value : this.kind,
      mime: data.mime.present ? data.mime.value : this.mime,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      thumbnailRelativePath: data.thumbnailRelativePath.present
          ? data.thumbnailRelativePath.value
          : this.thumbnailRelativePath,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      label: data.label.present ? data.label.value : this.label,
      isBaseline: data.isBaseline.present
          ? data.isBaseline.value
          : this.isBaseline,
      captureSource: data.captureSource.present
          ? data.captureSource.value
          : this.captureSource,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      storageState: data.storageState.present
          ? data.storageState.value
          : this.storageState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAsset(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('mime: $mime, ')
          ..write('byteLength: $byteLength, ')
          ..write('sha256: $sha256, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('label: $label, ')
          ..write('isBaseline: $isBaseline, ')
          ..write('captureSource: $captureSource, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('storageState: $storageState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    kind,
    mime,
    byteLength,
    sha256,
    relativePath,
    thumbnailRelativePath,
    durationMs,
    width,
    height,
    label,
    isBaseline,
    captureSource,
    createdAtUtc,
    storageState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAsset &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.kind == this.kind &&
          other.mime == this.mime &&
          other.byteLength == this.byteLength &&
          other.sha256 == this.sha256 &&
          other.relativePath == this.relativePath &&
          other.thumbnailRelativePath == this.thumbnailRelativePath &&
          other.durationMs == this.durationMs &&
          other.width == this.width &&
          other.height == this.height &&
          other.label == this.label &&
          other.isBaseline == this.isBaseline &&
          other.captureSource == this.captureSource &&
          other.createdAtUtc == this.createdAtUtc &&
          other.storageState == this.storageState);
}

class MediaAssetsCompanion extends UpdateCompanion<MediaAsset> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> kind;
  final Value<String> mime;
  final Value<int> byteLength;
  final Value<String> sha256;
  final Value<String> relativePath;
  final Value<String?> thumbnailRelativePath;
  final Value<int?> durationMs;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String?> label;
  final Value<bool> isBaseline;
  final Value<String> captureSource;
  final Value<DateTime> createdAtUtc;
  final Value<String> storageState;
  final Value<int> rowid;
  const MediaAssetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.kind = const Value.absent(),
    this.mime = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.thumbnailRelativePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.label = const Value.absent(),
    this.isBaseline = const Value.absent(),
    this.captureSource = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.storageState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaAssetsCompanion.insert({
    required String id,
    required String sessionId,
    required String kind,
    required String mime,
    required int byteLength,
    required String sha256,
    required String relativePath,
    this.thumbnailRelativePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.label = const Value.absent(),
    this.isBaseline = const Value.absent(),
    required String captureSource,
    required DateTime createdAtUtc,
    required String storageState,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       kind = Value(kind),
       mime = Value(mime),
       byteLength = Value(byteLength),
       sha256 = Value(sha256),
       relativePath = Value(relativePath),
       captureSource = Value(captureSource),
       createdAtUtc = Value(createdAtUtc),
       storageState = Value(storageState);
  static Insertable<MediaAsset> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? kind,
    Expression<String>? mime,
    Expression<int>? byteLength,
    Expression<String>? sha256,
    Expression<String>? relativePath,
    Expression<String>? thumbnailRelativePath,
    Expression<int>? durationMs,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? label,
    Expression<bool>? isBaseline,
    Expression<String>? captureSource,
    Expression<DateTime>? createdAtUtc,
    Expression<String>? storageState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (kind != null) 'kind': kind,
      if (mime != null) 'mime': mime,
      if (byteLength != null) 'byte_length': byteLength,
      if (sha256 != null) 'sha256': sha256,
      if (relativePath != null) 'relative_path': relativePath,
      if (thumbnailRelativePath != null)
        'thumbnail_relative_path': thumbnailRelativePath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (label != null) 'label': label,
      if (isBaseline != null) 'is_baseline': isBaseline,
      if (captureSource != null) 'capture_source': captureSource,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (storageState != null) 'storage_state': storageState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? kind,
    Value<String>? mime,
    Value<int>? byteLength,
    Value<String>? sha256,
    Value<String>? relativePath,
    Value<String?>? thumbnailRelativePath,
    Value<int?>? durationMs,
    Value<int?>? width,
    Value<int?>? height,
    Value<String?>? label,
    Value<bool>? isBaseline,
    Value<String>? captureSource,
    Value<DateTime>? createdAtUtc,
    Value<String>? storageState,
    Value<int>? rowid,
  }) {
    return MediaAssetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      kind: kind ?? this.kind,
      mime: mime ?? this.mime,
      byteLength: byteLength ?? this.byteLength,
      sha256: sha256 ?? this.sha256,
      relativePath: relativePath ?? this.relativePath,
      thumbnailRelativePath:
          thumbnailRelativePath ?? this.thumbnailRelativePath,
      durationMs: durationMs ?? this.durationMs,
      width: width ?? this.width,
      height: height ?? this.height,
      label: label ?? this.label,
      isBaseline: isBaseline ?? this.isBaseline,
      captureSource: captureSource ?? this.captureSource,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      storageState: storageState ?? this.storageState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (thumbnailRelativePath.present) {
      map['thumbnail_relative_path'] = Variable<String>(
        thumbnailRelativePath.value,
      );
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isBaseline.present) {
      map['is_baseline'] = Variable<bool>(isBaseline.value);
    }
    if (captureSource.present) {
      map['capture_source'] = Variable<String>(captureSource.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        MediaAssets.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (storageState.present) {
      map['storage_state'] = Variable<String>(storageState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('mime: $mime, ')
          ..write('byteLength: $byteLength, ')
          ..write('sha256: $sha256, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('label: $label, ')
          ..write('isBaseline: $isBaseline, ')
          ..write('captureSource: $captureSource, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('storageState: $storageState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Reminders extends Table with TableInfo<Reminders, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Reminders(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (length(id) = 36)',
  );
  static const VerificationMeta _skillIdMeta = const VerificationMeta(
    'skillId',
  );
  late final GeneratedColumn<String> skillId = GeneratedColumn<String>(
    'skill_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES skills(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE CHECK (enabled IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _localTimeHHmmMeta = const VerificationMeta(
    'localTimeHHmm',
  );
  late final GeneratedColumn<String> localTimeHHmm = GeneratedColumn<String>(
    'local_time_h_hmm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(local_time_h_hmm) = 5 AND local_time_h_hmm GLOB \'[0-2][0-9]:[0-5][0-9]\' AND substr(local_time_h_hmm, 1, 2) <= \'23\')',
  );
  static const VerificationMeta _weekdaysBitsetMeta = const VerificationMeta(
    'weekdaysBitset',
  );
  late final GeneratedColumn<int> weekdaysBitset = GeneratedColumn<int>(
    'weekdays_bitset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (weekdays_bitset BETWEEN 1 AND 127)',
  );
  static const VerificationMeta _ianaZoneMeta = const VerificationMeta(
    'ianaZone',
  );
  late final GeneratedColumn<String> ianaZone = GeneratedColumn<String>(
    'iana_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(iana_zone) BETWEEN 1 AND 128)',
  );
  static const VerificationMeta _quietHoursOverrideMeta =
      const VerificationMeta('quietHoursOverride');
  late final GeneratedColumn<bool> quietHoursOverride = GeneratedColumn<bool>(
    'quiet_hours_override',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT FALSE CHECK (quiet_hours_override IN (0, 1))',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _osNotificationIdMeta = const VerificationMeta(
    'osNotificationId',
  );
  late final GeneratedColumn<int> osNotificationId = GeneratedColumn<int>(
    'os_notification_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'UNIQUE',
  );
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  lastScheduledAtUtc = GeneratedColumn<DateTime>(
    'last_scheduled_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<DateTime?>(Reminders.$converterlastScheduledAtUtcn);
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(Reminders.$converterupdatedAtUtc);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    skillId,
    enabled,
    localTimeHHmm,
    weekdaysBitset,
    ianaZone,
    quietHoursOverride,
    messageId,
    osNotificationId,
    lastScheduledAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('skill_id')) {
      context.handle(
        _skillIdMeta,
        skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('local_time_h_hmm')) {
      context.handle(
        _localTimeHHmmMeta,
        localTimeHHmm.isAcceptableOrUnknown(
          data['local_time_h_hmm']!,
          _localTimeHHmmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTimeHHmmMeta);
    }
    if (data.containsKey('weekdays_bitset')) {
      context.handle(
        _weekdaysBitsetMeta,
        weekdaysBitset.isAcceptableOrUnknown(
          data['weekdays_bitset']!,
          _weekdaysBitsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekdaysBitsetMeta);
    }
    if (data.containsKey('iana_zone')) {
      context.handle(
        _ianaZoneMeta,
        ianaZone.isAcceptableOrUnknown(data['iana_zone']!, _ianaZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_ianaZoneMeta);
    }
    if (data.containsKey('quiet_hours_override')) {
      context.handle(
        _quietHoursOverrideMeta,
        quietHoursOverride.isAcceptableOrUnknown(
          data['quiet_hours_override']!,
          _quietHoursOverrideMeta,
        ),
      );
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('os_notification_id')) {
      context.handle(
        _osNotificationIdMeta,
        osNotificationId.isAcceptableOrUnknown(
          data['os_notification_id']!,
          _osNotificationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      skillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_id'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      localTimeHHmm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_time_h_hmm'],
      )!,
      weekdaysBitset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_bitset'],
      )!,
      ianaZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iana_zone'],
      )!,
      quietHoursOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quiet_hours_override'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      osNotificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}os_notification_id'],
      ),
      lastScheduledAtUtc: Reminders.$converterlastScheduledAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_scheduled_at_utc'],
        ),
      ),
      updatedAtUtc: Reminders.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
    );
  }

  @override
  Reminders createAlias(String alias) {
    return Reminders(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterlastScheduledAtUtc =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, DateTime?> $converterlastScheduledAtUtcn =
      NullAwareTypeConverter.wrap($converterlastScheduledAtUtc);
  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcDateTimeConverter();
  @override
  bool get dontWriteConstraints => true;
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String? skillId;
  final bool enabled;
  final String localTimeHHmm;
  final int weekdaysBitset;
  final String ianaZone;
  final bool quietHoursOverride;
  final String messageId;
  final int? osNotificationId;
  final DateTime? lastScheduledAtUtc;
  final DateTime updatedAtUtc;
  const Reminder({
    required this.id,
    this.skillId,
    required this.enabled,
    required this.localTimeHHmm,
    required this.weekdaysBitset,
    required this.ianaZone,
    required this.quietHoursOverride,
    required this.messageId,
    this.osNotificationId,
    this.lastScheduledAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || skillId != null) {
      map['skill_id'] = Variable<String>(skillId);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['local_time_h_hmm'] = Variable<String>(localTimeHHmm);
    map['weekdays_bitset'] = Variable<int>(weekdaysBitset);
    map['iana_zone'] = Variable<String>(ianaZone);
    map['quiet_hours_override'] = Variable<bool>(quietHoursOverride);
    map['message_id'] = Variable<String>(messageId);
    if (!nullToAbsent || osNotificationId != null) {
      map['os_notification_id'] = Variable<int>(osNotificationId);
    }
    if (!nullToAbsent || lastScheduledAtUtc != null) {
      map['last_scheduled_at_utc'] = Variable<DateTime>(
        Reminders.$converterlastScheduledAtUtcn.toSql(lastScheduledAtUtc),
      );
    }
    {
      map['updated_at_utc'] = Variable<DateTime>(
        Reminders.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      skillId: skillId == null && nullToAbsent
          ? const Value.absent()
          : Value(skillId),
      enabled: Value(enabled),
      localTimeHHmm: Value(localTimeHHmm),
      weekdaysBitset: Value(weekdaysBitset),
      ianaZone: Value(ianaZone),
      quietHoursOverride: Value(quietHoursOverride),
      messageId: Value(messageId),
      osNotificationId: osNotificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(osNotificationId),
      lastScheduledAtUtc: lastScheduledAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScheduledAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      skillId: serializer.fromJson<String?>(json['skill_id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      localTimeHHmm: serializer.fromJson<String>(json['local_time_h_hmm']),
      weekdaysBitset: serializer.fromJson<int>(json['weekdays_bitset']),
      ianaZone: serializer.fromJson<String>(json['iana_zone']),
      quietHoursOverride: serializer.fromJson<bool>(
        json['quiet_hours_override'],
      ),
      messageId: serializer.fromJson<String>(json['message_id']),
      osNotificationId: serializer.fromJson<int?>(json['os_notification_id']),
      lastScheduledAtUtc: serializer.fromJson<DateTime?>(
        json['last_scheduled_at_utc'],
      ),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updated_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'skill_id': serializer.toJson<String?>(skillId),
      'enabled': serializer.toJson<bool>(enabled),
      'local_time_h_hmm': serializer.toJson<String>(localTimeHHmm),
      'weekdays_bitset': serializer.toJson<int>(weekdaysBitset),
      'iana_zone': serializer.toJson<String>(ianaZone),
      'quiet_hours_override': serializer.toJson<bool>(quietHoursOverride),
      'message_id': serializer.toJson<String>(messageId),
      'os_notification_id': serializer.toJson<int?>(osNotificationId),
      'last_scheduled_at_utc': serializer.toJson<DateTime?>(lastScheduledAtUtc),
      'updated_at_utc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  Reminder copyWith({
    String? id,
    Value<String?> skillId = const Value.absent(),
    bool? enabled,
    String? localTimeHHmm,
    int? weekdaysBitset,
    String? ianaZone,
    bool? quietHoursOverride,
    String? messageId,
    Value<int?> osNotificationId = const Value.absent(),
    Value<DateTime?> lastScheduledAtUtc = const Value.absent(),
    DateTime? updatedAtUtc,
  }) => Reminder(
    id: id ?? this.id,
    skillId: skillId.present ? skillId.value : this.skillId,
    enabled: enabled ?? this.enabled,
    localTimeHHmm: localTimeHHmm ?? this.localTimeHHmm,
    weekdaysBitset: weekdaysBitset ?? this.weekdaysBitset,
    ianaZone: ianaZone ?? this.ianaZone,
    quietHoursOverride: quietHoursOverride ?? this.quietHoursOverride,
    messageId: messageId ?? this.messageId,
    osNotificationId: osNotificationId.present
        ? osNotificationId.value
        : this.osNotificationId,
    lastScheduledAtUtc: lastScheduledAtUtc.present
        ? lastScheduledAtUtc.value
        : this.lastScheduledAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      localTimeHHmm: data.localTimeHHmm.present
          ? data.localTimeHHmm.value
          : this.localTimeHHmm,
      weekdaysBitset: data.weekdaysBitset.present
          ? data.weekdaysBitset.value
          : this.weekdaysBitset,
      ianaZone: data.ianaZone.present ? data.ianaZone.value : this.ianaZone,
      quietHoursOverride: data.quietHoursOverride.present
          ? data.quietHoursOverride.value
          : this.quietHoursOverride,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      osNotificationId: data.osNotificationId.present
          ? data.osNotificationId.value
          : this.osNotificationId,
      lastScheduledAtUtc: data.lastScheduledAtUtc.present
          ? data.lastScheduledAtUtc.value
          : this.lastScheduledAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('enabled: $enabled, ')
          ..write('localTimeHHmm: $localTimeHHmm, ')
          ..write('weekdaysBitset: $weekdaysBitset, ')
          ..write('ianaZone: $ianaZone, ')
          ..write('quietHoursOverride: $quietHoursOverride, ')
          ..write('messageId: $messageId, ')
          ..write('osNotificationId: $osNotificationId, ')
          ..write('lastScheduledAtUtc: $lastScheduledAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    skillId,
    enabled,
    localTimeHHmm,
    weekdaysBitset,
    ianaZone,
    quietHoursOverride,
    messageId,
    osNotificationId,
    lastScheduledAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.skillId == this.skillId &&
          other.enabled == this.enabled &&
          other.localTimeHHmm == this.localTimeHHmm &&
          other.weekdaysBitset == this.weekdaysBitset &&
          other.ianaZone == this.ianaZone &&
          other.quietHoursOverride == this.quietHoursOverride &&
          other.messageId == this.messageId &&
          other.osNotificationId == this.osNotificationId &&
          other.lastScheduledAtUtc == this.lastScheduledAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String?> skillId;
  final Value<bool> enabled;
  final Value<String> localTimeHHmm;
  final Value<int> weekdaysBitset;
  final Value<String> ianaZone;
  final Value<bool> quietHoursOverride;
  final Value<String> messageId;
  final Value<int?> osNotificationId;
  final Value<DateTime?> lastScheduledAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.skillId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.localTimeHHmm = const Value.absent(),
    this.weekdaysBitset = const Value.absent(),
    this.ianaZone = const Value.absent(),
    this.quietHoursOverride = const Value.absent(),
    this.messageId = const Value.absent(),
    this.osNotificationId = const Value.absent(),
    this.lastScheduledAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    this.skillId = const Value.absent(),
    this.enabled = const Value.absent(),
    required String localTimeHHmm,
    required int weekdaysBitset,
    required String ianaZone,
    this.quietHoursOverride = const Value.absent(),
    required String messageId,
    this.osNotificationId = const Value.absent(),
    this.lastScheduledAtUtc = const Value.absent(),
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localTimeHHmm = Value(localTimeHHmm),
       weekdaysBitset = Value(weekdaysBitset),
       ianaZone = Value(ianaZone),
       messageId = Value(messageId),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? skillId,
    Expression<bool>? enabled,
    Expression<String>? localTimeHHmm,
    Expression<int>? weekdaysBitset,
    Expression<String>? ianaZone,
    Expression<bool>? quietHoursOverride,
    Expression<String>? messageId,
    Expression<int>? osNotificationId,
    Expression<DateTime>? lastScheduledAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillId != null) 'skill_id': skillId,
      if (enabled != null) 'enabled': enabled,
      if (localTimeHHmm != null) 'local_time_h_hmm': localTimeHHmm,
      if (weekdaysBitset != null) 'weekdays_bitset': weekdaysBitset,
      if (ianaZone != null) 'iana_zone': ianaZone,
      if (quietHoursOverride != null)
        'quiet_hours_override': quietHoursOverride,
      if (messageId != null) 'message_id': messageId,
      if (osNotificationId != null) 'os_notification_id': osNotificationId,
      if (lastScheduledAtUtc != null)
        'last_scheduled_at_utc': lastScheduledAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String?>? skillId,
    Value<bool>? enabled,
    Value<String>? localTimeHHmm,
    Value<int>? weekdaysBitset,
    Value<String>? ianaZone,
    Value<bool>? quietHoursOverride,
    Value<String>? messageId,
    Value<int?>? osNotificationId,
    Value<DateTime?>? lastScheduledAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      enabled: enabled ?? this.enabled,
      localTimeHHmm: localTimeHHmm ?? this.localTimeHHmm,
      weekdaysBitset: weekdaysBitset ?? this.weekdaysBitset,
      ianaZone: ianaZone ?? this.ianaZone,
      quietHoursOverride: quietHoursOverride ?? this.quietHoursOverride,
      messageId: messageId ?? this.messageId,
      osNotificationId: osNotificationId ?? this.osNotificationId,
      lastScheduledAtUtc: lastScheduledAtUtc ?? this.lastScheduledAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<String>(skillId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (localTimeHHmm.present) {
      map['local_time_h_hmm'] = Variable<String>(localTimeHHmm.value);
    }
    if (weekdaysBitset.present) {
      map['weekdays_bitset'] = Variable<int>(weekdaysBitset.value);
    }
    if (ianaZone.present) {
      map['iana_zone'] = Variable<String>(ianaZone.value);
    }
    if (quietHoursOverride.present) {
      map['quiet_hours_override'] = Variable<bool>(quietHoursOverride.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (osNotificationId.present) {
      map['os_notification_id'] = Variable<int>(osNotificationId.value);
    }
    if (lastScheduledAtUtc.present) {
      map['last_scheduled_at_utc'] = Variable<DateTime>(
        Reminders.$converterlastScheduledAtUtcn.toSql(lastScheduledAtUtc.value),
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        Reminders.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('enabled: $enabled, ')
          ..write('localTimeHHmm: $localTimeHHmm, ')
          ..write('weekdaysBitset: $weekdaysBitset, ')
          ..write('ianaZone: $ianaZone, ')
          ..write('quietHoursOverride: $quietHoursOverride, ')
          ..write('messageId: $messageId, ')
          ..write('osNotificationId: $osNotificationId, ')
          ..write('lastScheduledAtUtc: $lastScheduledAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DataMigrations extends Table
    with TableInfo<DataMigrations, DataMigration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DataMigrations(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime>
  completedAtUtc = GeneratedColumn<DateTime>(
    'completed_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  ).withConverter<DateTime>(DataMigrations.$convertercompletedAtUtc);
  @override
  List<GeneratedColumn> get $columns => [version, completedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'data_migrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DataMigration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {version};
  @override
  DataMigration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataMigration(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      completedAtUtc: DataMigrations.$convertercompletedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}completed_at_utc'],
        )!,
      ),
    );
  }

  @override
  DataMigrations createAlias(String alias) {
    return DataMigrations(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercompletedAtUtc =
      const UtcDateTimeConverter();
  @override
  bool get dontWriteConstraints => true;
}

class DataMigration extends DataClass implements Insertable<DataMigration> {
  final int version;
  final DateTime completedAtUtc;
  const DataMigration({required this.version, required this.completedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version'] = Variable<int>(version);
    {
      map['completed_at_utc'] = Variable<DateTime>(
        DataMigrations.$convertercompletedAtUtc.toSql(completedAtUtc),
      );
    }
    return map;
  }

  DataMigrationsCompanion toCompanion(bool nullToAbsent) {
    return DataMigrationsCompanion(
      version: Value(version),
      completedAtUtc: Value(completedAtUtc),
    );
  }

  factory DataMigration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataMigration(
      version: serializer.fromJson<int>(json['version']),
      completedAtUtc: serializer.fromJson<DateTime>(json['completed_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int>(version),
      'completed_at_utc': serializer.toJson<DateTime>(completedAtUtc),
    };
  }

  DataMigration copyWith({int? version, DateTime? completedAtUtc}) =>
      DataMigration(
        version: version ?? this.version,
        completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      );
  DataMigration copyWithCompanion(DataMigrationsCompanion data) {
    return DataMigration(
      version: data.version.present ? data.version.value : this.version,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DataMigration(')
          ..write('version: $version, ')
          ..write('completedAtUtc: $completedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, completedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataMigration &&
          other.version == this.version &&
          other.completedAtUtc == this.completedAtUtc);
}

class DataMigrationsCompanion extends UpdateCompanion<DataMigration> {
  final Value<int> version;
  final Value<DateTime> completedAtUtc;
  const DataMigrationsCompanion({
    this.version = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
  });
  DataMigrationsCompanion.insert({
    this.version = const Value.absent(),
    required DateTime completedAtUtc,
  }) : completedAtUtc = Value(completedAtUtc);
  static Insertable<DataMigration> custom({
    Expression<int>? version,
    Expression<DateTime>? completedAtUtc,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
    });
  }

  DataMigrationsCompanion copyWith({
    Value<int>? version,
    Value<DateTime>? completedAtUtc,
  }) {
    return DataMigrationsCompanion(
      version: version ?? this.version,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(
        DataMigrations.$convertercompletedAtUtc.toSql(completedAtUtc.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataMigrationsCompanion(')
          ..write('version: $version, ')
          ..write('completedAtUtc: $completedAtUtc')
          ..write(')'))
        .toString();
  }
}

class ExportHistory extends Table
    with TableInfo<ExportHistory, ExportHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ExportHistory(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(ExportHistory.$convertercreatedAtUtc);
  static const VerificationMeta _archiveSchemaMeta = const VerificationMeta(
    'archiveSchema',
  );
  late final GeneratedColumn<int> archiveSchema = GeneratedColumn<int>(
    'archive_schema',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (archive_schema > 0)',
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (byte_length >= 0)',
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (outcome IN (\'success\', \'failure\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAtUtc,
    archiveSchema,
    byteLength,
    outcome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('archive_schema')) {
      context.handle(
        _archiveSchemaMeta,
        archiveSchema.isAcceptableOrUnknown(
          data['archive_schema']!,
          _archiveSchemaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_archiveSchemaMeta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAtUtc: ExportHistory.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      archiveSchema: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archive_schema'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
    );
  }

  @override
  ExportHistory createAlias(String alias) {
    return ExportHistory(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcDateTimeConverter();
  @override
  bool get dontWriteConstraints => true;
}

class ExportHistoryData extends DataClass
    implements Insertable<ExportHistoryData> {
  final String id;
  final DateTime createdAtUtc;
  final int archiveSchema;
  final int? byteLength;
  final String outcome;
  const ExportHistoryData({
    required this.id,
    required this.createdAtUtc,
    required this.archiveSchema,
    this.byteLength,
    required this.outcome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at_utc'] = Variable<DateTime>(
        ExportHistory.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    map['archive_schema'] = Variable<int>(archiveSchema);
    if (!nullToAbsent || byteLength != null) {
      map['byte_length'] = Variable<int>(byteLength);
    }
    map['outcome'] = Variable<String>(outcome);
    return map;
  }

  ExportHistoryCompanion toCompanion(bool nullToAbsent) {
    return ExportHistoryCompanion(
      id: Value(id),
      createdAtUtc: Value(createdAtUtc),
      archiveSchema: Value(archiveSchema),
      byteLength: byteLength == null && nullToAbsent
          ? const Value.absent()
          : Value(byteLength),
      outcome: Value(outcome),
    );
  }

  factory ExportHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportHistoryData(
      id: serializer.fromJson<String>(json['id']),
      createdAtUtc: serializer.fromJson<DateTime>(json['created_at_utc']),
      archiveSchema: serializer.fromJson<int>(json['archive_schema']),
      byteLength: serializer.fromJson<int?>(json['byte_length']),
      outcome: serializer.fromJson<String>(json['outcome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'created_at_utc': serializer.toJson<DateTime>(createdAtUtc),
      'archive_schema': serializer.toJson<int>(archiveSchema),
      'byte_length': serializer.toJson<int?>(byteLength),
      'outcome': serializer.toJson<String>(outcome),
    };
  }

  ExportHistoryData copyWith({
    String? id,
    DateTime? createdAtUtc,
    int? archiveSchema,
    Value<int?> byteLength = const Value.absent(),
    String? outcome,
  }) => ExportHistoryData(
    id: id ?? this.id,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    archiveSchema: archiveSchema ?? this.archiveSchema,
    byteLength: byteLength.present ? byteLength.value : this.byteLength,
    outcome: outcome ?? this.outcome,
  );
  ExportHistoryData copyWithCompanion(ExportHistoryCompanion data) {
    return ExportHistoryData(
      id: data.id.present ? data.id.value : this.id,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      archiveSchema: data.archiveSchema.present
          ? data.archiveSchema.value
          : this.archiveSchema,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportHistoryData(')
          ..write('id: $id, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('archiveSchema: $archiveSchema, ')
          ..write('byteLength: $byteLength, ')
          ..write('outcome: $outcome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAtUtc, archiveSchema, byteLength, outcome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportHistoryData &&
          other.id == this.id &&
          other.createdAtUtc == this.createdAtUtc &&
          other.archiveSchema == this.archiveSchema &&
          other.byteLength == this.byteLength &&
          other.outcome == this.outcome);
}

class ExportHistoryCompanion extends UpdateCompanion<ExportHistoryData> {
  final Value<String> id;
  final Value<DateTime> createdAtUtc;
  final Value<int> archiveSchema;
  final Value<int?> byteLength;
  final Value<String> outcome;
  final Value<int> rowid;
  const ExportHistoryCompanion({
    this.id = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.archiveSchema = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportHistoryCompanion.insert({
    required String id,
    required DateTime createdAtUtc,
    required int archiveSchema,
    this.byteLength = const Value.absent(),
    required String outcome,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAtUtc = Value(createdAtUtc),
       archiveSchema = Value(archiveSchema),
       outcome = Value(outcome);
  static Insertable<ExportHistoryData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? archiveSchema,
    Expression<int>? byteLength,
    Expression<String>? outcome,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (archiveSchema != null) 'archive_schema': archiveSchema,
      if (byteLength != null) 'byte_length': byteLength,
      if (outcome != null) 'outcome': outcome,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportHistoryCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAtUtc,
    Value<int>? archiveSchema,
    Value<int?>? byteLength,
    Value<String>? outcome,
    Value<int>? rowid,
  }) {
    return ExportHistoryCompanion(
      id: id ?? this.id,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      archiveSchema: archiveSchema ?? this.archiveSchema,
      byteLength: byteLength ?? this.byteLength,
      outcome: outcome ?? this.outcome,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        ExportHistory.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (archiveSchema.present) {
      map['archive_schema'] = Variable<int>(archiveSchema.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportHistoryCompanion(')
          ..write('id: $id, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('archiveSchema: $archiveSchema, ')
          ..write('byteLength: $byteLength, ')
          ..write('outcome: $outcome, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class FileCleanupQueue extends Table
    with TableInfo<FileCleanupQueue, FileCleanupQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FileCleanupQueue(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> queuedAtUtc =
      GeneratedColumn<DateTime>(
        'queued_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<DateTime>(FileCleanupQueue.$converterqueuedAtUtc);
  @override
  List<GeneratedColumn> get $columns => [relativePath, queuedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_cleanup_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileCleanupQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {relativePath};
  @override
  FileCleanupQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileCleanupQueueData(
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      queuedAtUtc: FileCleanupQueue.$converterqueuedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}queued_at_utc'],
        )!,
      ),
    );
  }

  @override
  FileCleanupQueue createAlias(String alias) {
    return FileCleanupQueue(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $converterqueuedAtUtc =
      const UtcDateTimeConverter();
  @override
  bool get dontWriteConstraints => true;
}

class FileCleanupQueueData extends DataClass
    implements Insertable<FileCleanupQueueData> {
  final String relativePath;
  final DateTime queuedAtUtc;
  const FileCleanupQueueData({
    required this.relativePath,
    required this.queuedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['relative_path'] = Variable<String>(relativePath);
    {
      map['queued_at_utc'] = Variable<DateTime>(
        FileCleanupQueue.$converterqueuedAtUtc.toSql(queuedAtUtc),
      );
    }
    return map;
  }

  FileCleanupQueueCompanion toCompanion(bool nullToAbsent) {
    return FileCleanupQueueCompanion(
      relativePath: Value(relativePath),
      queuedAtUtc: Value(queuedAtUtc),
    );
  }

  factory FileCleanupQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileCleanupQueueData(
      relativePath: serializer.fromJson<String>(json['relative_path']),
      queuedAtUtc: serializer.fromJson<DateTime>(json['queued_at_utc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'relative_path': serializer.toJson<String>(relativePath),
      'queued_at_utc': serializer.toJson<DateTime>(queuedAtUtc),
    };
  }

  FileCleanupQueueData copyWith({
    String? relativePath,
    DateTime? queuedAtUtc,
  }) => FileCleanupQueueData(
    relativePath: relativePath ?? this.relativePath,
    queuedAtUtc: queuedAtUtc ?? this.queuedAtUtc,
  );
  FileCleanupQueueData copyWithCompanion(FileCleanupQueueCompanion data) {
    return FileCleanupQueueData(
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      queuedAtUtc: data.queuedAtUtc.present
          ? data.queuedAtUtc.value
          : this.queuedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileCleanupQueueData(')
          ..write('relativePath: $relativePath, ')
          ..write('queuedAtUtc: $queuedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(relativePath, queuedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileCleanupQueueData &&
          other.relativePath == this.relativePath &&
          other.queuedAtUtc == this.queuedAtUtc);
}

class FileCleanupQueueCompanion extends UpdateCompanion<FileCleanupQueueData> {
  final Value<String> relativePath;
  final Value<DateTime> queuedAtUtc;
  final Value<int> rowid;
  const FileCleanupQueueCompanion({
    this.relativePath = const Value.absent(),
    this.queuedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileCleanupQueueCompanion.insert({
    required String relativePath,
    required DateTime queuedAtUtc,
    this.rowid = const Value.absent(),
  }) : relativePath = Value(relativePath),
       queuedAtUtc = Value(queuedAtUtc);
  static Insertable<FileCleanupQueueData> custom({
    Expression<String>? relativePath,
    Expression<DateTime>? queuedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (relativePath != null) 'relative_path': relativePath,
      if (queuedAtUtc != null) 'queued_at_utc': queuedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileCleanupQueueCompanion copyWith({
    Value<String>? relativePath,
    Value<DateTime>? queuedAtUtc,
    Value<int>? rowid,
  }) {
    return FileCleanupQueueCompanion(
      relativePath: relativePath ?? this.relativePath,
      queuedAtUtc: queuedAtUtc ?? this.queuedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (queuedAtUtc.present) {
      map['queued_at_utc'] = Variable<DateTime>(
        FileCleanupQueue.$converterqueuedAtUtc.toSql(queuedAtUtc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileCleanupQueueCompanion(')
          ..write('relativePath: $relativePath, ')
          ..write('queuedAtUtc: $queuedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LoopDatabase extends GeneratedDatabase {
  _$LoopDatabase(QueryExecutor e) : super(e);
  late final Settings settings = Settings(this);
  late final Skills skills = Skills(this);
  late final MetricDefinitions metricDefinitions = MetricDefinitions(this);
  late final Goals goals = Goals(this);
  late final Exercises exercises = Exercises(this);
  late final Index exercisesSkillSort = Index(
    'exercises_skill_sort',
    'CREATE INDEX exercises_skill_sort ON exercises (skill_id, sort_order)',
  );
  late final Sessions sessions = Sessions(this);
  late final Index sessionsSkillEnd = Index(
    'sessions_skill_end',
    'CREATE INDEX sessions_skill_end ON sessions (skill_id, ended_at_utc)',
  );
  late final Index oneRunningSession = Index(
    'one_running_session',
    'CREATE UNIQUE INDEX one_running_session ON sessions (status) WHERE status = \'running\'',
  );
  late final JournalDrafts journalDrafts = JournalDrafts(this);
  late final PracticeCheckpoints practiceCheckpoints = PracticeCheckpoints(
    this,
  );
  late final SessionExercises sessionExercises = SessionExercises(this);
  late final MetricReadings metricReadings = MetricReadings(this);
  late final Index readingsDefinitionMeasured = Index(
    'readings_definition_measured',
    'CREATE INDEX readings_definition_measured ON metric_readings (metric_definition_id, measured_at_utc)',
  );
  late final MediaAssets mediaAssets = MediaAssets(this);
  late final Index mediaSessionKind = Index(
    'media_session_kind',
    'CREATE INDEX media_session_kind ON media_assets (session_id, kind)',
  );
  late final Reminders reminders = Reminders(this);
  late final DataMigrations dataMigrations = DataMigrations(this);
  late final ExportHistory exportHistory = ExportHistory(this);
  late final FileCleanupQueue fileCleanupQueue = FileCleanupQueue(this);
  late final Trigger immutableMetricSemantics = Trigger(
    'CREATE TRIGGER immutable_metric_semantics BEFORE UPDATE ON metric_definitions WHEN NEW.id != OLD.id OR NEW.version != OLD.version OR NEW.skill_id != OLD.skill_id OR NEW.label != OLD.label OR NEW.unit_key != OLD.unit_key OR NEW.value_type != OLD.value_type OR NEW.direction != OLD.direction OR NEW.target_value IS NOT OLD.target_value OR NEW.scale_min IS NOT OLD.scale_min OR NEW.scale_max IS NOT OLD.scale_max OR NEW.source_hint != OLD.source_hint BEGIN SELECT RAISE (ABORT, \'metric_version_immutable\');END',
    'immutable_metric_semantics',
  );
  late final Trigger validateGoalInsert = Trigger(
    'CREATE TRIGGER validate_goal_insert BEFORE INSERT ON goals WHEN NEW.metric_definition_id IS NOT NULL AND NEW.target_value IS NOT NULL AND NOT EXISTS (SELECT 1 FROM metric_definitions AS d WHERE d.id = NEW.metric_definition_id AND d.version = NEW.definition_version AND d.skill_id = NEW.skill_id AND d.value_type = \'numeric\' AND d.unit_key = NEW.target_unit) BEGIN SELECT RAISE (ABORT, \'goal_metric_unit\');END',
    'validate_goal_insert',
  );
  late final Trigger validateGoalUpdate = Trigger(
    'CREATE TRIGGER validate_goal_update BEFORE UPDATE ON goals WHEN NEW.metric_definition_id IS NOT NULL AND NEW.target_value IS NOT NULL AND NOT EXISTS (SELECT 1 FROM metric_definitions AS d WHERE d.id = NEW.metric_definition_id AND d.version = NEW.definition_version AND d.skill_id = NEW.skill_id AND d.value_type = \'numeric\' AND d.unit_key = NEW.target_unit) BEGIN SELECT RAISE (ABORT, \'goal_metric_unit\');END',
    'validate_goal_update',
  );
  late final Trigger nextMetricVersion = Trigger(
    'CREATE TRIGGER next_metric_version BEFORE INSERT ON metric_definitions WHEN NEW.version != COALESCE((SELECT MAX(version) + 1 FROM metric_definitions WHERE id = NEW.id), 1) OR EXISTS (SELECT 1 FROM metric_definitions WHERE id = NEW.id AND skill_id != NEW.skill_id) BEGIN SELECT RAISE (ABORT, \'metric_version_sequence\');END',
    'next_metric_version',
  );
  late final Trigger legalSessionTransition = Trigger(
    'CREATE TRIGGER legal_session_transition BEFORE UPDATE ON sessions WHEN NEW.skill_id != OLD.skill_id OR NEW.id != OLD.id OR NEW.entry_mode != OLD.entry_mode OR NEW.manual_intent IS NOT OLD.manual_intent OR NEW.revision != OLD.revision + 1 OR(NEW.status != OLD.status AND NOT((OLD.status = \'draft\' AND NEW.status IN (\'running\', \'completed\', \'discarded\'))OR(OLD.status = \'running\' AND NEW.status IN (\'paused\', \'completed\', \'discarded\'))OR(OLD.status = \'paused\' AND NEW.status IN (\'running\', \'completed\', \'discarded\'))))OR NEW.active_seconds < COALESCE((SELECT SUM(allocated_seconds) FROM session_exercises WHERE session_id = OLD.id), 0) BEGIN SELECT RAISE (ABORT, \'session_conflict\');END',
    'legal_session_transition',
  );
  late final Trigger validateExerciseInsert = Trigger(
    'CREATE TRIGGER validate_exercise_insert BEFORE INSERT ON session_exercises WHEN(NEW.exercise_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM exercises AS e JOIN sessions AS s ON s.id = NEW.session_id WHERE e.id = NEW.exercise_id AND e.skill_id = s.skill_id))OR COALESCE(NEW.allocated_seconds, 0) + COALESCE((SELECT SUM(allocated_seconds) FROM session_exercises WHERE session_id = NEW.session_id), 0) > (SELECT active_seconds FROM sessions WHERE id = NEW.session_id) BEGIN SELECT RAISE (ABORT, \'exercise_allocation\');END',
    'validate_exercise_insert',
  );
  late final Trigger validateExerciseUpdate = Trigger(
    'CREATE TRIGGER validate_exercise_update BEFORE UPDATE ON session_exercises WHEN(NEW.exercise_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM exercises AS e JOIN sessions AS s ON s.id = NEW.session_id WHERE e.id = NEW.exercise_id AND e.skill_id = s.skill_id))OR COALESCE(NEW.allocated_seconds, 0) + COALESCE((SELECT SUM(allocated_seconds) FROM session_exercises WHERE session_id = NEW.session_id AND NOT(session_id = OLD.session_id AND ordinal = OLD.ordinal)), 0) > (SELECT active_seconds FROM sessions WHERE id = NEW.session_id) BEGIN SELECT RAISE (ABORT, \'exercise_allocation\');END',
    'validate_exercise_update',
  );
  late final Trigger validateReadingInsert = Trigger(
    'CREATE TRIGGER validate_reading_insert BEFORE INSERT ON metric_readings WHEN NOT EXISTS (SELECT 1 FROM metric_definitions AS d JOIN sessions AS s ON s.id = NEW.session_id WHERE d.id = NEW.metric_definition_id AND d.version = NEW.definition_version AND d.skill_id = s.skill_id AND((d.value_type = \'numeric\' AND NEW.numeric_value IS NOT NULL AND NEW.text_value IS NULL AND NEW.bool_value IS NULL AND(d.scale_min IS NULL OR NEW.numeric_value >= d.scale_min)AND(d.scale_max IS NULL OR NEW.numeric_value <= d.scale_max))OR(d.value_type = \'text\' AND NEW.text_value IS NOT NULL AND NEW.numeric_value IS NULL AND NEW.bool_value IS NULL)OR(d.value_type = \'checklist\' AND NEW.bool_value IS NOT NULL AND NEW.text_value IS NULL AND NEW.numeric_value IS NULL))) BEGIN SELECT RAISE (ABORT, \'reading_type_range_skill\');END',
    'validate_reading_insert',
  );
  late final Trigger validateReadingUpdate = Trigger(
    'CREATE TRIGGER validate_reading_update BEFORE UPDATE ON metric_readings WHEN NOT EXISTS (SELECT 1 FROM metric_definitions AS d JOIN sessions AS s ON s.id = NEW.session_id WHERE d.id = NEW.metric_definition_id AND d.version = NEW.definition_version AND d.skill_id = s.skill_id AND((d.value_type = \'numeric\' AND NEW.numeric_value IS NOT NULL AND NEW.text_value IS NULL AND NEW.bool_value IS NULL AND(d.scale_min IS NULL OR NEW.numeric_value >= d.scale_min)AND(d.scale_max IS NULL OR NEW.numeric_value <= d.scale_max))OR(d.value_type = \'text\' AND NEW.text_value IS NOT NULL AND NEW.numeric_value IS NULL AND NEW.bool_value IS NULL)OR(d.value_type = \'checklist\' AND NEW.bool_value IS NOT NULL AND NEW.text_value IS NULL AND NEW.numeric_value IS NULL))) BEGIN SELECT RAISE (ABORT, \'reading_type_range_skill\');END',
    'validate_reading_update',
  );
  late final Trigger cleanupDeletedMedia = Trigger(
    'CREATE TRIGGER cleanup_deleted_media AFTER DELETE ON media_assets BEGIN INSERT OR IGNORE INTO file_cleanup_queue (relative_path, queued_at_utc) VALUES (OLD.relative_path, unixepoch());INSERT OR IGNORE INTO file_cleanup_queue (relative_path, queued_at_utc) SELECT OLD.thumbnail_relative_path, unixepoch() WHERE OLD.thumbnail_relative_path IS NOT NULL;END',
    'cleanup_deleted_media',
  );
  late final Trigger immutableMediaIdentity = Trigger(
    'CREATE TRIGGER immutable_media_identity BEFORE UPDATE ON media_assets WHEN NEW.id != OLD.id OR NEW.session_id != OLD.session_id OR NEW.relative_path != OLD.relative_path OR NEW.thumbnail_relative_path IS NOT OLD.thumbnail_relative_path OR NEW.sha256 != OLD.sha256 OR NEW.byte_length != OLD.byte_length BEGIN SELECT RAISE (ABORT, \'media_identity_immutable\');END',
    'immutable_media_identity',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    skills,
    metricDefinitions,
    goals,
    exercises,
    exercisesSkillSort,
    sessions,
    sessionsSkillEnd,
    oneRunningSession,
    journalDrafts,
    practiceCheckpoints,
    sessionExercises,
    metricReadings,
    readingsDefinitionMeasured,
    mediaAssets,
    mediaSessionKind,
    reminders,
    dataMigrations,
    exportHistory,
    fileCleanupQueue,
    immutableMetricSemantics,
    validateGoalInsert,
    validateGoalUpdate,
    nextMetricVersion,
    legalSessionTransition,
    validateExerciseInsert,
    validateExerciseUpdate,
    validateReadingInsert,
    validateReadingUpdate,
    cleanupDeletedMedia,
    immutableMediaIdentity,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'skills',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('metric_definitions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'skills',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('goals', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'skills',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'skills',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('journal_drafts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('practice_checkpoints', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercises', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('metric_readings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_assets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'skills',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metric_definitions',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metric_definitions',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_exercises',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_exercises',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metric_readings',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'metric_readings',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('file_cleanup_queue', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_assets',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
  ]);
}
