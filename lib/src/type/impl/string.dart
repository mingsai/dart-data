library data.type.impl.string;

import 'dart:math' as math;

import '../../shared/config.dart';
import '../models/equality.dart';
import '../models/order.dart';
import 'object.dart';

class StringDataType extends ObjectDataType<String> {
  const StringDataType();

  @override
  String get name => 'string';

  @override
  Equality<String> get equality => const StringEquality();

  @override
  Order<String> get order => const NaturalOrder<String>();

  @override
  String cast(Object value) => value?.toString();
}

class StringEquality extends Equality<String> {
  const StringEquality();

  @override
  bool isClose(String a, String b, double epsilon) =>
      editDistance(a, b) < epsilon.ceil();
}

/// Computes the Levenshtein edit distance between two strings [a] and [b]:
/// https://en.wikipedia.org/wiki/Levenshtein_distance
int editDistance(String a, String b) {
  if (a.length < b.length) {
    return editDistance(b, a);
  }
  var v0 = indexDataType.newList(b.length + 1);
  var v1 = indexDataType.newList(b.length + 1);
  for (var i = 0; i <= b.length; i++) {
    v0[i] = i;
  }
  for (var i = 0; i < a.length; i++) {
    v1[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      v1[j + 1] = math.min(
        v0[j + 1] + 1,
        math.min(
          v1[j] + 1,
          a[i] == b[j] ? v0[j] : v0[j] + 1,
        ),
      );
    }
    final temp = v0;
    v0 = v1;
    v1 = temp;
  }
  return v0[b.length];
}
