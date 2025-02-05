library data.type.models.order;

import 'package:meta/meta.dart';

/// Encapsulates a total order of objects.
@immutable
abstract class Order<T> {
  const Order();

  int compare(T a, T b);
}

/// Wraps around the natural order of objects.
class NaturalOrder<T extends Comparable> extends Order<T> {
  const NaturalOrder();

  @override
  int compare(T a, T b) => a.compareTo(b);
}
