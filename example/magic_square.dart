library data.magic_square;

import 'dart:math' as math;

import 'package:data/matrix.dart' as matrix;
import 'package:data/type.dart';
import 'package:data/vector.dart' as vector;
import 'package:more/printer.dart' show Printer;

/// Builder for magic matrices.
final _builder = matrix.Matrix.builder.withType(DataType.int64);

/// Generates a magic square test matrix.
matrix.Matrix<int> magic(int n) {
  if (n.isOdd) {
    final a = (n + 1) ~/ 2;
    final b = n + 1;
    return _builder.generate(
      n,
      n,
      (r, c) => n * ((r + c + a) % n) + ((r + 2 * c + b) % n) + 1,
    );
  } else if (n % 4 == 0) {
    return _builder.generate(
      n,
      n,
      (r, c) => ((r + 1) ~/ 2) % 2 == ((c + 1) ~/ 2) % 2
          ? n * n - n * r - c
          : n * r + c + 1,
    );
  } else {
    final R = _builder(n);
    final p = n ~/ 2;
    final k = (n - 2) ~/ 4;
    final A = magic(p);
    for (var j = 0; j < p; j++) {
      for (var i = 0; i < p; i++) {
        final aij = A.get(i, j);
        R.set(i, j, aij);
        R.set(i, j + p, aij + 2 * p * p);
        R.set(i + p, j, aij + 3 * p * p);
        R.set(i + p, j + p, aij + p * p);
      }
    }
    for (var i = 0; i < p; i++) {
      for (var j = 0; j < k; j++) {
        final t = R.get(i, j);
        R.set(i, j, R.get(i + p, j));
        R.set(i + p, j, t);
      }
      for (var j = n - k + 1; j < n; j++) {
        final t = R.get(i, j);
        R.set(i, j, R.get(i + p, j));
        R.set(i + p, j, t);
      }
    }
    var t = R.get(k, 0);
    R.set(k, 0, R.get(k + p, 0));
    R.set(k + p, 0, t);
    t = R.get(k, k);
    R.set(k, k, R.get(k + p, k));
    R.set(k + p, k, t);
    return R;
  }
}

/// Printers for console output.
Printer integerPrinter() => Printer.fixed();
Printer doublePrinter(int precision) => Printer.fixed(precision: precision);
Printer alignPrinter(int width) => Printer.standard().padLeft(width);

/// Configuration of output printing.
const int width = 14;
const List<String> columns = [
  'n',
  'trace',
  'max_eig',
  'rank',
  'cond',
  'lu_res',
  'qr_res'
];

void main() {
  final eps = math.pow(2.0, -52.0);

  print(columns.map(alignPrinter(width)).join());
  print('');

  for (var n = 3; n <= 64; n++) {
    final m = magic(n);
    final md = m.map((row, col, value) => value.toDouble(), DataType.float64);

    final buffer = [];

    // Order of magic square.
    buffer.add(integerPrinter()(n));

    // Diagonal sum, should be the magic sum, (n^3 + n)/2.
    {
      final t = vector.sum(m.diagonal());
      buffer.add(integerPrinter()(t));
      assert(t == (n * n * n + n) / 2, 'invalid magic sum');
    }

    // Maximum eigenvalue of (A + A') / 2, should equal trace.
    {
      final e =
          matrix.eigenvalue(matrix.scale(matrix.add(md, md.transposed), 0.5));
      buffer.add(doublePrinter(3)(e.realEigenvalues.last));
      assert((e.realEigenvalues.last - vector.sum(m.diagonal())).abs() < 0.0001,
          'invalid eigenvalue');
    }

    // Linear algebraic rank, should equal n if n is odd, be less than n if n
    // is even.
    {
      final r = matrix.rank(m);
      buffer.add(integerPrinter()(r));
      assert(n.isOdd ? r == n : r < n, 'invalid rank');
    }

    // L_2 condition number, ratio of singular values.
    {
      final c = matrix.cond(m);
      buffer.add(doublePrinter(3)(c < 1 / eps ? c : double.infinity));
    }

    // Test of LU factorization, norm1(L*U-A(p,:))/(n*eps).
    {
      final lu = matrix.lu(m);
      final l = lu.lower;
      final u = lu.upper;
      final p = lu.pivot;
      final r = matrix.sub(matrix.mul(l, u), md.rowIndex(p));
      final res = matrix.norm1(r) / (n * eps);
      buffer.add(doublePrinter(3)(res));
    }

    // Test of QR factorization, norm1(Q*R-A)/(n*eps).
    {
      final qr = matrix.qr(md);
      final q = qr.orthogonal;
      final r = qr.upper;
      final R = matrix.sub(matrix.mul(q, r), m.cast(DataType.float64));
      final res = matrix.norm1(R) / (n * eps);
      buffer.add(doublePrinter(3)(res));
    }

    print(buffer.map(alignPrinter(width)).join());
  }
}
