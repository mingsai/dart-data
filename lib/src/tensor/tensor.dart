library data.tensor.tensor;

import 'package:more/printer.dart' show Printer;

import '../../type.dart' show DataType;

/// Abstract tensor type.
abstract class Tensor<T> {
  /// Returns the data type of this tensor.
  DataType<T> get dataType;

  /// Returns the dimensions of this tensor.
  List<int> get shape;

  /// Returns the underlying storage containers of this tensor.
  Set<Tensor> get storage => {this};

  /// Returns a copy of this tensor.
  Tensor<T> copy();

  /// Returns a tensor or a scalar at the provided [index].
  Object operator [](int index);

  /// Returns a human readable representation of this tensor.
  String format({
    Printer valuePrinter,
    Printer paddingPrinter,
    Printer ellipsesPrinter,
    bool limit = true,
    int leadingItems = 3,
    int trailingItems = 3,
  });

  /// Returns the string representation of this tensor.
  @override
  String toString() => '$runtimeType[${shape.join(', ')}, ${dataType.name}]:\n'
      '${format()}';
}
