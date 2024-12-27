import 'package:cloud_firestore/cloud_firestore.dart';

enum Operator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
}

enum IterableOperator {
  arrayContainsAny,
  whereIn,
  whereNotIn,
}

enum LogicalOperator { and, or }

abstract class StoreFilter {
  Filter toFirestore();
}

class ValueStoreFilter implements StoreFilter {
  String field;
  Operator operator;
  Object value;

  ValueStoreFilter(
      {required this.field, required this.operator, required this.value});

  @override
  Filter toFirestore() {
    return switch (operator) {
      Operator.isEqualTo => Filter(field, isEqualTo: value),
      Operator.isNotEqualTo => Filter(field, isNotEqualTo: value),
      Operator.isLessThan => Filter(field, isLessThan: value),
      Operator.isLessThanOrEqualTo => Filter(field, isLessThanOrEqualTo: value),
      Operator.isGreaterThan => Filter(field, isGreaterThan: value),
      Operator.isGreaterThanOrEqualTo =>
        Filter(field, isGreaterThanOrEqualTo: value),
      Operator.arrayContains => Filter(field, isEqualTo: value),
    };
  }

  @override
  String toString() {
    return "${operator.name}($field:$value)";
  }
}

class IterableValueStoreFilter implements StoreFilter {
  String field;
  IterableOperator iterableOperator;
  Iterable<Object?> values;

  IterableValueStoreFilter(
      {required this.field,
      required this.iterableOperator,
      required this.values});

  @override
  Filter toFirestore() {
    return switch (iterableOperator) {
      IterableOperator.arrayContainsAny =>
        Filter(field, arrayContainsAny: values),
      IterableOperator.whereIn => Filter(field, whereIn: values),
      IterableOperator.whereNotIn => Filter(field, whereNotIn: values),
    };
  }

  @override
  String toString() {
    return "${iterableOperator.name}($field:$values)";
  }
}

class IsNullStoreFilter implements StoreFilter {
  String field;
  bool value;

  IsNullStoreFilter({required this.field, required this.value});

  @override
  Filter toFirestore() {
    return Filter(field, isNull: value);
  }

  @override
  String toString() {
    return "isNull($field:$value)";
  }
}

class LogicalStoreFilter implements StoreFilter {
  LogicalOperator logicalOperator;
  StoreFilter filter1;
  StoreFilter filter2;
  StoreFilter? filter3;
  StoreFilter? filter4;
  StoreFilter? filter5;
  StoreFilter? filter6;
  StoreFilter? filter7;
  StoreFilter? filter8;
  StoreFilter? filter9;
  StoreFilter? filter10;
  StoreFilter? filter11;
  StoreFilter? filter12;
  StoreFilter? filter13;
  StoreFilter? filter14;
  StoreFilter? filter15;
  StoreFilter? filter16;
  StoreFilter? filter17;
  StoreFilter? filter18;
  StoreFilter? filter19;
  StoreFilter? filter20;
  StoreFilter? filter21;
  StoreFilter? filter22;
  StoreFilter? filter23;
  StoreFilter? filter24;
  StoreFilter? filter25;
  StoreFilter? filter26;
  StoreFilter? filter27;
  StoreFilter? filter28;
  StoreFilter? filter29;
  StoreFilter? filter30;
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

  @override
  Filter toFirestore() {
    return switch (logicalOperator) {
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
  }

  @override
  String toString() {
    return "${logicalOperator.name}("
        "$filter1 "
        "$filter2 "
        "${filter3 ?? ""}"
        "${filter4 ?? ""}"
        "${filter5 ?? ""}"
        "${filter6 ?? ""}"
        "${filter7 ?? ""}"
        "${filter8 ?? ""}"
        "${filter9 ?? ""}"
        "${filter10 ?? ""}"
        "${filter11 ?? ""}"
        "${filter12 ?? ""}"
        "${filter13 ?? ""}"
        "${filter14 ?? ""}"
        "${filter15 ?? ""}"
        "${filter16 ?? ""}"
        "${filter17 ?? ""}"
        "${filter18 ?? ""}"
        "${filter19 ?? ""}"
        "${filter20 ?? ""}"
        "${filter21 ?? ""}"
        "${filter22 ?? ""}"
        "${filter23 ?? ""}"
        "${filter24 ?? ""}"
        "${filter25 ?? ""}"
        "${filter26 ?? ""}"
        "${filter27 ?? ""}"
        "${filter28 ?? ""}"
        "${filter29 ?? ""}"
        "${filter30 ?? ""})";
  }
}
