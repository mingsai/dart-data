library data.matrix.view.cast;

import '../../../tensor.dart';
import '../../../type.dart';
import '../matrix.dart';

/// Mutable matrix cast to a new type.
class CastMatrix<S, T> extends Matrix<T> {
  final Matrix<S> _matrix;

  CastMatrix(this._matrix, this.dataType);

  @override
  final DataType<T> dataType;

  @override
  int get rowCount => _matrix.rowCount;

  @override
  int get colCount => _matrix.colCount;

  @override
  Set<Tensor> get storage => _matrix.storage;

  @override
  Matrix<T> copy() => CastMatrix(_matrix.copy(), dataType);

  @override
  T getUnchecked(int row, int col) =>
      dataType.cast(_matrix.getUnchecked(row, col));

  @override
  void setUnchecked(int row, int col, T value) =>
      _matrix.setUnchecked(row, col, _matrix.dataType.cast(value));
}
