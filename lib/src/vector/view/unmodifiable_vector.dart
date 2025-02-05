library data.vector.view.unmodifiable;

import '../../../tensor.dart';
import '../../../type.dart';
import '../mixins/unmodifiable_vector.dart';
import '../vector.dart';

/// Read-only view of a mutable vector.
class UnmodifiableVector<T> extends Vector<T> with UnmodifiableVectorMixin<T> {
  final Vector<T> _vector;

  UnmodifiableVector(this._vector);

  @override
  DataType<T> get dataType => _vector.dataType;

  @override
  int get count => _vector.count;

  @override
  Set<Tensor> get storage => _vector.storage;

  @override
  Vector<T> copy() => UnmodifiableVector(_vector.copy());

  @override
  T getUnchecked(int index) => _vector.getUnchecked(index);
}
