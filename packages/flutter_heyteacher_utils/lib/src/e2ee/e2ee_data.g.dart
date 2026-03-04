// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2ee_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

E2EEValue _$E2EEValueFromJson(Map<String, dynamic> json) => E2EEValue(
  value: E2EEValue._unzip(json['value'] as String?),
  iv: E2EEValue._unzip(json['iv'] as String?),
);

Map<String, dynamic> _$E2EEValueToJson(E2EEValue instance) => <String, dynamic>{
  'value': E2EEValue._zip(instance.value),
  'iv': E2EEValue._zip(instance.iv),
};
