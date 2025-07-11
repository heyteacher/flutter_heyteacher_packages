/// Store filters define how to filter data provided by [Store] and i they match the structure of Firestore Filter.
/// Store filter are passed as paramenter [Store.storeFilter].
///
/// There are three type of filter which implement [StoreFilter] interface:
///
/// * [ValueStoreFilter]  where [ValueStoreFilter.field] is compared to
///   [ValueStoreFilter.value] according [Operator]
///
/// * [IterableValueStoreFilter] where [IterableValueStoreFilter.field] is compare to
///   iterable [IterableValueStoreFilter.values] according [IterableOperator]
///
/// * [IsNullStoreFilter] check if [IsNullStoreFilter.field] is null
///   in the case [IsNullStoreFilter.value] is true, or is not null if [IsNullStoreFilter.value] is false
///
/// * [LogicalStoreFilter] coumpound [StoreFilter] according [LogicalOperator]
///
/// For example, to filter data in an interval:
/// ```dart
/// LogicalStoreFilter(
///  logicalOperator: LogicalOperator.and,
///   filter1: ValueStoreFilter(
///    field: 'startTime',
///    operator: Operator.isGreaterThanOrEqualTo,
///    value: DateTime(intFormatter.parse(value).toInt())),
///   filter2: ValueStoreFilter(
///    field: 'startTime',
///    operator: Operator.isLessThan,
///    value: DateTime(intFormatter.parse(value).toInt() + 1)));
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Operators used in [ValueStoreFilter]
enum Operator {
  /// If field value is equal to value
  isEqualTo('='),
  /// If field value isn't equal to value
  isNotEqualTo('<>'),
  /// If field value is less than field
  isLessThan('<'),
  /// If field value is less then or equal to value
  isLessThanOrEqualTo('<='),
  /// If field value is greater than field
  isGreaterThan('>'),
  /// If field value is greater then or equal to value
  isGreaterThanOrEqualTo('>='),
  /// If field array value contains the value
  arrayContains('in');

  final String printable;
  const Operator(this.printable);
}

/// Operators used in [IterableValueStoreFilter]
enum IterableOperator {
  /// If field value is contained into the iterable values
  arrayContainsAny('in any'),
  /// If field value is is into iterable values
  whereIn('in'),
  /// If field value isn't into the iterable values
  whereNotIn('not in');

  final String printable;
  const IterableOperator(this.printable);
}

/// Operators used in [LogicalStoreFilter]
enum LogicalOperator {
  /// All [StoreFilter] children must be satisfied
  and,
  /// At least one [StoreFilter] children is satisfied
  or
}

/// The interface implemented by all store filters
abstract class StoreFilter {
  /// Converts the filter into Firestore [Filter]
  Filter toFirestore();
}

/// Compares [field] value to [value] according [Operator]
class ValueStoreFilter implements StoreFilter {
  /// The field in document
  String field;

  /// The operator used in comparition
  Operator operator;

  /// The value to check
  Object value;

  /// Creates a  value store filter
  ValueStoreFilter(
      {required this.field, required this.operator, required this.value});

  /// Converts the value store filter into a Firestore filter
  @override
  Filter toFirestore() => switch (operator) {
      Operator.isEqualTo => Filter(field, isEqualTo: value),
      Operator.isNotEqualTo => Filter(field, isNotEqualTo: value),
      Operator.isLessThan => Filter(field, isLessThan: value),
      Operator.isLessThanOrEqualTo => Filter(field, isLessThanOrEqualTo: value),
      Operator.isGreaterThan => Filter(field, isGreaterThan: value),
      Operator.isGreaterThanOrEqualTo =>
        Filter(field, isGreaterThanOrEqualTo: value),
      Operator.arrayContains => Filter(field, arrayContains: value),
    };

  /// Prints the filter in polish notation
  @override
  String toString() => '$field ${operator.printable} $value';
  }


/// Compares [field] value to iterable [values] according the [IterableOperator]
class IterableValueStoreFilter implements StoreFilter {
  /// The field in document
  String field;

  /// The operator used in comparison
  IterableOperator iterableOperator;

  /// The iterable values to check
  Iterable<Object?> values;

  /// Creates a iterable store filter
  IterableValueStoreFilter(
      {required this.field,
      required this.iterableOperator,
      required this.values});

  /// Converts the Iterable value store filter into a Firestore filter
  @override
  Filter toFirestore() => switch (iterableOperator) {
      IterableOperator.arrayContainsAny =>
        Filter(field, arrayContainsAny: values),
      IterableOperator.whereIn => Filter(field, whereIn: values),
      IterableOperator.whereNotIn => Filter(field, whereNotIn: values),
    };
  

  /// Prints the filter in polish notation
  @override
  String toString() => '$field ${iterableOperator.printable} $values';
}

/// If [value] is `true`, checks if [field] is null. Otherwise checks [field] is not null.
class IsNullStoreFilter implements StoreFilter {
  /// The field to check nullability
  String field;

  /// if `true`, check nullability. If `false` checks non-nullability
  bool value;

  /// creates a is null store filter
  IsNullStoreFilter({required this.field, required this.value});

  /// Converts the is null store filter into a Firestore filter
  @override
  Filter toFirestore() => Filter(field, isNull: value);

  /// Prints the filter in polish notation
  @override
  String toString() => '$field is${value ? '' : 'Not'}Null';
}

/// Applies [LogicalOperator] to [StoreFilter]. If [LogicalOperator.and] all [StoreFilter] must be satisfied.
/// If [LogicalOperator.or] at least one [StoreFilter] must be satisfied.
class LogicalStoreFilter implements StoreFilter {
  /// The logical operator applied to filters
  LogicalOperator logicalOperator;

  /// The filter to evaluate
  StoreFilter filter1;

  /// The filter to evaluate
  StoreFilter filter2;

  /// The filter to evaluate
  StoreFilter? filter3;

  /// The filter to evaluate
  StoreFilter? filter4;

  /// The filter to evaluate
  StoreFilter? filter5;

  /// The filter to evaluate
  StoreFilter? filter6;

  /// The filter to evaluate
  StoreFilter? filter7;

  /// The filter to evaluate
  StoreFilter? filter8;

  /// The filter to evaluate
  StoreFilter? filter9;

  /// The filter to evaluate
  StoreFilter? filter10;

  /// The filter to evaluate
  StoreFilter? filter11;

  /// The filter to evaluate
  StoreFilter? filter12;

  /// The filter to evaluate
  StoreFilter? filter13;

  /// The filter to evaluate
  StoreFilter? filter14;

  /// The filter to evaluate
  StoreFilter? filter15;

  /// The filter to evaluate
  StoreFilter? filter16;

  /// The filter to evaluate
  StoreFilter? filter17;

  /// The filter to evaluate
  StoreFilter? filter18;

  /// The filter to evaluate
  StoreFilter? filter19;

  /// The filter to evaluate
  StoreFilter? filter20;

  /// The filter to evaluate
  StoreFilter? filter21;

  /// The filter to evaluate
  StoreFilter? filter22;

  /// The filter to evaluate
  StoreFilter? filter23;

  /// The filter to evaluate
  StoreFilter? filter24;

  /// The filter to evaluate
  StoreFilter? filter25;

  /// The filter to evaluate
  StoreFilter? filter26;

  /// The filter to evaluate
  StoreFilter? filter27;

  /// The filter to evaluate
  StoreFilter? filter28;

  /// The filter to evaluate
  StoreFilter? filter29;

  /// The filter to evaluate
  StoreFilter? filter30;

  // Creates a logical filter
  LogicalStoreFilter({
    required this.logicalOperator,
    required this.filter1,
    required this.filter2,
    this.filter3,
    this.filter4,
    this.filter5,
    this.filter6,
    this.filter7,
    this.filter8,
    this.filter9,
    this.filter10,
    this.filter11,
    this.filter12,
    this.filter13,
    this.filter14,
    this.filter15,
    this.filter16,
    this.filter17,
    this.filter18,
    this.filter19,
    this.filter20,
    this.filter21,
    this.filter22,
    this.filter23,
    this.filter24,
    this.filter25,
    this.filter26,
    this.filter27,
    this.filter28,
    this.filter29,
    this.filter30,
  });

  /// Converts the logical store filter into a Firestore filter
  @override
  Filter toFirestore() => switch (logicalOperator) {
        LogicalOperator.and => Filter.and(
            filter1.toFirestore(),
            filter2.toFirestore(),
            filter3?.toFirestore(),
            filter4?.toFirestore(),
            filter5?.toFirestore(),
            filter6?.toFirestore(),
            filter7?.toFirestore(),
            filter8?.toFirestore(),
            filter9?.toFirestore(),
            filter10?.toFirestore(),
            filter11?.toFirestore(),
            filter12?.toFirestore(),
            filter13?.toFirestore(),
            filter14?.toFirestore(),
            filter15?.toFirestore(),
            filter16?.toFirestore(),
            filter17?.toFirestore(),
            filter18?.toFirestore(),
            filter19?.toFirestore(),
            filter20?.toFirestore(),
            filter21?.toFirestore(),
            filter22?.toFirestore(),
            filter23?.toFirestore(),
            filter24?.toFirestore(),
            filter25?.toFirestore(),
            filter26?.toFirestore(),
            filter27?.toFirestore(),
            filter28?.toFirestore(),
            filter29?.toFirestore(),
            filter30?.toFirestore(),
          ),
        LogicalOperator.or => Filter.or(
            filter1.toFirestore(),
            filter2.toFirestore(),
            filter3?.toFirestore(),
            filter4?.toFirestore(),
            filter5?.toFirestore(),
            filter6?.toFirestore(),
            filter7?.toFirestore(),
            filter8?.toFirestore(),
            filter9?.toFirestore(),
            filter10?.toFirestore(),
            filter11?.toFirestore(),
            filter12?.toFirestore(),
            filter13?.toFirestore(),
            filter14?.toFirestore(),
            filter15?.toFirestore(),
            filter16?.toFirestore(),
            filter17?.toFirestore(),
            filter18?.toFirestore(),
            filter19?.toFirestore(),
            filter20?.toFirestore(),
            filter21?.toFirestore(),
            filter22?.toFirestore(),
            filter23?.toFirestore(),
            filter24?.toFirestore(),
            filter25?.toFirestore(),
            filter26?.toFirestore(),
            filter27?.toFirestore(),
            filter28?.toFirestore(),
            filter29?.toFirestore(),
            filter30?.toFirestore(),
          ),
      };

  /// Prints the filter in polish notation
  @override
  String toString() => '('
      '$filter1 ${logicalOperator.name} $filter2'
      '${filter3 != null ? ' ${logicalOperator.name} ' : ''} ${filter3 ?? ''}'
      '${filter4 != null ? ' ${logicalOperator.name} ' : ''} ${filter4 ?? ''}'
      '${filter5 != null ? ' ${logicalOperator.name} ' : ''} ${filter5 ?? ''}'
      '${filter6 != null ? ' ${logicalOperator.name} ' : ''} ${filter6 ?? ''}'
      '${filter7 != null ? ' ${logicalOperator.name} ' : ''} ${filter7 ?? ''}'
      '${filter8 != null ? ' ${logicalOperator.name} ' : ''} ${filter8 ?? ''}'
      '${filter9 != null ? ' ${logicalOperator.name} ' : ''} ${filter9 ?? ''}'
      '${filter10 != null ? ' ${logicalOperator.name} ' : ''} ${filter10 ?? ''}'
      '${filter11 != null ? ' ${logicalOperator.name} ' : ''} ${filter11 ?? ''}'
      '${filter12 != null ? ' ${logicalOperator.name} ' : ''} ${filter12 ?? ''}'
      '${filter13 != null ? ' ${logicalOperator.name} ' : ''} ${filter13 ?? ''}'
      '${filter14 != null ? ' ${logicalOperator.name} ' : ''} ${filter14 ?? ''}'
      '${filter15 != null ? ' ${logicalOperator.name} ' : ''} ${filter15 ?? ''}'
      '${filter16 != null ? ' ${logicalOperator.name} ' : ''} ${filter16 ?? ''}'
      '${filter17 != null ? ' ${logicalOperator.name} ' : ''} ${filter17 ?? ''}'
      '${filter18 != null ? ' ${logicalOperator.name} ' : ''} ${filter18 ?? ''}'
      '${filter19 != null ? ' ${logicalOperator.name} ' : ''} ${filter19 ?? ''}'
      '${filter20 != null ? ' ${logicalOperator.name} ' : ''} ${filter20 ?? ''}'
      '${filter21 != null ? ' ${logicalOperator.name} ' : ''} ${filter21 ?? ''}'
      '${filter22 != null ? ' ${logicalOperator.name} ' : ''} ${filter22 ?? ''}'
      '${filter23 != null ? ' ${logicalOperator.name} ' : ''} ${filter23 ?? ''}'
      '${filter24 != null ? ' ${logicalOperator.name} ' : ''} ${filter24 ?? ''}'
      '${filter25 != null ? ' ${logicalOperator.name} ' : ''} ${filter25 ?? ''}'
      '${filter26 != null ? ' ${logicalOperator.name} ' : ''} ${filter26 ?? ''}'
      '${filter27 != null ? ' ${logicalOperator.name} ' : ''} ${filter27 ?? ''}'
      '${filter28 != null ? ' ${logicalOperator.name} ' : ''} ${filter28 ?? ''}'
      '${filter29 != null ? ' ${logicalOperator.name} ' : ''} ${filter29 ?? ''}'
      '${filter30 != null ? ' ${logicalOperator.name} ' : ''} ${filter30 ?? ''})';
}
