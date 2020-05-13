import 'package:flutter_test/flutter_test.dart';

import 'package:uniquerandomgenerator/uniquerandomgenerator.dart';

void main() {
  test('random generator', () {
    int min = 5, max = 10;
    UniqueRandomGenerator generator = UniqueRandomGenerator(min: min, max: max);
    List<int> numbers = List();

    try {
      while (true) {
        int num = generator.next();
        assert(!numbers.contains(num));
        numbers.add(num);
      }
    } catch (e) {
      assert (e is NoMoreRandomNumberException);
      expect(numbers.length, max - min);
    }
  });
}
