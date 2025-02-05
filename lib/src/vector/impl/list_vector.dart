library data.vector.impl.list;

import '../../../type.dart';
import '../../shared/config.dart';
import '../../shared/lists.dart';
import '../vector.dart';

/// Sparse compressed vector.
class ListVector<T> extends Vector<T> {
  List<int> _indexes;
  List<T> _values;
  int _length;

  ListVector(DataType<T> dataType, int count)
      : this._(dataType, count, indexDataType.newList(initialListLength),
            dataType.newList(initialListLength), 0);

  ListVector._(
      this.dataType, this.count, this._indexes, this._values, this._length);

  @override
  final DataType<T> dataType;

  @override
  final int count;

  @override
  Vector<T> copy() => ListVector._(dataType, count,
      indexDataType.copyList(_indexes), dataType.copyList(_values), _length);

  @override
  T getUnchecked(int index) {
    final pos = binarySearch(_indexes, 0, _length, index);
    return pos < 0 ? dataType.nullValue : _values[pos];
  }

  @override
  void setUnchecked(int index, T value) {
    final pos = binarySearch(_indexes, 0, _length, index);
    if (pos < 0) {
      if (value != dataType.nullValue) {
        _indexes = insertAt(indexDataType, _indexes, _length, -pos - 1, index);
        _values = insertAt(dataType, _values, _length, -pos - 1, value);
        _length++;
      }
    } else {
      if (value == dataType.nullValue) {
        _indexes = removeAt(indexDataType, _indexes, _length, pos);
        _values = removeAt(dataType, _values, _length, pos);
        _length--;
      } else {
        _values[pos] = value;
      }
    }
  }
}
