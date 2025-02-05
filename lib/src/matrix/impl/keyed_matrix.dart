library data.matrix.impl.keyed;

import '../../../type.dart';
import '../matrix.dart';

/// Sparse keyed matrix.
class KeyedMatrix<T> extends Matrix<T> {
  final Map<int, T> _values;

  KeyedMatrix(DataType<T> dataType, int rowCount, int colCount)
      : this._(dataType, rowCount, colCount, <int, T>{});

  KeyedMatrix._(this.dataType, this.rowCount, this.colCount, this._values);

  @override
  final DataType<T> dataType;

  @override
  final int rowCount;

  @override
  final int colCount;

  @override
  Matrix<T> copy() =>
      KeyedMatrix._(dataType, rowCount, colCount, Map.of(_values));

  @override
  T getUnchecked(int row, int col) =>
      _values[row * colCount + col] ?? dataType.nullValue;

  @override
  void setUnchecked(int row, int col, T value) {
    final index = row * colCount + col;
    if (value == dataType.nullValue) {
      _values.remove(index);
    } else {
      _values[index] = value;
    }
  }
}
