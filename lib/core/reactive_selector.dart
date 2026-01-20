// --------------------------
// reactive_selector.dart
// --------------------------

import 'package:flutter/material.dart';
import 'package:livo/livo.dart';

class ReactiveSelector<T extends ReactiveModel, V> extends StatefulWidget {
  final T model;
  final Symbol? field;
  final V Function(T model) selector;
  final Widget Function(V value) builder;

  const ReactiveSelector({
    required this.model,
    required this.selector,
    required this.builder,
    this.field,
    super.key,
  });

  @override
  State<ReactiveSelector<T, V>> createState() => _ReactiveSelectorState<T, V>();
}

class _ReactiveSelectorState<T extends ReactiveModel, V>
    extends State<ReactiveSelector<T, V>> {
  late V value;

  void _onChange() {
    final newValue = widget.selector(widget.model);
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    value = widget.selector(widget.model);
    widget.model.addListener(_onChange, field: widget.field);
  }

  @override
  void didUpdateWidget(covariant ReactiveSelector<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model || oldWidget.field != widget.field) {
      oldWidget.model.removeListener(_onChange, field: oldWidget.field);
      widget.model.addListener(_onChange, field: widget.field);
      value = widget.selector(widget.model);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(_onChange, field: widget.field);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(value);
  }
}

///Version 1.0.1.111
// import 'package:flutter/material.dart';
// import 'package:reactive_orm/livo.dart';
//
// class ReactiveSelector<T extends ReactiveModel, V> extends StatefulWidget {
//   final T model;
//   final Symbol? field;
//   final V Function(T model) selector;
//   final Widget Function(V value) builder;
//
//   const ReactiveSelector({
//     required this.model,
//     required this.selector,
//     required this.builder,
//     this.field,
//     super.key,
//   });
//
//   @override
//   State<ReactiveSelector<T, V>> createState() => _ReactiveSelectorState<T, V>();
// }
//
// class _ReactiveSelectorState<T extends ReactiveModel, V>
//     extends State<ReactiveSelector<T, V>> {
//   late V value;
//
//   void _onChange() {
//     final newValue = widget.selector(widget.model);
//     if (newValue != value) {
//       setState(() {
//         value = newValue;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     value = widget.selector(widget.model);
//     widget.model.addListener(_onChange, field: widget.field);
//   }
//
//   @override
//   void didUpdateWidget(covariant ReactiveSelector<T, V> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.model != widget.model) {
//       oldWidget.model.removeListener(_onChange, field: oldWidget.field);
//       value = widget.selector(widget.model);
//       widget.model.addListener(_onChange, field: widget.field);
//     }
//   }
//
//   @override
//   void dispose() {
//     widget.model.removeListener(_onChange, field: widget.field);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(value);
//   }
// }

///Version 1.0.0.1
// import 'package:flutter/material.dart';
// import 'package:reactive_orm/livo.dart';
//
// class ReactiveSelector<T extends ReactiveModel, V> extends StatefulWidget {
//   final T model;
//   final Symbol? field; // optional
//   final V Function(T model) selector;
//   final Widget Function(V value) builder;
//
//   const ReactiveSelector({
//     required this.model,
//     required this.selector,
//     required this.builder,
//     this.field,
//     super.key,
//   });
//
//   @override
//   State<ReactiveSelector<T, V>> createState() => _ReactiveSelectorState<T, V>();
// }
//
// class _ReactiveSelectorState<T extends ReactiveModel, V>
//     extends State<ReactiveSelector<T, V>> {
//   late V value;
//
//   void _onChange() {
//     final newValue = widget.selector(widget.model);
//     if (newValue != value) {
//       setState(() {
//         value = newValue;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     value = widget.selector(widget.model);
//     widget.model.addListener(_onChange, field: widget.field);
//   }
//
//   @override
//   void didUpdateWidget(covariant ReactiveSelector<T, V> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (oldWidget.model != widget.model) {
//       oldWidget.model.removeListener(_onChange, field: oldWidget.field);
//
//       value = widget.selector(widget.model);
//       widget.model.addListener(_onChange, field: widget.field);
//     }
//   }
//
//   @override
//   void dispose() {
//     widget.model.removeListener(_onChange, field: widget.field);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(value);
//   }
// }

///Version 1.0.0
// class _ReactiveSelectorState<T extends ReactiveModel, V>
//     extends State<ReactiveSelector<T, V>> {
//   late V value;
//
//   void _onChange() {
//     setState(() {
//       value = widget.selector(widget.model);
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     value = widget.selector(widget.model);
//     widget.model.addListener(_onChange, field: widget.field);
//   }
//
//   @override
//   void dispose() {
//     widget.model.removeListener(_onChange, field: widget.field);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(value);
//   }
// }
