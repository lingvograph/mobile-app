import 'package:flutter_test/flutter_test.dart';

import 'package:memoapp/utils.dart';

void main() {
  test('parse time', () {
    var date = parseTime('2019-04-26T16:41:31.646258705Z');
    expect(date.year, equals(2019));
    expect(date.month, equals(4));
    expect(date.day, equals(26));
    expect(date.hour, equals(16));
    expect(date.minute, equals(41));
    expect(date.second, equals(31));
  });
}
