// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CatsTable extends Cats with TableInfo<$CatsTable, CatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _neuteredMeta = const VerificationMeta(
    'neutered',
  );
  @override
  late final GeneratedColumn<bool> neutered = GeneratedColumn<bool>(
    'neutered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("neutered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('maintain'),
  );
  static const VerificationMeta _coatColorMeta = const VerificationMeta(
    'coatColor',
  );
  @override
  late final GeneratedColumn<String> coatColor = GeneratedColumn<String>(
    'coat_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSampleMeta = const VerificationMeta(
    'isSample',
  );
  @override
  late final GeneratedColumn<bool> isSample = GeneratedColumn<bool>(
    'is_sample',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sample" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recognitionSourceMeta = const VerificationMeta(
    'recognitionSource',
  );
  @override
  late final GeneratedColumn<String> recognitionSource =
      GeneratedColumn<String>(
        'recognition_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recognitionConfidenceMeta =
      const VerificationMeta('recognitionConfidence');
  @override
  late final GeneratedColumn<double> recognitionConfidence =
      GeneratedColumn<double>(
        'recognition_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recognitionDetailMeta = const VerificationMeta(
    'recognitionDetail',
  );
  @override
  late final GeneratedColumn<String> recognitionDetail =
      GeneratedColumn<String>(
        'recognition_detail',
        aliasedName,
        true,
        type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sex,
    birthday,
    neutered,
    goal,
    coatColor,
    breed,
    avatarPath,
    notes,
    isSample,
    recognitionSource,
    recognitionConfidence,
    recognitionDetail,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cats';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('neutered')) {
      context.handle(
        _neuteredMeta,
        neutered.isAcceptableOrUnknown(data['neutered']!, _neuteredMeta),
      );
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('coat_color')) {
      context.handle(
        _coatColorMeta,
        coatColor.isAcceptableOrUnknown(data['coat_color']!, _coatColorMeta),
      );
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_sample')) {
      context.handle(
        _isSampleMeta,
        isSample.isAcceptableOrUnknown(data['is_sample']!, _isSampleMeta),
      );
    }
    if (data.containsKey('recognition_source')) {
      context.handle(
        _recognitionSourceMeta,
        recognitionSource.isAcceptableOrUnknown(
          data['recognition_source']!,
          _recognitionSourceMeta,
        ),
      );
    }
    if (data.containsKey('recognition_confidence')) {
      context.handle(
        _recognitionConfidenceMeta,
        recognitionConfidence.isAcceptableOrUnknown(
          data['recognition_confidence']!,
          _recognitionConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('recognition_detail')) {
      context.handle(
        _recognitionDetailMeta,
        recognitionDetail.isAcceptableOrUnknown(
          data['recognition_detail']!,
          _recognitionDetailMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birthday'],
      ),
      neutered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}neutered'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      coatColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coat_color'],
      ),
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isSample: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sample'],
      )!,
      recognitionSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recognition_source'],
      ),
      recognitionConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recognition_confidence'],
      ),
      recognitionDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recognition_detail'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CatsTable createAlias(String alias) {
    return $CatsTable(attachedDatabase, alias);
  }
}

class CatRow extends DataClass implements Insertable<CatRow> {
  final int id;
  final String name;
  final String sex;
  final DateTime? birthday;
  final bool neutered;
  final String goal;
  final String? coatColor;
  final String? breed;
  final String? avatarPath;
  final String notes;
  final bool isSample;
  final String? recognitionSource;
  final double? recognitionConfidence;
  final String? recognitionDetail;
  final DateTime createdAt;
  const CatRow({
    required this.id,
    required this.name,
    required this.sex,
    this.birthday,
    required this.neutered,
    required this.goal,
    this.coatColor,
    this.breed,
    this.avatarPath,
    required this.notes,
    required this.isSample,
    this.recognitionSource,
    this.recognitionConfidence,
    this.recognitionDetail,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sex'] = Variable<String>(sex);
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<DateTime>(birthday);
    }
    map['neutered'] = Variable<bool>(neutered);
    map['goal'] = Variable<String>(goal);
    if (!nullToAbsent || coatColor != null) {
      map['coat_color'] = Variable<String>(coatColor);
    }
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['notes'] = Variable<String>(notes);
    map['is_sample'] = Variable<bool>(isSample);
    if (!nullToAbsent || recognitionSource != null) {
      map['recognition_source'] = Variable<String>(recognitionSource);
    }
    if (!nullToAbsent || recognitionConfidence != null) {
      map['recognition_confidence'] = Variable<double>(recognitionConfidence);
    }
    if (!nullToAbsent || recognitionDetail != null) {
      map['recognition_detail'] = Variable<String>(recognitionDetail);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CatsCompanion toCompanion(bool nullToAbsent) {
    return CatsCompanion(
      id: Value(id),
      name: Value(name),
      sex: Value(sex),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      neutered: Value(neutered),
      goal: Value(goal),
      coatColor: coatColor == null && nullToAbsent
          ? const Value.absent()
          : Value(coatColor),
      breed: breed == null && nullToAbsent
          ? const Value.absent()
          : Value(breed),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      notes: Value(notes),
      isSample: Value(isSample),
      recognitionSource: recognitionSource == null && nullToAbsent
          ? const Value.absent()
          : Value(recognitionSource),
      recognitionConfidence: recognitionConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(recognitionConfidence),
      recognitionDetail: recognitionDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(recognitionDetail),
      createdAt: Value(createdAt),
    );
  }

  factory CatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sex: serializer.fromJson<String>(json['sex']),
      birthday: serializer.fromJson<DateTime?>(json['birthday']),
      neutered: serializer.fromJson<bool>(json['neutered']),
      goal: serializer.fromJson<String>(json['goal']),
      coatColor: serializer.fromJson<String?>(json['coatColor']),
      breed: serializer.fromJson<String?>(json['breed']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      notes: serializer.fromJson<String>(json['notes']),
      isSample: serializer.fromJson<bool>(json['isSample']),
      recognitionSource: serializer.fromJson<String?>(
        json['recognitionSource'],
      ),
      recognitionConfidence: serializer.fromJson<double?>(
        json['recognitionConfidence'],
      ),
      recognitionDetail: serializer.fromJson<String?>(
        json['recognitionDetail'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sex': serializer.toJson<String>(sex),
      'birthday': serializer.toJson<DateTime?>(birthday),
      'neutered': serializer.toJson<bool>(neutered),
      'goal': serializer.toJson<String>(goal),
      'coatColor': serializer.toJson<String?>(coatColor),
      'breed': serializer.toJson<String?>(breed),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'notes': serializer.toJson<String>(notes),
      'isSample': serializer.toJson<bool>(isSample),
      'recognitionSource': serializer.toJson<String?>(recognitionSource),
      'recognitionConfidence': serializer.toJson<double?>(
        recognitionConfidence,
      ),
      'recognitionDetail': serializer.toJson<String?>(recognitionDetail),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CatRow copyWith({
    int? id,
    String? name,
    String? sex,
    Value<DateTime?> birthday = const Value.absent(),
    bool? neutered,
    String? goal,
    Value<String?> coatColor = const Value.absent(),
    Value<String?> breed = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    String? notes,
    bool? isSample,
    Value<String?> recognitionSource = const Value.absent(),
    Value<double?> recognitionConfidence = const Value.absent(),
    Value<String?> recognitionDetail = const Value.absent(),
    DateTime? createdAt,
  }) => CatRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sex: sex ?? this.sex,
    birthday: birthday.present ? birthday.value : this.birthday,
    neutered: neutered ?? this.neutered,
    goal: goal ?? this.goal,
    coatColor: coatColor.present ? coatColor.value : this.coatColor,
    breed: breed.present ? breed.value : this.breed,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    notes: notes ?? this.notes,
    isSample: isSample ?? this.isSample,
    recognitionSource: recognitionSource.present
        ? recognitionSource.value
        : this.recognitionSource,
    recognitionConfidence: recognitionConfidence.present
        ? recognitionConfidence.value
        : this.recognitionConfidence,
    recognitionDetail: recognitionDetail.present
        ? recognitionDetail.value
        : this.recognitionDetail,
    createdAt: createdAt ?? this.createdAt,
  );
  CatRow copyWithCompanion(CatsCompanion data) {
    return CatRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      neutered: data.neutered.present ? data.neutered.value : this.neutered,
      goal: data.goal.present ? data.goal.value : this.goal,
      coatColor: data.coatColor.present ? data.coatColor.value : this.coatColor,
      breed: data.breed.present ? data.breed.value : this.breed,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      isSample: data.isSample.present ? data.isSample.value : this.isSample,
      recognitionSource: data.recognitionSource.present
          ? data.recognitionSource.value
          : this.recognitionSource,
      recognitionConfidence: data.recognitionConfidence.present
          ? data.recognitionConfidence.value
          : this.recognitionConfidence,
      recognitionDetail: data.recognitionDetail.present
          ? data.recognitionDetail.value
          : this.recognitionDetail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthday: $birthday, ')
          ..write('neutered: $neutered, ')
          ..write('goal: $goal, ')
          ..write('coatColor: $coatColor, ')
          ..write('breed: $breed, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('notes: $notes, ')
          ..write('isSample: $isSample, ')
          ..write('recognitionSource: $recognitionSource, ')
          ..write('recognitionConfidence: $recognitionConfidence, ')
          ..write('recognitionDetail: $recognitionDetail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sex,
    birthday,
    neutered,
    goal,
    coatColor,
    breed,
    avatarPath,
    notes,
    isSample,
    recognitionSource,
    recognitionConfidence,
    recognitionDetail,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.birthday == this.birthday &&
          other.neutered == this.neutered &&
          other.goal == this.goal &&
          other.coatColor == this.coatColor &&
          other.breed == this.breed &&
          other.avatarPath == this.avatarPath &&
          other.notes == this.notes &&
          other.isSample == this.isSample &&
          other.recognitionSource == this.recognitionSource &&
          other.recognitionConfidence == this.recognitionConfidence &&
          other.recognitionDetail == this.recognitionDetail &&
          other.createdAt == this.createdAt);
}

class CatsCompanion extends UpdateCompanion<CatRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> sex;
  final Value<DateTime?> birthday;
  final Value<bool> neutered;
  final Value<String> goal;
  final Value<String?> coatColor;
  final Value<String?> breed;
  final Value<String?> avatarPath;
  final Value<String> notes;
  final Value<bool> isSample;
  final Value<String?> recognitionSource;
  final Value<double?> recognitionConfidence;
  final Value<String?> recognitionDetail;
  final Value<DateTime> createdAt;
  const CatsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthday = const Value.absent(),
    this.neutered = const Value.absent(),
    this.goal = const Value.absent(),
    this.coatColor = const Value.absent(),
    this.breed = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSample = const Value.absent(),
    this.recognitionSource = const Value.absent(),
    this.recognitionConfidence = const Value.absent(),
    this.recognitionDetail = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CatsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String sex,
    this.birthday = const Value.absent(),
    this.neutered = const Value.absent(),
    this.goal = const Value.absent(),
    this.coatColor = const Value.absent(),
    this.breed = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSample = const Value.absent(),
    this.recognitionSource = const Value.absent(),
    this.recognitionConfidence = const Value.absent(),
    this.recognitionDetail = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       sex = Value(sex),
       createdAt = Value(createdAt);
  static Insertable<CatRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? sex,
    Expression<DateTime>? birthday,
    Expression<bool>? neutered,
    Expression<String>? goal,
    Expression<String>? coatColor,
    Expression<String>? breed,
    Expression<String>? avatarPath,
    Expression<String>? notes,
    Expression<bool>? isSample,
    Expression<String>? recognitionSource,
    Expression<double>? recognitionConfidence,
    Expression<String>? recognitionDetail,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (birthday != null) 'birthday': birthday,
      if (neutered != null) 'neutered': neutered,
      if (goal != null) 'goal': goal,
      if (coatColor != null) 'coat_color': coatColor,
      if (breed != null) 'breed': breed,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (notes != null) 'notes': notes,
      if (isSample != null) 'is_sample': isSample,
      if (recognitionSource != null) 'recognition_source': recognitionSource,
      if (recognitionConfidence != null)
        'recognition_confidence': recognitionConfidence,
      if (recognitionDetail != null) 'recognition_detail': recognitionDetail,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CatsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? sex,
    Value<DateTime?>? birthday,
    Value<bool>? neutered,
    Value<String>? goal,
    Value<String?>? coatColor,
    Value<String?>? breed,
    Value<String?>? avatarPath,
    Value<String>? notes,
    Value<bool>? isSample,
    Value<String?>? recognitionSource,
    Value<double?>? recognitionConfidence,
    Value<String?>? recognitionDetail,
    Value<DateTime>? createdAt,
  }) {
    return CatsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      birthday: birthday ?? this.birthday,
      neutered: neutered ?? this.neutered,
      goal: goal ?? this.goal,
      coatColor: coatColor ?? this.coatColor,
      breed: breed ?? this.breed,
      avatarPath: avatarPath ?? this.avatarPath,
      notes: notes ?? this.notes,
      isSample: isSample ?? this.isSample,
      recognitionSource: recognitionSource ?? this.recognitionSource,
      recognitionConfidence:
          recognitionConfidence ?? this.recognitionConfidence,
      recognitionDetail: recognitionDetail ?? this.recognitionDetail,
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
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (neutered.present) {
      map['neutered'] = Variable<bool>(neutered.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (coatColor.present) {
      map['coat_color'] = Variable<String>(coatColor.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isSample.present) {
      map['is_sample'] = Variable<bool>(isSample.value);
    }
    if (recognitionSource.present) {
      map['recognition_source'] = Variable<String>(recognitionSource.value);
    }
    if (recognitionConfidence.present) {
      map['recognition_confidence'] = Variable<double>(
        recognitionConfidence.value,
      );
    }
    if (recognitionDetail.present) {
      map['recognition_detail'] = Variable<String>(recognitionDetail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthday: $birthday, ')
          ..write('neutered: $neutered, ')
          ..write('goal: $goal, ')
          ..write('coatColor: $coatColor, ')
          ..write('breed: $breed, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('notes: $notes, ')
          ..write('isSample: $isSample, ')
          ..write('recognitionSource: $recognitionSource, ')
          ..write('recognitionConfidence: $recognitionConfidence, ')
          ..write('recognitionDetail: $recognitionDetail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CatPhotosTable extends CatPhotos
    with TableInfo<$CatPhotosTable, CatPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatPhotosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    path,
    takenAt,
    weightKg,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cat_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatPhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatPhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $CatPhotosTable createAlias(String alias) {
    return $CatPhotosTable(attachedDatabase, alias);
  }
}

class CatPhotoRow extends DataClass implements Insertable<CatPhotoRow> {
  final int id;
  final int catId;
  final String path;
  final DateTime takenAt;
  final double? weightKg;
  final String note;
  const CatPhotoRow({
    required this.id,
    required this.catId,
    required this.path,
    required this.takenAt,
    this.weightKg,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['path'] = Variable<String>(path);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  CatPhotosCompanion toCompanion(bool nullToAbsent) {
    return CatPhotosCompanion(
      id: Value(id),
      catId: Value(catId),
      path: Value(path),
      takenAt: Value(takenAt),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      note: Value(note),
    );
  }

  factory CatPhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatPhotoRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      path: serializer.fromJson<String>(json['path']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'path': serializer.toJson<String>(path),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'weightKg': serializer.toJson<double?>(weightKg),
      'note': serializer.toJson<String>(note),
    };
  }

  CatPhotoRow copyWith({
    int? id,
    int? catId,
    String? path,
    DateTime? takenAt,
    Value<double?> weightKg = const Value.absent(),
    String? note,
  }) => CatPhotoRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    path: path ?? this.path,
    takenAt: takenAt ?? this.takenAt,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    note: note ?? this.note,
  );
  CatPhotoRow copyWithCompanion(CatPhotosCompanion data) {
    return CatPhotoRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      path: data.path.present ? data.path.value : this.path,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatPhotoRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('path: $path, ')
          ..write('takenAt: $takenAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, catId, path, takenAt, weightKg, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatPhotoRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.path == this.path &&
          other.takenAt == this.takenAt &&
          other.weightKg == this.weightKg &&
          other.note == this.note);
}

class CatPhotosCompanion extends UpdateCompanion<CatPhotoRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<String> path;
  final Value<DateTime> takenAt;
  final Value<double?> weightKg;
  final Value<String> note;
  const CatPhotosCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.path = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.note = const Value.absent(),
  });
  CatPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required String path,
    required DateTime takenAt,
    this.weightKg = const Value.absent(),
    this.note = const Value.absent(),
  }) : catId = Value(catId),
       path = Value(path),
       takenAt = Value(takenAt);
  static Insertable<CatPhotoRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? path,
    Expression<DateTime>? takenAt,
    Expression<double>? weightKg,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (path != null) 'path': path,
      if (takenAt != null) 'taken_at': takenAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (note != null) 'note': note,
    });
  }

  CatPhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<String>? path,
    Value<DateTime>? takenAt,
    Value<double?>? weightKg,
    Value<String>? note,
  }) {
    return CatPhotosCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      path: path ?? this.path,
      takenAt: takenAt ?? this.takenAt,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatPhotosCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('path: $path, ')
          ..write('takenAt: $takenAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $VaccinesTable extends Vaccines
    with TableInfo<$VaccinesTable, VaccineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _givenOnMeta = const VerificationMeta(
    'givenOn',
  );
  @override
  late final GeneratedColumn<DateTime> givenOn = GeneratedColumn<DateTime>(
    'given_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDueMeta = const VerificationMeta(
    'nextDue',
  );
  @override
  late final GeneratedColumn<DateTime> nextDue = GeneratedColumn<DateTime>(
    'next_due',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicMeta = const VerificationMeta('clinic');
  @override
  late final GeneratedColumn<String> clinic = GeneratedColumn<String>(
    'clinic',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    name,
    givenOn,
    nextDue,
    clinic,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccines';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaccineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('given_on')) {
      context.handle(
        _givenOnMeta,
        givenOn.isAcceptableOrUnknown(data['given_on']!, _givenOnMeta),
      );
    } else if (isInserting) {
      context.missing(_givenOnMeta);
    }
    if (data.containsKey('next_due')) {
      context.handle(
        _nextDueMeta,
        nextDue.isAcceptableOrUnknown(data['next_due']!, _nextDueMeta),
      );
    }
    if (data.containsKey('clinic')) {
      context.handle(
        _clinicMeta,
        clinic.isAcceptableOrUnknown(data['clinic']!, _clinicMeta),
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
  VaccineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaccineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      givenOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}given_on'],
      )!,
      nextDue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due'],
      ),
      clinic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $VaccinesTable createAlias(String alias) {
    return $VaccinesTable(attachedDatabase, alias);
  }
}

class VaccineRow extends DataClass implements Insertable<VaccineRow> {
  final int id;
  final int catId;
  final String name;
  final DateTime givenOn;
  final DateTime? nextDue;
  final String? clinic;
  final String notes;
  const VaccineRow({
    required this.id,
    required this.catId,
    required this.name,
    required this.givenOn,
    this.nextDue,
    this.clinic,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['name'] = Variable<String>(name);
    map['given_on'] = Variable<DateTime>(givenOn);
    if (!nullToAbsent || nextDue != null) {
      map['next_due'] = Variable<DateTime>(nextDue);
    }
    if (!nullToAbsent || clinic != null) {
      map['clinic'] = Variable<String>(clinic);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  VaccinesCompanion toCompanion(bool nullToAbsent) {
    return VaccinesCompanion(
      id: Value(id),
      catId: Value(catId),
      name: Value(name),
      givenOn: Value(givenOn),
      nextDue: nextDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDue),
      clinic: clinic == null && nullToAbsent
          ? const Value.absent()
          : Value(clinic),
      notes: Value(notes),
    );
  }

  factory VaccineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaccineRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      name: serializer.fromJson<String>(json['name']),
      givenOn: serializer.fromJson<DateTime>(json['givenOn']),
      nextDue: serializer.fromJson<DateTime?>(json['nextDue']),
      clinic: serializer.fromJson<String?>(json['clinic']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'name': serializer.toJson<String>(name),
      'givenOn': serializer.toJson<DateTime>(givenOn),
      'nextDue': serializer.toJson<DateTime?>(nextDue),
      'clinic': serializer.toJson<String?>(clinic),
      'notes': serializer.toJson<String>(notes),
    };
  }

  VaccineRow copyWith({
    int? id,
    int? catId,
    String? name,
    DateTime? givenOn,
    Value<DateTime?> nextDue = const Value.absent(),
    Value<String?> clinic = const Value.absent(),
    String? notes,
  }) => VaccineRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    name: name ?? this.name,
    givenOn: givenOn ?? this.givenOn,
    nextDue: nextDue.present ? nextDue.value : this.nextDue,
    clinic: clinic.present ? clinic.value : this.clinic,
    notes: notes ?? this.notes,
  );
  VaccineRow copyWithCompanion(VaccinesCompanion data) {
    return VaccineRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      name: data.name.present ? data.name.value : this.name,
      givenOn: data.givenOn.present ? data.givenOn.value : this.givenOn,
      nextDue: data.nextDue.present ? data.nextDue.value : this.nextDue,
      clinic: data.clinic.present ? data.clinic.value : this.clinic,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaccineRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('name: $name, ')
          ..write('givenOn: $givenOn, ')
          ..write('nextDue: $nextDue, ')
          ..write('clinic: $clinic, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catId, name, givenOn, nextDue, clinic, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaccineRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.name == this.name &&
          other.givenOn == this.givenOn &&
          other.nextDue == this.nextDue &&
          other.clinic == this.clinic &&
          other.notes == this.notes);
}

class VaccinesCompanion extends UpdateCompanion<VaccineRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<String> name;
  final Value<DateTime> givenOn;
  final Value<DateTime?> nextDue;
  final Value<String?> clinic;
  final Value<String> notes;
  const VaccinesCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.name = const Value.absent(),
    this.givenOn = const Value.absent(),
    this.nextDue = const Value.absent(),
    this.clinic = const Value.absent(),
    this.notes = const Value.absent(),
  });
  VaccinesCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required String name,
    required DateTime givenOn,
    this.nextDue = const Value.absent(),
    this.clinic = const Value.absent(),
    this.notes = const Value.absent(),
  }) : catId = Value(catId),
       name = Value(name),
       givenOn = Value(givenOn);
  static Insertable<VaccineRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? name,
    Expression<DateTime>? givenOn,
    Expression<DateTime>? nextDue,
    Expression<String>? clinic,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (name != null) 'name': name,
      if (givenOn != null) 'given_on': givenOn,
      if (nextDue != null) 'next_due': nextDue,
      if (clinic != null) 'clinic': clinic,
      if (notes != null) 'notes': notes,
    });
  }

  VaccinesCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<String>? name,
    Value<DateTime>? givenOn,
    Value<DateTime?>? nextDue,
    Value<String?>? clinic,
    Value<String>? notes,
  }) {
    return VaccinesCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      name: name ?? this.name,
      givenOn: givenOn ?? this.givenOn,
      nextDue: nextDue ?? this.nextDue,
      clinic: clinic ?? this.clinic,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (givenOn.present) {
      map['given_on'] = Variable<DateTime>(givenOn.value);
    }
    if (nextDue.present) {
      map['next_due'] = Variable<DateTime>(nextDue.value);
    }
    if (clinic.present) {
      map['clinic'] = Variable<String>(clinic.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinesCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('name: $name, ')
          ..write('givenOn: $givenOn, ')
          ..write('nextDue: $nextDue, ')
          ..write('clinic: $clinic, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $DewormingsTable extends Dewormings
    with TableInfo<$DewormingsTable, DewormRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DewormingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productMeta = const VerificationMeta(
    'product',
  );
  @override
  late final GeneratedColumn<String> product = GeneratedColumn<String>(
    'product',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _givenOnMeta = const VerificationMeta(
    'givenOn',
  );
  @override
  late final GeneratedColumn<DateTime> givenOn = GeneratedColumn<DateTime>(
    'given_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDueMeta = const VerificationMeta(
    'nextDue',
  );
  @override
  late final GeneratedColumn<DateTime> nextDue = GeneratedColumn<DateTime>(
    'next_due',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    kind,
    product,
    givenOn,
    nextDue,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dewormings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DewormRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('product')) {
      context.handle(
        _productMeta,
        product.isAcceptableOrUnknown(data['product']!, _productMeta),
      );
    } else if (isInserting) {
      context.missing(_productMeta);
    }
    if (data.containsKey('given_on')) {
      context.handle(
        _givenOnMeta,
        givenOn.isAcceptableOrUnknown(data['given_on']!, _givenOnMeta),
      );
    } else if (isInserting) {
      context.missing(_givenOnMeta);
    }
    if (data.containsKey('next_due')) {
      context.handle(
        _nextDueMeta,
        nextDue.isAcceptableOrUnknown(data['next_due']!, _nextDueMeta),
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
  DewormRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DewormRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      product: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product'],
      )!,
      givenOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}given_on'],
      )!,
      nextDue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $DewormingsTable createAlias(String alias) {
    return $DewormingsTable(attachedDatabase, alias);
  }
}

class DewormRow extends DataClass implements Insertable<DewormRow> {
  final int id;
  final int catId;
  final String kind;
  final String product;
  final DateTime givenOn;
  final DateTime? nextDue;
  final String notes;
  const DewormRow({
    required this.id,
    required this.catId,
    required this.kind,
    required this.product,
    required this.givenOn,
    this.nextDue,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['kind'] = Variable<String>(kind);
    map['product'] = Variable<String>(product);
    map['given_on'] = Variable<DateTime>(givenOn);
    if (!nullToAbsent || nextDue != null) {
      map['next_due'] = Variable<DateTime>(nextDue);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  DewormingsCompanion toCompanion(bool nullToAbsent) {
    return DewormingsCompanion(
      id: Value(id),
      catId: Value(catId),
      kind: Value(kind),
      product: Value(product),
      givenOn: Value(givenOn),
      nextDue: nextDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDue),
      notes: Value(notes),
    );
  }

  factory DewormRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DewormRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      kind: serializer.fromJson<String>(json['kind']),
      product: serializer.fromJson<String>(json['product']),
      givenOn: serializer.fromJson<DateTime>(json['givenOn']),
      nextDue: serializer.fromJson<DateTime?>(json['nextDue']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'kind': serializer.toJson<String>(kind),
      'product': serializer.toJson<String>(product),
      'givenOn': serializer.toJson<DateTime>(givenOn),
      'nextDue': serializer.toJson<DateTime?>(nextDue),
      'notes': serializer.toJson<String>(notes),
    };
  }

  DewormRow copyWith({
    int? id,
    int? catId,
    String? kind,
    String? product,
    DateTime? givenOn,
    Value<DateTime?> nextDue = const Value.absent(),
    String? notes,
  }) => DewormRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    kind: kind ?? this.kind,
    product: product ?? this.product,
    givenOn: givenOn ?? this.givenOn,
    nextDue: nextDue.present ? nextDue.value : this.nextDue,
    notes: notes ?? this.notes,
  );
  DewormRow copyWithCompanion(DewormingsCompanion data) {
    return DewormRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      kind: data.kind.present ? data.kind.value : this.kind,
      product: data.product.present ? data.product.value : this.product,
      givenOn: data.givenOn.present ? data.givenOn.value : this.givenOn,
      nextDue: data.nextDue.present ? data.nextDue.value : this.nextDue,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DewormRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('kind: $kind, ')
          ..write('product: $product, ')
          ..write('givenOn: $givenOn, ')
          ..write('nextDue: $nextDue, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catId, kind, product, givenOn, nextDue, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DewormRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.kind == this.kind &&
          other.product == this.product &&
          other.givenOn == this.givenOn &&
          other.nextDue == this.nextDue &&
          other.notes == this.notes);
}

class DewormingsCompanion extends UpdateCompanion<DewormRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<String> kind;
  final Value<String> product;
  final Value<DateTime> givenOn;
  final Value<DateTime?> nextDue;
  final Value<String> notes;
  const DewormingsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.kind = const Value.absent(),
    this.product = const Value.absent(),
    this.givenOn = const Value.absent(),
    this.nextDue = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DewormingsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required String kind,
    required String product,
    required DateTime givenOn,
    this.nextDue = const Value.absent(),
    this.notes = const Value.absent(),
  }) : catId = Value(catId),
       kind = Value(kind),
       product = Value(product),
       givenOn = Value(givenOn);
  static Insertable<DewormRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? kind,
    Expression<String>? product,
    Expression<DateTime>? givenOn,
    Expression<DateTime>? nextDue,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (kind != null) 'kind': kind,
      if (product != null) 'product': product,
      if (givenOn != null) 'given_on': givenOn,
      if (nextDue != null) 'next_due': nextDue,
      if (notes != null) 'notes': notes,
    });
  }

  DewormingsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<String>? kind,
    Value<String>? product,
    Value<DateTime>? givenOn,
    Value<DateTime?>? nextDue,
    Value<String>? notes,
  }) {
    return DewormingsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      kind: kind ?? this.kind,
      product: product ?? this.product,
      givenOn: givenOn ?? this.givenOn,
      nextDue: nextDue ?? this.nextDue,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (product.present) {
      map['product'] = Variable<String>(product.value);
    }
    if (givenOn.present) {
      map['given_on'] = Variable<DateTime>(givenOn.value);
    }
    if (nextDue.present) {
      map['next_due'] = Variable<DateTime>(nextDue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DewormingsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('kind: $kind, ')
          ..write('product: $product, ')
          ..write('givenOn: $givenOn, ')
          ..write('nextDue: $nextDue, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $VetVisitsTable extends VetVisits
    with TableInfo<$VetVisitsTable, VetVisitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VetVisitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _visitedOnMeta = const VerificationMeta(
    'visitedOn',
  );
  @override
  late final GeneratedColumn<DateTime> visitedOn = GeneratedColumn<DateTime>(
    'visited_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clinicMeta = const VerificationMeta('clinic');
  @override
  late final GeneratedColumn<String> clinic = GeneratedColumn<String>(
    'clinic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosisMeta = const VerificationMeta(
    'diagnosis',
  );
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
    'diagnosis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _treatmentMeta = const VerificationMeta(
    'treatment',
  );
  @override
  late final GeneratedColumn<String> treatment = GeneratedColumn<String>(
    'treatment',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    visitedOn,
    clinic,
    reason,
    diagnosis,
    treatment,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vet_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<VetVisitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('visited_on')) {
      context.handle(
        _visitedOnMeta,
        visitedOn.isAcceptableOrUnknown(data['visited_on']!, _visitedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_visitedOnMeta);
    }
    if (data.containsKey('clinic')) {
      context.handle(
        _clinicMeta,
        clinic.isAcceptableOrUnknown(data['clinic']!, _clinicMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('diagnosis')) {
      context.handle(
        _diagnosisMeta,
        diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta),
      );
    }
    if (data.containsKey('treatment')) {
      context.handle(
        _treatmentMeta,
        treatment.isAcceptableOrUnknown(data['treatment']!, _treatmentMeta),
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
  VetVisitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VetVisitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      visitedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_on'],
      )!,
      clinic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      diagnosis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosis'],
      ),
      treatment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $VetVisitsTable createAlias(String alias) {
    return $VetVisitsTable(attachedDatabase, alias);
  }
}

class VetVisitRow extends DataClass implements Insertable<VetVisitRow> {
  final int id;
  final int catId;
  final DateTime visitedOn;
  final String? clinic;
  final String reason;
  final String? diagnosis;
  final String? treatment;
  final String notes;
  const VetVisitRow({
    required this.id,
    required this.catId,
    required this.visitedOn,
    this.clinic,
    required this.reason,
    this.diagnosis,
    this.treatment,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['visited_on'] = Variable<DateTime>(visitedOn);
    if (!nullToAbsent || clinic != null) {
      map['clinic'] = Variable<String>(clinic);
    }
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || diagnosis != null) {
      map['diagnosis'] = Variable<String>(diagnosis);
    }
    if (!nullToAbsent || treatment != null) {
      map['treatment'] = Variable<String>(treatment);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  VetVisitsCompanion toCompanion(bool nullToAbsent) {
    return VetVisitsCompanion(
      id: Value(id),
      catId: Value(catId),
      visitedOn: Value(visitedOn),
      clinic: clinic == null && nullToAbsent
          ? const Value.absent()
          : Value(clinic),
      reason: Value(reason),
      diagnosis: diagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosis),
      treatment: treatment == null && nullToAbsent
          ? const Value.absent()
          : Value(treatment),
      notes: Value(notes),
    );
  }

  factory VetVisitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VetVisitRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      visitedOn: serializer.fromJson<DateTime>(json['visitedOn']),
      clinic: serializer.fromJson<String?>(json['clinic']),
      reason: serializer.fromJson<String>(json['reason']),
      diagnosis: serializer.fromJson<String?>(json['diagnosis']),
      treatment: serializer.fromJson<String?>(json['treatment']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'visitedOn': serializer.toJson<DateTime>(visitedOn),
      'clinic': serializer.toJson<String?>(clinic),
      'reason': serializer.toJson<String>(reason),
      'diagnosis': serializer.toJson<String?>(diagnosis),
      'treatment': serializer.toJson<String?>(treatment),
      'notes': serializer.toJson<String>(notes),
    };
  }

  VetVisitRow copyWith({
    int? id,
    int? catId,
    DateTime? visitedOn,
    Value<String?> clinic = const Value.absent(),
    String? reason,
    Value<String?> diagnosis = const Value.absent(),
    Value<String?> treatment = const Value.absent(),
    String? notes,
  }) => VetVisitRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    visitedOn: visitedOn ?? this.visitedOn,
    clinic: clinic.present ? clinic.value : this.clinic,
    reason: reason ?? this.reason,
    diagnosis: diagnosis.present ? diagnosis.value : this.diagnosis,
    treatment: treatment.present ? treatment.value : this.treatment,
    notes: notes ?? this.notes,
  );
  VetVisitRow copyWithCompanion(VetVisitsCompanion data) {
    return VetVisitRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      visitedOn: data.visitedOn.present ? data.visitedOn.value : this.visitedOn,
      clinic: data.clinic.present ? data.clinic.value : this.clinic,
      reason: data.reason.present ? data.reason.value : this.reason,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      treatment: data.treatment.present ? data.treatment.value : this.treatment,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VetVisitRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('visitedOn: $visitedOn, ')
          ..write('clinic: $clinic, ')
          ..write('reason: $reason, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('treatment: $treatment, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catId,
    visitedOn,
    clinic,
    reason,
    diagnosis,
    treatment,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VetVisitRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.visitedOn == this.visitedOn &&
          other.clinic == this.clinic &&
          other.reason == this.reason &&
          other.diagnosis == this.diagnosis &&
          other.treatment == this.treatment &&
          other.notes == this.notes);
}

class VetVisitsCompanion extends UpdateCompanion<VetVisitRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<DateTime> visitedOn;
  final Value<String?> clinic;
  final Value<String> reason;
  final Value<String?> diagnosis;
  final Value<String?> treatment;
  final Value<String> notes;
  const VetVisitsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.visitedOn = const Value.absent(),
    this.clinic = const Value.absent(),
    this.reason = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.treatment = const Value.absent(),
    this.notes = const Value.absent(),
  });
  VetVisitsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required DateTime visitedOn,
    this.clinic = const Value.absent(),
    required String reason,
    this.diagnosis = const Value.absent(),
    this.treatment = const Value.absent(),
    this.notes = const Value.absent(),
  }) : catId = Value(catId),
       visitedOn = Value(visitedOn),
       reason = Value(reason);
  static Insertable<VetVisitRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<DateTime>? visitedOn,
    Expression<String>? clinic,
    Expression<String>? reason,
    Expression<String>? diagnosis,
    Expression<String>? treatment,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (visitedOn != null) 'visited_on': visitedOn,
      if (clinic != null) 'clinic': clinic,
      if (reason != null) 'reason': reason,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (treatment != null) 'treatment': treatment,
      if (notes != null) 'notes': notes,
    });
  }

  VetVisitsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<DateTime>? visitedOn,
    Value<String?>? clinic,
    Value<String>? reason,
    Value<String?>? diagnosis,
    Value<String?>? treatment,
    Value<String>? notes,
  }) {
    return VetVisitsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      visitedOn: visitedOn ?? this.visitedOn,
      clinic: clinic ?? this.clinic,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (visitedOn.present) {
      map['visited_on'] = Variable<DateTime>(visitedOn.value);
    }
    if (clinic.present) {
      map['clinic'] = Variable<String>(clinic.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (treatment.present) {
      map['treatment'] = Variable<String>(treatment.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VetVisitsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('visitedOn: $visitedOn, ')
          ..write('clinic: $clinic, ')
          ..write('reason: $reason, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('treatment: $treatment, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $WeightLogsTable extends WeightLogs
    with TableInfo<$WeightLogsTable, WeightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _loggedOnMeta = const VerificationMeta(
    'loggedOn',
  );
  @override
  late final GeneratedColumn<DateTime> loggedOn = GeneratedColumn<DateTime>(
    'logged_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, catId, loggedOn, weightKg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('logged_on')) {
      context.handle(
        _loggedOnMeta,
        loggedOn.isAcceptableOrUnknown(data['logged_on']!, _loggedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedOnMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      loggedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_on'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
    );
  }

  @override
  $WeightLogsTable createAlias(String alias) {
    return $WeightLogsTable(attachedDatabase, alias);
  }
}

class WeightRow extends DataClass implements Insertable<WeightRow> {
  final int id;
  final int catId;
  final DateTime loggedOn;
  final double weightKg;
  const WeightRow({
    required this.id,
    required this.catId,
    required this.loggedOn,
    required this.weightKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['logged_on'] = Variable<DateTime>(loggedOn);
    map['weight_kg'] = Variable<double>(weightKg);
    return map;
  }

  WeightLogsCompanion toCompanion(bool nullToAbsent) {
    return WeightLogsCompanion(
      id: Value(id),
      catId: Value(catId),
      loggedOn: Value(loggedOn),
      weightKg: Value(weightKg),
    );
  }

  factory WeightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      loggedOn: serializer.fromJson<DateTime>(json['loggedOn']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'loggedOn': serializer.toJson<DateTime>(loggedOn),
      'weightKg': serializer.toJson<double>(weightKg),
    };
  }

  WeightRow copyWith({
    int? id,
    int? catId,
    DateTime? loggedOn,
    double? weightKg,
  }) => WeightRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    loggedOn: loggedOn ?? this.loggedOn,
    weightKg: weightKg ?? this.weightKg,
  );
  WeightRow copyWithCompanion(WeightLogsCompanion data) {
    return WeightRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      loggedOn: data.loggedOn.present ? data.loggedOn.value : this.loggedOn,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, catId, loggedOn, weightKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.loggedOn == this.loggedOn &&
          other.weightKg == this.weightKg);
}

class WeightLogsCompanion extends UpdateCompanion<WeightRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<DateTime> loggedOn;
  final Value<double> weightKg;
  const WeightLogsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.loggedOn = const Value.absent(),
    this.weightKg = const Value.absent(),
  });
  WeightLogsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required DateTime loggedOn,
    required double weightKg,
  }) : catId = Value(catId),
       loggedOn = Value(loggedOn),
       weightKg = Value(weightKg);
  static Insertable<WeightRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<DateTime>? loggedOn,
    Expression<double>? weightKg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (loggedOn != null) 'logged_on': loggedOn,
      if (weightKg != null) 'weight_kg': weightKg,
    });
  }

  WeightLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<DateTime>? loggedOn,
    Value<double>? weightKg,
  }) {
    return WeightLogsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      loggedOn: loggedOn ?? this.loggedOn,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (loggedOn.present) {
      map['logged_on'] = Variable<DateTime>(loggedOn.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }
}

class $HealthNotesTable extends HealthNotes
    with TableInfo<$HealthNotesTable, HealthNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthNotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _notedOnMeta = const VerificationMeta(
    'notedOn',
  );
  @override
  late final GeneratedColumn<DateTime> notedOn = GeneratedColumn<DateTime>(
    'noted_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, catId, notedOn, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('noted_on')) {
      context.handle(
        _notedOnMeta,
        notedOn.isAcceptableOrUnknown(data['noted_on']!, _notedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_notedOnMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      notedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}noted_on'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $HealthNotesTable createAlias(String alias) {
    return $HealthNotesTable(attachedDatabase, alias);
  }
}

class HealthNoteRow extends DataClass implements Insertable<HealthNoteRow> {
  final int id;
  final int catId;
  final DateTime notedOn;
  final String content;
  const HealthNoteRow({
    required this.id,
    required this.catId,
    required this.notedOn,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['noted_on'] = Variable<DateTime>(notedOn);
    map['content'] = Variable<String>(content);
    return map;
  }

  HealthNotesCompanion toCompanion(bool nullToAbsent) {
    return HealthNotesCompanion(
      id: Value(id),
      catId: Value(catId),
      notedOn: Value(notedOn),
      content: Value(content),
    );
  }

  factory HealthNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthNoteRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      notedOn: serializer.fromJson<DateTime>(json['notedOn']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'notedOn': serializer.toJson<DateTime>(notedOn),
      'content': serializer.toJson<String>(content),
    };
  }

  HealthNoteRow copyWith({
    int? id,
    int? catId,
    DateTime? notedOn,
    String? content,
  }) => HealthNoteRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    notedOn: notedOn ?? this.notedOn,
    content: content ?? this.content,
  );
  HealthNoteRow copyWithCompanion(HealthNotesCompanion data) {
    return HealthNoteRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      notedOn: data.notedOn.present ? data.notedOn.value : this.notedOn,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthNoteRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('notedOn: $notedOn, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, catId, notedOn, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthNoteRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.notedOn == this.notedOn &&
          other.content == this.content);
}

class HealthNotesCompanion extends UpdateCompanion<HealthNoteRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<DateTime> notedOn;
  final Value<String> content;
  const HealthNotesCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.notedOn = const Value.absent(),
    this.content = const Value.absent(),
  });
  HealthNotesCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required DateTime notedOn,
    required String content,
  }) : catId = Value(catId),
       notedOn = Value(notedOn),
       content = Value(content);
  static Insertable<HealthNoteRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<DateTime>? notedOn,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (notedOn != null) 'noted_on': notedOn,
      if (content != null) 'content': content,
    });
  }

  HealthNotesCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<DateTime>? notedOn,
    Value<String>? content,
  }) {
    return HealthNotesCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      notedOn: notedOn ?? this.notedOn,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (notedOn.present) {
      map['noted_on'] = Variable<DateTime>(notedOn.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthNotesCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('notedOn: $notedOn, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

class $FoodProductsTable extends FoodProducts
    with TableInfo<$FoodProductsTable, FoodProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodProductsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
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
  static const VerificationMeta _specMeta = const VerificationMeta('spec');
  @override
  late final GeneratedColumn<String> spec = GeneratedColumn<String>(
    'spec',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodFormMeta = const VerificationMeta(
    'foodForm',
  );
  @override
  late final GeneratedColumn<String> foodForm = GeneratedColumn<String>(
    'food_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta(
    'kcalPer100g',
  );
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
    'kcal_per100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storageMethodMeta = const VerificationMeta(
    'storageMethod',
  );
  @override
  late final GeneratedColumn<String> storageMethod = GeneratedColumn<String>(
    'storage_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _afterOpenDaysMeta = const VerificationMeta(
    'afterOpenDays',
  );
  @override
  late final GeneratedColumn<int> afterOpenDays = GeneratedColumn<int>(
    'after_open_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSampleMeta = const VerificationMeta(
    'isSample',
  );
  @override
  late final GeneratedColumn<bool> isSample = GeneratedColumn<bool>(
    'is_sample',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sample" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    barcode,
    brand,
    name,
    spec,
    foodForm,
    kcalPer100g,
    storageMethod,
    afterOpenDays,
    isSample,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('spec')) {
      context.handle(
        _specMeta,
        spec.isAcceptableOrUnknown(data['spec']!, _specMeta),
      );
    } else if (isInserting) {
      context.missing(_specMeta);
    }
    if (data.containsKey('food_form')) {
      context.handle(
        _foodFormMeta,
        foodForm.isAcceptableOrUnknown(data['food_form']!, _foodFormMeta),
      );
    } else if (isInserting) {
      context.missing(_foodFormMeta);
    }
    if (data.containsKey('kcal_per100g')) {
      context.handle(
        _kcalPer100gMeta,
        kcalPer100g.isAcceptableOrUnknown(
          data['kcal_per100g']!,
          _kcalPer100gMeta,
        ),
      );
    }
    if (data.containsKey('storage_method')) {
      context.handle(
        _storageMethodMeta,
        storageMethod.isAcceptableOrUnknown(
          data['storage_method']!,
          _storageMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storageMethodMeta);
    }
    if (data.containsKey('after_open_days')) {
      context.handle(
        _afterOpenDaysMeta,
        afterOpenDays.isAcceptableOrUnknown(
          data['after_open_days']!,
          _afterOpenDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_afterOpenDaysMeta);
    }
    if (data.containsKey('is_sample')) {
      context.handle(
        _isSampleMeta,
        isSample.isAcceptableOrUnknown(data['is_sample']!, _isSampleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      spec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spec'],
      )!,
      foodForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_form'],
      )!,
      kcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per100g'],
      ),
      storageMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_method'],
      )!,
      afterOpenDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}after_open_days'],
      )!,
      isSample: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sample'],
      )!,
    );
  }

  @override
  $FoodProductsTable createAlias(String alias) {
    return $FoodProductsTable(attachedDatabase, alias);
  }
}

class FoodProductRow extends DataClass implements Insertable<FoodProductRow> {
  final int id;
  final String? barcode;
  final String brand;
  final String name;
  final String spec;
  final String foodForm;
  final double? kcalPer100g;
  final String storageMethod;
  final int afterOpenDays;
  final bool isSample;
  const FoodProductRow({
    required this.id,
    this.barcode,
    required this.brand,
    required this.name,
    required this.spec,
    required this.foodForm,
    this.kcalPer100g,
    required this.storageMethod,
    required this.afterOpenDays,
    required this.isSample,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['brand'] = Variable<String>(brand);
    map['name'] = Variable<String>(name);
    map['spec'] = Variable<String>(spec);
    map['food_form'] = Variable<String>(foodForm);
    if (!nullToAbsent || kcalPer100g != null) {
      map['kcal_per100g'] = Variable<double>(kcalPer100g);
    }
    map['storage_method'] = Variable<String>(storageMethod);
    map['after_open_days'] = Variable<int>(afterOpenDays);
    map['is_sample'] = Variable<bool>(isSample);
    return map;
  }

  FoodProductsCompanion toCompanion(bool nullToAbsent) {
    return FoodProductsCompanion(
      id: Value(id),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      brand: Value(brand),
      name: Value(name),
      spec: Value(spec),
      foodForm: Value(foodForm),
      kcalPer100g: kcalPer100g == null && nullToAbsent
          ? const Value.absent()
          : Value(kcalPer100g),
      storageMethod: Value(storageMethod),
      afterOpenDays: Value(afterOpenDays),
      isSample: Value(isSample),
    );
  }

  factory FoodProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodProductRow(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      brand: serializer.fromJson<String>(json['brand']),
      name: serializer.fromJson<String>(json['name']),
      spec: serializer.fromJson<String>(json['spec']),
      foodForm: serializer.fromJson<String>(json['foodForm']),
      kcalPer100g: serializer.fromJson<double?>(json['kcalPer100g']),
      storageMethod: serializer.fromJson<String>(json['storageMethod']),
      afterOpenDays: serializer.fromJson<int>(json['afterOpenDays']),
      isSample: serializer.fromJson<bool>(json['isSample']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String?>(barcode),
      'brand': serializer.toJson<String>(brand),
      'name': serializer.toJson<String>(name),
      'spec': serializer.toJson<String>(spec),
      'foodForm': serializer.toJson<String>(foodForm),
      'kcalPer100g': serializer.toJson<double?>(kcalPer100g),
      'storageMethod': serializer.toJson<String>(storageMethod),
      'afterOpenDays': serializer.toJson<int>(afterOpenDays),
      'isSample': serializer.toJson<bool>(isSample),
    };
  }

  FoodProductRow copyWith({
    int? id,
    Value<String?> barcode = const Value.absent(),
    String? brand,
    String? name,
    String? spec,
    String? foodForm,
    Value<double?> kcalPer100g = const Value.absent(),
    String? storageMethod,
    int? afterOpenDays,
    bool? isSample,
  }) => FoodProductRow(
    id: id ?? this.id,
    barcode: barcode.present ? barcode.value : this.barcode,
    brand: brand ?? this.brand,
    name: name ?? this.name,
    spec: spec ?? this.spec,
    foodForm: foodForm ?? this.foodForm,
    kcalPer100g: kcalPer100g.present ? kcalPer100g.value : this.kcalPer100g,
    storageMethod: storageMethod ?? this.storageMethod,
    afterOpenDays: afterOpenDays ?? this.afterOpenDays,
    isSample: isSample ?? this.isSample,
  );
  FoodProductRow copyWithCompanion(FoodProductsCompanion data) {
    return FoodProductRow(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      brand: data.brand.present ? data.brand.value : this.brand,
      name: data.name.present ? data.name.value : this.name,
      spec: data.spec.present ? data.spec.value : this.spec,
      foodForm: data.foodForm.present ? data.foodForm.value : this.foodForm,
      kcalPer100g: data.kcalPer100g.present
          ? data.kcalPer100g.value
          : this.kcalPer100g,
      storageMethod: data.storageMethod.present
          ? data.storageMethod.value
          : this.storageMethod,
      afterOpenDays: data.afterOpenDays.present
          ? data.afterOpenDays.value
          : this.afterOpenDays,
      isSample: data.isSample.present ? data.isSample.value : this.isSample,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodProductRow(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('brand: $brand, ')
          ..write('name: $name, ')
          ..write('spec: $spec, ')
          ..write('foodForm: $foodForm, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('storageMethod: $storageMethod, ')
          ..write('afterOpenDays: $afterOpenDays, ')
          ..write('isSample: $isSample')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    barcode,
    brand,
    name,
    spec,
    foodForm,
    kcalPer100g,
    storageMethod,
    afterOpenDays,
    isSample,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodProductRow &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.brand == this.brand &&
          other.name == this.name &&
          other.spec == this.spec &&
          other.foodForm == this.foodForm &&
          other.kcalPer100g == this.kcalPer100g &&
          other.storageMethod == this.storageMethod &&
          other.afterOpenDays == this.afterOpenDays &&
          other.isSample == this.isSample);
}

class FoodProductsCompanion extends UpdateCompanion<FoodProductRow> {
  final Value<int> id;
  final Value<String?> barcode;
  final Value<String> brand;
  final Value<String> name;
  final Value<String> spec;
  final Value<String> foodForm;
  final Value<double?> kcalPer100g;
  final Value<String> storageMethod;
  final Value<int> afterOpenDays;
  final Value<bool> isSample;
  const FoodProductsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.brand = const Value.absent(),
    this.name = const Value.absent(),
    this.spec = const Value.absent(),
    this.foodForm = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.storageMethod = const Value.absent(),
    this.afterOpenDays = const Value.absent(),
    this.isSample = const Value.absent(),
  });
  FoodProductsCompanion.insert({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    required String brand,
    required String name,
    required String spec,
    required String foodForm,
    this.kcalPer100g = const Value.absent(),
    required String storageMethod,
    required int afterOpenDays,
    this.isSample = const Value.absent(),
  }) : brand = Value(brand),
       name = Value(name),
       spec = Value(spec),
       foodForm = Value(foodForm),
       storageMethod = Value(storageMethod),
       afterOpenDays = Value(afterOpenDays);
  static Insertable<FoodProductRow> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? brand,
    Expression<String>? name,
    Expression<String>? spec,
    Expression<String>? foodForm,
    Expression<double>? kcalPer100g,
    Expression<String>? storageMethod,
    Expression<int>? afterOpenDays,
    Expression<bool>? isSample,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (brand != null) 'brand': brand,
      if (name != null) 'name': name,
      if (spec != null) 'spec': spec,
      if (foodForm != null) 'food_form': foodForm,
      if (kcalPer100g != null) 'kcal_per100g': kcalPer100g,
      if (storageMethod != null) 'storage_method': storageMethod,
      if (afterOpenDays != null) 'after_open_days': afterOpenDays,
      if (isSample != null) 'is_sample': isSample,
    });
  }

  FoodProductsCompanion copyWith({
    Value<int>? id,
    Value<String?>? barcode,
    Value<String>? brand,
    Value<String>? name,
    Value<String>? spec,
    Value<String>? foodForm,
    Value<double?>? kcalPer100g,
    Value<String>? storageMethod,
    Value<int>? afterOpenDays,
    Value<bool>? isSample,
  }) {
    return FoodProductsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      spec: spec ?? this.spec,
      foodForm: foodForm ?? this.foodForm,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      storageMethod: storageMethod ?? this.storageMethod,
      afterOpenDays: afterOpenDays ?? this.afterOpenDays,
      isSample: isSample ?? this.isSample,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (spec.present) {
      map['spec'] = Variable<String>(spec.value);
    }
    if (foodForm.present) {
      map['food_form'] = Variable<String>(foodForm.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per100g'] = Variable<double>(kcalPer100g.value);
    }
    if (storageMethod.present) {
      map['storage_method'] = Variable<String>(storageMethod.value);
    }
    if (afterOpenDays.present) {
      map['after_open_days'] = Variable<int>(afterOpenDays.value);
    }
    if (isSample.present) {
      map['is_sample'] = Variable<bool>(isSample.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodProductsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('brand: $brand, ')
          ..write('name: $name, ')
          ..write('spec: $spec, ')
          ..write('foodForm: $foodForm, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('storageMethod: $storageMethod, ')
          ..write('afterOpenDays: $afterOpenDays, ')
          ..write('isSample: $isSample')
          ..write(')'))
        .toString();
  }
}

class $FeedingLogsTable extends FeedingLogs
    with TableInfo<$FeedingLogsTable, FeedingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodFormMeta = const VerificationMeta(
    'foodForm',
  );
  @override
  late final GeneratedColumn<String> foodForm = GeneratedColumn<String>(
    'food_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES food_products (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    loggedAt,
    foodName,
    foodForm,
    grams,
    kcal,
    productId,
    slot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeding_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('food_form')) {
      context.handle(
        _foodFormMeta,
        foodForm.isAcceptableOrUnknown(data['food_form']!, _foodFormMeta),
      );
    } else if (isInserting) {
      context.missing(_foodFormMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      foodForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_form'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
    );
  }

  @override
  $FeedingLogsTable createAlias(String alias) {
    return $FeedingLogsTable(attachedDatabase, alias);
  }
}

class FeedingRow extends DataClass implements Insertable<FeedingRow> {
  final int id;
  final int catId;
  final DateTime loggedAt;
  final String foodName;
  final String foodForm;
  final double grams;
  final double? kcal;
  final int? productId;
  final String slot;
  const FeedingRow({
    required this.id,
    required this.catId,
    required this.loggedAt,
    required this.foodName,
    required this.foodForm,
    required this.grams,
    this.kcal,
    this.productId,
    required this.slot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['food_name'] = Variable<String>(foodName);
    map['food_form'] = Variable<String>(foodForm);
    map['grams'] = Variable<double>(grams);
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['slot'] = Variable<String>(slot);
    return map;
  }

  FeedingLogsCompanion toCompanion(bool nullToAbsent) {
    return FeedingLogsCompanion(
      id: Value(id),
      catId: Value(catId),
      loggedAt: Value(loggedAt),
      foodName: Value(foodName),
      foodForm: Value(foodForm),
      grams: Value(grams),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      slot: Value(slot),
    );
  }

  factory FeedingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      foodName: serializer.fromJson<String>(json['foodName']),
      foodForm: serializer.fromJson<String>(json['foodForm']),
      grams: serializer.fromJson<double>(json['grams']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      productId: serializer.fromJson<int?>(json['productId']),
      slot: serializer.fromJson<String>(json['slot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'foodName': serializer.toJson<String>(foodName),
      'foodForm': serializer.toJson<String>(foodForm),
      'grams': serializer.toJson<double>(grams),
      'kcal': serializer.toJson<double?>(kcal),
      'productId': serializer.toJson<int?>(productId),
      'slot': serializer.toJson<String>(slot),
    };
  }

  FeedingRow copyWith({
    int? id,
    int? catId,
    DateTime? loggedAt,
    String? foodName,
    String? foodForm,
    double? grams,
    Value<double?> kcal = const Value.absent(),
    Value<int?> productId = const Value.absent(),
    String? slot,
  }) => FeedingRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    loggedAt: loggedAt ?? this.loggedAt,
    foodName: foodName ?? this.foodName,
    foodForm: foodForm ?? this.foodForm,
    grams: grams ?? this.grams,
    kcal: kcal.present ? kcal.value : this.kcal,
    productId: productId.present ? productId.value : this.productId,
    slot: slot ?? this.slot,
  );
  FeedingRow copyWithCompanion(FeedingLogsCompanion data) {
    return FeedingRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      foodForm: data.foodForm.present ? data.foodForm.value : this.foodForm,
      grams: data.grams.present ? data.grams.value : this.grams,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      productId: data.productId.present ? data.productId.value : this.productId,
      slot: data.slot.present ? data.slot.value : this.slot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('foodName: $foodName, ')
          ..write('foodForm: $foodForm, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('productId: $productId, ')
          ..write('slot: $slot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catId,
    loggedAt,
    foodName,
    foodForm,
    grams,
    kcal,
    productId,
    slot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.loggedAt == this.loggedAt &&
          other.foodName == this.foodName &&
          other.foodForm == this.foodForm &&
          other.grams == this.grams &&
          other.kcal == this.kcal &&
          other.productId == this.productId &&
          other.slot == this.slot);
}

class FeedingLogsCompanion extends UpdateCompanion<FeedingRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<DateTime> loggedAt;
  final Value<String> foodName;
  final Value<String> foodForm;
  final Value<double> grams;
  final Value<double?> kcal;
  final Value<int?> productId;
  final Value<String> slot;
  const FeedingLogsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.foodName = const Value.absent(),
    this.foodForm = const Value.absent(),
    this.grams = const Value.absent(),
    this.kcal = const Value.absent(),
    this.productId = const Value.absent(),
    this.slot = const Value.absent(),
  });
  FeedingLogsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required DateTime loggedAt,
    required String foodName,
    required String foodForm,
    required double grams,
    this.kcal = const Value.absent(),
    this.productId = const Value.absent(),
    required String slot,
  }) : catId = Value(catId),
       loggedAt = Value(loggedAt),
       foodName = Value(foodName),
       foodForm = Value(foodForm),
       grams = Value(grams),
       slot = Value(slot);
  static Insertable<FeedingRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<DateTime>? loggedAt,
    Expression<String>? foodName,
    Expression<String>? foodForm,
    Expression<double>? grams,
    Expression<double>? kcal,
    Expression<int>? productId,
    Expression<String>? slot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (foodName != null) 'food_name': foodName,
      if (foodForm != null) 'food_form': foodForm,
      if (grams != null) 'grams': grams,
      if (kcal != null) 'kcal': kcal,
      if (productId != null) 'product_id': productId,
      if (slot != null) 'slot': slot,
    });
  }

  FeedingLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<DateTime>? loggedAt,
    Value<String>? foodName,
    Value<String>? foodForm,
    Value<double>? grams,
    Value<double?>? kcal,
    Value<int?>? productId,
    Value<String>? slot,
  }) {
    return FeedingLogsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      loggedAt: loggedAt ?? this.loggedAt,
      foodName: foodName ?? this.foodName,
      foodForm: foodForm ?? this.foodForm,
      grams: grams ?? this.grams,
      kcal: kcal ?? this.kcal,
      productId: productId ?? this.productId,
      slot: slot ?? this.slot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (foodForm.present) {
      map['food_form'] = Variable<String>(foodForm.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingLogsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('foodName: $foodName, ')
          ..write('foodForm: $foodForm, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('productId: $productId, ')
          ..write('slot: $slot')
          ..write(')'))
        .toString();
  }
}

class $FoodTransitionsTable extends FoodTransitions
    with TableInfo<$FoodTransitionsTable, TransitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodTransitionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fromFoodMeta = const VerificationMeta(
    'fromFood',
  );
  @override
  late final GeneratedColumn<String> fromFood = GeneratedColumn<String>(
    'from_food',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toFoodMeta = const VerificationMeta('toFood');
  @override
  late final GeneratedColumn<String> toFood = GeneratedColumn<String>(
    'to_food',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    fromFood,
    toFood,
    startDate,
    days,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_transitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('from_food')) {
      context.handle(
        _fromFoodMeta,
        fromFood.isAcceptableOrUnknown(data['from_food']!, _fromFoodMeta),
      );
    } else if (isInserting) {
      context.missing(_fromFoodMeta);
    }
    if (data.containsKey('to_food')) {
      context.handle(
        _toFoodMeta,
        toFood.isAcceptableOrUnknown(data['to_food']!, _toFoodMeta),
      );
    } else if (isInserting) {
      context.missing(_toFoodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      fromFood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_food'],
      )!,
      toFood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_food'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
    );
  }

  @override
  $FoodTransitionsTable createAlias(String alias) {
    return $FoodTransitionsTable(attachedDatabase, alias);
  }
}

class TransitionRow extends DataClass implements Insertable<TransitionRow> {
  final int id;
  final int catId;
  final String fromFood;
  final String toFood;
  final DateTime startDate;
  final int days;
  const TransitionRow({
    required this.id,
    required this.catId,
    required this.fromFood,
    required this.toFood,
    required this.startDate,
    required this.days,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['from_food'] = Variable<String>(fromFood);
    map['to_food'] = Variable<String>(toFood);
    map['start_date'] = Variable<DateTime>(startDate);
    map['days'] = Variable<int>(days);
    return map;
  }

  FoodTransitionsCompanion toCompanion(bool nullToAbsent) {
    return FoodTransitionsCompanion(
      id: Value(id),
      catId: Value(catId),
      fromFood: Value(fromFood),
      toFood: Value(toFood),
      startDate: Value(startDate),
      days: Value(days),
    );
  }

  factory TransitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransitionRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      fromFood: serializer.fromJson<String>(json['fromFood']),
      toFood: serializer.fromJson<String>(json['toFood']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      days: serializer.fromJson<int>(json['days']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'fromFood': serializer.toJson<String>(fromFood),
      'toFood': serializer.toJson<String>(toFood),
      'startDate': serializer.toJson<DateTime>(startDate),
      'days': serializer.toJson<int>(days),
    };
  }

  TransitionRow copyWith({
    int? id,
    int? catId,
    String? fromFood,
    String? toFood,
    DateTime? startDate,
    int? days,
  }) => TransitionRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    fromFood: fromFood ?? this.fromFood,
    toFood: toFood ?? this.toFood,
    startDate: startDate ?? this.startDate,
    days: days ?? this.days,
  );
  TransitionRow copyWithCompanion(FoodTransitionsCompanion data) {
    return TransitionRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      fromFood: data.fromFood.present ? data.fromFood.value : this.fromFood,
      toFood: data.toFood.present ? data.toFood.value : this.toFood,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      days: data.days.present ? data.days.value : this.days,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransitionRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('fromFood: $fromFood, ')
          ..write('toFood: $toFood, ')
          ..write('startDate: $startDate, ')
          ..write('days: $days')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, catId, fromFood, toFood, startDate, days);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransitionRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.fromFood == this.fromFood &&
          other.toFood == this.toFood &&
          other.startDate == this.startDate &&
          other.days == this.days);
}

class FoodTransitionsCompanion extends UpdateCompanion<TransitionRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<String> fromFood;
  final Value<String> toFood;
  final Value<DateTime> startDate;
  final Value<int> days;
  const FoodTransitionsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.fromFood = const Value.absent(),
    this.toFood = const Value.absent(),
    this.startDate = const Value.absent(),
    this.days = const Value.absent(),
  });
  FoodTransitionsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required String fromFood,
    required String toFood,
    required DateTime startDate,
    this.days = const Value.absent(),
  }) : catId = Value(catId),
       fromFood = Value(fromFood),
       toFood = Value(toFood),
       startDate = Value(startDate);
  static Insertable<TransitionRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? fromFood,
    Expression<String>? toFood,
    Expression<DateTime>? startDate,
    Expression<int>? days,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (fromFood != null) 'from_food': fromFood,
      if (toFood != null) 'to_food': toFood,
      if (startDate != null) 'start_date': startDate,
      if (days != null) 'days': days,
    });
  }

  FoodTransitionsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<String>? fromFood,
    Value<String>? toFood,
    Value<DateTime>? startDate,
    Value<int>? days,
  }) {
    return FoodTransitionsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      fromFood: fromFood ?? this.fromFood,
      toFood: toFood ?? this.toFood,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (fromFood.present) {
      map['from_food'] = Variable<String>(fromFood.value);
    }
    if (toFood.present) {
      map['to_food'] = Variable<String>(toFood.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodTransitionsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('fromFood: $fromFood, ')
          ..write('toFood: $toFood, ')
          ..write('startDate: $startDate, ')
          ..write('days: $days')
          ..write(')'))
        .toString();
  }
}

class $PantryItemsTable extends PantryItems
    with TableInfo<$PantryItemsTable, PantryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PantryItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES food_products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productionDateMeta = const VerificationMeta(
    'productionDate',
  );
  @override
  late final GeneratedColumn<DateTime> productionDate =
      GeneratedColumn<DateTime>(
        'production_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchMeta = const VerificationMeta('batch');
  @override
  late final GeneratedColumn<String> batch = GeneratedColumn<String>(
    'batch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateSourceMeta = const VerificationMeta(
    'dateSource',
  );
  @override
  late final GeneratedColumn<String> dateSource = GeneratedColumn<String>(
    'date_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterOpenDaysMeta = const VerificationMeta(
    'afterOpenDays',
  );
  @override
  late final GeneratedColumn<int> afterOpenDays = GeneratedColumn<int>(
    'after_open_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    productionDate,
    expiryDate,
    batch,
    dateSource,
    openedAt,
    afterOpenDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pantry_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PantryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('production_date')) {
      context.handle(
        _productionDateMeta,
        productionDate.isAcceptableOrUnknown(
          data['production_date']!,
          _productionDateMeta,
        ),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('batch')) {
      context.handle(
        _batchMeta,
        batch.isAcceptableOrUnknown(data['batch']!, _batchMeta),
      );
    }
    if (data.containsKey('date_source')) {
      context.handle(
        _dateSourceMeta,
        dateSource.isAcceptableOrUnknown(data['date_source']!, _dateSourceMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('after_open_days')) {
      context.handle(
        _afterOpenDaysMeta,
        afterOpenDays.isAcceptableOrUnknown(
          data['after_open_days']!,
          _afterOpenDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PantryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PantryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      productionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}production_date'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      batch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch'],
      ),
      dateSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_source'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      afterOpenDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}after_open_days'],
      ),
    );
  }

  @override
  $PantryItemsTable createAlias(String alias) {
    return $PantryItemsTable(attachedDatabase, alias);
  }
}

class PantryRow extends DataClass implements Insertable<PantryRow> {
  final int id;
  final int productId;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String? batch;
  final String dateSource;
  final DateTime? openedAt;
  final int? afterOpenDays;
  const PantryRow({
    required this.id,
    required this.productId,
    this.productionDate,
    this.expiryDate,
    this.batch,
    required this.dateSource,
    this.openedAt,
    this.afterOpenDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    if (!nullToAbsent || productionDate != null) {
      map['production_date'] = Variable<DateTime>(productionDate);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || batch != null) {
      map['batch'] = Variable<String>(batch);
    }
    map['date_source'] = Variable<String>(dateSource);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    if (!nullToAbsent || afterOpenDays != null) {
      map['after_open_days'] = Variable<int>(afterOpenDays);
    }
    return map;
  }

  PantryItemsCompanion toCompanion(bool nullToAbsent) {
    return PantryItemsCompanion(
      id: Value(id),
      productId: Value(productId),
      productionDate: productionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(productionDate),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      batch: batch == null && nullToAbsent
          ? const Value.absent()
          : Value(batch),
      dateSource: Value(dateSource),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
      afterOpenDays: afterOpenDays == null && nullToAbsent
          ? const Value.absent()
          : Value(afterOpenDays),
    );
  }

  factory PantryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PantryRow(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      productionDate: serializer.fromJson<DateTime?>(json['productionDate']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      batch: serializer.fromJson<String?>(json['batch']),
      dateSource: serializer.fromJson<String>(json['dateSource']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      afterOpenDays: serializer.fromJson<int?>(json['afterOpenDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'productionDate': serializer.toJson<DateTime?>(productionDate),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'batch': serializer.toJson<String?>(batch),
      'dateSource': serializer.toJson<String>(dateSource),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'afterOpenDays': serializer.toJson<int?>(afterOpenDays),
    };
  }

  PantryRow copyWith({
    int? id,
    int? productId,
    Value<DateTime?> productionDate = const Value.absent(),
    Value<DateTime?> expiryDate = const Value.absent(),
    Value<String?> batch = const Value.absent(),
    String? dateSource,
    Value<DateTime?> openedAt = const Value.absent(),
    Value<int?> afterOpenDays = const Value.absent(),
  }) => PantryRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    productionDate: productionDate.present
        ? productionDate.value
        : this.productionDate,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    batch: batch.present ? batch.value : this.batch,
    dateSource: dateSource ?? this.dateSource,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    afterOpenDays: afterOpenDays.present
        ? afterOpenDays.value
        : this.afterOpenDays,
  );
  PantryRow copyWithCompanion(PantryItemsCompanion data) {
    return PantryRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      productionDate: data.productionDate.present
          ? data.productionDate.value
          : this.productionDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      batch: data.batch.present ? data.batch.value : this.batch,
      dateSource: data.dateSource.present
          ? data.dateSource.value
          : this.dateSource,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      afterOpenDays: data.afterOpenDays.present
          ? data.afterOpenDays.value
          : this.afterOpenDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PantryRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productionDate: $productionDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('batch: $batch, ')
          ..write('dateSource: $dateSource, ')
          ..write('openedAt: $openedAt, ')
          ..write('afterOpenDays: $afterOpenDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    productionDate,
    expiryDate,
    batch,
    dateSource,
    openedAt,
    afterOpenDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PantryRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.productionDate == this.productionDate &&
          other.expiryDate == this.expiryDate &&
          other.batch == this.batch &&
          other.dateSource == this.dateSource &&
          other.openedAt == this.openedAt &&
          other.afterOpenDays == this.afterOpenDays);
}

class PantryItemsCompanion extends UpdateCompanion<PantryRow> {
  final Value<int> id;
  final Value<int> productId;
  final Value<DateTime?> productionDate;
  final Value<DateTime?> expiryDate;
  final Value<String?> batch;
  final Value<String> dateSource;
  final Value<DateTime?> openedAt;
  final Value<int?> afterOpenDays;
  const PantryItemsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.productionDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.batch = const Value.absent(),
    this.dateSource = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.afterOpenDays = const Value.absent(),
  });
  PantryItemsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    this.productionDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.batch = const Value.absent(),
    this.dateSource = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.afterOpenDays = const Value.absent(),
  }) : productId = Value(productId);
  static Insertable<PantryRow> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<DateTime>? productionDate,
    Expression<DateTime>? expiryDate,
    Expression<String>? batch,
    Expression<String>? dateSource,
    Expression<DateTime>? openedAt,
    Expression<int>? afterOpenDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (productionDate != null) 'production_date': productionDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (batch != null) 'batch': batch,
      if (dateSource != null) 'date_source': dateSource,
      if (openedAt != null) 'opened_at': openedAt,
      if (afterOpenDays != null) 'after_open_days': afterOpenDays,
    });
  }

  PantryItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<DateTime?>? productionDate,
    Value<DateTime?>? expiryDate,
    Value<String?>? batch,
    Value<String>? dateSource,
    Value<DateTime?>? openedAt,
    Value<int?>? afterOpenDays,
  }) {
    return PantryItemsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productionDate: productionDate ?? this.productionDate,
      expiryDate: expiryDate ?? this.expiryDate,
      batch: batch ?? this.batch,
      dateSource: dateSource ?? this.dateSource,
      openedAt: openedAt ?? this.openedAt,
      afterOpenDays: afterOpenDays ?? this.afterOpenDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productionDate.present) {
      map['production_date'] = Variable<DateTime>(productionDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (batch.present) {
      map['batch'] = Variable<String>(batch.value);
    }
    if (dateSource.present) {
      map['date_source'] = Variable<String>(dateSource.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (afterOpenDays.present) {
      map['after_open_days'] = Variable<int>(afterOpenDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PantryItemsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productionDate: $productionDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('batch: $batch, ')
          ..write('dateSource: $dateSource, ')
          ..write('openedAt: $openedAt, ')
          ..write('afterOpenDays: $afterOpenDays')
          ..write(')'))
        .toString();
  }
}

class $FeedingRemindersTable extends FeedingReminders
    with TableInfo<$FeedingRemindersTable, FeedingReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingRemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    slot,
    hour,
    minute,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeding_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedingReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $FeedingRemindersTable createAlias(String alias) {
    return $FeedingRemindersTable(attachedDatabase, alias);
  }
}

class FeedingReminderRow extends DataClass
    implements Insertable<FeedingReminderRow> {
  final int id;
  final int catId;
  final int slot;
  final int hour;
  final int minute;
  final bool enabled;
  const FeedingReminderRow({
    required this.id,
    required this.catId,
    required this.slot,
    required this.hour,
    required this.minute,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['slot'] = Variable<int>(slot);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  FeedingRemindersCompanion toCompanion(bool nullToAbsent) {
    return FeedingRemindersCompanion(
      id: Value(id),
      catId: Value(catId),
      slot: Value(slot),
      hour: Value(hour),
      minute: Value(minute),
      enabled: Value(enabled),
    );
  }

  factory FeedingReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingReminderRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      slot: serializer.fromJson<int>(json['slot']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'slot': serializer.toJson<int>(slot),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  FeedingReminderRow copyWith({
    int? id,
    int? catId,
    int? slot,
    int? hour,
    int? minute,
    bool? enabled,
  }) => FeedingReminderRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    slot: slot ?? this.slot,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    enabled: enabled ?? this.enabled,
  );
  FeedingReminderRow copyWithCompanion(FeedingRemindersCompanion data) {
    return FeedingReminderRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      slot: data.slot.present ? data.slot.value : this.slot,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingReminderRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('slot: $slot, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, catId, slot, hour, minute, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingReminderRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.slot == this.slot &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.enabled == this.enabled);
}

class FeedingRemindersCompanion extends UpdateCompanion<FeedingReminderRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<int> slot;
  final Value<int> hour;
  final Value<int> minute;
  final Value<bool> enabled;
  const FeedingRemindersCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.slot = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  FeedingRemindersCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required int slot,
    required int hour,
    required int minute,
    this.enabled = const Value.absent(),
  }) : catId = Value(catId),
       slot = Value(slot),
       hour = Value(hour),
       minute = Value(minute);
  static Insertable<FeedingReminderRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<int>? slot,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (slot != null) 'slot': slot,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (enabled != null) 'enabled': enabled,
    });
  }

  FeedingRemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<int>? slot,
    Value<int>? hour,
    Value<int>? minute,
    Value<bool>? enabled,
  }) {
    return FeedingRemindersCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      slot: slot ?? this.slot,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingRemindersCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('slot: $slot, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $CatConditionsTable extends CatConditions
    with TableInfo<$CatConditionsTable, CatConditionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatConditionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _diseaseIdMeta = const VerificationMeta(
    'diseaseId',
  );
  @override
  late final GeneratedColumn<String> diseaseId = GeneratedColumn<String>(
    'disease_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosedOnMeta = const VerificationMeta(
    'diagnosedOn',
  );
  @override
  late final GeneratedColumn<DateTime> diagnosedOn = GeneratedColumn<DateTime>(
    'diagnosed_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageLabelMeta = const VerificationMeta(
    'stageLabel',
  );
  @override
  late final GeneratedColumn<String> stageLabel = GeneratedColumn<String>(
    'stage_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nextRecheckMeta = const VerificationMeta(
    'nextRecheck',
  );
  @override
  late final GeneratedColumn<DateTime> nextRecheck = GeneratedColumn<DateTime>(
    'next_recheck',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    diseaseId,
    diagnosedOn,
    stageLabel,
    note,
    nextRecheck,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cat_conditions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatConditionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('disease_id')) {
      context.handle(
        _diseaseIdMeta,
        diseaseId.isAcceptableOrUnknown(data['disease_id']!, _diseaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_diseaseIdMeta);
    }
    if (data.containsKey('diagnosed_on')) {
      context.handle(
        _diagnosedOnMeta,
        diagnosedOn.isAcceptableOrUnknown(
          data['diagnosed_on']!,
          _diagnosedOnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diagnosedOnMeta);
    }
    if (data.containsKey('stage_label')) {
      context.handle(
        _stageLabelMeta,
        stageLabel.isAcceptableOrUnknown(data['stage_label']!, _stageLabelMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('next_recheck')) {
      context.handle(
        _nextRecheckMeta,
        nextRecheck.isAcceptableOrUnknown(
          data['next_recheck']!,
          _nextRecheckMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatConditionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatConditionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      diseaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disease_id'],
      )!,
      diagnosedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diagnosed_on'],
      )!,
      stageLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_label'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      nextRecheck: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_recheck'],
      ),
    );
  }

  @override
  $CatConditionsTable createAlias(String alias) {
    return $CatConditionsTable(attachedDatabase, alias);
  }
}

class CatConditionRow extends DataClass implements Insertable<CatConditionRow> {
  final int id;
  final int catId;
  final String diseaseId;
  final DateTime diagnosedOn;
  final String stageLabel;
  final String note;
  final DateTime? nextRecheck;
  const CatConditionRow({
    required this.id,
    required this.catId,
    required this.diseaseId,
    required this.diagnosedOn,
    required this.stageLabel,
    required this.note,
    this.nextRecheck,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['disease_id'] = Variable<String>(diseaseId);
    map['diagnosed_on'] = Variable<DateTime>(diagnosedOn);
    map['stage_label'] = Variable<String>(stageLabel);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || nextRecheck != null) {
      map['next_recheck'] = Variable<DateTime>(nextRecheck);
    }
    return map;
  }

  CatConditionsCompanion toCompanion(bool nullToAbsent) {
    return CatConditionsCompanion(
      id: Value(id),
      catId: Value(catId),
      diseaseId: Value(diseaseId),
      diagnosedOn: Value(diagnosedOn),
      stageLabel: Value(stageLabel),
      note: Value(note),
      nextRecheck: nextRecheck == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRecheck),
    );
  }

  factory CatConditionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatConditionRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      diseaseId: serializer.fromJson<String>(json['diseaseId']),
      diagnosedOn: serializer.fromJson<DateTime>(json['diagnosedOn']),
      stageLabel: serializer.fromJson<String>(json['stageLabel']),
      note: serializer.fromJson<String>(json['note']),
      nextRecheck: serializer.fromJson<DateTime?>(json['nextRecheck']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'diseaseId': serializer.toJson<String>(diseaseId),
      'diagnosedOn': serializer.toJson<DateTime>(diagnosedOn),
      'stageLabel': serializer.toJson<String>(stageLabel),
      'note': serializer.toJson<String>(note),
      'nextRecheck': serializer.toJson<DateTime?>(nextRecheck),
    };
  }

  CatConditionRow copyWith({
    int? id,
    int? catId,
    String? diseaseId,
    DateTime? diagnosedOn,
    String? stageLabel,
    String? note,
    Value<DateTime?> nextRecheck = const Value.absent(),
  }) => CatConditionRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    diseaseId: diseaseId ?? this.diseaseId,
    diagnosedOn: diagnosedOn ?? this.diagnosedOn,
    stageLabel: stageLabel ?? this.stageLabel,
    note: note ?? this.note,
    nextRecheck: nextRecheck.present ? nextRecheck.value : this.nextRecheck,
  );
  CatConditionRow copyWithCompanion(CatConditionsCompanion data) {
    return CatConditionRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      diseaseId: data.diseaseId.present ? data.diseaseId.value : this.diseaseId,
      diagnosedOn: data.diagnosedOn.present
          ? data.diagnosedOn.value
          : this.diagnosedOn,
      stageLabel: data.stageLabel.present
          ? data.stageLabel.value
          : this.stageLabel,
      note: data.note.present ? data.note.value : this.note,
      nextRecheck: data.nextRecheck.present
          ? data.nextRecheck.value
          : this.nextRecheck,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatConditionRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('diagnosedOn: $diagnosedOn, ')
          ..write('stageLabel: $stageLabel, ')
          ..write('note: $note, ')
          ..write('nextRecheck: $nextRecheck')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catId,
    diseaseId,
    diagnosedOn,
    stageLabel,
    note,
    nextRecheck,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatConditionRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.diseaseId == this.diseaseId &&
          other.diagnosedOn == this.diagnosedOn &&
          other.stageLabel == this.stageLabel &&
          other.note == this.note &&
          other.nextRecheck == this.nextRecheck);
}

class CatConditionsCompanion extends UpdateCompanion<CatConditionRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<String> diseaseId;
  final Value<DateTime> diagnosedOn;
  final Value<String> stageLabel;
  final Value<String> note;
  final Value<DateTime?> nextRecheck;
  const CatConditionsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.diseaseId = const Value.absent(),
    this.diagnosedOn = const Value.absent(),
    this.stageLabel = const Value.absent(),
    this.note = const Value.absent(),
    this.nextRecheck = const Value.absent(),
  });
  CatConditionsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required String diseaseId,
    required DateTime diagnosedOn,
    this.stageLabel = const Value.absent(),
    this.note = const Value.absent(),
    this.nextRecheck = const Value.absent(),
  }) : catId = Value(catId),
       diseaseId = Value(diseaseId),
       diagnosedOn = Value(diagnosedOn);
  static Insertable<CatConditionRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? diseaseId,
    Expression<DateTime>? diagnosedOn,
    Expression<String>? stageLabel,
    Expression<String>? note,
    Expression<DateTime>? nextRecheck,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (diseaseId != null) 'disease_id': diseaseId,
      if (diagnosedOn != null) 'diagnosed_on': diagnosedOn,
      if (stageLabel != null) 'stage_label': stageLabel,
      if (note != null) 'note': note,
      if (nextRecheck != null) 'next_recheck': nextRecheck,
    });
  }

  CatConditionsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<String>? diseaseId,
    Value<DateTime>? diagnosedOn,
    Value<String>? stageLabel,
    Value<String>? note,
    Value<DateTime?>? nextRecheck,
  }) {
    return CatConditionsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      diseaseId: diseaseId ?? this.diseaseId,
      diagnosedOn: diagnosedOn ?? this.diagnosedOn,
      stageLabel: stageLabel ?? this.stageLabel,
      note: note ?? this.note,
      nextRecheck: nextRecheck ?? this.nextRecheck,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (diseaseId.present) {
      map['disease_id'] = Variable<String>(diseaseId.value);
    }
    if (diagnosedOn.present) {
      map['diagnosed_on'] = Variable<DateTime>(diagnosedOn.value);
    }
    if (stageLabel.present) {
      map['stage_label'] = Variable<String>(stageLabel.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (nextRecheck.present) {
      map['next_recheck'] = Variable<DateTime>(nextRecheck.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatConditionsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('diseaseId: $diseaseId, ')
          ..write('diagnosedOn: $diagnosedOn, ')
          ..write('stageLabel: $stageLabel, ')
          ..write('note: $note, ')
          ..write('nextRecheck: $nextRecheck')
          ..write(')'))
        .toString();
  }
}

class $CheckupLogsTable extends CheckupLogs
    with TableInfo<$CheckupLogsTable, CheckupLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckupLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedOnMeta = const VerificationMeta(
    'completedOn',
  );
  @override
  late final GeneratedColumn<DateTime> completedOn = GeneratedColumn<DateTime>(
    'completed_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nextDueMeta = const VerificationMeta(
    'nextDue',
  );
  @override
  late final GeneratedColumn<DateTime> nextDue = GeneratedColumn<DateTime>(
    'next_due',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    itemId,
    completedOn,
    result,
    nextDue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkup_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckupLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('completed_on')) {
      context.handle(
        _completedOnMeta,
        completedOn.isAcceptableOrUnknown(
          data['completed_on']!,
          _completedOnMeta,
        ),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    }
    if (data.containsKey('next_due')) {
      context.handle(
        _nextDueMeta,
        nextDue.isAcceptableOrUnknown(data['next_due']!, _nextDueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckupLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckupLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      completedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_on'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      nextDue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due'],
      ),
    );
  }

  @override
  $CheckupLogsTable createAlias(String alias) {
    return $CheckupLogsTable(attachedDatabase, alias);
  }
}

class CheckupLogRow extends DataClass implements Insertable<CheckupLogRow> {
  final int id;
  final int catId;
  final String itemId;
  final DateTime? completedOn;
  final String result;
  final DateTime? nextDue;
  const CheckupLogRow({
    required this.id,
    required this.catId,
    required this.itemId,
    this.completedOn,
    required this.result,
    this.nextDue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || completedOn != null) {
      map['completed_on'] = Variable<DateTime>(completedOn);
    }
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || nextDue != null) {
      map['next_due'] = Variable<DateTime>(nextDue);
    }
    return map;
  }

  CheckupLogsCompanion toCompanion(bool nullToAbsent) {
    return CheckupLogsCompanion(
      id: Value(id),
      catId: Value(catId),
      itemId: Value(itemId),
      completedOn: completedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(completedOn),
      result: Value(result),
      nextDue: nextDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDue),
    );
  }

  factory CheckupLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckupLogRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      completedOn: serializer.fromJson<DateTime?>(json['completedOn']),
      result: serializer.fromJson<String>(json['result']),
      nextDue: serializer.fromJson<DateTime?>(json['nextDue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'itemId': serializer.toJson<String>(itemId),
      'completedOn': serializer.toJson<DateTime?>(completedOn),
      'result': serializer.toJson<String>(result),
      'nextDue': serializer.toJson<DateTime?>(nextDue),
    };
  }

  CheckupLogRow copyWith({
    int? id,
    int? catId,
    String? itemId,
    Value<DateTime?> completedOn = const Value.absent(),
    String? result,
    Value<DateTime?> nextDue = const Value.absent(),
  }) => CheckupLogRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    itemId: itemId ?? this.itemId,
    completedOn: completedOn.present ? completedOn.value : this.completedOn,
    result: result ?? this.result,
    nextDue: nextDue.present ? nextDue.value : this.nextDue,
  );
  CheckupLogRow copyWithCompanion(CheckupLogsCompanion data) {
    return CheckupLogRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      completedOn: data.completedOn.present
          ? data.completedOn.value
          : this.completedOn,
      result: data.result.present ? data.result.value : this.result,
      nextDue: data.nextDue.present ? data.nextDue.value : this.nextDue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckupLogRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('itemId: $itemId, ')
          ..write('completedOn: $completedOn, ')
          ..write('result: $result, ')
          ..write('nextDue: $nextDue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catId, itemId, completedOn, result, nextDue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckupLogRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.itemId == this.itemId &&
          other.completedOn == this.completedOn &&
          other.result == this.result &&
          other.nextDue == this.nextDue);
}

class CheckupLogsCompanion extends UpdateCompanion<CheckupLogRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<String> itemId;
  final Value<DateTime?> completedOn;
  final Value<String> result;
  final Value<DateTime?> nextDue;
  const CheckupLogsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.completedOn = const Value.absent(),
    this.result = const Value.absent(),
    this.nextDue = const Value.absent(),
  });
  CheckupLogsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required String itemId,
    this.completedOn = const Value.absent(),
    this.result = const Value.absent(),
    this.nextDue = const Value.absent(),
  }) : catId = Value(catId),
       itemId = Value(itemId);
  static Insertable<CheckupLogRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? itemId,
    Expression<DateTime>? completedOn,
    Expression<String>? result,
    Expression<DateTime>? nextDue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (itemId != null) 'item_id': itemId,
      if (completedOn != null) 'completed_on': completedOn,
      if (result != null) 'result': result,
      if (nextDue != null) 'next_due': nextDue,
    });
  }

  CheckupLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<String>? itemId,
    Value<DateTime?>? completedOn,
    Value<String>? result,
    Value<DateTime?>? nextDue,
  }) {
    return CheckupLogsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      itemId: itemId ?? this.itemId,
      completedOn: completedOn ?? this.completedOn,
      result: result ?? this.result,
      nextDue: nextDue ?? this.nextDue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (completedOn.present) {
      map['completed_on'] = Variable<DateTime>(completedOn.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (nextDue.present) {
      map['next_due'] = Variable<DateTime>(nextDue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckupLogsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('itemId: $itemId, ')
          ..write('completedOn: $completedOn, ')
          ..write('result: $result, ')
          ..write('nextDue: $nextDue')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _loggedOnMeta = const VerificationMeta(
    'loggedOn',
  );
  @override
  late final GeneratedColumn<DateTime> loggedOn = GeneratedColumn<DateTime>(
    'logged_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _millilitersMeta = const VerificationMeta(
    'milliliters',
  );
  @override
  late final GeneratedColumn<double> milliliters = GeneratedColumn<double>(
    'milliliters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, catId, loggedOn, milliliters];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('logged_on')) {
      context.handle(
        _loggedOnMeta,
        loggedOn.isAcceptableOrUnknown(data['logged_on']!, _loggedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedOnMeta);
    }
    if (data.containsKey('milliliters')) {
      context.handle(
        _millilitersMeta,
        milliliters.isAcceptableOrUnknown(
          data['milliliters']!,
          _millilitersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_millilitersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      loggedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_on'],
      )!,
      milliliters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}milliliters'],
      )!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLogRow extends DataClass implements Insertable<WaterLogRow> {
  final int id;
  final int catId;
  final DateTime loggedOn;
  final double milliliters;
  const WaterLogRow({
    required this.id,
    required this.catId,
    required this.loggedOn,
    required this.milliliters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    map['logged_on'] = Variable<DateTime>(loggedOn);
    map['milliliters'] = Variable<double>(milliliters);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      catId: Value(catId),
      loggedOn: Value(loggedOn),
      milliliters: Value(milliliters),
    );
  }

  factory WaterLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLogRow(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      loggedOn: serializer.fromJson<DateTime>(json['loggedOn']),
      milliliters: serializer.fromJson<double>(json['milliliters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'loggedOn': serializer.toJson<DateTime>(loggedOn),
      'milliliters': serializer.toJson<double>(milliliters),
    };
  }

  WaterLogRow copyWith({
    int? id,
    int? catId,
    DateTime? loggedOn,
    double? milliliters,
  }) => WaterLogRow(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    loggedOn: loggedOn ?? this.loggedOn,
    milliliters: milliliters ?? this.milliliters,
  );
  WaterLogRow copyWithCompanion(WaterLogsCompanion data) {
    return WaterLogRow(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      loggedOn: data.loggedOn.present ? data.loggedOn.value : this.loggedOn,
      milliliters: data.milliliters.present
          ? data.milliliters.value
          : this.milliliters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogRow(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('milliliters: $milliliters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, catId, loggedOn, milliliters);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLogRow &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.loggedOn == this.loggedOn &&
          other.milliliters == this.milliliters);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLogRow> {
  final Value<int> id;
  final Value<int> catId;
  final Value<DateTime> loggedOn;
  final Value<double> milliliters;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.loggedOn = const Value.absent(),
    this.milliliters = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required DateTime loggedOn,
    required double milliliters,
  }) : catId = Value(catId),
       loggedOn = Value(loggedOn),
       milliliters = Value(milliliters);
  static Insertable<WaterLogRow> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<DateTime>? loggedOn,
    Expression<double>? milliliters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (loggedOn != null) 'logged_on': loggedOn,
      if (milliliters != null) 'milliliters': milliliters,
    });
  }

  WaterLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<DateTime>? loggedOn,
    Value<double>? milliliters,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      loggedOn: loggedOn ?? this.loggedOn,
      milliliters: milliliters ?? this.milliliters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (loggedOn.present) {
      map['logged_on'] = Variable<DateTime>(loggedOn.value);
    }
    if (milliliters.present) {
      map['milliliters'] = Variable<double>(milliliters.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('milliliters: $milliliters')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(AppSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CatsTable cats = $CatsTable(this);
  late final $CatPhotosTable catPhotos = $CatPhotosTable(this);
  late final $VaccinesTable vaccines = $VaccinesTable(this);
  late final $DewormingsTable dewormings = $DewormingsTable(this);
  late final $VetVisitsTable vetVisits = $VetVisitsTable(this);
  late final $WeightLogsTable weightLogs = $WeightLogsTable(this);
  late final $HealthNotesTable healthNotes = $HealthNotesTable(this);
  late final $FoodProductsTable foodProducts = $FoodProductsTable(this);
  late final $FeedingLogsTable feedingLogs = $FeedingLogsTable(this);
  late final $FoodTransitionsTable foodTransitions = $FoodTransitionsTable(
    this,
  );
  late final $PantryItemsTable pantryItems = $PantryItemsTable(this);
  late final $FeedingRemindersTable feedingReminders = $FeedingRemindersTable(
    this,
  );
  late final $CatConditionsTable catConditions = $CatConditionsTable(this);
  late final $CheckupLogsTable checkupLogs = $CheckupLogsTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cats,
    catPhotos,
    vaccines,
    dewormings,
    vetVisits,
    weightLogs,
    healthNotes,
    foodProducts,
    feedingLogs,
    foodTransitions,
    pantryItems,
    feedingReminders,
    catConditions,
    checkupLogs,
    waterLogs,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cat_photos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vaccines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dewormings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vet_visits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('weight_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('health_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feeding_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'food_products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feeding_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('food_transitions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'food_products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pantry_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feeding_reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cat_conditions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('checkup_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('water_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CatsTableCreateCompanionBuilder = CatsCompanion Function({
  Value<int> id,
  required String name,
  required String sex,
  Value<DateTime?> birthday,
  Value<bool> neutered,
  Value<String> goal,
  Value<String?> coatColor,
  Value<String?> breed,
  Value<String?> avatarPath,
  Value<String> notes,
  Value<bool> isSample,
  Value<String?> recognitionSource,
  Value<double?> recognitionConfidence,
  Value<String?> recognitionDetail,
  required DateTime createdAt,
});
typedef $$CatsTableUpdateCompanionBuilder = CatsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> sex,
  Value<DateTime?> birthday,
  Value<bool> neutered,
  Value<String> goal,
  Value<String?> coatColor,
  Value<String?> breed,
  Value<String?> avatarPath,
  Value<String> notes,
  Value<bool> isSample,
  Value<String?> recognitionSource,
  Value<double?> recognitionConfidence,
  Value<String?> recognitionDetail,
  Value<DateTime> createdAt,
});

final class $$CatsTableReferences
    extends BaseReferences<_$AppDatabase, $CatsTable, CatRow> {
  $$CatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CatPhotosTable, List<CatPhotoRow>>
  _catPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catPhotos,
    aliasName: 'cats__id__cat_photos__cat_id',
  );

  $$CatPhotosTableProcessedTableManager get catPhotosRefs {
    final manager = $$CatPhotosTableTableManager(
      $_db,
      $_db.catPhotos,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_catPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VaccinesTable, List<VaccineRow>>
  _vaccinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vaccines,
    aliasName: 'cats__id__vaccines__cat_id',
  );

  $$VaccinesTableProcessedTableManager get vaccinesRefs {
    final manager = $$VaccinesTableTableManager(
      $_db,
      $_db.vaccines,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vaccinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DewormingsTable, List<DewormRow>>
  _dewormingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dewormings,
    aliasName: 'cats__id__dewormings__cat_id',
  );

  $$DewormingsTableProcessedTableManager get dewormingsRefs {
    final manager = $$DewormingsTableTableManager(
      $_db,
      $_db.dewormings,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dewormingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VetVisitsTable, List<VetVisitRow>>
  _vetVisitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vetVisits,
    aliasName: 'cats__id__vet_visits__cat_id',
  );

  $$VetVisitsTableProcessedTableManager get vetVisitsRefs {
    final manager = $$VetVisitsTableTableManager(
      $_db,
      $_db.vetVisits,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vetVisitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WeightLogsTable, List<WeightRow>>
  _weightLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.weightLogs,
    aliasName: 'cats__id__weight_logs__cat_id',
  );

  $$WeightLogsTableProcessedTableManager get weightLogsRefs {
    final manager = $$WeightLogsTableTableManager(
      $_db,
      $_db.weightLogs,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weightLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HealthNotesTable, List<HealthNoteRow>>
  _healthNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.healthNotes,
    aliasName: 'cats__id__health_notes__cat_id',
  );

  $$HealthNotesTableProcessedTableManager get healthNotesRefs {
    final manager = $$HealthNotesTableTableManager(
      $_db,
      $_db.healthNotes,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_healthNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeedingLogsTable, List<FeedingRow>>
  _feedingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedingLogs,
    aliasName: 'cats__id__feeding_logs__cat_id',
  );

  $$FeedingLogsTableProcessedTableManager get feedingLogsRefs {
    final manager = $$FeedingLogsTableTableManager(
      $_db,
      $_db.feedingLogs,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedingLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FoodTransitionsTable, List<TransitionRow>>
  _foodTransitionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.foodTransitions,
    aliasName: 'cats__id__food_transitions__cat_id',
  );

  $$FoodTransitionsTableProcessedTableManager get foodTransitionsRefs {
    final manager = $$FoodTransitionsTableTableManager(
      $_db,
      $_db.foodTransitions,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _foodTransitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FeedingRemindersTable, List<FeedingReminderRow>>
  _feedingRemindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedingReminders,
    aliasName: 'cats__id__feeding_reminders__cat_id',
  );

  $$FeedingRemindersTableProcessedTableManager get feedingRemindersRefs {
    final manager = $$FeedingRemindersTableTableManager(
      $_db,
      $_db.feedingReminders,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _feedingRemindersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CatConditionsTable, List<CatConditionRow>>
  _catConditionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catConditions,
    aliasName: 'cats__id__cat_conditions__cat_id',
  );

  $$CatConditionsTableProcessedTableManager get catConditionsRefs {
    final manager = $$CatConditionsTableTableManager(
      $_db,
      $_db.catConditions,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_catConditionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CheckupLogsTable, List<CheckupLogRow>>
  _checkupLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checkupLogs,
    aliasName: 'cats__id__checkup_logs__cat_id',
  );

  $$CheckupLogsTableProcessedTableManager get checkupLogsRefs {
    final manager = $$CheckupLogsTableTableManager(
      $_db,
      $_db.checkupLogs,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkupLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WaterLogsTable, List<WaterLogRow>>
  _waterLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.waterLogs,
    aliasName: 'cats__id__water_logs__cat_id',
  );

  $$WaterLogsTableProcessedTableManager get waterLogsRefs {
    final manager = $$WaterLogsTableTableManager(
      $_db,
      $_db.waterLogs,
    ).filter((f) => f.catId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_waterLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatsTableFilterComposer extends Composer<_$AppDatabase, $CatsTable> {
  $$CatsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get neutered => $composableBuilder(
    column: $table.neutered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coatColor => $composableBuilder(
    column: $table.coatColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recognitionSource => $composableBuilder(
    column: $table.recognitionSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recognitionConfidence => $composableBuilder(
    column: $table.recognitionConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recognitionDetail => $composableBuilder(
    column: $table.recognitionDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> catPhotosRefs(
    Expression<bool> Function($$CatPhotosTableFilterComposer f) f,
  ) {
    final $$CatPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catPhotos,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatPhotosTableFilterComposer(
            $db: $db,
            $table: $db.catPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vaccinesRefs(
    Expression<bool> Function($$VaccinesTableFilterComposer f) f,
  ) {
    final $$VaccinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vaccines,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaccinesTableFilterComposer(
            $db: $db,
            $table: $db.vaccines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dewormingsRefs(
    Expression<bool> Function($$DewormingsTableFilterComposer f) f,
  ) {
    final $$DewormingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dewormings,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DewormingsTableFilterComposer(
            $db: $db,
            $table: $db.dewormings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vetVisitsRefs(
    Expression<bool> Function($$VetVisitsTableFilterComposer f) f,
  ) {
    final $$VetVisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vetVisits,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VetVisitsTableFilterComposer(
            $db: $db,
            $table: $db.vetVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> weightLogsRefs(
    Expression<bool> Function($$WeightLogsTableFilterComposer f) f,
  ) {
    final $$WeightLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weightLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeightLogsTableFilterComposer(
            $db: $db,
            $table: $db.weightLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> healthNotesRefs(
    Expression<bool> Function($$HealthNotesTableFilterComposer f) f,
  ) {
    final $$HealthNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.healthNotes,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HealthNotesTableFilterComposer(
            $db: $db,
            $table: $db.healthNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feedingLogsRefs(
    Expression<bool> Function($$FeedingLogsTableFilterComposer f) f,
  ) {
    final $$FeedingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingLogsTableFilterComposer(
            $db: $db,
            $table: $db.feedingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> foodTransitionsRefs(
    Expression<bool> Function($$FoodTransitionsTableFilterComposer f) f,
  ) {
    final $$FoodTransitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foodTransitions,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodTransitionsTableFilterComposer(
            $db: $db,
            $table: $db.foodTransitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> feedingRemindersRefs(
    Expression<bool> Function($$FeedingRemindersTableFilterComposer f) f,
  ) {
    final $$FeedingRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingReminders,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingRemindersTableFilterComposer(
            $db: $db,
            $table: $db.feedingReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> catConditionsRefs(
    Expression<bool> Function($$CatConditionsTableFilterComposer f) f,
  ) {
    final $$CatConditionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catConditions,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatConditionsTableFilterComposer(
            $db: $db,
            $table: $db.catConditions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> checkupLogsRefs(
    Expression<bool> Function($$CheckupLogsTableFilterComposer f) f,
  ) {
    final $$CheckupLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkupLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckupLogsTableFilterComposer(
            $db: $db,
            $table: $db.checkupLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> waterLogsRefs(
    Expression<bool> Function($$WaterLogsTableFilterComposer f) f,
  ) {
    final $$WaterLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.waterLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterLogsTableFilterComposer(
            $db: $db,
            $table: $db.waterLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatsTableOrderingComposer extends Composer<_$AppDatabase, $CatsTable> {
  $$CatsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get neutered => $composableBuilder(
    column: $table.neutered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coatColor => $composableBuilder(
    column: $table.coatColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recognitionSource => $composableBuilder(
    column: $table.recognitionSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recognitionConfidence => $composableBuilder(
    column: $table.recognitionConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recognitionDetail => $composableBuilder(
    column: $table.recognitionDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatsTable> {
  $$CatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<bool> get neutered =>
      $composableBuilder(column: $table.neutered, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get coatColor =>
      $composableBuilder(column: $table.coatColor, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSample =>
      $composableBuilder(column: $table.isSample, builder: (column) => column);

  GeneratedColumn<String> get recognitionSource => $composableBuilder(
    column: $table.recognitionSource,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recognitionConfidence => $composableBuilder(
    column: $table.recognitionConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recognitionDetail => $composableBuilder(
    column: $table.recognitionDetail,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> catPhotosRefs<T extends Object>(
    Expression<T> Function($$CatPhotosTableAnnotationComposer a) f,
  ) {
    final $$CatPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catPhotos,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.catPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vaccinesRefs<T extends Object>(
    Expression<T> Function($$VaccinesTableAnnotationComposer a) f,
  ) {
    final $$VaccinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vaccines,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaccinesTableAnnotationComposer(
            $db: $db,
            $table: $db.vaccines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dewormingsRefs<T extends Object>(
    Expression<T> Function($$DewormingsTableAnnotationComposer a) f,
  ) {
    final $$DewormingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dewormings,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DewormingsTableAnnotationComposer(
            $db: $db,
            $table: $db.dewormings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vetVisitsRefs<T extends Object>(
    Expression<T> Function($$VetVisitsTableAnnotationComposer a) f,
  ) {
    final $$VetVisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vetVisits,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VetVisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.vetVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> weightLogsRefs<T extends Object>(
    Expression<T> Function($$WeightLogsTableAnnotationComposer a) f,
  ) {
    final $$WeightLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weightLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeightLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.weightLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> healthNotesRefs<T extends Object>(
    Expression<T> Function($$HealthNotesTableAnnotationComposer a) f,
  ) {
    final $$HealthNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.healthNotes,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HealthNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.healthNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feedingLogsRefs<T extends Object>(
    Expression<T> Function($$FeedingLogsTableAnnotationComposer a) f,
  ) {
    final $$FeedingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.feedingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> foodTransitionsRefs<T extends Object>(
    Expression<T> Function($$FoodTransitionsTableAnnotationComposer a) f,
  ) {
    final $$FoodTransitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foodTransitions,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodTransitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.foodTransitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> feedingRemindersRefs<T extends Object>(
    Expression<T> Function($$FeedingRemindersTableAnnotationComposer a) f,
  ) {
    final $$FeedingRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingReminders,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.feedingReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> catConditionsRefs<T extends Object>(
    Expression<T> Function($$CatConditionsTableAnnotationComposer a) f,
  ) {
    final $$CatConditionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catConditions,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatConditionsTableAnnotationComposer(
            $db: $db,
            $table: $db.catConditions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> checkupLogsRefs<T extends Object>(
    Expression<T> Function($$CheckupLogsTableAnnotationComposer a) f,
  ) {
    final $$CheckupLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkupLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckupLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkupLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> waterLogsRefs<T extends Object>(
    Expression<T> Function($$WaterLogsTableAnnotationComposer a) f,
  ) {
    final $$WaterLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.waterLogs,
      getReferencedColumn: (t) => t.catId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.waterLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatsTable,
          CatRow,
          $$CatsTableFilterComposer,
          $$CatsTableOrderingComposer,
          $$CatsTableAnnotationComposer,
          $$CatsTableCreateCompanionBuilder,
          $$CatsTableUpdateCompanionBuilder,
          (CatRow, $$CatsTableReferences),
          CatRow,
          PrefetchHooks Function({
            bool catPhotosRefs,
            bool vaccinesRefs,
            bool dewormingsRefs,
            bool vetVisitsRefs,
            bool weightLogsRefs,
            bool healthNotesRefs,
            bool feedingLogsRefs,
            bool foodTransitionsRefs,
            bool feedingRemindersRefs,
            bool catConditionsRefs,
            bool checkupLogsRefs,
            bool waterLogsRefs,
          })
        > {
  $$CatsTableTableManager(_$AppDatabase db, $CatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<DateTime?> birthday = const Value.absent(),
                Value<bool> neutered = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String?> coatColor = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isSample = const Value.absent(),
                Value<String?> recognitionSource = const Value.absent(),
                Value<double?> recognitionConfidence = const Value.absent(),
                Value<String?> recognitionDetail = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CatsCompanion(
                id: id,
                name: name,
                sex: sex,
                birthday: birthday,
                neutered: neutered,
                goal: goal,
                coatColor: coatColor,
                breed: breed,
                avatarPath: avatarPath,
                notes: notes,
                isSample: isSample,
                recognitionSource: recognitionSource,
                recognitionConfidence: recognitionConfidence,
                recognitionDetail: recognitionDetail,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String sex,
                Value<DateTime?> birthday = const Value.absent(),
                Value<bool> neutered = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String?> coatColor = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isSample = const Value.absent(),
                Value<String?> recognitionSource = const Value.absent(),
                Value<double?> recognitionConfidence = const Value.absent(),
                Value<String?> recognitionDetail = const Value.absent(),
                required DateTime createdAt,
              }) => CatsCompanion.insert(
                id: id,
                name: name,
                sex: sex,
                birthday: birthday,
                neutered: neutered,
                goal: goal,
                coatColor: coatColor,
                breed: breed,
                avatarPath: avatarPath,
                notes: notes,
                isSample: isSample,
                recognitionSource: recognitionSource,
                recognitionConfidence: recognitionConfidence,
                recognitionDetail: recognitionDetail,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatsTable, CatRow>(table),
                  $$CatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                catPhotosRefs = false,
                vaccinesRefs = false,
                dewormingsRefs = false,
                vetVisitsRefs = false,
                weightLogsRefs = false,
                healthNotesRefs = false,
                feedingLogsRefs = false,
                foodTransitionsRefs = false,
                feedingRemindersRefs = false,
                catConditionsRefs = false,
                checkupLogsRefs = false,
                waterLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (catPhotosRefs) db.catPhotos,
                    if (vaccinesRefs) db.vaccines,
                    if (dewormingsRefs) db.dewormings,
                    if (vetVisitsRefs) db.vetVisits,
                    if (weightLogsRefs) db.weightLogs,
                    if (healthNotesRefs) db.healthNotes,
                    if (feedingLogsRefs) db.feedingLogs,
                    if (foodTransitionsRefs) db.foodTransitions,
                    if (feedingRemindersRefs) db.feedingReminders,
                    if (catConditionsRefs) db.catConditions,
                    if (checkupLogsRefs) db.checkupLogs,
                    if (waterLogsRefs) db.waterLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (catPhotosRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          CatPhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._catPhotosRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).catPhotosRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (vaccinesRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          VaccineRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._vaccinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatsTableReferences(db, table, p0).vaccinesRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (dewormingsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          DewormRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._dewormingsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).dewormingsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (vetVisitsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          VetVisitRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._vetVisitsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).vetVisitsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (weightLogsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          WeightRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._weightLogsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).weightLogsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (healthNotesRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          HealthNoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._healthNotesRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).healthNotesRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (feedingLogsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          FeedingRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._feedingLogsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).feedingLogsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (foodTransitionsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          TransitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._foodTransitionsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).foodTransitionsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (feedingRemindersRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          FeedingReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._feedingRemindersRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).feedingRemindersRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (catConditionsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          CatConditionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._catConditionsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).catConditionsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (checkupLogsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          CheckupLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._checkupLogsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).checkupLogsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                      if (waterLogsRefs)
                        await $_getPrefetchedData<
                          CatRow,
                          $CatsTable,
                          WaterLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatsTableReferences
                              ._waterLogsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CatsTableReferences(
                            db,
                            table,
                            p0,
                          ).waterLogsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.catId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatsTable,
      CatRow,
      $$CatsTableFilterComposer,
      $$CatsTableOrderingComposer,
      $$CatsTableAnnotationComposer,
      $$CatsTableCreateCompanionBuilder,
      $$CatsTableUpdateCompanionBuilder,
      (CatRow, $$CatsTableReferences),
      CatRow,
      PrefetchHooks Function({
        bool catPhotosRefs,
        bool vaccinesRefs,
        bool dewormingsRefs,
        bool vetVisitsRefs,
        bool weightLogsRefs,
        bool healthNotesRefs,
        bool feedingLogsRefs,
        bool foodTransitionsRefs,
        bool feedingRemindersRefs,
        bool catConditionsRefs,
        bool checkupLogsRefs,
        bool waterLogsRefs,
      })
    >;
typedef $$CatPhotosTableCreateCompanionBuilder = CatPhotosCompanion Function({
  Value<int> id,
  required int catId,
  required String path,
  required DateTime takenAt,
  Value<double?> weightKg,
  Value<String> note,
});
typedef $$CatPhotosTableUpdateCompanionBuilder = CatPhotosCompanion Function({
  Value<int> id,
  Value<int> catId,
  Value<String> path,
  Value<DateTime> takenAt,
  Value<double?> weightKg,
  Value<String> note,
});

final class $$CatPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $CatPhotosTable, CatPhotoRow> {
  $$CatPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('cat_photos__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CatPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $CatPhotosTable> {
  $$CatPhotosTableFilterComposer({
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $CatPhotosTable> {
  $$CatPhotosTableOrderingComposer({
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatPhotosTable> {
  $$CatPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatPhotosTable,
          CatPhotoRow,
          $$CatPhotosTableFilterComposer,
          $$CatPhotosTableOrderingComposer,
          $$CatPhotosTableAnnotationComposer,
          $$CatPhotosTableCreateCompanionBuilder,
          $$CatPhotosTableUpdateCompanionBuilder,
          (CatPhotoRow, $$CatPhotosTableReferences),
          CatPhotoRow,
          PrefetchHooks Function({bool catId})
        > {
  $$CatPhotosTableTableManager(_$AppDatabase db, $CatPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => CatPhotosCompanion(
                id: id,
                catId: catId,
                path: path,
                takenAt: takenAt,
                weightKg: weightKg,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required String path,
                required DateTime takenAt,
                Value<double?> weightKg = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => CatPhotosCompanion.insert(
                id: id,
                catId: catId,
                path: path,
                takenAt: takenAt,
                weightKg: weightKg,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatPhotosTable, CatPhotoRow>(table),
                  $$CatPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$CatPhotosTableReferences._catIdTable(
                          db,
                        ),
                        referencedColumn: $$CatPhotosTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CatPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatPhotosTable,
      CatPhotoRow,
      $$CatPhotosTableFilterComposer,
      $$CatPhotosTableOrderingComposer,
      $$CatPhotosTableAnnotationComposer,
      $$CatPhotosTableCreateCompanionBuilder,
      $$CatPhotosTableUpdateCompanionBuilder,
      (CatPhotoRow, $$CatPhotosTableReferences),
      CatPhotoRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$VaccinesTableCreateCompanionBuilder = VaccinesCompanion Function({
  Value<int> id,
  required int catId,
  required String name,
  required DateTime givenOn,
  Value<DateTime?> nextDue,
  Value<String?> clinic,
  Value<String> notes,
});
typedef $$VaccinesTableUpdateCompanionBuilder = VaccinesCompanion Function({
  Value<int> id,
  Value<int> catId,
  Value<String> name,
  Value<DateTime> givenOn,
  Value<DateTime?> nextDue,
  Value<String?> clinic,
  Value<String> notes,
});

final class $$VaccinesTableReferences
    extends BaseReferences<_$AppDatabase, $VaccinesTable, VaccineRow> {
  $$VaccinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('vaccines__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VaccinesTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinesTable> {
  $$VaccinesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get givenOn => $composableBuilder(
    column: $table.givenOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDue => $composableBuilder(
    column: $table.nextDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VaccinesTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinesTable> {
  $$VaccinesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get givenOn => $composableBuilder(
    column: $table.givenOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDue => $composableBuilder(
    column: $table.nextDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VaccinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinesTable> {
  $$VaccinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get givenOn =>
      $composableBuilder(column: $table.givenOn, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDue =>
      $composableBuilder(column: $table.nextDue, builder: (column) => column);

  GeneratedColumn<String> get clinic =>
      $composableBuilder(column: $table.clinic, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VaccinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaccinesTable,
          VaccineRow,
          $$VaccinesTableFilterComposer,
          $$VaccinesTableOrderingComposer,
          $$VaccinesTableAnnotationComposer,
          $$VaccinesTableCreateCompanionBuilder,
          $$VaccinesTableUpdateCompanionBuilder,
          (VaccineRow, $$VaccinesTableReferences),
          VaccineRow,
          PrefetchHooks Function({bool catId})
        > {
  $$VaccinesTableTableManager(_$AppDatabase db, $VaccinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> givenOn = const Value.absent(),
                Value<DateTime?> nextDue = const Value.absent(),
                Value<String?> clinic = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => VaccinesCompanion(
                id: id,
                catId: catId,
                name: name,
                givenOn: givenOn,
                nextDue: nextDue,
                clinic: clinic,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required String name,
                required DateTime givenOn,
                Value<DateTime?> nextDue = const Value.absent(),
                Value<String?> clinic = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => VaccinesCompanion.insert(
                id: id,
                catId: catId,
                name: name,
                givenOn: givenOn,
                nextDue: nextDue,
                clinic: clinic,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VaccinesTable, VaccineRow>(table),
                  $$VaccinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$VaccinesTableReferences._catIdTable(
                          db,
                        ),
                        referencedColumn: $$VaccinesTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$VaccinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaccinesTable,
      VaccineRow,
      $$VaccinesTableFilterComposer,
      $$VaccinesTableOrderingComposer,
      $$VaccinesTableAnnotationComposer,
      $$VaccinesTableCreateCompanionBuilder,
      $$VaccinesTableUpdateCompanionBuilder,
      (VaccineRow, $$VaccinesTableReferences),
      VaccineRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$DewormingsTableCreateCompanionBuilder = DewormingsCompanion Function({
  Value<int> id,
  required int catId,
  required String kind,
  required String product,
  required DateTime givenOn,
  Value<DateTime?> nextDue,
  Value<String> notes,
});
typedef $$DewormingsTableUpdateCompanionBuilder = DewormingsCompanion Function({
  Value<int> id,
  Value<int> catId,
  Value<String> kind,
  Value<String> product,
  Value<DateTime> givenOn,
  Value<DateTime?> nextDue,
  Value<String> notes,
});

final class $$DewormingsTableReferences
    extends BaseReferences<_$AppDatabase, $DewormingsTable, DewormRow> {
  $$DewormingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('dewormings__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DewormingsTableFilterComposer
    extends Composer<_$AppDatabase, $DewormingsTable> {
  $$DewormingsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get givenOn => $composableBuilder(
    column: $table.givenOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDue => $composableBuilder(
    column: $table.nextDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DewormingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DewormingsTable> {
  $$DewormingsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get product => $composableBuilder(
    column: $table.product,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get givenOn => $composableBuilder(
    column: $table.givenOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDue => $composableBuilder(
    column: $table.nextDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DewormingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DewormingsTable> {
  $$DewormingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get product =>
      $composableBuilder(column: $table.product, builder: (column) => column);

  GeneratedColumn<DateTime> get givenOn =>
      $composableBuilder(column: $table.givenOn, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDue =>
      $composableBuilder(column: $table.nextDue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DewormingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DewormingsTable,
          DewormRow,
          $$DewormingsTableFilterComposer,
          $$DewormingsTableOrderingComposer,
          $$DewormingsTableAnnotationComposer,
          $$DewormingsTableCreateCompanionBuilder,
          $$DewormingsTableUpdateCompanionBuilder,
          (DewormRow, $$DewormingsTableReferences),
          DewormRow,
          PrefetchHooks Function({bool catId})
        > {
  $$DewormingsTableTableManager(_$AppDatabase db, $DewormingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DewormingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DewormingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DewormingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> product = const Value.absent(),
                Value<DateTime> givenOn = const Value.absent(),
                Value<DateTime?> nextDue = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => DewormingsCompanion(
                id: id,
                catId: catId,
                kind: kind,
                product: product,
                givenOn: givenOn,
                nextDue: nextDue,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required String kind,
                required String product,
                required DateTime givenOn,
                Value<DateTime?> nextDue = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => DewormingsCompanion.insert(
                id: id,
                catId: catId,
                kind: kind,
                product: product,
                givenOn: givenOn,
                nextDue: nextDue,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DewormingsTable, DewormRow>(table),
                  $$DewormingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$DewormingsTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$DewormingsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$DewormingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DewormingsTable,
      DewormRow,
      $$DewormingsTableFilterComposer,
      $$DewormingsTableOrderingComposer,
      $$DewormingsTableAnnotationComposer,
      $$DewormingsTableCreateCompanionBuilder,
      $$DewormingsTableUpdateCompanionBuilder,
      (DewormRow, $$DewormingsTableReferences),
      DewormRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$VetVisitsTableCreateCompanionBuilder = VetVisitsCompanion Function({
  Value<int> id,
  required int catId,
  required DateTime visitedOn,
  Value<String?> clinic,
  required String reason,
  Value<String?> diagnosis,
  Value<String?> treatment,
  Value<String> notes,
});
typedef $$VetVisitsTableUpdateCompanionBuilder = VetVisitsCompanion Function({
  Value<int> id,
  Value<int> catId,
  Value<DateTime> visitedOn,
  Value<String?> clinic,
  Value<String> reason,
  Value<String?> diagnosis,
  Value<String?> treatment,
  Value<String> notes,
});

final class $$VetVisitsTableReferences
    extends BaseReferences<_$AppDatabase, $VetVisitsTable, VetVisitRow> {
  $$VetVisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('vet_visits__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VetVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VetVisitsTable> {
  $$VetVisitsTableFilterComposer({
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

  ColumnFilters<DateTime> get visitedOn => $composableBuilder(
    column: $table.visitedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VetVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VetVisitsTable> {
  $$VetVisitsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get visitedOn => $composableBuilder(
    column: $table.visitedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosis => $composableBuilder(
    column: $table.diagnosis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VetVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VetVisitsTable> {
  $$VetVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedOn =>
      $composableBuilder(column: $table.visitedOn, builder: (column) => column);

  GeneratedColumn<String> get clinic =>
      $composableBuilder(column: $table.clinic, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get treatment =>
      $composableBuilder(column: $table.treatment, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VetVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VetVisitsTable,
          VetVisitRow,
          $$VetVisitsTableFilterComposer,
          $$VetVisitsTableOrderingComposer,
          $$VetVisitsTableAnnotationComposer,
          $$VetVisitsTableCreateCompanionBuilder,
          $$VetVisitsTableUpdateCompanionBuilder,
          (VetVisitRow, $$VetVisitsTableReferences),
          VetVisitRow,
          PrefetchHooks Function({bool catId})
        > {
  $$VetVisitsTableTableManager(_$AppDatabase db, $VetVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VetVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VetVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VetVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<DateTime> visitedOn = const Value.absent(),
                Value<String?> clinic = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> diagnosis = const Value.absent(),
                Value<String?> treatment = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => VetVisitsCompanion(
                id: id,
                catId: catId,
                visitedOn: visitedOn,
                clinic: clinic,
                reason: reason,
                diagnosis: diagnosis,
                treatment: treatment,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required DateTime visitedOn,
                Value<String?> clinic = const Value.absent(),
                required String reason,
                Value<String?> diagnosis = const Value.absent(),
                Value<String?> treatment = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => VetVisitsCompanion.insert(
                id: id,
                catId: catId,
                visitedOn: visitedOn,
                clinic: clinic,
                reason: reason,
                diagnosis: diagnosis,
                treatment: treatment,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VetVisitsTable, VetVisitRow>(table),
                  $$VetVisitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$VetVisitsTableReferences._catIdTable(
                          db,
                        ),
                        referencedColumn: $$VetVisitsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$VetVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VetVisitsTable,
      VetVisitRow,
      $$VetVisitsTableFilterComposer,
      $$VetVisitsTableOrderingComposer,
      $$VetVisitsTableAnnotationComposer,
      $$VetVisitsTableCreateCompanionBuilder,
      $$VetVisitsTableUpdateCompanionBuilder,
      (VetVisitRow, $$VetVisitsTableReferences),
      VetVisitRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$WeightLogsTableCreateCompanionBuilder = WeightLogsCompanion Function({
  Value<int> id,
  required int catId,
  required DateTime loggedOn,
  required double weightKg,
});
typedef $$WeightLogsTableUpdateCompanionBuilder = WeightLogsCompanion Function({
  Value<int> id,
  Value<int> catId,
  Value<DateTime> loggedOn,
  Value<double> weightKg,
});

final class $$WeightLogsTableReferences
    extends BaseReferences<_$AppDatabase, $WeightLogsTable, WeightRow> {
  $$WeightLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('weight_logs__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WeightLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeightLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeightLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedOn =>
      $composableBuilder(column: $table.loggedOn, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeightLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightLogsTable,
          WeightRow,
          $$WeightLogsTableFilterComposer,
          $$WeightLogsTableOrderingComposer,
          $$WeightLogsTableAnnotationComposer,
          $$WeightLogsTableCreateCompanionBuilder,
          $$WeightLogsTableUpdateCompanionBuilder,
          (WeightRow, $$WeightLogsTableReferences),
          WeightRow,
          PrefetchHooks Function({bool catId})
        > {
  $$WeightLogsTableTableManager(_$AppDatabase db, $WeightLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<DateTime> loggedOn = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
              }) => WeightLogsCompanion(
                id: id,
                catId: catId,
                loggedOn: loggedOn,
                weightKg: weightKg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required DateTime loggedOn,
                required double weightKg,
              }) => WeightLogsCompanion.insert(
                id: id,
                catId: catId,
                loggedOn: loggedOn,
                weightKg: weightKg,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeightLogsTable, WeightRow>(table),
                  $$WeightLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$WeightLogsTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$WeightLogsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$WeightLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightLogsTable,
      WeightRow,
      $$WeightLogsTableFilterComposer,
      $$WeightLogsTableOrderingComposer,
      $$WeightLogsTableAnnotationComposer,
      $$WeightLogsTableCreateCompanionBuilder,
      $$WeightLogsTableUpdateCompanionBuilder,
      (WeightRow, $$WeightLogsTableReferences),
      WeightRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$HealthNotesTableCreateCompanionBuilder =
    HealthNotesCompanion Function({
      Value<int> id,
      required int catId,
      required DateTime notedOn,
      required String content,
    });
typedef $$HealthNotesTableUpdateCompanionBuilder =
    HealthNotesCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<DateTime> notedOn,
      Value<String> content,
    });

final class $$HealthNotesTableReferences
    extends BaseReferences<_$AppDatabase, $HealthNotesTable, HealthNoteRow> {
  $$HealthNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('health_notes__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HealthNotesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthNotesTable> {
  $$HealthNotesTableFilterComposer({
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

  ColumnFilters<DateTime> get notedOn => $composableBuilder(
    column: $table.notedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthNotesTable> {
  $$HealthNotesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get notedOn => $composableBuilder(
    column: $table.notedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthNotesTable> {
  $$HealthNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get notedOn =>
      $composableBuilder(column: $table.notedOn, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HealthNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthNotesTable,
          HealthNoteRow,
          $$HealthNotesTableFilterComposer,
          $$HealthNotesTableOrderingComposer,
          $$HealthNotesTableAnnotationComposer,
          $$HealthNotesTableCreateCompanionBuilder,
          $$HealthNotesTableUpdateCompanionBuilder,
          (HealthNoteRow, $$HealthNotesTableReferences),
          HealthNoteRow,
          PrefetchHooks Function({bool catId})
        > {
  $$HealthNotesTableTableManager(_$AppDatabase db, $HealthNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<DateTime> notedOn = const Value.absent(),
                Value<String> content = const Value.absent(),
              }) => HealthNotesCompanion(
                id: id,
                catId: catId,
                notedOn: notedOn,
                content: content,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required DateTime notedOn,
                required String content,
              }) => HealthNotesCompanion.insert(
                id: id,
                catId: catId,
                notedOn: notedOn,
                content: content,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HealthNotesTable, HealthNoteRow>(table),
                  $$HealthNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$HealthNotesTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$HealthNotesTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$HealthNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthNotesTable,
      HealthNoteRow,
      $$HealthNotesTableFilterComposer,
      $$HealthNotesTableOrderingComposer,
      $$HealthNotesTableAnnotationComposer,
      $$HealthNotesTableCreateCompanionBuilder,
      $$HealthNotesTableUpdateCompanionBuilder,
      (HealthNoteRow, $$HealthNotesTableReferences),
      HealthNoteRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$FoodProductsTableCreateCompanionBuilder =
    FoodProductsCompanion Function({
      Value<int> id,
      Value<String?> barcode,
      required String brand,
      required String name,
      required String spec,
      required String foodForm,
      Value<double?> kcalPer100g,
      required String storageMethod,
      required int afterOpenDays,
      Value<bool> isSample,
    });
typedef $$FoodProductsTableUpdateCompanionBuilder =
    FoodProductsCompanion Function({
      Value<int> id,
      Value<String?> barcode,
      Value<String> brand,
      Value<String> name,
      Value<String> spec,
      Value<String> foodForm,
      Value<double?> kcalPer100g,
      Value<String> storageMethod,
      Value<int> afterOpenDays,
      Value<bool> isSample,
    });

final class $$FoodProductsTableReferences
    extends BaseReferences<_$AppDatabase, $FoodProductsTable, FoodProductRow> {
  $$FoodProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FeedingLogsTable, List<FeedingRow>>
  _feedingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedingLogs,
    aliasName: 'food_products__id__feeding_logs__product_id',
  );

  $$FeedingLogsTableProcessedTableManager get feedingLogsRefs {
    final manager = $$FeedingLogsTableTableManager(
      $_db,
      $_db.feedingLogs,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedingLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PantryItemsTable, List<PantryRow>>
  _pantryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pantryItems,
    aliasName: 'food_products__id__pantry_items__product_id',
  );

  $$PantryItemsTableProcessedTableManager get pantryItemsRefs {
    final manager = $$PantryItemsTableTableManager(
      $_db,
      $_db.pantryItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pantryItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodProductsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableFilterComposer({
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

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spec => $composableBuilder(
    column: $table.spec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodForm => $composableBuilder(
    column: $table.foodForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageMethod => $composableBuilder(
    column: $table.storageMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> feedingLogsRefs(
    Expression<bool> Function($$FeedingLogsTableFilterComposer f) f,
  ) {
    final $$FeedingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingLogs,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingLogsTableFilterComposer(
            $db: $db,
            $table: $db.feedingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pantryItemsRefs(
    Expression<bool> Function($$PantryItemsTableFilterComposer f) f,
  ) {
    final $$PantryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pantryItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PantryItemsTableFilterComposer(
            $db: $db,
            $table: $db.pantryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableOrderingComposer({
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

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spec => $composableBuilder(
    column: $table.spec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodForm => $composableBuilder(
    column: $table.foodForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageMethod => $composableBuilder(
    column: $table.storageMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSample => $composableBuilder(
    column: $table.isSample,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get spec =>
      $composableBuilder(column: $table.spec, builder: (column) => column);

  GeneratedColumn<String> get foodForm =>
      $composableBuilder(column: $table.foodForm, builder: (column) => column);

  GeneratedColumn<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storageMethod => $composableBuilder(
    column: $table.storageMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSample =>
      $composableBuilder(column: $table.isSample, builder: (column) => column);

  Expression<T> feedingLogsRefs<T extends Object>(
    Expression<T> Function($$FeedingLogsTableAnnotationComposer a) f,
  ) {
    final $$FeedingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingLogs,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.feedingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pantryItemsRefs<T extends Object>(
    Expression<T> Function($$PantryItemsTableAnnotationComposer a) f,
  ) {
    final $$PantryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pantryItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PantryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.pantryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodProductsTable,
          FoodProductRow,
          $$FoodProductsTableFilterComposer,
          $$FoodProductsTableOrderingComposer,
          $$FoodProductsTableAnnotationComposer,
          $$FoodProductsTableCreateCompanionBuilder,
          $$FoodProductsTableUpdateCompanionBuilder,
          (FoodProductRow, $$FoodProductsTableReferences),
          FoodProductRow,
          PrefetchHooks Function({bool feedingLogsRefs, bool pantryItemsRefs})
        > {
  $$FoodProductsTableTableManager(_$AppDatabase db, $FoodProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> spec = const Value.absent(),
                Value<String> foodForm = const Value.absent(),
                Value<double?> kcalPer100g = const Value.absent(),
                Value<String> storageMethod = const Value.absent(),
                Value<int> afterOpenDays = const Value.absent(),
                Value<bool> isSample = const Value.absent(),
              }) => FoodProductsCompanion(
                id: id,
                barcode: barcode,
                brand: brand,
                name: name,
                spec: spec,
                foodForm: foodForm,
                kcalPer100g: kcalPer100g,
                storageMethod: storageMethod,
                afterOpenDays: afterOpenDays,
                isSample: isSample,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String brand,
                required String name,
                required String spec,
                required String foodForm,
                Value<double?> kcalPer100g = const Value.absent(),
                required String storageMethod,
                required int afterOpenDays,
                Value<bool> isSample = const Value.absent(),
              }) => FoodProductsCompanion.insert(
                id: id,
                barcode: barcode,
                brand: brand,
                name: name,
                spec: spec,
                foodForm: foodForm,
                kcalPer100g: kcalPer100g,
                storageMethod: storageMethod,
                afterOpenDays: afterOpenDays,
                isSample: isSample,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodProductsTable, FoodProductRow>(table),
                  $$FoodProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({feedingLogsRefs = false, pantryItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (feedingLogsRefs) db.feedingLogs,
                    if (pantryItemsRefs) db.pantryItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (feedingLogsRefs)
                        await $_getPrefetchedData<
                          FoodProductRow,
                          $FoodProductsTable,
                          FeedingRow
                        >(
                          currentTable: table,
                          referencedTable: $$FoodProductsTableReferences
                              ._feedingLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).feedingLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pantryItemsRefs)
                        await $_getPrefetchedData<
                          FoodProductRow,
                          $FoodProductsTable,
                          PantryRow
                        >(
                          currentTable: table,
                          referencedTable: $$FoodProductsTableReferences
                              ._pantryItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).pantryItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
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

typedef $$FoodProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodProductsTable,
      FoodProductRow,
      $$FoodProductsTableFilterComposer,
      $$FoodProductsTableOrderingComposer,
      $$FoodProductsTableAnnotationComposer,
      $$FoodProductsTableCreateCompanionBuilder,
      $$FoodProductsTableUpdateCompanionBuilder,
      (FoodProductRow, $$FoodProductsTableReferences),
      FoodProductRow,
      PrefetchHooks Function({bool feedingLogsRefs, bool pantryItemsRefs})
    >;
typedef $$FeedingLogsTableCreateCompanionBuilder =
    FeedingLogsCompanion Function({
      Value<int> id,
      required int catId,
      required DateTime loggedAt,
      required String foodName,
      required String foodForm,
      required double grams,
      Value<double?> kcal,
      Value<int?> productId,
      required String slot,
    });
typedef $$FeedingLogsTableUpdateCompanionBuilder =
    FeedingLogsCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<DateTime> loggedAt,
      Value<String> foodName,
      Value<String> foodForm,
      Value<double> grams,
      Value<double?> kcal,
      Value<int?> productId,
      Value<String> slot,
    });

final class $$FeedingLogsTableReferences
    extends BaseReferences<_$AppDatabase, $FeedingLogsTable, FeedingRow> {
  $$FeedingLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('feeding_logs__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoodProductsTable _productIdTable(_$AppDatabase db) => db.foodProducts
      .createAlias('feeding_logs__product_id__food_products__id');

  $$FoodProductsTableProcessedTableManager? get productId {
    final $_column = $_itemColumn<int>('product_id');
    if ($_column == null) return null;
    final manager = $$FoodProductsTableTableManager(
      $_db,
      $_db.foodProducts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeedingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodForm => $composableBuilder(
    column: $table.foodForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodProductsTableFilterComposer get productId {
    final $$FoodProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.foodProducts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodProductsTableFilterComposer(
            $db: $db,
            $table: $db.foodProducts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodForm => $composableBuilder(
    column: $table.foodForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodProductsTableOrderingComposer get productId {
    final $$FoodProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.foodProducts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodProductsTableOrderingComposer(
            $db: $db,
            $table: $db.foodProducts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get foodForm =>
      $composableBuilder(column: $table.foodForm, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoodProductsTableAnnotationComposer get productId {
    final $$FoodProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.foodProducts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.foodProducts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedingLogsTable,
          FeedingRow,
          $$FeedingLogsTableFilterComposer,
          $$FeedingLogsTableOrderingComposer,
          $$FeedingLogsTableAnnotationComposer,
          $$FeedingLogsTableCreateCompanionBuilder,
          $$FeedingLogsTableUpdateCompanionBuilder,
          (FeedingRow, $$FeedingLogsTableReferences),
          FeedingRow,
          PrefetchHooks Function({bool catId, bool productId})
        > {
  $$FeedingLogsTableTableManager(_$AppDatabase db, $FeedingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String> foodForm = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<String> slot = const Value.absent(),
              }) => FeedingLogsCompanion(
                id: id,
                catId: catId,
                loggedAt: loggedAt,
                foodName: foodName,
                foodForm: foodForm,
                grams: grams,
                kcal: kcal,
                productId: productId,
                slot: slot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required DateTime loggedAt,
                required String foodName,
                required String foodForm,
                required double grams,
                Value<double?> kcal = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                required String slot,
              }) => FeedingLogsCompanion.insert(
                id: id,
                catId: catId,
                loggedAt: loggedAt,
                foodName: foodName,
                foodForm: foodForm,
                grams: grams,
                kcal: kcal,
                productId: productId,
                slot: slot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedingLogsTable, FeedingRow>(table),
                  $$FeedingLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false, productId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$FeedingLogsTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$FeedingLogsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$FeedingLogsTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$FeedingLogsTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
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

typedef $$FeedingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedingLogsTable,
      FeedingRow,
      $$FeedingLogsTableFilterComposer,
      $$FeedingLogsTableOrderingComposer,
      $$FeedingLogsTableAnnotationComposer,
      $$FeedingLogsTableCreateCompanionBuilder,
      $$FeedingLogsTableUpdateCompanionBuilder,
      (FeedingRow, $$FeedingLogsTableReferences),
      FeedingRow,
      PrefetchHooks Function({bool catId, bool productId})
    >;
typedef $$FoodTransitionsTableCreateCompanionBuilder =
    FoodTransitionsCompanion Function({
      Value<int> id,
      required int catId,
      required String fromFood,
      required String toFood,
      required DateTime startDate,
      Value<int> days,
    });
typedef $$FoodTransitionsTableUpdateCompanionBuilder =
    FoodTransitionsCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<String> fromFood,
      Value<String> toFood,
      Value<DateTime> startDate,
      Value<int> days,
    });

final class $$FoodTransitionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $FoodTransitionsTable, TransitionRow> {
  $$FoodTransitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('food_transitions__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FoodTransitionsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodTransitionsTable> {
  $$FoodTransitionsTableFilterComposer({
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

  ColumnFilters<String> get fromFood => $composableBuilder(
    column: $table.fromFood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toFood => $composableBuilder(
    column: $table.toFood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodTransitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodTransitionsTable> {
  $$FoodTransitionsTableOrderingComposer({
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

  ColumnOrderings<String> get fromFood => $composableBuilder(
    column: $table.fromFood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toFood => $composableBuilder(
    column: $table.toFood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodTransitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodTransitionsTable> {
  $$FoodTransitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromFood =>
      $composableBuilder(column: $table.fromFood, builder: (column) => column);

  GeneratedColumn<String> get toFood =>
      $composableBuilder(column: $table.toFood, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoodTransitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodTransitionsTable,
          TransitionRow,
          $$FoodTransitionsTableFilterComposer,
          $$FoodTransitionsTableOrderingComposer,
          $$FoodTransitionsTableAnnotationComposer,
          $$FoodTransitionsTableCreateCompanionBuilder,
          $$FoodTransitionsTableUpdateCompanionBuilder,
          (TransitionRow, $$FoodTransitionsTableReferences),
          TransitionRow,
          PrefetchHooks Function({bool catId})
        > {
  $$FoodTransitionsTableTableManager(
    _$AppDatabase db,
    $FoodTransitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodTransitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodTransitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodTransitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<String> fromFood = const Value.absent(),
                Value<String> toFood = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<int> days = const Value.absent(),
              }) => FoodTransitionsCompanion(
                id: id,
                catId: catId,
                fromFood: fromFood,
                toFood: toFood,
                startDate: startDate,
                days: days,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required String fromFood,
                required String toFood,
                required DateTime startDate,
                Value<int> days = const Value.absent(),
              }) => FoodTransitionsCompanion.insert(
                id: id,
                catId: catId,
                fromFood: fromFood,
                toFood: toFood,
                startDate: startDate,
                days: days,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodTransitionsTable, TransitionRow>(table),
                  $$FoodTransitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$FoodTransitionsTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$FoodTransitionsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$FoodTransitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodTransitionsTable,
      TransitionRow,
      $$FoodTransitionsTableFilterComposer,
      $$FoodTransitionsTableOrderingComposer,
      $$FoodTransitionsTableAnnotationComposer,
      $$FoodTransitionsTableCreateCompanionBuilder,
      $$FoodTransitionsTableUpdateCompanionBuilder,
      (TransitionRow, $$FoodTransitionsTableReferences),
      TransitionRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$PantryItemsTableCreateCompanionBuilder =
    PantryItemsCompanion Function({
      Value<int> id,
      required int productId,
      Value<DateTime?> productionDate,
      Value<DateTime?> expiryDate,
      Value<String?> batch,
      Value<String> dateSource,
      Value<DateTime?> openedAt,
      Value<int?> afterOpenDays,
    });
typedef $$PantryItemsTableUpdateCompanionBuilder =
    PantryItemsCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<DateTime?> productionDate,
      Value<DateTime?> expiryDate,
      Value<String?> batch,
      Value<String> dateSource,
      Value<DateTime?> openedAt,
      Value<int?> afterOpenDays,
    });

final class $$PantryItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PantryItemsTable, PantryRow> {
  $$PantryItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodProductsTable _productIdTable(_$AppDatabase db) => db.foodProducts
      .createAlias('pantry_items__product_id__food_products__id');

  $$FoodProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$FoodProductsTableTableManager(
      $_db,
      $_db.foodProducts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PantryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableFilterComposer({
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

  ColumnFilters<DateTime> get productionDate => $composableBuilder(
    column: $table.productionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batch => $composableBuilder(
    column: $table.batch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateSource => $composableBuilder(
    column: $table.dateSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodProductsTableFilterComposer get productId {
    final $$FoodProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.foodProducts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodProductsTableFilterComposer(
            $db: $db,
            $table: $db.foodProducts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PantryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get productionDate => $composableBuilder(
    column: $table.productionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batch => $composableBuilder(
    column: $table.batch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateSource => $composableBuilder(
    column: $table.dateSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodProductsTableOrderingComposer get productId {
    final $$FoodProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.foodProducts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodProductsTableOrderingComposer(
            $db: $db,
            $table: $db.foodProducts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PantryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PantryItemsTable> {
  $$PantryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get productionDate => $composableBuilder(
    column: $table.productionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batch =>
      $composableBuilder(column: $table.batch, builder: (column) => column);

  GeneratedColumn<String> get dateSource => $composableBuilder(
    column: $table.dateSource,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<int> get afterOpenDays => $composableBuilder(
    column: $table.afterOpenDays,
    builder: (column) => column,
  );

  $$FoodProductsTableAnnotationComposer get productId {
    final $$FoodProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.foodProducts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.foodProducts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PantryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PantryItemsTable,
          PantryRow,
          $$PantryItemsTableFilterComposer,
          $$PantryItemsTableOrderingComposer,
          $$PantryItemsTableAnnotationComposer,
          $$PantryItemsTableCreateCompanionBuilder,
          $$PantryItemsTableUpdateCompanionBuilder,
          (PantryRow, $$PantryItemsTableReferences),
          PantryRow,
          PrefetchHooks Function({bool productId})
        > {
  $$PantryItemsTableTableManager(_$AppDatabase db, $PantryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PantryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PantryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PantryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<DateTime?> productionDate = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String?> batch = const Value.absent(),
                Value<String> dateSource = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<int?> afterOpenDays = const Value.absent(),
              }) => PantryItemsCompanion(
                id: id,
                productId: productId,
                productionDate: productionDate,
                expiryDate: expiryDate,
                batch: batch,
                dateSource: dateSource,
                openedAt: openedAt,
                afterOpenDays: afterOpenDays,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                Value<DateTime?> productionDate = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String?> batch = const Value.absent(),
                Value<String> dateSource = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<int?> afterOpenDays = const Value.absent(),
              }) => PantryItemsCompanion.insert(
                id: id,
                productId: productId,
                productionDate: productionDate,
                expiryDate: expiryDate,
                batch: batch,
                dateSource: dateSource,
                openedAt: openedAt,
                afterOpenDays: afterOpenDays,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PantryItemsTable, PantryRow>(table),
                  $$PantryItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$PantryItemsTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$PantryItemsTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
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

typedef $$PantryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PantryItemsTable,
      PantryRow,
      $$PantryItemsTableFilterComposer,
      $$PantryItemsTableOrderingComposer,
      $$PantryItemsTableAnnotationComposer,
      $$PantryItemsTableCreateCompanionBuilder,
      $$PantryItemsTableUpdateCompanionBuilder,
      (PantryRow, $$PantryItemsTableReferences),
      PantryRow,
      PrefetchHooks Function({bool productId})
    >;
typedef $$FeedingRemindersTableCreateCompanionBuilder =
    FeedingRemindersCompanion Function({
      Value<int> id,
      required int catId,
      required int slot,
      required int hour,
      required int minute,
      Value<bool> enabled,
    });
typedef $$FeedingRemindersTableUpdateCompanionBuilder =
    FeedingRemindersCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<int> slot,
      Value<int> hour,
      Value<int> minute,
      Value<bool> enabled,
    });

final class $$FeedingRemindersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FeedingRemindersTable,
          FeedingReminderRow
        > {
  $$FeedingRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('feeding_reminders__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeedingRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $FeedingRemindersTable> {
  $$FeedingRemindersTableFilterComposer({
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

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedingRemindersTable> {
  $$FeedingRemindersTableOrderingComposer({
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

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedingRemindersTable> {
  $$FeedingRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedingRemindersTable,
          FeedingReminderRow,
          $$FeedingRemindersTableFilterComposer,
          $$FeedingRemindersTableOrderingComposer,
          $$FeedingRemindersTableAnnotationComposer,
          $$FeedingRemindersTableCreateCompanionBuilder,
          $$FeedingRemindersTableUpdateCompanionBuilder,
          (FeedingReminderRow, $$FeedingRemindersTableReferences),
          FeedingReminderRow,
          PrefetchHooks Function({bool catId})
        > {
  $$FeedingRemindersTableTableManager(
    _$AppDatabase db,
    $FeedingRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => FeedingRemindersCompanion(
                id: id,
                catId: catId,
                slot: slot,
                hour: hour,
                minute: minute,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required int slot,
                required int hour,
                required int minute,
                Value<bool> enabled = const Value.absent(),
              }) => FeedingRemindersCompanion.insert(
                id: id,
                catId: catId,
                slot: slot,
                hour: hour,
                minute: minute,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedingRemindersTable, FeedingReminderRow>(
                    table,
                  ),
                  $$FeedingRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$FeedingRemindersTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$FeedingRemindersTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$FeedingRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedingRemindersTable,
      FeedingReminderRow,
      $$FeedingRemindersTableFilterComposer,
      $$FeedingRemindersTableOrderingComposer,
      $$FeedingRemindersTableAnnotationComposer,
      $$FeedingRemindersTableCreateCompanionBuilder,
      $$FeedingRemindersTableUpdateCompanionBuilder,
      (FeedingReminderRow, $$FeedingRemindersTableReferences),
      FeedingReminderRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$CatConditionsTableCreateCompanionBuilder =
    CatConditionsCompanion Function({
      Value<int> id,
      required int catId,
      required String diseaseId,
      required DateTime diagnosedOn,
      Value<String> stageLabel,
      Value<String> note,
      Value<DateTime?> nextRecheck,
    });
typedef $$CatConditionsTableUpdateCompanionBuilder =
    CatConditionsCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<String> diseaseId,
      Value<DateTime> diagnosedOn,
      Value<String> stageLabel,
      Value<String> note,
      Value<DateTime?> nextRecheck,
    });

final class $$CatConditionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CatConditionsTable, CatConditionRow> {
  $$CatConditionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('cat_conditions__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CatConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $CatConditionsTable> {
  $$CatConditionsTableFilterComposer({
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

  ColumnFilters<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diagnosedOn => $composableBuilder(
    column: $table.diagnosedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageLabel => $composableBuilder(
    column: $table.stageLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRecheck => $composableBuilder(
    column: $table.nextRecheck,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatConditionsTable> {
  $$CatConditionsTableOrderingComposer({
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

  ColumnOrderings<String> get diseaseId => $composableBuilder(
    column: $table.diseaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diagnosedOn => $composableBuilder(
    column: $table.diagnosedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageLabel => $composableBuilder(
    column: $table.stageLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRecheck => $composableBuilder(
    column: $table.nextRecheck,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatConditionsTable> {
  $$CatConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get diseaseId =>
      $composableBuilder(column: $table.diseaseId, builder: (column) => column);

  GeneratedColumn<DateTime> get diagnosedOn => $composableBuilder(
    column: $table.diagnosedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stageLabel => $composableBuilder(
    column: $table.stageLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRecheck => $composableBuilder(
    column: $table.nextRecheck,
    builder: (column) => column,
  );

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatConditionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatConditionsTable,
          CatConditionRow,
          $$CatConditionsTableFilterComposer,
          $$CatConditionsTableOrderingComposer,
          $$CatConditionsTableAnnotationComposer,
          $$CatConditionsTableCreateCompanionBuilder,
          $$CatConditionsTableUpdateCompanionBuilder,
          (CatConditionRow, $$CatConditionsTableReferences),
          CatConditionRow,
          PrefetchHooks Function({bool catId})
        > {
  $$CatConditionsTableTableManager(_$AppDatabase db, $CatConditionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatConditionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<String> diseaseId = const Value.absent(),
                Value<DateTime> diagnosedOn = const Value.absent(),
                Value<String> stageLabel = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime?> nextRecheck = const Value.absent(),
              }) => CatConditionsCompanion(
                id: id,
                catId: catId,
                diseaseId: diseaseId,
                diagnosedOn: diagnosedOn,
                stageLabel: stageLabel,
                note: note,
                nextRecheck: nextRecheck,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required String diseaseId,
                required DateTime diagnosedOn,
                Value<String> stageLabel = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime?> nextRecheck = const Value.absent(),
              }) => CatConditionsCompanion.insert(
                id: id,
                catId: catId,
                diseaseId: diseaseId,
                diagnosedOn: diagnosedOn,
                stageLabel: stageLabel,
                note: note,
                nextRecheck: nextRecheck,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatConditionsTable, CatConditionRow>(table),
                  $$CatConditionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$CatConditionsTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$CatConditionsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CatConditionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatConditionsTable,
      CatConditionRow,
      $$CatConditionsTableFilterComposer,
      $$CatConditionsTableOrderingComposer,
      $$CatConditionsTableAnnotationComposer,
      $$CatConditionsTableCreateCompanionBuilder,
      $$CatConditionsTableUpdateCompanionBuilder,
      (CatConditionRow, $$CatConditionsTableReferences),
      CatConditionRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$CheckupLogsTableCreateCompanionBuilder =
    CheckupLogsCompanion Function({
      Value<int> id,
      required int catId,
      required String itemId,
      Value<DateTime?> completedOn,
      Value<String> result,
      Value<DateTime?> nextDue,
    });
typedef $$CheckupLogsTableUpdateCompanionBuilder =
    CheckupLogsCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<String> itemId,
      Value<DateTime?> completedOn,
      Value<String> result,
      Value<DateTime?> nextDue,
    });

final class $$CheckupLogsTableReferences
    extends BaseReferences<_$AppDatabase, $CheckupLogsTable, CheckupLogRow> {
  $$CheckupLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('checkup_logs__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CheckupLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckupLogsTable> {
  $$CheckupLogsTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDue => $composableBuilder(
    column: $table.nextDue,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckupLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckupLogsTable> {
  $$CheckupLogsTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDue => $composableBuilder(
    column: $table.nextDue,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckupLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckupLogsTable> {
  $$CheckupLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDue =>
      $composableBuilder(column: $table.nextDue, builder: (column) => column);

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckupLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckupLogsTable,
          CheckupLogRow,
          $$CheckupLogsTableFilterComposer,
          $$CheckupLogsTableOrderingComposer,
          $$CheckupLogsTableAnnotationComposer,
          $$CheckupLogsTableCreateCompanionBuilder,
          $$CheckupLogsTableUpdateCompanionBuilder,
          (CheckupLogRow, $$CheckupLogsTableReferences),
          CheckupLogRow,
          PrefetchHooks Function({bool catId})
        > {
  $$CheckupLogsTableTableManager(_$AppDatabase db, $CheckupLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckupLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckupLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckupLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<DateTime?> completedOn = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime?> nextDue = const Value.absent(),
              }) => CheckupLogsCompanion(
                id: id,
                catId: catId,
                itemId: itemId,
                completedOn: completedOn,
                result: result,
                nextDue: nextDue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required String itemId,
                Value<DateTime?> completedOn = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime?> nextDue = const Value.absent(),
              }) => CheckupLogsCompanion.insert(
                id: id,
                catId: catId,
                itemId: itemId,
                completedOn: completedOn,
                result: result,
                nextDue: nextDue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckupLogsTable, CheckupLogRow>(table),
                  $$CheckupLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$CheckupLogsTableReferences
                            ._catIdTable(db),
                        referencedColumn: $$CheckupLogsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CheckupLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckupLogsTable,
      CheckupLogRow,
      $$CheckupLogsTableFilterComposer,
      $$CheckupLogsTableOrderingComposer,
      $$CheckupLogsTableAnnotationComposer,
      $$CheckupLogsTableCreateCompanionBuilder,
      $$CheckupLogsTableUpdateCompanionBuilder,
      (CheckupLogRow, $$CheckupLogsTableReferences),
      CheckupLogRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$WaterLogsTableCreateCompanionBuilder = WaterLogsCompanion Function({
  Value<int> id,
  required int catId,
  required DateTime loggedOn,
  required double milliliters,
});
typedef $$WaterLogsTableUpdateCompanionBuilder = WaterLogsCompanion Function({
  Value<int> id,
  Value<int> catId,
  Value<DateTime> loggedOn,
  Value<double> milliliters,
});

final class $$WaterLogsTableReferences
    extends BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLogRow> {
  $$WaterLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatsTable _catIdTable(_$AppDatabase db) =>
      db.cats.createAlias('water_logs__cat_id__cats__id');

  $$CatsTableProcessedTableManager get catId {
    final $_column = $_itemColumn<int>('cat_id')!;

    final manager = $$CatsTableTableManager(
      $_db,
      $_db.cats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get milliliters => $composableBuilder(
    column: $table.milliliters,
    builder: (column) => ColumnFilters(column),
  );

  $$CatsTableFilterComposer get catId {
    final $$CatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableFilterComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get loggedOn => $composableBuilder(
    column: $table.loggedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get milliliters => $composableBuilder(
    column: $table.milliliters,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatsTableOrderingComposer get catId {
    final $$CatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableOrderingComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedOn =>
      $composableBuilder(column: $table.loggedOn, builder: (column) => column);

  GeneratedColumn<double> get milliliters => $composableBuilder(
    column: $table.milliliters,
    builder: (column) => column,
  );

  $$CatsTableAnnotationComposer get catId {
    final $$CatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catId,
      referencedTable: $db.cats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatsTableAnnotationComposer(
            $db: $db,
            $table: $db.cats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterLogsTable,
          WaterLogRow,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (WaterLogRow, $$WaterLogsTableReferences),
          WaterLogRow,
          PrefetchHooks Function({bool catId})
        > {
  $$WaterLogsTableTableManager(_$AppDatabase db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<DateTime> loggedOn = const Value.absent(),
                Value<double> milliliters = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                catId: catId,
                loggedOn: loggedOn,
                milliliters: milliliters,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required DateTime loggedOn,
                required double milliliters,
              }) => WaterLogsCompanion.insert(
                id: id,
                catId: catId,
                loggedOn: loggedOn,
                milliliters: milliliters,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaterLogsTable, WaterLogRow>(table),
                  $$WaterLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({catId = false}) {
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
                    if (catId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.catId,
                        referencedTable: $$WaterLogsTableReferences._catIdTable(
                          db,
                        ),
                        referencedColumn: $$WaterLogsTableReferences
                            ._catIdTable(db)
                            .id,
                      ) as T;
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

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterLogsTable,
      WaterLogRow,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (WaterLogRow, $$WaterLogsTableReferences),
      WaterLogRow,
      PrefetchHooks Function({bool catId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          SettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      SettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CatsTableTableManager get cats => $$CatsTableTableManager(_db, _db.cats);
  $$CatPhotosTableTableManager get catPhotos =>
      $$CatPhotosTableTableManager(_db, _db.catPhotos);
  $$VaccinesTableTableManager get vaccines =>
      $$VaccinesTableTableManager(_db, _db.vaccines);
  $$DewormingsTableTableManager get dewormings =>
      $$DewormingsTableTableManager(_db, _db.dewormings);
  $$VetVisitsTableTableManager get vetVisits =>
      $$VetVisitsTableTableManager(_db, _db.vetVisits);
  $$WeightLogsTableTableManager get weightLogs =>
      $$WeightLogsTableTableManager(_db, _db.weightLogs);
  $$HealthNotesTableTableManager get healthNotes =>
      $$HealthNotesTableTableManager(_db, _db.healthNotes);
  $$FoodProductsTableTableManager get foodProducts =>
      $$FoodProductsTableTableManager(_db, _db.foodProducts);
  $$FeedingLogsTableTableManager get feedingLogs =>
      $$FeedingLogsTableTableManager(_db, _db.feedingLogs);
  $$FoodTransitionsTableTableManager get foodTransitions =>
      $$FoodTransitionsTableTableManager(_db, _db.foodTransitions);
  $$PantryItemsTableTableManager get pantryItems =>
      $$PantryItemsTableTableManager(_db, _db.pantryItems);
  $$FeedingRemindersTableTableManager get feedingReminders =>
      $$FeedingRemindersTableTableManager(_db, _db.feedingReminders);
  $$CatConditionsTableTableManager get catConditions =>
      $$CatConditionsTableTableManager(_db, _db.catConditions);
  $$CheckupLogsTableTableManager get checkupLogs =>
      $$CheckupLogsTableTableManager(_db, _db.checkupLogs);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
