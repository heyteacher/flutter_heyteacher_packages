/// Store filters define how to filter data provided by [Store] and i they
/// match the structure of Firestore Filter.
/// Store filter are passed as paramenter [Store.storeFilter].
///
/// There are three type of filter which implement [StoreFilter] interface:
///
/// * [ValueStoreFilter]  where [ValueStoreFilter.field] is compared to
///   [ValueStoreFilter.value] according [Operator]
///
/// * [IterableValueStoreFilter] where [IterableValueStoreFilter.field] is
///   compare to iterable [IterableValueStoreFilter.values] according
///   [IterableOperator]
///
/// * [IsNullStoreFilter] check if [IsNullStoreFilter.field] is null
///   in the case [IsNullStoreFilter.value] is true, or is not null if
///   [IsNullStoreFilter.value] is false
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
// ignore_for_file: sort_constructors_first

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';

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

  final String _printable;
  const Operator(this._printable);
}

/// Operators used in [IterableValueStoreFilter]
enum IterableOperator {
  /// If field value is contained into the iterable values
  arrayContainsAny('in any'),

  /// If field value is is into iterable values
  whereIn('in'),

  /// If field value isn't into the iterable values
  whereNotIn('not in');

  final String _printable;
  const IterableOperator(this._printable);
}

/// Operators used in [LogicalStoreFilter]
enum LogicalOperator {
  /// All [StoreFilter] children must be satisfied
  and,

  /// At least one [StoreFilter] children is satisfied
  or
}

/// The interface implemented by all store filters
abstract class StoreFilter extends Equatable {
  /// Converts the filter into Firestore [Filter]
  Filter toFirestore();
}

/// Compares [field] value to [value] according [Operator]
class ValueStoreFilter extends Equatable implements StoreFilter {
  /// The field in document
  final String field;

  /// The operator used in comparition
  final Operator operator;

  /// The value to check
  final Object value;

  /// Creates a  value store filter
  const ValueStoreFilter({
    required this.field,
    required this.operator,
    required this.value,
  });

  /// Converts the value store filter into a Firestore filter
  @override
  Filter toFirestore() => switch (operator) {
        Operator.isEqualTo => Filter(field, isEqualTo: value),
        Operator.isNotEqualTo => Filter(field, isNotEqualTo: value),
        Operator.isLessThan => Filter(field, isLessThan: value),
        Operator.isLessThanOrEqualTo =>
          Filter(field, isLessThanOrEqualTo: value),
        Operator.isGreaterThan => Filter(field, isGreaterThan: value),
        Operator.isGreaterThanOrEqualTo =>
          Filter(field, isGreaterThanOrEqualTo: value),
        Operator.arrayContains => Filter(field, arrayContains: value),
      };

  /// Prints the filter in polish notation
  @override
  String toString() => '$field ${operator._printable} $value';
  
  @override
  List<Object?> get props => [field, operator, value];
}

/// Compares [field] value to iterable [values] according the [IterableOperator]
class IterableValueStoreFilter extends Equatable implements StoreFilter {
  /// The field in document
  final String field;

  /// The operator used in comparison
  final IterableOperator iterableOperator;

  /// The iterable values to check
  final Iterable<Object?> values;

  /// Creates a iterable store filter
  const IterableValueStoreFilter({
    required this.field,
    required this.iterableOperator,
    required this.values,
  });

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
  String toString() => '$field ${iterableOperator._printable} $values';

  @override
  List<Object?> get props => [field, iterableOperator, values];
}

/// If [value] is `true`, checks if [field] is null. Otherwise checks [field]
///  is not null.
class IsNullStoreFilter extends Equatable implements StoreFilter {
  /// The field to check nullability
  final String field;

  /// if `true`, check nullability. If `false` checks non-nullability
  final bool value;

  /// creates a is null store filter
  const IsNullStoreFilter({required this.field, required this.value});

  /// Converts the is null store filter into a Firestore filter
  @override
  Filter toFirestore() => Filter(field, isNull: value);

  /// Prints the filter in polish notation
  @override
  String toString() => '$field is${value ? '' : 'Not'}Null';

  @override
  List<Object?> get props => [field, value];
}

/// Applies [LogicalOperator] to [StoreFilter]. If [LogicalOperator.and] all
/// [StoreFilter] must be satisfied.
/// If [LogicalOperator.or] at least one [StoreFilter] must be satisfied.
class LogicalStoreFilter extends Equatable implements StoreFilter {
  /// The logical operator applied to filters
  final LogicalOperator logicalOperator;

  /// The filter to evaluate
  final StoreFilter filter1;

  /// The filter to evaluate
  final StoreFilter filter2;

  /// The filter to evaluate
  final StoreFilter? filter3;

  /// The filter to evaluate
  final StoreFilter? filter4;

  /// The filter to evaluate
  final StoreFilter? filter5;

  /// The filter to evaluate
  final StoreFilter? filter6;

  /// The filter to evaluate
  final StoreFilter? filter7;

  /// The filter to evaluate
  final StoreFilter? filter8;

  /// The filter to evaluate
  final StoreFilter? filter9;

  /// The filter to evaluate
  final StoreFilter? filter10;

  /// The filter to evaluate
  final StoreFilter? filter11;

  /// The filter to evaluate
  final StoreFilter? filter12;

  /// The filter to evaluate
  final StoreFilter? filter13;

  /// The filter to evaluate
  final StoreFilter? filter14;

  /// The filter to evaluate
  final StoreFilter? filter15;

  /// The filter to evaluate
  final StoreFilter? filter16;

  /// The filter to evaluate
  final StoreFilter? filter17;

  /// The filter to evaluate
  final StoreFilter? filter18;

  /// The filter to evaluate
  final StoreFilter? filter19;

  /// The filter to evaluate
  final StoreFilter? filter20;

  /// The filter to evaluate
  final StoreFilter? filter21;

  /// The filter to evaluate
  final StoreFilter? filter22;

  /// The filter to evaluate
  final StoreFilter? filter23;

  /// The filter to evaluate
  final StoreFilter? filter24;

  /// The filter to evaluate
  final StoreFilter? filter25;

  /// The filter to evaluate
  final StoreFilter? filter26;

  /// The filter to evaluate
  final StoreFilter? filter27;

  /// The filter to evaluate
  final StoreFilter? filter28;

  /// The filter to evaluate
  final StoreFilter? filter29;

  /// The filter to evaluate
  final StoreFilter? filter30;

  /// Creates a logical filter
  const LogicalStoreFilter({
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

  @override
  List<Object?> get props => [
        filter1,
        filter2,
        filter3,
        filter4,
        filter5,
        filter6,
        filter7,
        filter8,
        filter9,
        filter10,
        filter11,
        filter12,
        filter13,
        filter14,
        filter15,
        filter16,
        filter17,
        filter18,
        filter19,
        filter20,
        filter21,
        filter22,
        filter23,
        filter24,
        filter25,
        filter26,
        filter27,
        filter28,
        filter29,
        filter30,
      ];
}
