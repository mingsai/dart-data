library data.type.impl.numeric;

import 'dart:math' as math;

import 'package:data/src/type/models/equality.dart';
import 'package:data/src/type/models/field.dart';
import 'package:data/src/type/models/order.dart';
import 'package:data/src/type/type.dart';
import 'package:more/number.dart' show Fraction;

class NumericDataType extends DataType<num> {
  const NumericDataType();

  @override
  String get name => 'numeric';

  @override
  bool get isNullable => true;

  @override
  num get nullValue => null;

  @override
  Equality<num> get equality => const NumericEquality();

  @override
  Order<num> get order => const NaturalOrder<num>();

  @override
  Field<num> get field => const NumericField();

  @override
  num cast(Object value) {
    if (value == null || value is num) {
      return value;
    } else if (value is BigInt) {
      return value.toInt();
    } else if (value is Fraction) {
      return value.toDouble();
    } else if (value is String) {
      return num.tryParse(value) ?? super.cast(value);
    }
    return super.cast(value);
  }
}

class NumericField extends Field<num> {
  const NumericField();

  @override
  num get additiveIdentity => 0;

  @override
  num neg(num a) => -a;

  @override
  num add(num a, num b) => a + b;

  @override
  num sub(num a, num b) => a - b;

  @override
  num get multiplicativeIdentity => 1;

  @override
  num inv(num a) => 1 / a;

  @override
  num mul(num a, num b) => a * b;

  @override
  num scale(num a, num f) => a * f;

  @override
  num div(num a, num b) => a / b;

  @override
  num mod(num a, num b) => a % b;

  @override
  num pow(num a, num b) => math.pow(a, b);
}

class NumericEquality extends Equality<num> {
  const NumericEquality();

  @override
  bool isClose(num a, num b, double epsilon) => (a - b).abs() < epsilon;
}
