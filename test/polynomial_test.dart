library data.test.polynomial;

import 'dart:math';

import 'package:data/polynomial.dart';
import 'package:data/type.dart';
import 'package:data/vector.dart' as vector;
import 'package:test/test.dart';

void polynomialTest(String name, Builder builder) {
  group(name, () {
    group('builder', () {
      test('call', () {
        final polynomial = builder.withType(DataType.int8)();
        expect(polynomial.dataType, DataType.int8);
        expect(polynomial.degree, -1);
        expect(polynomial.count, greaterThan(polynomial.degree));
        expect(polynomial.shape, [polynomial.degree]);
        expect(polynomial.storage, [polynomial]);
        for (var i = 0; i < 10; i++) {
          expect(polynomial[i], 0);
        }
      });
      test('call (with degree)', () {
        final polynomial = builder.withType(DataType.int8)(4);
        expect(polynomial.dataType, DataType.int8);
        expect(polynomial.degree, -1);
        expect(polynomial.count, greaterThan(polynomial.degree));
        expect(polynomial.shape, [polynomial.degree]);
        expect(polynomial.storage, [polynomial]);
        for (var i = 0; i < 10; i++) {
          expect(polynomial[i], 0);
        }
      });
      test('call, error', () {
        expect(() => builder(-2), throwsRangeError);
        expect(() => builder.withType(null)(4), throwsArgumentError);
        expect(() => builder.withFormat(null)(4), throwsArgumentError);
      });
      test('generate', () {
        final polynomial =
            builder.withType(DataType.int16).generate(7, (i) => i - 4);
        expect(polynomial.dataType, DataType.int16);
        expect(polynomial.degree, 7);
        expect(polynomial.count, greaterThan(polynomial.degree));
        expect(polynomial.shape, [polynomial.degree]);
        expect(polynomial.storage, [polynomial]);
        for (var i = 0; i <= polynomial.degree; i++) {
          expect(polynomial[i], i - 4);
        }
        expect(polynomial[8], 0);
        polynomial[3] = 42;
        expect(polynomial[3], 42);
      });
      test('generate, lazy', () {
        final polynomial = builder
            .withType(DataType.int16)
            .generate(7, (i) => i - 4, lazy: true);
        expect(polynomial.dataType, DataType.int16);
        expect(polynomial.degree, 7);
        expect(polynomial.count, greaterThan(polynomial.degree));
        expect(polynomial.shape, [polynomial.degree]);
        for (var i = 0; i <= polynomial.degree; i++) {
          expect(polynomial[i], i - 4);
        }
        expect(polynomial[8], 0);
        expect(() => polynomial[3] = 42, throwsUnsupportedError);
        final copy = polynomial.copy();
        expect(copy, same(polynomial));
      });
      group('differentiate', () {
        final p0 = builder.withType(DataType.int8).fromList([11, 7, 5, 2, 0]);
        final p1 = builder.withType(DataType.int8).fromList([7, 10, 6, 0, 0]);
        final p2 = builder.withType(DataType.int8).fromList([10, 12, 0, 0, 0]);
        test('default', () {
          final result = builder.withType(DataType.int32).differentiate(p0);
          expect(result.dataType, DataType.int32);
          expect(result.storage, [result]);
          expect(compare(result, p1), isTrue);
        });
        test('lazy', () {
          final result = builder.differentiate(p0, lazy: true);
          expect(result.dataType, p0.dataType);
          expect(result.storage, [p0]);
          expect(compare(result, p1), isTrue);
        });
        test('count', () {
          final result =
              builder.withType(DataType.int32).differentiate(p0, count: 2);
          expect(result.dataType, DataType.int32);
          expect(result.storage, [result]);
          expect(compare(result, p2), isTrue);
        });
        test('count, error', () {
          expect(() => builder.differentiate(p0, count: -1), throwsRangeError);
        });
      });
      group('integrate', () {
        final p0 = builder.withType(DataType.int8).fromList([7, 10, 6, 12]);
        final p1 = builder.withType(DataType.int8).fromList([0, 7, 5, 2, 3]);
        final p2 = builder.withType(DataType.int8).fromList([0, 0, 3, 1]);
        test('default', () {
          final result = builder.withType(DataType.int32).integrate(p0);
          expect(result.dataType, DataType.int32);
          expect(result.storage, [result]);
          expect(compare(result, p1), isTrue);
        });
        test('constant', () {
          final result =
              builder.withType(DataType.int32).integrate(p0, constant: 42);
          expect(result.dataType, DataType.int32);
          expect(result.storage, [result]);
          expect(
              compare(result,
                  builder.withType(DataType.int32).fromList([42, 7, 5, 2, 3])),
              isTrue);
        });
        test('lazy', () {
          final result = builder.integrate(p0, lazy: true);
          expect(result.dataType, p0.dataType);
          expect(result.storage, [p0]);
          expect(compare(result, p1), isTrue);
        });
        test('count', () {
          final result =
              builder.withType(DataType.int32).integrate(p0, count: 2);
          expect(result.dataType, DataType.int32);
          expect(result.storage, [result]);
          expect(compare(result, p2), isTrue);
        });
        test('count, zero', () {
          final result = builder.integrate(p0, count: 0, lazy: true);
          expect(result, p0);
        });
        test('count, error', () {
          expect(() => builder.integrate(p0, count: -1), throwsRangeError);
        });
      });
      test('fromPolynomial', () {
        final source =
            builder.withType(DataType.int8).generate(5, (i) => i - 2);
        final polynomial =
            builder.withType(DataType.int16).fromPolynomial(source);
        expect(polynomial.dataType, DataType.int16);
        expect(polynomial.degree, 5);
        expect(polynomial.count, greaterThan(polynomial.degree));
        expect(polynomial.shape, [polynomial.degree]);
        expect(polynomial.storage, [polynomial]);
        for (var i = 0; i <= polynomial.degree; i++) {
          expect(polynomial[i], i - 2);
        }
      });
      group('fromRoots', () {
        test('empty', () {
          final actual = builder.withType(DataType.int32).fromRoots([]);
          final expected = builder.withType(DataType.int32).fromList([]);
          expect(actual.toString(), expected.toString());
        });
        test('linear', () {
          final actual = builder.withType(DataType.int32).fromRoots([1]);
          final expected = builder.withType(DataType.int32).fromList([-1, 1]);
          expect(actual.toString(), expected.toString());
        });
        test('qubic', () {
          final actual = builder.withType(DataType.int32).fromRoots([1, -2]);
          final expected =
              builder.withType(DataType.int32).fromList([-2, 1, 1]);
          expect(actual.toString(), expected.toString());
        });
        test('septic', () {
          final actual = builder
              .withType(DataType.int32)
              .fromRoots([8, -4, -7, 3, 1, 1, 0]);
          final expected = builder
              .withType(DataType.int32)
              .fromList([0, 672, -1388, 691, 94, -68, -2, 1]);
          expect(actual.toString(), expected.toString());
        });
      });
      test('fromVector', () {
        final source =
            vector.Vector.builder.withType(DataType.int8).fromList([-1, 0, 2]);
        final polynomial = builder.withType(DataType.int8).fromVector(source);
        expect(polynomial.dataType, DataType.int8);
        expect(polynomial.degree, 2);
        expect(polynomial.count, greaterThan(polynomial.degree));
        expect(polynomial.shape, [polynomial.degree]);
        expect(polynomial.storage, [polynomial]);
        expect(polynomial[0], -1);
        expect(polynomial[1], 0);
        expect(polynomial[2], 2);
        expect(polynomial[3], 0);
      });
      test('fromList', () {
        final source = [-1, 0, 2];
        final polynomial = builder.withType(DataType.int8).fromList(source);
        expect(polynomial.dataType, DataType.int8);
        expect(polynomial.degree, 2);
        expect(polynomial.count, greaterThan(polynomial.degree));
        expect(polynomial.shape, [polynomial.degree]);
        expect(polynomial.storage, [polynomial]);
        expect(polynomial[0], -1);
        expect(polynomial[1], 0);
        expect(polynomial[2], 2);
        expect(polynomial[3], 0);
      });
    });
    group('accesssing', () {
      test('random', () {
        const degree = 100;
        final polynomial = builder(degree);
        final values = <int>[];
        for (var i = 0; i <= degree; i++) {
          values.add(i);
        }
        // add values
        values.shuffle();
        for (final value in values) {
          polynomial[value] = value;
        }
        for (var i = 0; i < values.length; i++) {
          expect(polynomial[i], i);
        }
        // update values
        values.shuffle();
        for (final value in values) {
          polynomial[value] = value + 1;
        }
        for (var i = 0; i < values.length; i++) {
          expect(polynomial[i], i + 1);
        }
        // remove values
        values.shuffle();
        for (final value in values) {
          polynomial[value] = polynomial.dataType.nullValue;
        }
        for (var i = 0; i < values.length; i++) {
          expect(polynomial[i], polynomial.dataType.nullValue);
        }
      });
      test('read (range error)', () {
        final polynomial = builder.withType(DataType.int8).fromList([1, 2]);
        expect(() => polynomial[-1], throwsRangeError);
        expect(polynomial[2], 0);
      });
      test('write (range error)', () {
        final polynomial = builder.withType(DataType.int8).fromList([1, 2]);
        expect(() => polynomial[-1] = 1, throwsRangeError);
        polynomial[2] = 3;
      });
    });
    group('evaluating', () {
      test('empty', () {
        final polynomial = builder.withType(DataType.int32)();
        expect(polynomial(-1), 0);
        expect(polynomial(0), 0);
        expect(polynomial(1), 0);
        expect(polynomial(2), 0);
      });
      test('constant', () {
        final polynomial = builder.withType(DataType.int32).fromList([2]);
        expect(polynomial(-1), 2);
        expect(polynomial(0), 2);
        expect(polynomial(1), 2);
        expect(polynomial(2), 2);
      });
      test('linear', () {
        final polynomial = builder.withType(DataType.int32).fromList([1, 2]);
        expect(polynomial(-1), -1);
        expect(polynomial(0), 1);
        expect(polynomial(1), 3);
        expect(polynomial(2), 5);
      });
      test('square', () {
        final polynomial = builder.withType(DataType.int32).fromList([2, 0, 3]);
        expect(polynomial(-1), 5);
        expect(polynomial(0), 2);
        expect(polynomial(1), 5);
        expect(polynomial(2), 14);
      });
    });
    group('roots', () {
      final epsilon = pow(2.0, -32.0);
      test('empty', () {
        final polynomial = builder.withType(DataType.int32)();
        final solutions = roots(polynomial);
        expect(solutions, isEmpty);
      });
      test('constant', () {
        final polynomial = builder.withType(DataType.int32).fromList([2]);
        final solutions = roots(polynomial);
        expect(solutions, isEmpty);
      });
      test('linear', () {
        final polynomial = builder.withType(DataType.int32).fromList([1, 2]);
        final solutions = roots(polynomial);
        expect(solutions, hasLength(1));
        expect(solutions[0].closeTo(const Complex(-0.5), epsilon), isTrue);
      });
      test('square', () {
        final polynomial = builder.withType(DataType.int32).fromList([2, 0, 3]);
        final solutions = roots(polynomial);
        expect(solutions, hasLength(2));
        expect(solutions[0].closeTo(Complex(0, sqrt(2 / 3)), epsilon), isTrue);
        expect(solutions[1].closeTo(Complex(0, -sqrt(2 / 3)), epsilon), isTrue);
      });
      test('cubic', () {
        final polynomial =
            builder.withType(DataType.int32).fromList([6, -5, -2, 1]);
        final solutions = roots(polynomial);
        expect(solutions, hasLength(3));
        expect(solutions[0].closeTo(const Complex(1), epsilon), isTrue);
        expect(solutions[1].closeTo(const Complex(3), epsilon), isTrue);
        expect(solutions[2].closeTo(const Complex(-2), epsilon), isTrue);
      });
      test('septic', () {
        final polynomial = builder
            .withType(DataType.int32)
            .fromList([5, -8, 7, -3, 0, -3, 5, -4]);
        final solutions = roots(polynomial);
        expect(solutions, hasLength(7));
        expect(
            solutions[0]
                .closeTo(const Complex(-0.8850843987, 0.6981874373), epsilon),
            isTrue);
        expect(
            solutions[1]
                .closeTo(const Complex(-0.8850843987, -0.6981874373), epsilon),
            isTrue);
        expect(
            solutions[2]
                .closeTo(const Complex(0.2543482521, 0.9163091163), epsilon),
            isTrue);
        expect(
            solutions[3]
                .closeTo(const Complex(0.2543482521, -0.9163091163), epsilon),
            isTrue);
        expect(
            solutions[4]
                .closeTo(const Complex(0.9247965171, 0.0000000000), epsilon),
            isTrue);
        expect(
            solutions[5]
                .closeTo(const Complex(0.7933378880, 0.7394177680), epsilon),
            isTrue);
        expect(
            solutions[6]
                .closeTo(const Complex(0.7933378880, -0.7394177680), epsilon),
            isTrue);
      });
    });
    group('view', () {
      group('differentiate', () {
        final cs0 = [11, 7, 5, 2, 0], cs1 = [7, 10, 6, 0, 0];
        test('read', () {
          final source = builder.withType(DataType.int16).fromList(cs0);
          final result = source.differentiate;
          expect(result.dataType, source.dataType);
          expect(result.storage, [source]);
          expect(result.degree, source.degree - 1);
          expect(compare(result.copy(), result), isTrue);
          for (var i = 0; i < cs1.length; i++) {
            expect(source[i], cs0[i]);
            expect(result[i], cs1[i]);
          }
        });
        test('write', () {
          final source = builder.withType(DataType.int16)();
          final result = source.differentiate;
          expect(result.degree, -1);
          for (var i = 0; i < cs1.length; i++) {
            result[i] = cs1[i];
          }
          for (var i = 0; i < cs1.length; i++) {
            expect(source[i], i == 0 ? 0 : cs0[i]);
            expect(result[i], cs1[i]);
          }
        });
      });
      group('integrate', () {
        final cs0 = [7, 10, 6, 12, 0, 0], cs1 = [0, 7, 5, 2, 3, 0];
        test('read', () {
          final source = builder.withType(DataType.int16).fromList(cs0);
          final result = source.integrate;
          expect(result.dataType, source.dataType);
          expect(result.storage, [source]);
          expect(result.degree, source.degree + 1);
          expect(compare(result.copy(), result), isTrue);
          for (var i = 0; i < cs1.length; i++) {
            expect(source[i], cs0[i]);
            expect(result[i], cs1[i]);
          }
        });
        test('write', () {
          final source = builder.withType(DataType.int16)();
          final result = source.integrate;
          expect(result.degree, -1);
          for (var i = 0; i < cs1.length; i++) {
            result[i] = cs1[i];
          }
          for (var i = 0; i < cs1.length; i++) {
            expect(source[i], cs0[i]);
            expect(result[i], cs1[i]);
          }
        });
      });
      test('copy', () {
        final source = builder.generate(7, (i) => i - 4);
        final copy = source.copy();
        expect(copy.dataType, source.dataType);
        expect(copy.degree, source.degree);
        expect(copy.count, source.count);
        expect(copy.storage, [copy]);
        for (var i = source.degree; i >= 0; i--) {
          source[i] = i.isEven ? 0 : -i;
          copy[i] = i.isEven ? -i : 0;
        }
        for (var i = source.degree; i >= 0; i--) {
          expect(source[i], i.isEven ? 0 : -i);
          expect(copy[i], i.isEven ? -i : 0);
        }
      });
      test('unmodifiable', () {
        final source =
            builder.withType(DataType.int64).generate(7, (i) => i + 1);
        final readonly = source.unmodifiable;
        expect(readonly.dataType, source.dataType);
        expect(readonly.degree, 7);
        expect(readonly.storage, [source]);
        expect(readonly.unmodifiable, readonly);
        expect(compare(readonly.copy(), readonly), isTrue);
        for (var i = readonly.degree; i >= 0; i--) {
          expect(readonly[i], i + 1);
          expect(() => readonly[i] = i, throwsUnsupportedError);
        }
        for (var i = source.degree; i >= 0; i--) {
          expect(source[i], i + 1);
          source[i] = -source[i];
        }
        for (var i = readonly.degree; i >= 0; i--) {
          expect(readonly[i], -i - 1);
        }
      });
      group('format', () {
        test('empty', () {
          final polynomial =
              builder.withType(DataType.int8).fromCoefficients([]);
          expect(polynomial.format(), '0');
        });
        test('constant', () {
          final polynomial =
              builder.withType(DataType.int8).fromCoefficients([1]);
          expect(polynomial.format(), '1');
        });
        test('2th-degree', () {
          final polynomial =
              builder.withType(DataType.int8).fromCoefficients([1, 2]);
          expect(polynomial.format(), 'x + 2');
        });
        test('3rd-degree', () {
          final polynomial =
              builder.withType(DataType.int8).fromCoefficients([1, 2, 3]);
          expect(polynomial.format(), 'x^2 + 2 x + 3');
        });
        test('null values (skipped)', () {
          final polynomial =
              builder.withType(DataType.int8).fromCoefficients([2, 0, 0, 1]);
          expect(polynomial.format(), '2 x^3 + 1');
        });
        test('null values (not skipped)', () {
          final polynomial =
              builder.withType(DataType.int8).fromCoefficients([2, 0, 1]);
          expect(polynomial.format(skipNulls: false), '2 x^2 + 0 x + 1');
        });
        test('limit', () {
          final polynomial =
              builder.withType(DataType.int8).generate(19, (i) => i - 10);
          expect(polynomial.format(),
              '9 x^19 + 8 x^18 + 7 x^17 + … + -8 x^2 + -9 x + -10');
        });
      });
      test('toString', () {
        final polynomial =
            builder.withType(DataType.int8).fromCoefficients([1, 2, 3]);
        expect(
            polynomial.toString(),
            '${polynomial.runtimeType}'
            '[2, ${polynomial.dataType.name}]:\n'
            'x^2 + 2 x + 3');
      });
    });
    group('iterables', () {
      test('basic', () {
        final source =
            builder.withType(DataType.int16).generate(4, (i) => i - 2);
        final list = source.iterable;
        expect(list, [-2, -1, 0, 1, 2]);
        expect(list.length, source.degree + 1);
        expect(() => list.length = 0, throwsUnsupportedError);
        list[2] = 42;
        expect(list, [-2, -1, 42, 1, 2]);
        source[2] = 43;
        expect(list, [-2, -1, 43, 1, 2]);
      });
    });
    group('operators', () {
      final random = Random();
      final sourceA = builder
          .withType(DataType.int32)
          .generate(100, (i) => random.nextInt(100));
      final sourceB = builder
          .withType(DataType.int32)
          .generate(100, (i) => random.nextInt(100));
      test('unary', () {
        final result = unaryOperator(sourceA, (a) => a * a);
        expect(result.dataType, sourceA.dataType);
        expect(result.degree, sourceA.degree);
        for (var i = 0; i <= result.degree; i++) {
          final a = sourceA[i];
          expect(result[i], a * a);
        }
      });
      test('binary', () {
        final result =
            binaryOperator(sourceA, sourceB, (a, b) => a * a + b * b);
        expect(result.dataType, sourceA.dataType);
        expect(result.degree, sourceA.degree);
        for (var i = 0; i <= result.degree; i++) {
          final a = sourceA[i];
          final b = sourceB[i];
          expect(result[i], a * a + b * b);
        }
      });
      group('add', () {
        test('default', () {
          final result = add(sourceA, sourceB);
          expect(result.dataType, sourceA.dataType);
          expect(result.degree, sourceA.degree);
          for (var i = 0; i <= result.degree; i++) {
            expect(result[i], sourceA[i] + sourceB[i]);
          }
        });
        test('default, different degree', () {
          final sourceB = builder.withType(DataType.int8).fromList([1, 2]);
          final result = add(sourceA, sourceB);
          expect(result.dataType, sourceA.dataType);
          expect(result.degree, sourceA.degree);
          for (var i = 0; i <= result.degree; i++) {
            expect(result[i], sourceA[i] + sourceB[i]);
          }
        });
        test('target', () {
          final target = builder.withType(DataType.int16)(sourceA.degree);
          final result = add(sourceA, sourceB, target: target);
          expect(target.dataType, DataType.int16);
          expect(target.degree, sourceA.degree);
          for (var i = 0; i <= target.degree; i++) {
            expect(target[i], sourceA[i] + sourceB[i]);
          }
          expect(result, target);
        });
        test('target, different degree', () {
          final target = builder.withType(DataType.int16)(2);
          final result = add(sourceA, sourceB, target: target);
          expect(target.dataType, DataType.int16);
          expect(target.degree, sourceA.degree);
          for (var i = 0; i <= target.degree; i++) {
            expect(target[i], sourceA[i] + sourceB[i]);
          }
          expect(result, target);
        });
        test('builder', () {
          final result =
              add(sourceA, sourceB, builder: builder.withType(DataType.int16));
          expect(result.dataType, DataType.int16);
          expect(result.degree, sourceA.degree);
          for (var i = 0; i <= result.degree; i++) {
            expect(result[i], sourceA[i] + sourceB[i]);
          }
        });
      });
      test('sub', () {
        final target = sub(sourceA, sourceB);
        expect(target.dataType, sourceA.dataType);
        expect(target.degree, sourceA.degree);
        for (var i = 0; i <= target.degree; i++) {
          expect(target[i], sourceA[i] - sourceB[i]);
        }
      });
      test('neg', () {
        final target = neg(sourceA);
        expect(target.dataType, sourceA.dataType);
        expect(target.degree, sourceA.degree);
        for (var i = 0; i <= target.degree; i++) {
          expect(target[i], -sourceA[i]);
        }
      });
      test('scale', () {
        final target = scale(sourceA, 2);
        expect(target.dataType, sourceA.dataType);
        expect(target.degree, sourceA.degree);
        for (var i = 0; i < target.degree; i++) {
          expect(target[i], 2 * sourceA[i]);
        }
      });
      group('lerp', () {
        final v0 = builder.withType(DataType.float32).fromList([1, 6, 8]);
        final v1 = builder.withType(DataType.float32).fromList([9, -2, 8]);
        test('at start', () {
          final p = lerp(v0, v1, 0.0);
          expect(p.dataType, v1.dataType);
          expect(p.degree, v1.degree);
          expect(p[0], v0[0]);
          expect(p[1], v0[1]);
          expect(p[2], v0[2]);
        });
        test('at middle', () {
          final p = lerp(v0, v1, 0.5);
          expect(p.dataType, v1.dataType);
          expect(p.degree, v1.degree);
          expect(p[0], 5.0);
          expect(p[1], 2.0);
          expect(p[2], 8.0);
        });
        test('at end', () {
          final p = lerp(v0, v1, 1.0);
          expect(p.dataType, v1.dataType);
          expect(p.degree, v1.degree);
          expect(p[0], v1[0]);
          expect(p[1], v1[1]);
          expect(p[2], v1[2]);
        });
        test('at outside', () {
          final p = lerp(v0, v1, 2.0);
          expect(p.dataType, v1.dataType);
          expect(p.degree, v1.degree);
          expect(p[0], 17.0);
          expect(p[1], -10.0);
          expect(p[2], 8.0);
        });
        test('different degree', () {
          final v3 = builder.withType(DataType.float32).fromList([9, -2]);
          final p = lerp(v0, v3, 0.5);
          expect(p.dataType, v0.dataType);
          expect(p.degree, v0.degree);
          expect(p[0], 5.0);
          expect(p[1], 2.0);
          expect(p[2], 4.0);
        });
      });
      group('compare', () {
        test('identity', () {
          expect(compare(sourceA, sourceA), isTrue);
          expect(compare(sourceB, sourceB), isTrue);
          expect(compare(sourceA, sourceB), isFalse);
          expect(compare(sourceB, sourceA), isFalse);
        });
        test('custom', () {
          final negated = neg(sourceA);
          expect(compare(sourceA, negated), isFalse);
          expect(compare(sourceA, negated, equals: (a, b) => a == -b), isTrue);
        });
      });
    });
  });
}

void main() {
  polynomialTest('standard', Polynomial.builder.standard);
  polynomialTest('keyed', Polynomial.builder.keyed);
  polynomialTest('list', Polynomial.builder.list);
}
