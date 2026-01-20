# LIVO

[![Pub Version](https://img.shields.io/pub/v/livo)](https://pub.dev/packages/livo)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)

> **LIVO — Live Objects**  
> A reactive object-relationship **state management system** for Flutter with
> **field-level**, **object-level**, and **relationship-based reactivity**.

---

## 🧠 What is LIVO?

**LIVO (Live Objects)** is a **model-driven state management solution** for Flutter.

Instead of managing state through providers, streams, or immutable snapshots,
LIVO treats your **Dart objects as live state**.

- Objects hold state
- Fields are reactive
- Relationships propagate changes automatically
- UI stays in sync with minimal boilerplate

---

## ✨ Core Philosophy

- Models are **plain Dart objects**
- State changes happen via **normal field mutation**
- UI reacts **automatically**
- No `ChangeNotifier`, providers, streams, or boilerplate
- Supports:
  - **Object-level reactivity**
  - **Field-level reactivity**
  - **Nested & shared models**
  - **One → Many and Many ↔ Many relationships**

> Think of LIVO as **Live, connected objects driving your UI**

---

## ✨ Features

- ✅ Reactive models with automatic UI updates
- ✅ Object-wise reactivity (`watch`)
- ✅ Field-wise reactivity (`watchField`)
- ✅ Computed / derived reactivity (`watchComputed`)
- ✅ ReactiveList & ReactiveMap
- ✅ Nested & shared models
- ✅ One → Many and Many ↔ Many relationships
- ✅ Debug inspection support
- ✅ Minimal boilerplate
- ✅ No code generation required

---

## 🚀 Installation:

```yaml
dependencies:
  livo: <latest_version>
```

## 🧩 Basic Example:
```
import 'package:livo/livo.dart';

class Task extends ReactiveModel {
  String _title;
  bool _completed = false;

  Task(this._title);

  String get title => _title;
  set title(String value) {
    _title = value;
    notifyListeners(#title);
  }

  bool get completed => _completed;
  set completed(bool value) {
    _completed = value;
    notifyListeners(#completed);
  }
}
```

## 🔗 Relationships
- One → Many
```
class Dashboard extends ReactiveModel {
  final List<Task> tasks;

  Dashboard(this.tasks) {
    for (final t in tasks) addNested(t);
  }
}

```

- Many ↔ Many
```
class Group extends ReactiveModel {
  final String name;
  final List<Task> tasks;

  Group(this.name, this.tasks) {
    for (final t in tasks) addNested(t);
  }
}

```

## 🧭 Why LIVO?
| Traditional State | LIVO                   |
| ----------------- | ---------------------- |
| External stores   | State lives in objects |
| Boilerplate       | Minimal                |
| Manual wiring     | Automatic propagation  |
| Flat state        | Connected object graph |


## 🔄 Migration Notice:
### This package replaces `reactive_orm`.
### `reactive_orm` has been deprecated and rebranded as LIVO to remove ORM/database confusion and better reflect its purpose as a state management system.

### Migration is simple:
```
- import 'package:reactive_orm/reactive_orm.dart';
+ import 'package:livo/livo.dart';

```

## 📌 Summary:
###  LIVO is ideal for:
- Model-centric Flutter apps
- Fine-grained UI reactivity
- Complex domain models with relationships
- Clean architecture with minimal overhead