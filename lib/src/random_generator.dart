import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:quiver/core.dart';

// TODO publish to pubdev and answer the following questions on stackoverflow:
// - https://stackoverflow.com/questions/57657287/generate-unique-random-numbers-in-dart
// - https://stackoverflow.com/questions/52576870/flutter-how-to-generate-random-numbers-without-duplication?rq=1

class OutOfRangeException implements Exception {

  final int num;
  const OutOfRangeException(this.num);

  @override
  String toString() => 'Number $num is out of range';
}


class NoMoreRandomNumberException implements Exception {
  final int min;
  final int max;

  const NoMoreRandomNumberException(this.min, this.max);

  @override
  String toString() => 'There are no more random numbers between $min and $max';
}

class ExclusiveRange {
  final int left;
  final int right;

  ExclusiveRange(this.left, this.right);

  bool contains(int x) => x > left && x < right;

  List<ExclusiveRange> split(int x) {
    return [ExclusiveRange(left, x), ExclusiveRange(x, right)];
  }

  int get length => right - left;

  bool get isEmpty => length <= 1;

  @override
  bool operator ==(o) =>
      o is ExclusiveRange && left == o.left && right == o.right;

  @override
  int get hashCode => hash2(left.hashCode, right.hashCode);
}

class SplittableExclusiveRange {
  final int min;
  final int max;

  final List<ExclusiveRange> _subRanges;

  SplittableExclusiveRange(this.min, this.max): assert(min < max), _subRanges = [ExclusiveRange(min, max)];

  void split(int x) {
    for (ExclusiveRange range in _subRanges) {
      if (range.contains(x)) {
        _subRanges.remove(range);
        List<ExclusiveRange> subRanges = range.split(x);
        _subRanges.addAll(subRanges.where((e) => !e.isEmpty));
        return;
      }
    }
    throw OutOfRangeException(x);
  }

  List<ExclusiveRange> get subRanges => List.unmodifiable(_subRanges);

  void reset() {
    _subRanges.clear();
    _subRanges.add(ExclusiveRange(min, max));
  }
}

/// A random generator with unique value each time...
class UniqueRandomGenerator {
  /// inclusive min value
  final int min;

  /// exclusive max value
  final int max;

  final bool autoReset;

  final Random _random = Random();
  final SplittableExclusiveRange _range;

  UniqueRandomGenerator({
    this.min = 1,
    @required this.max,
    this.autoReset = false,
  }) : _range = SplittableExclusiveRange(min - 1, max);

  /// Get next random number which is different than all random numbers
  /// that were previously generated
  int next() {
    List<ExclusiveRange> subRanges = _range.subRanges;
    if (subRanges == null || subRanges.isEmpty) {
      // All possible random numbers were already generated
      if (!autoReset) {
        throw NoMoreRandomNumberException(min, max);
      }
      reset();
      // update the local subRanges after reset...
      subRanges = _range.subRanges;
    }

    // choose a random range...
    ExclusiveRange range = subRanges[_random.nextInt(subRanges.length)];

    // choose a random number from the selected range
    int result = _random.nextInt(range.right - range.left - 1) + range.left + 1;

    // split the range so that this number won't be chosen again...
    _range.split(result);

    return result;
  }

  void reset() => _range.reset();

}
