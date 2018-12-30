library data.vector.builder;

import 'package:data/type.dart';

import 'format.dart';
import 'impl/constant_vector.dart';
import 'impl/keyed_vector.dart';
import 'impl/list_vector.dart';
import 'impl/standard_vector.dart';
import 'vector.dart';

/// Builds a vector of a custom type.
class Builder<T> {
  /// Constructors a builder with the provided storage [format] and data [type].
  Builder(this.format, this.type);

  /// Returns the storage format of the builder.
  final Format format;

  /// Returns the data type of the builder.
  final DataType<T> type;

  /// Returns a builder for standard vectors.
  Builder<T> get standard => withFormat(Format.standard);

  /// Returns a builder for list vectors.
  Builder<T> get list => withFormat(Format.list);

  /// Returns a builder for keyed vectors.
  Builder<T> get keyed => withFormat(Format.keyed);

  /// Returns a builder with the provided storage [format].
  Builder<T> withFormat(Format format) =>
      this.format == format ? this : Builder<T>(format, type);

  /// Returns a builder with the provided data [type].
  Builder<S> withType<S>(DataType<S> type) =>
      // ignore: unrelated_type_equality_checks
      this.type == type ? this : Builder<S>(format, type);

  /// Builds a new vector of the configured format.
  Vector<T> call(int count) {
    RangeError.checkNotNegative(count, 'count');
    switch (format) {
      case Format.standard:
        return StandardVector<T>(type, count);
      case Format.list:
        return ListVector<T>(type, count);
      case Format.keyed:
        return KeyedVector<T>(type, count);
    }
    throw ArgumentError.value(format, 'format');
  }

  /// Builds a vector with a constant [value].
  Vector<T> constant(int count, T value, {bool mutable = false}) {
    if (mutable) {
      final result = this(count);
      for (var i = 0; i < count; i++) {
        result.setUnchecked(i, value);
      }
      return result;
    } else {
      return ConstantVector(type, count, value);
    }
  }

  /// Builds a vector from calling a [callback] on every value.
  Vector<T> generate(int count, T Function(int) callback) {
    final result = this(count);
    for (var i = 0; i < count; i++) {
      result.setUnchecked(i, callback(i));
    }
    return result;
  }

  /// Builds a vector by transforming another one with a [callback].
  Vector<T> transform<S>(Vector<S> source, T Function(int, S) callback) {
    final result = this(source.count);
    for (var i = 0; i < result.count; i++) {
      result.setUnchecked(i, callback(i, source.getUnchecked(i)));
    }
    return result;
  }

  /// Builds a vector from another vector.
  Vector<T> fromVector(Vector<T> source) {
    final result = this(source.count);
    for (var i = 0; i < result.count; i++) {
      result.setUnchecked(i, source.getUnchecked(i));
    }
    return result;
  }

  /// Builds a vector from a list of values.
  Vector<T> fromList(List<T> source) {
    if (Format.standard == format) {
      // Optimized case for flat vectors.
      return StandardVector.internal(type, type.copyList(source));
    }
    final result = this(source.length);
    for (var i = 0; i < source.length; i++) {
      result.setUnchecked(i, source[i]);
    }
    return result;
  }
}
