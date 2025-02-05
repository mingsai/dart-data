import 'dart:math' as math;

import 'package:more/number.dart';

import '../shared/config.dart' as config;
import 'impl/integer.dart';
import 'type.dart';

/// Derives a fitting [DataType] from [Object] [instance].
DataType fromInstance(Object instance) => fromType(instance.runtimeType);

/// Derives a fitting [DataType] from a runtime [Type] [type].
DataType fromType(Type type) {
  switch (type) {
    case double:
      return config.floatDataType;
    case int:
      return config.intDataType;
    case num:
      return DataType.numeric;
    case bool:
      return DataType.boolean;
    case String:
      return DataType.string;
    case BigInt:
      return DataType.bigInt;
    case Fraction:
      return DataType.fraction;
    case Complex:
      return DataType.complex;
    case Quaternion:
      return DataType.quaternion;
    default:
      return DataType.object;
  }
}

/// Derives a fitting [DataType] from an [Iterable] of [values].
DataType fromIterable(Iterable values) {
  if (values.isEmpty) {
    return DataType.object;
  }

  var nullCount = 0;
  var boolCount = 0;
  var stringCount = 0;
  var intCount = 0;
  var doubleCount = 0;
  var numberCount = 0;
  num minValue = double.infinity;
  num maxValue = double.negativeInfinity;

  for (final value in values) {
    if (value == null) {
      nullCount++;
    } else if (value is bool) {
      boolCount++;
    } else if (value is String) {
      stringCount++;
    } else if (value is num) {
      minValue = math.min(minValue, value);
      maxValue = math.max(maxValue, value);
      numberCount++;
      if (config.isJavaScript) {
        // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isInteger#Polyfill
        if (value.isFinite && value.floor() == value) {
          intCount++;
        } else {
          doubleCount++;
        }
      } else {
        if (value is int) {
          intCount++;
        } else if (value is double) {
          doubleCount++;
        }
      }
    } else {
      return DataType.object;
    }
  }

  DataType resolve() {
    if (boolCount > 0 && stringCount == 0 && numberCount == 0) {
      return DataType.boolean;
    } else if (boolCount == 0 && stringCount > 0 && numberCount == 0) {
      return DataType.string;
    } else if (boolCount == 0 && stringCount == 0 && numberCount > 0) {
      if (intCount > 0 && doubleCount == 0) {
        for (final dataType in _intDataTypes) {
          if (dataType.safeMin <= minValue &&
              minValue <= dataType.safeMax &&
              dataType.safeMin <= maxValue &&
              maxValue <= dataType.safeMax) {
            return dataType;
          }
        }
      } else if (intCount == 0 && doubleCount > 0) {
        return DataType.float64;
      }
      return DataType.numeric;
    }
    return DataType.object;
  }

  return nullCount == 0 ? resolve() : resolve().nullable;
}

const List<IntegerDataType> _intDataTypes = [
  DataType.uint8,
  DataType.int8,
  DataType.uint16,
  DataType.int16,
  DataType.uint32,
  DataType.int32,
  DataType.uint64,
  DataType.int64,
];
