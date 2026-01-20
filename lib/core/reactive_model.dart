// --------------------------
// reactive_model.dart
// --------------------------

import 'package:flutter/material.dart';
import 'package:livo/livo.dart';

/// Reaction container for field or object-specific callbacks
class _Reaction<T extends ReactiveModel> {
  final List<Symbol>? fields; // null = listen to all fields
  final void Function(T) callback;
  final bool once;

  _Reaction({this.fields, required this.callback, this.once = false});
}

typedef VoidCallback = void Function();

/// Base ReactiveModel
class ReactiveModel {
  // ----------------------------
  // Core fields
  // ----------------------------
  final Map<Symbol, List<VoidCallback>> _fieldListeners = {};
  final List<ReactiveModel> _nestedModels = [];
  final List<_Reaction> _reactions = [];

  bool _isBatching = false;
  final Set<Symbol> _batchedFields = {};
  bool _disposed = false;

  /// Debug flag for development
  bool debugNotify = false;

  // ----------------------------
  // Read-only getters for DevTools / Inspector
  // ----------------------------
  Map<Symbol, List<VoidCallback>> get fieldListeners =>
      Map.unmodifiable(_fieldListeners);
  List<ReactiveModel> get nestedModels => List.unmodifiable(_nestedModels);

  // ----------------------------
  // Add / Remove listeners
  // ----------------------------
  void addListener(VoidCallback listener, {Symbol? field}) {
    final key = field ?? #*;
    final list = _fieldListeners.putIfAbsent(key, () => []);
    if (!list.contains(listener)) list.add(listener);
  }

  void removeListener(VoidCallback listener, {Symbol? field}) {
    final key = field ?? #*;
    _fieldListeners[key]?.remove(listener);
  }

  // ----------------------------
  // Notify listeners
  // ----------------------------
  void notifyListeners([Symbol? field]) {
    if (_isBatching) {
      if (field != null) _batchedFields.add(field);
      return;
    }

    if (debugNotify) {
      debugPrint('ReactiveModel($runtimeType) notify: $field');
    }

    final notified = <VoidCallback>{};

    // Field-specific listeners
    for (final l in List<VoidCallback>.from(
      _fieldListeners[field] ?? const [],
    )) {
      if (notified.add(l)) l();
    }

    // Global listeners
    for (final l in List<VoidCallback>.from(_fieldListeners[#*] ?? const [])) {
      if (notified.add(l)) l();
    }

    // Run reactions
    final toRemove = <_Reaction>[];
    for (final r in _reactions) {
      if (r.fields == null || (field != null && r.fields!.contains(field))) {
        r.callback(this);
        if (r.once) toRemove.add(r);
      }
    }
    _reactions.removeWhere((r) => toRemove.contains(r));
  }

  // ----------------------------
  // Nested models
  // ----------------------------
  void addNested(ReactiveModel nested, {Symbol? field}) {
    if (_nestedModels.contains(nested)) return;
    _nestedModels.add(nested);

    nested.addListener(() {
      if (debugNotify) {
        debugPrint(
          'Nested change: ${nested.runtimeType} -> ${field ?? #nested}',
        );
      }
      notifyListeners(field ?? #nested);
    });
  }

  void removeNested(ReactiveModel nested) {
    if (!_nestedModels.contains(nested)) return;
    _nestedModels.remove(nested);
  }

  // ----------------------------
  // Batch updates
  // ----------------------------
  void batch(VoidCallback fn) {
    _isBatching = true;
    try {
      fn();
    } finally {
      _isBatching = false;
      for (final field in _batchedFields) {
        notifyListeners(field);
      }
      _batchedFields.clear();
    }
  }

  // ----------------------------
  // Dispose
  // ----------------------------
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _fieldListeners.clear();
    for (final nested in _nestedModels) {
      nested.dispose();
    }
    _nestedModels.clear();
  }

  // ----------------------------
  // Reactions / Hooks
  // ----------------------------
  void once(VoidCallback callback, {Symbol? field}) {
    void wrapper() {
      removeListener(wrapper, field: field);
      callback();
    }

    addListener(wrapper, field: field);
  }

  void reaction<V>(
    V Function() selector,
    void Function(V value) callback, {
    List<Symbol>? fields,
  }) {
    V? lastValue;
    final r = _Reaction(
      fields: fields,
      once: false,
      callback: (ReactiveModel _) {
        final newValue = selector();
        if (lastValue != newValue) {
          lastValue = newValue;
          callback(newValue);
        }
      },
    );
    _reactions.add(r);
    r.callback(this); // initial run
  }

  void when(
    bool Function() condition,
    VoidCallback callback, {
    List<Symbol>? fields,
  }) {
    final r = _Reaction(
      fields: fields,
      once: true,
      callback: (_) {
        if (condition()) callback();
      },
    );
    _reactions.add(r);
    r.callback(this); // check immediately
  }

  void listen({
    List<Symbol>? fields,
    required void Function(ReactiveModel) callback,
  }) {
    _reactions.add(_Reaction(fields: fields, callback: callback, once: false));
  }

  // ----------------------------
  // ----------------------------
  // v1.2.x Relationship helpers
  // ----------------------------
  /// Many → One
  void addRelation(ReactiveModel child, {Symbol? field}) =>
      addNested(child, field: field);

  void removeRelation(ReactiveModel child) => removeNested(child);

  /// Many ↔ Many helper
  void shareRelation(ReactiveModel other, {Symbol? field}) {
    addNested(other, field: field);
    other.addNested(this, field: field);
  }

  void unshareRelation(ReactiveModel other) {
    removeNested(other);
    other.removeNested(this);
  }
}

/// ----------------------------
/// v1.2.x Watch helpers (field/computed)
/// ----------------------------
extension ReactiveWatchHelpers on ReactiveModel {
  /// Watch a specific field
  Widget watchField(Symbol field, Widget Function() builder) {
    return ReactiveBuilder<ReactiveModel>(
      model: this,
      fields: [field],
      builder: (_) => builder(),
    );
  }

  /// Watch a computed value
  Widget watchComputed<T>(
    T Function() compute,
    Widget Function(T value) builder,
  ) {
    T cachedValue = compute();
    return ReactiveBuilder<ReactiveModel>(
      model: this,
      builder: (_) {
        final newValue = compute();
        if (cachedValue != newValue) cachedValue = newValue;
        return builder(cachedValue);
      },
    );
  }
}

///Version 1.1.2
// // --------------------------
// // reactive_model.dart
// // --------------------------
//
// import 'package:flutter/material.dart';
//
// class _Reaction<T extends ReactiveModel> {
//   final List<Symbol>? fields; // null = listen to all fields
//   final void Function(T) callback;
//   final bool once;
//   //dynamic _lastValue;
//
//   _Reaction({this.fields, required this.callback, this.once = false});
// }
//
//
//
// typedef VoidCallback = void Function();
//
// class ReactiveModel {
//   final Map<Symbol, List<VoidCallback>> _fieldListeners = {};
//   final List<ReactiveModel> _nestedModels = [];
//   final List<_Reaction> _reactions = [];
//
//   bool _isBatching = false;
//   final Set<Symbol> _batchedFields = {};
//   bool _disposed = false;
//
//   /// Debug flag for development
//   bool debugNotify = false;
//
//   /// ----------------------------
//   /// Add listener
//   /// ----------------------------
//   void addListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*;
//     final list = _fieldListeners.putIfAbsent(key, () => []);
//     if (!list.contains(listener)) {
//       list.add(listener);
//     }
//   }
//
//   void removeListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*;
//     _fieldListeners[key]?.remove(listener);
//   }
//
//   /// ----------------------------
//   /// Notify listeners
//   /// ----------------------------
//   // void notifyListeners([Symbol? field]) {
//   //   if (_isBatching) {
//   //     if (field != null) _batchedFields.add(field);
//   //     return;
//   //   }
//   //
//   //   if (debugNotify) {
//   //     debugPrint('ReactiveModel($runtimeType) notify: $field');
//   //   }
//   //
//   //   final notified = <VoidCallback>{};
//   //
//   //   // Field-specific listeners
//   //   final fieldListeners = List<VoidCallback>.from(
//   //     _fieldListeners[field] ?? const [],
//   //   );
//   //   for (final l in fieldListeners) {
//   //     if (notified.add(l)) l();
//   //   }
//   //
//   //   // Global listeners
//   //   final globalListeners = List<VoidCallback>.from(
//   //     _fieldListeners[#*] ?? const [],
//   //   );
//   //   for (final l in globalListeners) {
//   //     if (notified.add(l)) l();
//   //   }
//   // }
//
//   void notifyListeners([Symbol? field]) {
//     if (_isBatching) {
//       if (field != null) _batchedFields.add(field);
//       return;
//     }
//
//     if (debugNotify) {
//       debugPrint('ReactiveModel($runtimeType) notify: $field');
//     }
//
//     final notified = <VoidCallback>{};
//
//     // Field-specific listeners
//     final fieldListeners = List<VoidCallback>.from(
//       _fieldListeners[field] ?? const [],
//     );
//     for (final l in fieldListeners) {
//       if (notified.add(l)) l();
//     }
//
//     // Global listeners
//     final globalListeners = List<VoidCallback>.from(
//       _fieldListeners[#*] ?? const [],
//     );
//     for (final l in globalListeners) {
//       if (notified.add(l)) l();
//     }
//
//     // ------------------------
//     // Run reactions
//     // ------------------------
//     final toRemove = <_Reaction>[];
//     for (final r in _reactions) {
//       // If fields is null, run always; else check if field is included
//       if (r.fields == null || (field != null && r.fields!.contains(field))) {
//         r.callback(this);
//         if (r.once) toRemove.add(r);
//       }
//     }
//     _reactions.removeWhere((r) => toRemove.contains(r));
//   }
//
//
//   /// ----------------------------
//   /// Nested models
//   /// ----------------------------
//   void addNested(ReactiveModel nested, {Symbol? field}) {
//     if (_nestedModels.contains(nested)) return;
//     _nestedModels.add(nested);
//
//     nested.addListener(() {
//       if (debugNotify) {
//         debugPrint(
//           'Nested change: ${nested.runtimeType} -> ${field ?? #nested}',
//         );
//       }
//       notifyListeners(field ?? #nested);
//     });
//   }
//
//   /// ----------------------------
//   /// Batch updates
//   /// ----------------------------
//   void batch(VoidCallback fn) {
//     _isBatching = true;
//     try {
//       fn();
//     } finally {
//       _isBatching = false;
//       for (final field in _batchedFields) {
//         notifyListeners(field);
//       }
//       _batchedFields.clear();
//     }
//   }
//
//   /// ----------------------------
//   /// Dispose
//   /// ----------------------------
//   void dispose() {
//     if (_disposed) return;
//     _disposed = true;
//
//     _fieldListeners.clear();
//     for (final nested in _nestedModels) {
//       nested.dispose();
//     }
//     _nestedModels.clear();
//   }
//
//   // ----------------------------
//   // Optional hooks for v1.1.0
//   // ----------------------------
//
//   // void listen(VoidCallback callback, {Symbol? field}) {
//   //   addListener(callback, field: field);
//   // }
//
//   void once(VoidCallback callback, {Symbol? field}) {
//     void wrapper() {
//       removeListener(wrapper, field: field);
//       callback();
//     }
//
//     addListener(wrapper, field: field);
//   }
//
//   // void reaction<V>(V Function() selector, void Function(V value) callback) {
//   //   V? lastValue;
//   //   void listener() {
//   //     final newValue = selector();
//   //     if (lastValue != newValue) {
//   //       lastValue = newValue;
//   //       callback(newValue);
//   //     }
//   //   }
//   //
//   //   addListener(listener);
//   //   listener(); // initial call
//   // }
//   //
//   // void when(bool Function() condition, VoidCallback callback) {
//   //   void listener() {
//   //     if (condition()) {
//   //       removeListener(listener);
//   //       callback();
//   //     }
//   //   }
//   //
//   //   addListener(listener);
//   //   listener();
//   // }
//
//   void reaction<V>(
//       V Function() selector,
//       void Function(V value) callback, {
//         List<Symbol>? fields,
//       }) {
//     V? lastValue;
//     final r = _Reaction(
//       fields: fields,
//       once: false,
//       callback: (ReactiveModel _) {
//         final newValue = selector();
//         if (lastValue != newValue) {
//           lastValue = newValue;
//           callback(newValue);
//         }
//       },
//     );
//     _reactions.add(r);
//     r.callback(this); // initial run
//   }
//
//   void when(bool Function() condition, VoidCallback callback, {List<Symbol>? fields}) {
//     final r = _Reaction(
//       fields: fields,
//       once: true,
//       callback: (_) {
//         if (condition()) {
//           callback();
//         }
//       },
//     );
//     _reactions.add(r);
//     r.callback(this); // check immediately
//   }
//
//   void listen({List<Symbol>? fields, required void Function(ReactiveModel) callback}) {
//     _reactions.add(_Reaction(fields: fields, callback: callback, once: false));
//   }
//
// }

///Version 1.0.1
// // --------------------------
// // reactive_model.dart
// // --------------------------
//
// import 'package:flutter/material.dart';
//
// typedef VoidCallback = void Function();
//
// class ReactiveModel {
//   final Map<Symbol, List<VoidCallback>> _fieldListeners = {};
//   final List<ReactiveModel> _nestedModels = [];
//
//   bool _isBatching = false;
//   final Set<Symbol> _batchedFields = {};
//   bool _disposed = false;
//
//   /// Debug flag for development
//   bool debugNotify = false;
//
//   /// ----------------------------
//   /// Add listener
//   /// ----------------------------
//   void addListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*;
//     final list = _fieldListeners.putIfAbsent(key, () => []);
//     if (!list.contains(listener)) {
//       list.add(listener);
//     }
//   }
//
//   void removeListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*;
//     _fieldListeners[key]?.remove(listener);
//   }
//
//   /// ----------------------------
//   /// Notify listeners
//   /// ----------------------------
//   void notifyListeners([Symbol? field]) {
//     if (_isBatching) {
//       if (field != null) _batchedFields.add(field);
//       return;
//     }
//
//     if (debugNotify) {
//       debugPrint("ReactiveModel($runtimeType) notify: $field");
//     }
//
//     final notified = <VoidCallback>{};
//
//     // Field-specific listeners
//     final fieldListeners = List<VoidCallback>.from(
//       _fieldListeners[field] ?? const [],
//     );
//     for (final l in fieldListeners) {
//       if (notified.add(l)) l();
//     }
//
//     // Global listeners
//     final globalListeners = List<VoidCallback>.from(
//       _fieldListeners[#*] ?? const [],
//     );
//     for (final l in globalListeners) {
//       if (notified.add(l)) l();
//     }
//   }
//
//   /// ----------------------------
//   /// Nested models
//   /// ----------------------------
//   void addNested(ReactiveModel nested, {Symbol? field}) {
//     if (_nestedModels.contains(nested)) return;
//     _nestedModels.add(nested);
//
//     nested.addListener(() {
//       if (debugNotify) {
//         debugPrint(
//           'Nested change: ${nested.runtimeType} -> ${field ?? #nested}',
//         );
//       }
//       notifyListeners(field ?? #nested);
//     });
//   }
//
//   /// ----------------------------
//   /// Batch updates
//   /// ----------------------------
//   void batch(VoidCallback fn) {
//     _isBatching = true;
//     try {
//       fn();
//     } finally {
//       _isBatching = false;
//       for (final field in _batchedFields) {
//         notifyListeners(field);
//       }
//       _batchedFields.clear();
//     }
//   }
//
//   /// ----------------------------
//   /// Dispose
//   /// ----------------------------
//   void dispose() {
//     if (_disposed) return;
//     _disposed = true;
//
//     _fieldListeners.clear();
//     for (final nested in _nestedModels) {
//       nested.dispose();
//     }
//     _nestedModels.clear();
//   }
// }

///Version 1.0.0
// typedef VoidCallback = void Function();
//
// class ReactiveModel {
//   final Map<Symbol, List<VoidCallback>> _fieldListeners = {};
//   final List<ReactiveModel> _nestedModels = [];
//
//   bool _isBatching = false;
//   final Set<Symbol> _batchedFields = {}; // ✅ WHY Set? Explained below
//
//   /// ----------------------------
//   /// Add listener
//   /// ----------------------------
//   void addListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*; // wildcard
//     _fieldListeners.putIfAbsent(key, () => []).add(listener);
//   }
//
//   void removeListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*;
//     _fieldListeners[key]?.remove(listener);
//   }
//
//   /// ----------------------------
//   /// Notify listeners
//   /// ----------------------------
//   void notifyListeners([Symbol? field]) {
//     if (_isBatching) {
//       if (field != null) _batchedFields.add(field);
//       return;
//     }
//
//     final notified = <VoidCallback>{};
//
//     // Field-specific
//     if (field != null) {
//       for (final l in _fieldListeners[field] ?? []) {
//         if (notified.add(l)) l();
//       }
//     }
//
//     // Global listeners
//     for (final l in _fieldListeners[#*] ?? []) {
//       if (notified.add(l)) l();
//     }
//   }
//
//   /// ----------------------------
//   /// Nested models
//   /// ----------------------------
//   void addNested(ReactiveModel nested) {
//     if (_nestedModels.contains(nested)) return;
//     _nestedModels.add(nested);
//     nested.addListener(() => notifyListeners());
//   }
//
//   /// ----------------------------
//   /// Batch updates
//   /// ----------------------------
//   void batch(VoidCallback fn) {
//     _isBatching = true;
//     try {
//       fn();
//     } finally {
//       _isBatching = false;
//       for (final field in _batchedFields) {
//         notifyListeners(field);
//       }
//       _batchedFields.clear();
//     }
//   }
//
//   /// ----------------------------
//   /// Dispose
//   /// ----------------------------
//   void dispose() {
//     _fieldListeners.clear();
//     for (final nested in _nestedModels) {
//       nested.dispose();
//     }
//     _nestedModels.clear();
//   }
// }

///Version 0.0.9
// typedef VoidCallback = void Function();
//
// class ReactiveModel {
//   final Map<Symbol, List<VoidCallback>> _fieldListeners = {};
//   final List<ReactiveModel> _nestedModels = [];
//   bool _isBatching = false;
//   final Set<Symbol> _batchedFields = {};
//
//   // Add listener for a specific field or all fields
//   void addListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*; // #* = wildcard for all fields
//     _fieldListeners.putIfAbsent(key, () => []).add(listener);
//   }
//
//   void removeListener(VoidCallback listener, {Symbol? field}) {
//     final key = field ?? #*;
//     _fieldListeners[key]?.remove(listener);
//   }
//
//   void notifyListeners([Symbol? field]) {
//     if (_isBatching) {
//       if (field != null) _batchedFields.add(field);
//       return;
//     }
//
//     final notified = <VoidCallback>{};
//
//     // Field-specific listeners
//     if (field != null) {
//       for (final l in _fieldListeners[field] ?? []) {
//         if (!notified.contains(l)) {
//           l();
//           notified.add(l);
//         }
//       }
//     }
//
//     // Global listeners
//     for (final l in _fieldListeners[#*] ?? []) {
//       if (!notified.contains(l)) {
//         l();
//         notified.add(l);
//       }
//     }
//   }
//
//   void addNested(ReactiveModel nested) {
//     if (_nestedModels.contains(nested)) return; // prevent duplicates
//     _nestedModels.add(nested);
//     nested.addListener(() => notifyListeners());
//   }
//
//   /// Batch updates to avoid multiple rebuilds
//   void batch(VoidCallback fn) {
//     _isBatching = true;
//     try {
//       fn();
//     } finally {
//       _isBatching = false;
//       for (var field in _batchedFields) {
//         notifyListeners(field);
//       }
//       _batchedFields.clear();
//     }
//   }
//
//   /// Debug helper: returns listener counts per field
//   Map<String, int> get listenerCount {
//     return {
//       for (var entry in _fieldListeners.entries)
//         '${entry.key}': entry.value.length,
//     };
//   }
//
//   /// Dispose all listeners
//   void dispose() {
//     _fieldListeners.clear();
//     for (var nested in _nestedModels) {
//       nested.dispose();
//     }
//     _nestedModels.clear();
//   }
// }

///Version 0.0.7
// import 'dart:ui';
//
// class ReactiveModel {
//   // Field-specific listeners: field name -> listeners
//   final Map<String, List<VoidCallback>> _fieldListeners = {};
//
//   // Add listener for a specific field or all fields if field == null
//   void addListener(VoidCallback listener, {String? field}) {
//     final key = field ?? '*'; // '*' = wildcard for all-fields listeners
//     _fieldListeners.putIfAbsent(key, () => []).add(listener);
//   }
//
//   void removeListener(VoidCallback listener, {String? field}) {
//     final key = field ?? '*';
//     _fieldListeners[key]?.remove(listener);
//   }
//
//   // Notify listeners for a specific field, or all if field == null
//   void notifyListeners([String? field]) {
//     if (field != null) {
//       for (final listener in _fieldListeners[field] ?? []) {
//         listener();
//       }
//     }
//
//     // Notify global listeners
//     for (final listener in _fieldListeners['*'] ?? []) {
//       listener();
//     }
//   }
//
//   // Nested reactive model support
//   void addNested(ReactiveModel nested, {String? field}) {
//     nested.addListener(() => notifyListeners(field));
//   }
// }

///Try Version
// import 'dart:async';
// import 'dart:ui';
//
// class ReactiveModel {
//   // Map of field name → listeners
//   final Map<String, List<VoidCallback>> _fieldListeners = {};
//
//   // Add listener for a specific field or all fields if field == null
//   void addListener(VoidCallback listener, {String? field}) {
//     final key = field ?? '*'; // '*' is a special key for all-fields listeners
//     _fieldListeners.putIfAbsent(key, () => []).add(listener);
//   }
//
//   // Remove listener
//   void removeListener(VoidCallback listener, {String? field}) {
//     final key = field ?? '*';
//     _fieldListeners[key]?.remove(listener);
//   }
//
//   // Notify listeners
//   void notifyListeners([String? field]) {
//     if (field != null) {
//       for (final listener in _fieldListeners[field] ?? []) {
//         listener();
//       }
//     }
//
//     // Notify global listeners
//     for (final listener in _fieldListeners['*'] ?? []) {
//       listener();
//     }
//   }
// }

///Version 0.0.1
// import 'dart:async';
// import 'dart:ui';
//
// class ReactiveModel {
//   final _listeners = <VoidCallback>[];
//
//   // Subscribe to changes
//   void addListener(VoidCallback listener) {
//     _listeners.add(listener);
//   }
//
//   void removeListener(VoidCallback listener) {
//     _listeners.remove(listener);
//   }
//
//   // Notify all listeners of change
//   void notifyListeners() {
//     for (final listener in _listeners) {
//       listener();
//     }
//   }
//
//   // Placeholder for saving to DB
//   Future<void> save() async {}
//   Future<void> load() async {}
// }
