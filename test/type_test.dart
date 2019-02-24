library data.test.type;

import 'dart:math' as math;

import 'package:data/src/shared/config.dart' as config;
import 'package:data/type.dart';
import 'package:test/test.dart';

void listTest<T>(DataType<T> type, List<List<T>> lists) {
  if ([
    DataType.float64,
    DataType.int64,
    DataType.boolean,
    DataType.string,
    DataType.object,
  ].contains(type)) {
    // Inference based on single example or runtime type.
    final exampleInstance = lists.expand((list) => list).first;
    final exampleType = exampleInstance.runtimeType;
    test('fromInstance: $exampleInstance', () {
      expect(DataType.fromInstance(exampleInstance), type,
          reason: 'DataType.fromInstance($exampleInstance)');
    });
    test('fromType: $exampleType', () {
      expect(DataType.fromType(exampleType), type,
          reason: 'DataType.fromType($exampleType)');
    });
  }
  if ([
    DataType.float64,
    DataType.int64,
    DataType.int32,
    DataType.int16,
    DataType.int8,
    DataType.uint64,
    DataType.uint32,
    DataType.uint16,
    DataType.uint8,
    DataType.boolean,
    DataType.string,
    DataType.object,
  ].contains(type)) {
    // Inference based on iterable of examples.
    for (var list in lists) {
      test('fromIterable: $list', () {
        expect(DataType.fromIterable(list), type,
            reason: 'DataType.fromIterable($list)');
      });
    }
  }
  if (![DataType.float32].contains(type)) {
    for (var list in lists) {
      test('convertList: $list', () {
        final result = type.convertList(list);
        expect(result.length, list.length);
        expect(type.convertList(list),
            pairwiseCompare(list, type.equality.isEqual, 'isEqual'),
            reason: '$type.convertList($list)');
      });
    }
  }
  final example = lists.last;
  test('copyList', () {
    final copy = type.copyList(example);
    expect(copy, pairwiseCompare(example, type.equality.isEqual, 'isEqual'));
  });
  test('copyList (smaller)', () {
    final copy = type.copyList(example, length: example.length - 1);
    expect(copy.length, example.length - 1);
    expect(
        copy,
        pairwiseCompare(example.getRange(0, example.length - 1),
            type.equality.isEqual, 'isEqual'));
  });
  test('copyList (larger)', () {
    final copy = type.copyList(example, length: example.length + 5);
    expect(copy.length, example.length + 5);
    expect(copy.getRange(0, example.length),
        pairwiseCompare(example, type.equality.isEqual, 'isEqual'));
    expect(
        copy.getRange(example.length, copy.length),
        pairwiseCompare(
            List.filled(5, type.nullValue), type.equality.isEqual, 'isEqual'));
  });
  test('copyList (larger, with custom fill)', () {
    final copy = type.copyList(example,
        length: example.length + 5, fillValue: example[0]);
    expect(copy.length, example.length + 5);
    expect(copy.getRange(0, example.length),
        pairwiseCompare(example, type.equality.isEqual, 'isEqual'));
    expect(
        copy.getRange(example.length, copy.length),
        pairwiseCompare(
            List.filled(5, example[0]), type.equality.isEqual, 'isEqual'));
  });
  test('printer', () {
    final printer = type.printer;
    final examples = lists.expand((list) => list).toList();
    for (var example in examples) {
      final printed = printer(example);
      expect(printed, contains(example.toString().substring(0, 1)));
    }
  });
}

void floatGroup(DataType type, int bits) {
  final name = 'float$bits';
  group('$name', () {
    test('name', () {
      expect(type.name, name);
      expect(type.toString(), 'DataType.$name');
    });
    test('nullable', () {
      expect(type.isNullable, isFalse);
      expect(type.nullValue, 0.0);
    });
    test('convert', () {
      expect(() => type.convert(null), throwsArgumentError);
      expect(type.convert(0), 0.0);
      expect(type.convert(1), 1.0);
      expect(type.convert(12.34), 12.34);
      expect(type.convert('123.45'), 123.45);
      expect(type.convert(Fraction(1, 2)), 0.5);
      expect(() => type.convert('abc'), throwsArgumentError);
    });
    listTest(type, <List<double>>[
      [math.pi, math.e],
      [-0.750, 1.5, 0.375],
    ]);
    fieldTest(type, <double>[-0.75, 1.5, 0.375]);
  });
  group('$name.nullable', () {
    final nullableType = type.nullable;
    test('name', () {
      expect(nullableType.name, '$name.nullable');
      expect(nullableType.toString(), 'DataType.$name.nullable');
    });
    test('equality', () {
      final sameNullableType = type.nullable;
      expect(nullableType, sameNullableType);
      expect(nullableType.hashCode, sameNullableType.hashCode);
    });
    test('nullable', () {
      expect(nullableType.isNullable, isTrue);
      expect(nullableType.nullValue, isNull);
      expect(nullableType.nullable, nullableType);
    });
    test('convert', () {
      expect(nullableType.convert(null), isNull);
      expect(nullableType.convert(0), 0.0);
      expect(nullableType.convert(1), 1.0);
      expect(nullableType.convert(12.34), 12.34);
      expect(nullableType.convert('123.45'), 123.45);
      expect(() => nullableType.convert('abc'), throwsArgumentError);
    });
    if (DataType.float64 == type) {
      listTest(nullableType, <List<double>>[
        [math.pi, null, math.e],
        [-1.1, 0.1, 1.1, null],
      ]);
    }
  });
}

void integerGroup(IntegerDataType type, bool isSigned, int bits) {
  final name = '${isSigned ? '' : 'u'}int$bits';
  group('$name', () {
    test('name', () {
      expect(type.name, name);
      expect(type.toString(), 'DataType.$name');
    });
    test('metadata', () {
      expect(type.isSigned, isSigned);
      expect(type.bits, bits);
    });
    test('min/max', () {
      if (type.isSigned) {
        expect(type.min, -math.pow(2, bits - 1));
        expect(type.max, math.pow(2, bits - 1) - 1);
      } else {
        expect(type.min, 0);
        expect(type.max, math.pow(2, bits) - 1);
      }
    });
    test('safe', () {
      if (type.bits <= 32) {
        expect(type.safeBits, type.bits);
        expect(type.safeMin, type.min);
        expect(type.safeMax, type.max);
      } else {
        expect(type.safeBits <= type.bits, isTrue);
        if (type.isSigned) {
          expect(type.safeMin, -math.pow(2, type.safeBits - 1));
          expect(type.safeMax, math.pow(2, type.safeBits - 1) - 1);
        } else {
          expect(type.safeMin, 0);
          expect(type.safeMax, math.pow(2, type.safeBits) - 1);
        }
      }
    });
    test('nullable', () {
      expect(type.isNullable, isFalse);
      expect(type.nullValue, 0);
    });
    test('convert', () {
      expect(() => type.convert(null), throwsArgumentError);
      expect(type.convert(0), 0);
      expect(type.convert(1), 1);
      expect(type.convert(12.34), 12);
      expect(type.convert('123'), 123);
      expect(type.convert(Fraction(2, 1)), 2);
      if (isSigned) {
        expect(type.convert(-12.34), -12);
        expect(type.convert('-123'), -123);
      }
      expect(() => type.convert('abc'), throwsArgumentError);
    });
    listTest(type, <List<int>>[
      [type.safeMin, 0, type.safeMax],
      [type.safeMin + 123, type.safeMax - 45, type.safeMax - 67],
    ]);
    fieldTest(type, <int>[-2, 5]);
  });
  group('$name.nullable', () {
    final nullableType = type.nullable;
    test('name', () {
      expect(nullableType.name, '$name.nullable');
      expect(nullableType.toString(), 'DataType.$name.nullable');
    });
    test('nullable', () {
      expect(nullableType.isNullable, isTrue);
      expect(nullableType.nullValue, isNull);
      expect(nullableType.nullable, nullableType);
    });
    test('convert', () {
      expect(nullableType.convert(null), isNull);
      expect(nullableType.convert(0), 0);
      expect(nullableType.convert(1), 1);
      expect(nullableType.convert(12.34), 12);
      if (isSigned) {
        expect(type.convert(-12.34), -12);
        expect(type.convert('-123'), -123);
      }
      expect(() => nullableType.convert('abc'), throwsArgumentError);
    });
    listTest(nullableType, <List<int>>[
      [type.safeMin, 0, null, type.safeMax, null],
      [type.safeMin + 123, type.safeMax - 45, null, type.safeMax - 67],
    ]);
  });
}

void compositeGroup<T, B>(
    CompositeDataType<T, B> type, DataType<B> base, int size) {
  group('${type.name}', () {
    test('name', () {
      expect(type.name, '${base.name}x$size');
      expect(type.toString(), 'DataType.${type.name}');
    });
    test('metadata', () {
      expect(type.base, base);
      expect(type.size, size);
    });
    test('nullable', () {
      expect(type.isNullable, isFalse);
      expect(type.toList(type.nullValue), everyElement(base.nullValue));
    });
    test('convert', () {
      expect(() => type.convert(null), throwsArgumentError);
      final expected = List.generate(size, (i) => i);
      final converted = type.convert(expected);
      final actual = type.toList(converted);
      expect(expected, actual);
    });
    listTest(type, <List<T>>[
      type.convertList([
        [1, 2, 3, 4],
        [5, 6, 7, 8],
      ]),
    ]);
  });
  group('${type.name}.nullable', () {
    final nullableType = type.nullable;
    test('name', () {
      expect(nullableType.name, '${type.name}.nullable');
      expect(nullableType.toString(), 'DataType.${type.name}.nullable');
    });
    test('nullable', () {
      expect(nullableType.isNullable, isTrue);
      expect(nullableType.nullValue, isNull);
      expect(nullableType.nullable, nullableType);
    });
  });
}

void fieldTest<T>(DataType<T> type, List<T> values) {
  const epsilon = 0.01;

  // field functions
  final neg = type.field.neg;
  final add = type.field.add;
  final sub = type.field.sub;
  final mul = type.field.mul;
  final inv = type.field.inv;
  final div = type.field.div;
  final scale = type.field.scale;
  final addId = type.field.additiveIdentity;
  final mulId = type.field.multiplicativeIdentity;

  // equality functions
  final isEqual = type.equality.isEqual;
  final isClose = type.equality.isClose;
  final hash = type.equality.hash;

  group('equality', () {
    test('isEqual', () {
      expect(isEqual(addId, mulId), isFalse);
      for (var value in values) {
        expect(isEqual(value, value), isTrue);
        expect(isEqual(value, addId), isFalse);
        expect(isEqual(value, mulId), isFalse);
      }
    });
    test('isClose', () {
      expect(isClose(addId, mulId, epsilon), isFalse);
      for (var value in values) {
        expect(isClose(value, value, epsilon), isTrue);
        expect(isClose(value, addId, epsilon), isFalse);
        expect(isClose(value, mulId, epsilon), isFalse);
      }
    });
    test('hash', () {
      expect(hash(addId), isNot(hash(mulId)));
      for (var value in values) {
        expect(hash(value), hash(value));
        expect(hash(value), isNot(hash(addId)));
        expect(hash(value), isNot(hash(mulId)));
      }
    });
  });
  group('field', () {
    test('neg', () {
      for (var value in values) {
        expect(isEqual(neg(neg(value)), value), isTrue);
        expect(isEqual(sub(addId, value), neg(value)), isTrue);
      }
    });
    test('add', () {
      for (var value in values) {
        expect(isEqual(add(value, addId), value), isTrue);
        expect(isEqual(add(addId, value), value), isTrue);
        expect(isEqual(add(value, neg(value)), addId), isTrue);
      }
    });
    test('sub', () {
      for (var value in values) {
        expect(isEqual(sub(value, addId), value), isTrue);
        expect(isEqual(sub(addId, value), neg(value)), isTrue);
        expect(isEqual(sub(addId, neg(value)), value), isTrue);
      }
    });
    if ([
      DataType.numeric,
      DataType.float32,
      DataType.float64,
      DataType.complex,
      DataType.quaternion,
      DataType.fraction,
    ].contains(type)) {
      test('inv', () {
        expect(isClose(inv(mulId), mulId, epsilon), isTrue);
        for (var value in values) {
          expect(isClose(inv(inv(value)), value, epsilon), isTrue);
        }
      });
      test('mul', () {
        for (var value in values) {
          expect(isClose(mul(value, inv(value)), mulId, epsilon), isTrue);
        }
      });
      test('div', () {
        for (var value in values) {
          expect(isClose(div(value, value), mulId, epsilon), isTrue);
        }
      });
    }
    test('scale', () {
      for (var value in values) {
        expect(isClose(scale(value, 2), add(value, value), epsilon), isTrue);
      }
    });
  });
}

void main() {
  group('object', () {
    const type = DataType.object;
    test('name', () {
      expect(type.name, 'object');
      expect(type.toString(), 'DataType.object');
    });
    test('nullable', () {
      expect(type.isNullable, isTrue);
      expect(type.nullValue, isNull);
      expect(type.nullable, type);
    });
    test('convert', () {
      expect(type.convert(null), isNull);
      expect(type.convert(123), 123);
      expect(type.convert('foo'), 'foo');
      expect(type.convert(true), true);
    });
    listTest(type, <List<Object>>[
      [],
      [Uri.parse('https://lukas-renggli.ch/')],
      [1, true],
      ['abc', 123],
    ]);
  });
  group('string', () {
    const type = DataType.string;
    test('name', () {
      expect(type.name, 'string');
      expect(type.toString(), 'DataType.string');
    });
    test('nullable', () {
      expect(type.isNullable, isTrue);
      expect(type.nullValue, isNull);
      expect(type.nullable, type);
    });
    test('convert', () {
      expect(type.convert(null), isNull);
      expect(type.convert(123), '123');
      expect(type.convert('foo'), 'foo');
      expect(type.convert(true), 'true');
    });
    listTest(type, <List<String>>[
      ['abc'],
      ['abc', null],
      ['abc', 'def'],
    ]);
  });
  group('numeric', () {
    const type = DataType.numeric;
    test('name', () {
      expect(type.name, 'numeric');
      expect(type.toString(), 'DataType.numeric');
    });
    test('nullable', () {
      expect(type.isNullable, isTrue);
      expect(type.nullValue, isNull);
      expect(type.nullable, type);
    });
    test('convert', () {
      expect(type.convert(null), isNull);
      expect(type.convert(123), 123);
      expect(type.convert(12.3), 12.3);
      expect(type.convert('123'), 123);
      expect(type.convert('123.4'), 123.4);
      expect(type.convert(Fraction(1, 2)), 0.5);
      expect(() => type.convert('abc'), throwsArgumentError);
      expect(() => type.convert(const Symbol('bad')), throwsArgumentError);
    });
    listTest(type, <List<num>>[
      [1, 2.3],
      [1, 2.3, null],
    ]);
    fieldTest(type, [-2, 2.3]);
  });
  group('boolean', () {
    const type = DataType.boolean;
    test('name', () {
      expect(type.name, 'boolean');
      expect(type.toString(), 'DataType.boolean');
    });
    test('nullable', () {
      expect(type.isNullable, isFalse);
      expect(type.nullValue, false);
    });
    test('convert', () {
      expect(() => type.convert(null), throwsArgumentError);
      expect(type.convert(true), isTrue);
      expect(type.convert(false), isFalse);
      expect(type.convert('true'), isTrue);
      expect(type.convert('false'), isFalse);
      expect(type.convert(1), isTrue);
      expect(type.convert(2), isTrue);
      expect(type.convert(0), isFalse);
      expect(() => type.convert('abc'), throwsArgumentError);
    });
    listTest(type, <List<bool>>[
      [true],
      [true, false],
    ]);
  });
  group('boolean.nullable', () {
    final type = DataType.boolean.nullable;
    test('name', () {
      expect(type.name, 'boolean.nullable');
      expect(type.toString(), 'DataType.boolean.nullable');
    });
    test('nullable', () {
      expect(type.isNullable, isTrue);
      expect(type.nullValue, isNull);
      expect(type.nullable, type);
    });
    test('convert', () {
      expect(type.convert(null), isNull);
      expect(type.convert(true), isTrue);
      expect(type.convert(false), isFalse);
      expect(type.convert('true'), isTrue);
      expect(type.convert('false'), isFalse);
      expect(type.convert(1), isTrue);
      expect(type.convert(2), isTrue);
      expect(type.convert(0), isFalse);
      expect(() => type.convert('abc'), throwsArgumentError);
    });
    listTest(type, <List<bool>>[
      [true, null],
      [true, false, null],
    ]);
  });
  integerGroup(DataType.int8, true, 8);
  integerGroup(DataType.uint8, false, 8);
  integerGroup(DataType.int16, true, 16);
  integerGroup(DataType.uint16, false, 16);
  integerGroup(DataType.int32, true, 32);
  integerGroup(DataType.uint32, false, 32);
  if (!config.isJavaScript) {
    /// int64 and uint64 are only supported in VM
    integerGroup(DataType.int64, true, 64);
    integerGroup(DataType.uint64, false, 64);
  }
  floatGroup(DataType.float32, 32);
  floatGroup(DataType.float64, 64);

  group('fraction', () {
    const type = DataType.fraction;
    test('name', () {
      expect(type.name, 'fraction');
      expect(type.toString(), 'DataType.fraction');
    });
    test('nullable', () {
      expect(type.isNullable, isTrue);
      expect(type.nullValue, null);
    });
    test('convert', () {
      expect(type.convert(null), isNull);
      expect(type.convert(Fraction(1, 2)), Fraction(1, 2));
      expect(type.convert(2), Fraction(2));
      expect(type.convert(0.5), Fraction(1, 2));
      expect(type.convert('1/2'), Fraction(1, 2));
      expect(() => type.convert(''), throwsArgumentError);
      expect(() => type.convert(const Symbol('bad')), throwsArgumentError);
    });
    fieldTest(type, [
      Fraction(1, 2),
      Fraction(-3, 4),
      Fraction(5, -6),
    ]);
  });
  group('complex', () {
    const type = DataType.complex;
    test('name', () {
      expect(type.name, 'complex');
      expect(type.toString(), 'DataType.complex');
    });
    test('nullable', () {
      expect(type.isNullable, isTrue);
      expect(type.nullValue, null);
    });
    test('convert', () {
      expect(type.convert(null), isNull);
      expect(type.convert(const Complex(1, 2)), const Complex(1, 2));
      expect(type.convert(2), const Complex(2));
      expect(type.convert(0.5), const Complex(0.5));
      expect(type.convert(Fraction(1, 2)), const Complex(0.5));
      expect(type.convert('1+2i'), const Complex(1, 2));
      expect(() => type.convert(''), throwsArgumentError);
      expect(() => type.convert(const Symbol('bad')), throwsArgumentError);
    });
    fieldTest(type, [
      const Complex(1, 2),
      const Complex(-3, 4),
      const Complex(5, -6),
    ]);
  });
  group('quaternion', () {
    const type = DataType.quaternion;
    test('name', () {
      expect(type.name, 'quaternion');
      expect(type.toString(), 'DataType.quaternion');
    });
    test('nullable', () {
      expect(type.isNullable, isTrue);
      expect(type.nullValue, null);
    });
    test('convert', () {
      expect(type.convert(null), isNull);
      expect(type.convert(const Quaternion(1, 2, 3, 4)),
          const Quaternion(1, 2, 3, 4));
      expect(type.convert(2), const Quaternion(2));
      expect(type.convert(0.5), const Quaternion(0.5));
      expect(type.convert(Fraction(1, 2)), const Quaternion(0.5));
      expect(type.convert(const Complex(1, 2)), const Quaternion(1, 2));
      expect(type.convert('1+2i+3j+4k'), const Quaternion(1, 2, 3, 4));
      expect(() => type.convert(''), throwsArgumentError);
      expect(() => type.convert(const Symbol('bad')), throwsArgumentError);
    });
    fieldTest(type, [
      const Quaternion(1, 2, 3, 4),
      const Quaternion(-3, 5, -7, 9),
    ]);
  });

//  compositeGroup(DataType.complex, DataType.float64, 2);
//  compositeGroup(DataType.quaternion, DataType.float32, 4);
//  compositeGroup(DataType.float64x2, DataType.float64, 2);
//  compositeGroup(DataType.float32x4, DataType.float32, 4);
//  compositeGroup(DataType.int32x4, DataType.int32, 4);
}
