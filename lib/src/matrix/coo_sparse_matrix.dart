library data.matrix.coo_sparse_matrix;

import 'dart:math' as math;

import 'package:data/src/type/type.dart';

import 'sparse_matrix.dart';

const int _initialSize = 4;
const DataType<int> _indexDataType = DataType.int32;

// Coordinate list (COO)
// COO stores a list of (row, column, value) tuples. Ideally, the entries are sorted first by row index and then by column index, to improve random access times. This is another format that is good for incremental matrix construction.[3]
class COOSparseMatrix<T> extends SparseMatrix<T> {
  @override
  final DataType<T> dataType;

  @override
  final int rowCount;

  @override
  final int colCount;

  List<int> _rows;
  List<int> _cols;
  List<T> _vals;
  int _length;

  COOSparseMatrix(this.dataType, this.rowCount, this.colCount)
      : _rows = _indexDataType.newList(_initialSize),
        _cols = _indexDataType.newList(_initialSize),
        _vals = dataType.newList(_initialSize),
        _length = 0;

  int _binarySearch(int row, int col) {
    var min = 0;
    var max = _length;
    while (min < max) {
      final mid = min + ((max - min) >> 1);
      final rowAtMid = _rows[mid], colAtMid = _cols[mid];
      if (rowAtMid == row && colAtMid == col) {
        return mid;
      } else if (rowAtMid < row || (rowAtMid == row && colAtMid < col)) {
        min = mid + 1;
      } else {
        max = mid;
      }
    }
    return -min - 1;
  }

  @override
  T get(int row, int col) {
    final index = _binarySearch(row, col);
    return index < 0 ? dataType.nullValue : _vals[index];
  }

  @override
  void set(int row, int col, T val) {
    final index = _binarySearch(row, col);
    if (val == null || val == dataType.nullValue) {
      // Remove the tuple from the lists, if present:
      if (index >= 0) {
        _rows.setRange(index, _length - 1, _rows.getRange(index + 1, _length));
        _cols.setRange(index, _length - 1, _cols.getRange(index + 1, _length));
        _vals.setRange(index, _length - 1, _vals.getRange(index + 1, _length));
        _rows[_length] = _cols[_length] = 0;
        _vals[_length] = dataType.nullValue;
        _length--;
      }
    } else {
      if (index < 0) {
        // Tuple absent: add a new tuple
        if (_vals.length == _length) {
          final newSize = math.min(_length + _length >> 1, rowCount * colCount);
          _rows = _indexDataType.copyList(_rows, length: newSize);
          _cols = _indexDataType.copyList(_cols, length: newSize);
          _vals = dataType.copyList(_vals, length: newSize);
        }
        _rows.setRange(-index, _length + 1, _rows.getRange(-index - 1, _length));
        _cols.setRange(-index, _length + 1, _cols.getRange(-index - 1, _length));
        _vals.setRange(-index, _length + 1, _vals.getRange(-index - 1, _length));
        _rows[-index - 1] = row;
        _cols[-index - 1] = col;
        _vals[-index - 1] = val;
        _length++;
      } else {
        // Tuple present: update value
        _vals[index] = val;
      }
    }
  }
}
