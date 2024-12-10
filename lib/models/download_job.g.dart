// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_job.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDownloadJobCollection on Isar {
  IsarCollection<DownloadJob> get downloadJobs => this.collection();
}

const DownloadJobSchema = CollectionSchema(
  name: r'DownloadJob',
  id: -4183604532101285418,
  properties: {
    r'progress': PropertySchema(
      id: 0,
      name: r'progress',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 1,
      name: r'status',
      type: IsarType.string,
      enumMap: _DownloadJobstatusEnumValueMap,
    )
  },
  estimateSize: _downloadJobEstimateSize,
  serialize: _downloadJobSerialize,
  deserialize: _downloadJobDeserialize,
  deserializeProp: _downloadJobDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'resource': LinkSchema(
      id: 1061748862724252451,
      name: r'resource',
      target: r'OfflineResource',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _downloadJobGetId,
  getLinks: _downloadJobGetLinks,
  attach: _downloadJobAttach,
  version: '3.1.0+1',
);

int _downloadJobEstimateSize(
  DownloadJob object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _downloadJobSerialize(
  DownloadJob object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.progress);
  writer.writeString(offsets[1], object.status.name);
}

DownloadJob _downloadJobDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DownloadJob();
  object.id = id;
  object.progress = reader.readLong(offsets[0]);
  object.status =
      _DownloadJobstatusValueEnumMap[reader.readStringOrNull(offsets[1])] ??
          DownloadStatus.queued;
  return object;
}

P _downloadJobDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (_DownloadJobstatusValueEnumMap[reader.readStringOrNull(offset)] ??
          DownloadStatus.queued) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DownloadJobstatusEnumValueMap = {
  r'queued': r'queued',
  r'downloading': r'downloading',
  r'completed': r'completed',
  r'failed': r'failed',
  r'paused': r'paused',
  r'canceled': r'canceled',
};
const _DownloadJobstatusValueEnumMap = {
  r'queued': DownloadStatus.queued,
  r'downloading': DownloadStatus.downloading,
  r'completed': DownloadStatus.completed,
  r'failed': DownloadStatus.failed,
  r'paused': DownloadStatus.paused,
  r'canceled': DownloadStatus.canceled,
};

Id _downloadJobGetId(DownloadJob object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _downloadJobGetLinks(DownloadJob object) {
  return [object.resource];
}

void _downloadJobAttach(
    IsarCollection<dynamic> col, Id id, DownloadJob object) {
  object.id = id;
  object.resource
      .attach(col, col.isar.collection<OfflineResource>(), r'resource', id);
}

extension DownloadJobQueryWhereSort
    on QueryBuilder<DownloadJob, DownloadJob, QWhere> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DownloadJobQueryWhere
    on QueryBuilder<DownloadJob, DownloadJob, QWhereClause> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DownloadJobQueryFilter
    on QueryBuilder<DownloadJob, DownloadJob, QFilterCondition> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> progressEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      progressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      progressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> progressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusEqualTo(
    DownloadStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      statusGreaterThan(
    DownloadStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusLessThan(
    DownloadStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusBetween(
    DownloadStatus lower,
    DownloadStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension DownloadJobQueryObject
    on QueryBuilder<DownloadJob, DownloadJob, QFilterCondition> {}

extension DownloadJobQueryLinks
    on QueryBuilder<DownloadJob, DownloadJob, QFilterCondition> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> resource(
      FilterQuery<OfflineResource> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'resource');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'resource', 0, true, 0, true);
    });
  }
}

extension DownloadJobQuerySortBy
    on QueryBuilder<DownloadJob, DownloadJob, QSortBy> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension DownloadJobQuerySortThenBy
    on QueryBuilder<DownloadJob, DownloadJob, QSortThenBy> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension DownloadJobQueryWhereDistinct
    on QueryBuilder<DownloadJob, DownloadJob, QDistinct> {
  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension DownloadJobQueryProperty
    on QueryBuilder<DownloadJob, DownloadJob, QQueryProperty> {
  QueryBuilder<DownloadJob, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DownloadJob, int, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<DownloadJob, DownloadStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
