import 'dart:async';

T firstByKey<T>(Map<String, T> map, String key, [bool eq = true]) {
  if (map.isEmpty) {
    return null;
  }
  var entry =
      map.entries.firstWhere((e) => (e.key == key) == eq, orElse: () => null);
  if (entry == null) {
    return null;
  }
  return entry.value;
}

const ms = const Duration(milliseconds: 1);

setTimeout(void callback(), [int milliseconds = 5]) {
  var duration = ms * milliseconds;
  return new Timer(duration, callback);
}
