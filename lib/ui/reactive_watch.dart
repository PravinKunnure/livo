// --------------------------
// reactive_watch.dart
// --------------------------

import 'package:flutter/widgets.dart';
import 'package:livo/livo.dart';

/// =====================================================
/// Extension on ReactiveModel for ergonomic watch
/// =====================================================
extension ReactiveWatch<T extends ReactiveModel> on T {
  /// Watch the entire model (object-wise) or specific fields
  Widget watch(Widget Function(T model) builder, {List<Symbol>? fields}) {
    return ReactiveBuilder<T>(model: this, fields: fields, builder: builder);
  }

  /// Watch a specific field on this model
  Widget watchField(Symbol field, Widget Function() builder) {
    return ReactiveBuilder<T>(
      model: this,
      fields: [field],
      builder: (_) => builder(),
    );
  }

  /// Watch a computed value derived from this model
  Widget watchComputed<R>(
    R Function() compute,
    Widget Function(R value) builder,
  ) {
    R cachedValue = compute();
    return ReactiveBuilder<T>(
      model: this,
      builder: (_) {
        final newValue = compute();
        if (cachedValue != newValue) cachedValue = newValue;
        return builder(cachedValue);
      },
    );
  }
}

/// =====================================================
/// Standalone functions (optional, for convenience)
/// =====================================================

/// Watch a specific field on any ReactiveModel
Widget watchFieldModel(
  ReactiveModel model,
  Symbol field,
  Widget Function() builder,
) {
  return ReactiveBuilder<ReactiveModel>(
    model: model,
    fields: [field],
    builder: (_) => builder(),
  );
}

/// Watch a computed value from any ReactiveModel
Widget watchComputedModel<R>(
  ReactiveModel model,
  R Function() compute,
  Widget Function(R value) builder,
) {
  R cachedValue = compute();
  return ReactiveBuilder<ReactiveModel>(
    model: model,
    builder: (_) {
      final newValue = compute();
      if (cachedValue != newValue) cachedValue = newValue;
      return builder(cachedValue);
    },
  );
}
