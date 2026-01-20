// --------------------------
// reactive_builder.dart
// --------------------------

import 'package:flutter/material.dart';
import 'package:livo/livo.dart';

class ReactiveBuilder<T extends ReactiveModel> extends StatefulWidget {
  final T model;
  final Widget Function(T model) builder;
  final List<Symbol>? fields;

  const ReactiveBuilder({
    required this.model,
    required this.builder,
    this.fields,
    super.key,
  });

  @override
  State<ReactiveBuilder<T>> createState() => _ReactiveBuilderState<T>();
}

class _ReactiveBuilderState<T extends ReactiveModel>
    extends State<ReactiveBuilder<T>> {
  void _onChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _registerListeners();
  }

  @override
  void didUpdateWidget(covariant ReactiveBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      _unregisterListeners(oldWidget.model);
      _registerListeners();
    }
  }

  void _registerListeners() {
    if (widget.fields != null) {
      for (final f in widget.fields!) {
        widget.model.addListener(_onChange, field: f);
      }
    } else {
      widget.model.addListener(_onChange);
    }
  }

  void _unregisterListeners(T model) {
    if (widget.fields != null) {
      for (final f in widget.fields!) {
        model.removeListener(_onChange, field: f);
      }
    } else {
      model.removeListener(_onChange);
    }
  }

  @override
  void dispose() {
    _unregisterListeners(widget.model);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(widget.model);
}

///Version 1.0.1
// import 'package:flutter/material.dart';
// import 'package:reactive_orm/livo.dart';
//
// class ReactiveBuilder<T extends ReactiveModel> extends StatefulWidget {
//   final T model;
//   final Widget Function(T model) builder;
//   final List<Symbol>? fields;
//
//   const ReactiveBuilder({
//     required this.model,
//     required this.builder,
//     this.fields,
//     super.key,
//   });
//
//   @override
//   State<ReactiveBuilder<T>> createState() => _ReactiveBuilderState<T>();
// }
//
// class _ReactiveBuilderState<T extends ReactiveModel>
//     extends State<ReactiveBuilder<T>> {
//   void _onChange() {
//     if (!mounted) return;
//     setState(() {});
//   }
//
//   void _addListeners(T model) {
//     if (widget.fields != null) {
//       for (final f in widget.fields!) {
//         model.addListener(_onChange, field: f);
//       }
//     } else {
//       model.addListener(_onChange);
//     }
//   }
//
//   void _removeListeners(T model) {
//     if (widget.fields != null) {
//       for (final f in widget.fields!) {
//         model.removeListener(_onChange, field: f);
//       }
//     } else {
//       model.removeListener(_onChange);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _addListeners(widget.model);
//   }
//
//   @override
//   void didUpdateWidget(covariant ReactiveBuilder<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (oldWidget.model != widget.model) {
//       _removeListeners(oldWidget.model);
//       _addListeners(widget.model);
//     }
//   }
//
//   @override
//   void dispose() {
//     _removeListeners(widget.model);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => widget.builder(widget.model);
// }

///Version 1.0.0
// class _ReactiveBuilderState<T extends ReactiveModel>
//     extends State<ReactiveBuilder<T>> {
//   void _onChange() {
//     if (!mounted) return;
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.fields != null) {
//       for (final f in widget.fields!) {
//         widget.model.addListener(_onChange, field: f);
//       }
//     } else {
//       widget.model.addListener(_onChange);
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.fields != null) {
//       for (final f in widget.fields!) {
//         widget.model.removeListener(_onChange, field: f);
//       }
//     } else {
//       widget.model.removeListener(_onChange);
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => widget.builder(widget.model);
// }

///Version 0.0.9
// import 'package:flutter/material.dart';
// import 'reactive_model.dart';
//
// class ReactiveBuilder<T extends ReactiveModel> extends StatefulWidget {
//   final T model;
//   final Widget Function(T model) builder;
//   final List<Symbol>? fields;
//   final bool Function(T oldModel, T newModel)? shouldRebuild;
//
//   const ReactiveBuilder({
//     required this.model,
//     required this.builder,
//     this.fields,
//     this.shouldRebuild,
//     super.key,
//   });
//
//   @override
//   ReactiveBuilderState<T> createState() => ReactiveBuilderState<T>();
// }
//
// class ReactiveBuilderState<T extends ReactiveModel>
//     extends State<ReactiveBuilder<T>> {
//   void _onChange() {
//     if (!mounted) return;
//     if (widget.shouldRebuild != null) {
//       if (!widget.shouldRebuild!(widget.model, widget.model)) return;
//     }
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.fields != null) {
//       for (var f in widget.fields!) {
//         widget.model.addListener(_onChange, field: f);
//       }
//     } else {
//       widget.model.addListener(_onChange); // listen to all fields
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.fields != null) {
//       for (var f in widget.fields!) {
//         widget.model.removeListener(_onChange, field: f);
//       }
//     } else {
//       widget.model.removeListener(_onChange);
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => widget.builder(widget.model);
// }

///Version 0.0.7
// import 'package:flutter/material.dart';
// import 'reactive_model.dart';
//
// class ReactiveBuilder<T extends ReactiveModel> extends StatefulWidget {
//   final T model;
//   final Widget Function(T model) builder;
//   final List<String>? fields; // optional field filter
//
//   const ReactiveBuilder({
//     required this.model,
//     required this.builder,
//     this.fields,
//     super.key,
//   });
//
//   @override
//   ReactiveBuilderState<T> createState() => ReactiveBuilderState<T>();
// }
//
// class ReactiveBuilderState<T extends ReactiveModel>
//     extends State<ReactiveBuilder<T>> {
//   void _onChange() => setState(() {});
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.fields != null) {
//       for (var f in widget.fields!) {
//         widget.model.addListener(_onChange, field: f);
//       }
//     } else {
//       widget.model.addListener(_onChange); // listen to all fields
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.fields != null) {
//       for (var f in widget.fields!) {
//         widget.model.removeListener(_onChange, field: f);
//       }
//     } else {
//       widget.model.removeListener(_onChange);
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => widget.builder(widget.model);
// }

///Try Version
// import 'package:flutter/material.dart';
// import 'reactive_model.dart';
//
// class ReactiveBuilder<T extends ReactiveModel> extends StatefulWidget {
//   final T model;
//   final Widget Function(T model) builder;
//   final List<String>? fields; // optional list of fields to listen to
//
//   const ReactiveBuilder({
//     required this.model,
//     required this.builder,
//     this.fields,
//     super.key,
//   });
//
//   @override
//   ReactiveBuilderState<T> createState() => ReactiveBuilderState<T>();
// }
//
// class ReactiveBuilderState<T extends ReactiveModel> extends State<ReactiveBuilder<T>> {
//   void _onChange() => setState(() {});
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.fields != null) {
//       for (var field in widget.fields!) {
//         widget.model.addListener(_onChange, field: field);
//       }
//     } else {
//       widget.model.addListener(_onChange); // listens to all fields
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.fields != null) {
//       for (var field in widget.fields!) {
//         widget.model.removeListener(_onChange, field: field);
//       }
//     } else {
//       widget.model.removeListener(_onChange);
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(widget.model);
//   }
// }

///Version 0.0.1
/*
import 'package:flutter/material.dart';
import 'reactive_model.dart';

class ReactiveBuilder<T extends ReactiveModel> extends StatefulWidget {
  final T model;
  final Widget Function(T model) builder;

  const ReactiveBuilder({
    required this.model,
    required this.builder,
    super.key,
  });

  @override
  ReactiveBuilderState<T> createState() => ReactiveBuilderState<T>();
}

class ReactiveBuilderState<T extends ReactiveModel>
    extends State<ReactiveBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onModelChange);
  }

  void _onModelChange() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.model.removeListener(_onModelChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(widget.model);
  }
}
*/
