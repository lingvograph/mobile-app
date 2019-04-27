import 'dart:async';

T getOrElse<T>(Map<String, dynamic> map, String key, T orElse) {
  return map.containsKey(key) ? map[key] : orElse;
}

T firstOrElse<T>(Iterable<T> list, T orElse) {
  return list.firstWhere((t) => true, orElse: () => orElse);
}

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

// dart supports only one-to-six digit second fraction
DateTime parseTime(String s) {
  final p = new RegExp(r'\.(\d+)Z');
  final m = p.firstMatch(s);
  if (m != null) {
    final i = m.start;
    var f = m.group(1);
    if (f.length > 6) {
      f = f.substring(0, 6);
    }
    s = s.substring(0, i) + '.${f}Z';
  }
  return DateTime.parse(s);
}
