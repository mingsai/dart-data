library data.matrix.mixins.unmodifiable;

import '../matrix.dart';

/// Mixin for unmodifiable matrices.
mixin UnmodifiableMatrixMixin<T> implements Matrix<T> {
  @override
  Matrix<T> get unmodifiable => this;

  @override
  void setUnchecked(int row, int col, T value) =>
      throw UnsupportedError('Matrix is not mutable.');
}
