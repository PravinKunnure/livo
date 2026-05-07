# Changelog

All notable changes to this project will be documented in this file.

This project follows semantic versioning.

---

## 1.0.5 —
- Document Changes
- Minor bug fixes


## 1.0.4 — 
- Document Changes
- Minor bug fixes

## 1.0.3 — 
- Document Changes
- Minor bug fixes

## 1.0.2 — 
- Document Changes

## 1.0.1 — 
- Document Changes 

## 1.0.0 — LIVO Initial Release 🎉

### 🚀 Introduction

This is the **first official release of LIVO — Live Objects**.

LIVO is a **rebranded and clarified continuation** of the `reactive_orm` package.
The rename was done to remove confusion around the term *ORM* and to better
represent the package’s true purpose as a **model-driven state management system**.

---

### 🔄 Why the Rename?

The previous name `reactive_orm` was often misunderstood as a
**database ORM**, even though the package is:

- Fully in-memory
- UI-focused
- Designed for Flutter state management
- Centered around reactive Dart models and relationships

**LIVO (Live Objects)** more accurately reflects the core idea:

> Application state lives inside **live, reactive objects** that automatically
> keep the UI in sync.

---

### ✨ Features Included

- ReactiveModel base class
- Object-level reactivity (`watch`)
- Field-level reactivity (`watchField`)
- Computed / derived reactivity (`watchComputed`)
- ReactiveList and ReactiveMap collections
- Nested and shared reactive models
- One → Many relationships
- Many ↔ Many relationships
- Automatic change propagation across object graphs
- Debug inspection utilities
- Minimal boilerplate
- No code generation
- No ChangeNotifier, providers, or streams required

---

### 🧩 Migration from `reactive_orm`

Migration is straightforward and **non-breaking** in terms of behavior.

#### Dependency change:
```diff
- reactive_orm
+ livo
