library data.vector.view.range;

import '../../../tensor.dart';
import '../../../type.dart';
import '../vector.dart';

/// Mutable range of a vector.
class RangeVector<T> extends Vector<T> {
  final Vector<T> _vector;
  final int _start;

  RangeVector(Vector<T> vector, int start, int end)
      : this._(vector, start, end - start);

  RangeVector._(this._vector, this._start, this.count);

  @override
  DataType<T> get dataType => _vector.dataType;

  @override
  final int count;

  @override
  Set<Tensor> get storage => _vector.storage;

  @override
  Vector<T> copy() => RangeVector._(_vector.copy(), _start, count);

  @override
  T getUnchecked(int index) => _vector.getUnchecked(_start + index);

  @override
  void setUnchecked(int index, T value) =>
      _vector.setUnchecked(_start + index, value);

  @override
  Vector<T> rangeUnchecked(int start, int end) =>
      RangeVector(_vector, _start + start, _start + end);
}
