import 'package:livo/livo.dart';

class ReactiveList<T> extends ReactiveModel {
  final List<T> _items;

  ReactiveList([List<T>? initial]) : _items = initial ?? [];

  List<T> get value => List.unmodifiable(_items);

  int get length => _items.length;

  T operator [](int index) => _items[index];

  void add(T item) {
    _items.add(item);
    notifyListeners(#add);
  }

  void remove(T item) {
    _items.remove(item);
    notifyListeners(#remove);
  }

  void clear() {
    _items.clear();
    notifyListeners(#clear);
  }

  void replace(int index, T item) {
    _items[index] = item;
    notifyListeners(#replace);
  }
}
