library data.matrix.view.index;

import '../../../tensor.dart';
import '../../../type.dart';
import '../../shared/config.dart';
import '../matrix.dart';

/// Mutable indexed view of the rows and columns of a matrix.
class IndexMatrix<T> extends Matrix<T> {
  final Matrix<T> _matrix;
  final List<int> _rowIndexes;
  final List<int> _colIndexes;

  IndexMatrix(
      Matrix<T> _matrix, Iterable<int> rowIndexes, Iterable<int> colIndexes)
      : this._(_matrix, indexDataType.copyList(rowIndexes),
            indexDataType.copyList(colIndexes));

  IndexMatrix._(this._matrix, this._rowIndexes, this._colIndexes);

  @override
  DataType<T> get dataType => _matrix.dataType;

  @override
  int get rowCount => _rowIndexes.length;

  @override
  int get colCount => _colIndexes.length;

  @override
  Set<Tensor> get storage => _matrix.storage;

  @override
  Matrix<T> copy() => IndexMatrix._(_matrix.copy(), _rowIndexes, _colIndexes);

  @override
  T getUnchecked(int row, int col) =>
      _matrix.getUnchecked(_rowIndexes[row], _colIndexes[col]);

  @override
  void setUnchecked(int row, int col, T value) =>
      _matrix.setUnchecked(_rowIndexes[row], _colIndexes[col], value);

  @override
  Matrix<T> indexUnchecked(
          Iterable<int> rowIndexes, Iterable<int> colIndexes) =>
      IndexMatrix<T>(_matrix, rowIndexes.map((index) => _rowIndexes[index]),
          colIndexes.map((index) => _colIndexes[index]));
}
