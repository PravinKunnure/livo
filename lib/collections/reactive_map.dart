import 'package:livo/livo.dart';

class ReactiveMap<K, V> extends ReactiveModel {
  final Map<K, V> _map;

  ReactiveMap([Map<K, V>? initial]) : _map = initial ?? {};

  Map<K, V> get value => Map.unmodifiable(_map);

  V? operator [](K key) => _map[key];

  void put(K key, V value) {
    _map[key] = value;
    notifyListeners(#put);
  }

  void remove(K key) {
    _map.remove(key);
    notifyListeners(#remove);
  }

  void clear() {
    _map.clear();
    notifyListeners(#clear);
  }
}
