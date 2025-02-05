library data.polynomial.view.differentiate;

import '../../../tensor.dart';
import '../../../type.dart';
import '../polynomial.dart';

/// Differentiate modifiable view of a polynomial.
class DifferentiatePolynomial<T> extends Polynomial<T> {
  final Polynomial<T> _polynomial;

  DifferentiatePolynomial(this._polynomial);

  @override
  DataType<T> get dataType => _polynomial.dataType;

  @override
  int get degree => _polynomial.degree <= 0 ? -1 : _polynomial.degree - 1;

  @override
  Set<Tensor> get storage => _polynomial.storage;

  @override
  Polynomial<T> copy() => DifferentiatePolynomial(_polynomial.copy());

  @override
  T getUnchecked(int exponent) => dataType.field.mul(
        _polynomial.getUnchecked(exponent + 1),
        dataType.cast(exponent + 1),
      );

  @override
  void setUnchecked(int exponent, T value) {
    _polynomial.setUnchecked(
      exponent + 1,
      dataType.field.div(
        value,
        dataType.cast(exponent + 1),
      ),
    );
  }
}
