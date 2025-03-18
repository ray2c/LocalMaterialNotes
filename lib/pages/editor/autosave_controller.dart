// ignore_for_file: public_member_api_docs, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_this, override_on_non_overriding_member, always_put_control_body_on_new_line, overridden_fields, annotate_overrides, implicit_call_tearoffs, no_leading_underscores_for_local_identifiers

import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:async/async.dart';
import 'package:flutter/material.dart';

/// WIP.
/// TO-DO: Cleanup (and possibly simplify)

class ReferTo<O extends Object> {
  ReferTo(O object) {
    this.ref = WeakReference(object);
  }

  WeakReference<O>? ref;

  O? call() {
    print('[ReferTo] called for ' + ref.toString() + ': ' + this.toString());
    final o = ref?.target;
    if (o != null) {
      print('[ReferTo] returning ' + o.toString());
      return o;
    }
    print('[ReferTo] returning null');
    return null;
  }
}

/// Vehicle for passing callbacks without holding a strong reference to the instance object.
class WeakCallback<T, O extends Object> {
  /// Strongly holds a callback to be called on a weakly held object as subject.
  WeakCallback([O? object, T Function(O)? cb]) {
    if (object != null) this.ref = WeakReference(object);
    this.callback = cb;
  }

  WeakReference<O>? ref;

  T Function(O)? callback;

  T? call() {
    print('[WeakCallback] called for ' + ref.toString() + ', ' + callback.toString());
    final o = ref?.target;
    if (o != null && callback != null) {
      print('[WeakCallback] invoking ' + callback.toString() + ' with ' + o.toString());
      return callback?.call(o);
    }
    print('[WeakCallback] returning null');
    return null;
  }
}

/// Part supplier to Autosave controller.
class PartSupplier<P, T> {
  /// Supplies a part of the note content for [AutosaveController].
  PartSupplier({required this.part, this.pullCallback, this.specs});

  /// The part this supplies.
  final P part;

  /// Pull callback for this part to supply its latest value.
  T? Function()? pullCallback;

  ReferTo<AutosavePartSpecs>? specs;

  AutosavePartSpecs? getSpecs() {
    print('[AutosavePartSpecs] getSpecs(): ' + specs.toString());
    if (specs != null) {
      final s = specs!();
      print('[AutosavePartSpecs] returning ' + s.toString());
      return s;
    }
    print('[AutosavepartSpecs] returning null');
    return null;
  }

  void setPullCallback(T? Function()? callback) {
    pullCallback = callback;
  }

  T? _lastValue;

  bool _dirty = false;

  bool _pullPending = false;

  static void Function() pull<P, T>(AutosaveController? controller, P part, T Function()? pullCallback) {
    print('[PartSupplier] Create pull supplier for ' + part.toString() + ', ' + pullCallback.toString());
    final supplier = PartSupplier<P, T>(part: part, pullCallback: pullCallback);
    controller?.attachPart(supplier);
    return supplier.onPullChange;
  }

  static void Function(T?) push<P, T>(AutosaveController? controller, P part) {
    print('[PartSupplier] Create push supplier for ' + part.toString());
    final supplier = PartSupplier<P, T>(part: part);
    controller?.attachPart(supplier);
    return supplier.pushCallback;
  }

  void onPullChange() {
    print('[PartSupplier] onPullChange(), _pullPending = true');
    _pullPending = true;
  }

  void pushCallback(T? newValue) {
    print('[PartSupplier] pushCallback: ' + newValue.toString());
    if (newValue != null) {
      _lastValue = newValue;
      markDirty(true);
      print('[PartSupplier] _lastValue is now: ' + _lastValue.toString());
    }
  }

  void markDirty(bool isDirty) {
    print('[PartSupplier] markDirty: ' + isDirty.toString());
    _dirty = isDirty;
  }

  /// Finalize this [PartSupplier] so that it won't update anymore,
  /// returning the value salvaged from this call on future [get()]s.
  void finalize() {
    print('[PartSupplier] Finalizing ' + part.toString() + ' salvaging value from get()');
    get();
    print('[PartSupplier] Disposing pullCallback ' + pullCallback.toString());
    pullCallback = null;
    _pullPending = false;
    print('[PartSupplier] Salvaged _lastValue: ' + _lastValue.toString());
  }

  P getPart() => part;
  bool isDirty() => _dirty || _pullPending;

  void _pull() {
    print('[PartSupplier] _pull requested, _pullPending = ' + _pullPending.toString());
    if (_pullPending && pullCallback != null) {
      final value = pullCallback!.call();
      _pullPending = false;
      print('[PartSupplier] pulled via ' + pullCallback.toString() + ' and got ' + value.toString());
      if (value != null) {
        _lastValue = value;
        markDirty(true);
      }
    }
  }

  T? get() {
    print('[PartSupplier] getting value for ' + this.toString());
    if (_pullPending && pullCallback != null) _pull();
    print('[PartSupplier] returning _lastValue ' + _lastValue.toString());
    return _lastValue;
  }

  void migrateFrom(PartSupplier old) {
    print('[PartSupplier] Migrating from old PartSupplier ' + old.toString() + ' to ' + this.toString());
    final oldIsDirty = old.isDirty();
    print('[PartSupplier] Old PartSupplier dirty: ' + oldIsDirty.toString() + ', this: ' + isDirty().toString());
    if (!oldIsDirty) {
      print('[PartSupplier] No utility to migrate old PartSupplier which is not marked dirty');
      return;
    }
    final oldPart = old.getPart();
    print('[PartSupplier] Old PartSupplier part: ' + oldPart.toString() + ', new: ' + part.toString());
    if (part != oldPart) {
      print('[PartSupplier] Not migrating from old PartSupplier due to part mismatch');
      return;
    }
    print('[PartSupplier] Finalizing old PartSupplier for migration');
    old.finalize();
    final oldValue = old.get();
    print(
      '[PartSupplier] Old PartSupplier value: ' +
          oldValue.toString() +
          ', current _lastValue: ' +
          _lastValue.toString(),
    );
    if (oldValue == null) {
      print('[PartSupplier] Nothing to migrate from old PartSupplier which last salvaged value is null');
      return;
    }
    if (_lastValue != null) {
      print(
        '[PartSupplier] Skipped migration to avoid overwriting current _lastValue which is not null: ' +
            _lastValue.toString(),
      );
      return;
    }
    if (_lastValue == oldValue) {
      print(
        '[PartSupplier] Skipped migration since old PartSupplier value is same as current _lastValue: ' +
            _lastValue.toString(),
      );
      return;
    }
    _lastValue = oldValue;
    print('[PartSupplier] Migrated old PartSupplier value to this _lastValue: ' + _lastValue.toString());
    markDirty(true);
  }
}

mixin DebounceTimer {
  RestartableTimer? _timer;

  void Function() debounceCallback();

  Duration debounceDuration = Duration(seconds: 30);

  void cancelTimer() {
    print('[DebounceTimer] Cancelling timer ' + _timer.toString() + ': ' + this.toString());
    _timer?.cancel();
  }

  void resetTimer([bool clear = false]) {
    if (clear) {
      print('[DebounceTimer] Clearing old timer ' + _timer.toString() + ': ' + this.toString());
      _timer?.cancel();
      _timer = null;
      return;
    }
    final callback = debounceCallback();
    if (_timer == null) {
      _timer = RestartableTimer(debounceDuration, callback);
      print(
        '[DebounceTimer] Created new timer to callback ' +
            callback.toString() +
            ' in ' +
            debounceDuration.toString() +
            ': ' +
            this.toString(),
      );
    } else {
      _timer!.reset();
      print(
        '[DebounceTimer] Resetting timer to callback ' +
            callback.toString() +
            ' in ' +
            debounceDuration.toString() +
            ': ' +
            this.toString(),
      );
    }
  }
}

/// Autosave controller.
class AutosaveController<N> with WidgetsBindingObserver, DebounceTimer {
  // ignore: unused_field
  static const _debugFinalizers = true;

  final debounceDuration = Duration(seconds: 15);
  debounceCallback() => flush;

  /// An autosave controller for editing a note.
  AutosaveController({required this.note, this.specs});

  /// The note to autosave.
  final N note;

  ReferTo<AutosaveControllerSpecs>? specs;

  /// Whether autosave is pending.
  bool _dirty = false;

  final Map<int, PartSupplier> _parts = {};
  final List<PartSupplier> _oldParts = [];

  void attachPart(PartSupplier supplier) {
    final part = supplier.getPart();
    print('[AutosaveController] attaching PartSupplier ' + supplier.toString() + ' for ' + part.toString());
    _parts.update(part.index, (oldSupplier) {
      print('[AutosaveController] ' + part.toString() + ' already exists in ' + _parts.toString() + ', reattaching');
      print(
        '[AutosaveController] detaching old supplier ' +
            oldSupplier.toString() +
            ' for ' +
            part.toString() +
            ', was dirty: ' +
            oldSupplier.isDirty().toString(),
      );
      //oldPart.dispose();
      //detachPart(oldSupplier);
      _oldParts.add(oldSupplier);
      print('[AutosaveController] moved old supplier to _oldParts: ' + _oldParts.toString());
      supplier.migrateFrom(oldSupplier);
      return supplier;
    }, ifAbsent: () => supplier);
    print('[AutosaveController] post attachPart() _parts: ' + _parts.toString());
  }

  void detachPart(PartSupplier supplier, [bool salvage = true]) {
    final part = supplier.getPart();
    print('[AutosaveController] detaching PartSupplier ' + supplier.toString() + ' for ' + part.toString());
    bool detached = false;
    if (_parts.containsKey(part.index)) {
      final attached = _parts[part.index];
      print(
        '[AutosaveController] looking up ' + part.toString() + ' in ' + _parts.toString() + ': ' + attached.toString(),
      );
      if (identical(supplier, attached)) {
        final removed = _parts.remove(part.index);
        print(
          '[AutosaveController] removing old supplier ' +
              removed.toString() +
              ' at ' +
              part.index.toString() +
              ', was dirty: ' +
              (removed?.isDirty().toString() ?? 'false'),
        );
        detached = true;
        if (salvage && removed != null && removed.isDirty()) {
          print(
            '[AutosaveController] old supplier ' + removed.toString() + ' was dirty, commiting to note to salvage data',
          );
          commitPart(removed);
        }
      } else {
        print(
          '[AutosaveController] another supplier had already been attached at ' +
              part.index.toString() +
              ': ' +
              attached.toString(),
        );
      }
    }
    if (!detached) {
      final isThere = _parts.containsValue(supplier);
      print('[AutosaveController] _parts contains ' + supplier.toString() + ': ' + isThere.toString());
      if (isThere) {
        print('[AutosaveController] trying to remove by value: ' + supplier.toString());
        _parts.removeWhere((key, value) {
          print('[AutosaveController] detachPart: looking at ' + key.toString() + '=' + value.toString());
          final found = identical(supplier, value);
          if (found) {
            detached = true;
            print(
              '[AutosaveController] detachPart: found detach target at ' +
                  key.toString() +
                  ' instead of ' +
                  part.index.toString(),
            );
          }
          return found;
        });
      }
    }
    if (!detached) {
      final wasThere = _oldParts.contains(supplier);
      print('[AutosaveController] _oldParts contains ' + supplier.toString() + ': ' + wasThere.toString());
      if (wasThere) {
        _oldParts.remove(supplier);
        print('[AutosaveController] removed supplier from _oldParts: ' + _oldParts.toString());
        detached = true;
      }
    }
    print('[AutosaveController] detached ' + supplier.toString() + ': ' + detached.toString());

    print('[AutosaveController] post detachPart() _parts: ' + _parts.toString());

    if (_partFinalizer != null) {
      _partFinalizer?.detach(supplier);
      print(
        '[AutosaveController] detaching ' +
            supplier.toString() +
            ' from _partFinalizer ' +
            (_partFinalizer?.toString() ?? 'null'),
      );
    } else {
      print('[AutosaveController] _partFinalizer is null on detachPart()');
    }
  }

  Finalizer<PartSupplier>? _partFinalizer;

  Widget toPush<P, T>(P part, Widget Function(void Function(T)) builder) {
    print('[AutosaveController] toPush: creating supplier for ' + part.toString());
    final supplier = PartSupplier<P, T>(part: part);
    attachPart(supplier);
    final pushCallback = supplier.pushCallback;
    final widget = builder.call((val) {
      pushCallback.call(val);
      partChanged(supplier);
    });
    _attachFinalizer(widget, supplier);
    return widget;
  }

  O toPull<P, T, O extends Widget>(P part, O Function(void Function()) builder, T Function(O?)? pullCallbackMethod) {
    print(
      '[AutosaveController] toPull: creating supplier for ' + part.toString() + ', ' + pullCallbackMethod.toString(),
    );
    final supplier = PartSupplier<P, T>(part: part);
    attachPart(supplier);
    final onPullChange = supplier.onPullChange;
    final widget = builder.call(() {
      onPullChange.call();
      partChanged(supplier);
    });
    supplier.setPullCallback(WeakCallback(widget, pullCallbackMethod));
    _attachFinalizer(widget, supplier);
    return widget;
  }

  void _attachFinalizer(Widget? widget, PartSupplier supplier) {
    if (widget == null) return;
    _partFinalizer ??= Finalizer((oldPart) {
      print('[PartFinalizer] Finalizing old PartSupplier ' + oldPart.toString());
      detachPart(oldPart);
    });

    _partFinalizer!.attach(widget, supplier, detach: supplier);
    print(
      '[PartFinalizer] Attached PartSupplier ' +
          supplier.toString() +
          ' for ' +
          widget.toString() +
          ' to _partFinalizer',
    );
  }

  void partChanged(PartSupplier supplier) {
    print(
      '[AutosaveController] Part changed from supplier ' + supplier.toString() + ' on ' + supplier.getPart().toString(),
    );
    markDirty(true);
  }

  void commitParts() {
    print('[AutosaveController] Commiting changes to note from PartSuppliers: ' + _parts.toString());
    for (var part in _parts.values) {
      commitPart(part);
    }
  }

  void commitPart(PartSupplier part) {
    print('[AutosaveController] Inspecting ' + part.toString() + ', isDirty: ' + part.isDirty().toString());
    if (part.isDirty()) {
      print(
        '[AutosaveController] PartSupplier is dirty, updating changes for ' +
            part.getPart().toString() +
            ' to note: ' +
            note.toString(),
      );
      final item = part.getPart();
      final value = part.get();
      print('[AutosaveController] Commit ' + part.toString() + ' for ' + item.toString() + ': ' + value.toString());

      if (value != null) {
        print('[AutosaveController] bubbling up specs to commit part: ' + part.getSpecs().toString());
        final handled = part.getSpecs()?.saveContent(note, part) ?? false;
        print(
          '[AutosaveController] specs handled commiting ' +
              part.toString() +
              ' for ' +
              item.toString() +
              ': ' +
              handled.toString(),
        );
      } else {
        print('[AutosaveController] Skipped ' + part.toString() + ' for ' + item.toString() + ' since value is null');
      }
    }
  }

  /// Notifier for the current autosave state.
  final ValueNotifier _autosaveNotifier = ValueNotifier<int>(-1);

  ValueNotifier getAutosaveNotifier() {
    return _autosaveNotifier;
  }

  void _updateNotifier(bool isDirty) {
    if (isDirty) resetTimer();
    final state = _dirty ? 1 : 0;
    if (_autosaveNotifier.value != state) _autosaveNotifier.value = state;
  }

  @override
  Future<bool> didPopRoute() {
    print('[AutosaveController] Received didPopRoute, flushing');
    flush();
    return Future<bool>.value(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState: ' + state.toString());
    switch (state) {
      case AppLifecycleState.hidden:
        print('[AutosaveController] Received AppLifecycleState.hidden, flushing');
        flush(true);
      /* case AppLifecycleState.detached:
        print('[AutosaveController] Received AppLifecycleState.detached'); */
      default:
        break;
    }
  }

  void markDirty(bool isDirty) {
    _dirty = isDirty;
    _updateNotifier(isDirty);
  }

  void flush([bool sync = false]) {
    print('[AutosaveController] flush: sync=' + sync.toString() + ', _dirty=' + _dirty.toString());
    if (_dirty) {
      commitParts();

      _timer?.cancel();
      final handled = commit(sync);
      _dirty = false;
      print('[AutosaveController] saved note ' + note.toString() + ' via commit(): ' + handled.toString());
      _updateNotifier(false);
    }
  }

  bool commit(bool sync) {
    final s = specs?.call();
    print(
      '[AutosaveController] commit() via specs ' + s.toString() + ', sync=' + sync.toString() + ': ' + this.toString(),
    );
    final handled = s != null && s.commit(note, sync);
    print('[AutosaveController] commit() returns ' + (handled ? 'successful' : 'unsuccessful'));
    return handled;
  }
}

abstract interface class AutosaveSpecs {}

abstract interface class AutosaveControllerSpecs<N> extends AutosaveSpecs {
  /// Logic to be implemented by client to commit, synchronously as may be preferred,
  /// the whole document object as latest updated to persistent storage, returning true if successful.
  bool commit(N note, bool sync);
}

abstract interface class AutosavePartSpecs<N> extends AutosaveSpecs {
  /// Logic to be implemented by client to save content for their part to the document object,
  /// returning true if handled, false to bubble up to parent handlers.
  bool saveContent(N note, PartSupplier supplier);
}

mixin AutosaveHandler<N> implements AutosaveControllerSpecs<N> {
  @override
  ReferTo<AutosaveControllerSpecs> getSpecs() => ReferTo(this);

  @override
  bool commit(N note, bool sync) {
    throw UnimplementedError();
  }
}

// https://stackoverflow.com/questions/57840704/how-do-i-correctly-mixin-on-state
mixin AutosaveState<N, T extends StatefulWidget> on State<T> {
  /// Autosave controller for the current note in the editor.
  AutosaveController? _autosaveController;

  AutosaveController? getAutosaveController() => _autosaveController;

  @mustCallSuper
  @override
  void dispose() {
    print('[AutosaveState] dispose(): ' + this.toString());
    cleanupAutosaveController();
    super.dispose();
  }

  ReferTo<AutosaveControllerSpecs>? getSpecs();

  void setupAutosaveController(N note) {
    print('[AutosaveState] setupAutosaveController for ' + note.toString());
    cleanupAutosaveController();
    _autosaveController = AutosaveController(note: note, specs: getSpecs());

    WidgetsBinding.instance.addObserver(_autosaveController!);
    print('WidgetsBinding.instance.addObserver: ' + _autosaveController.toString());
    print('[AutosaveState] _autosaveController: ' + _autosaveController.toString() + ', this: ' + this.toString());
  }

  void cleanupAutosaveController() {
    print(
      '[AutosaveState] cleanupAutosaveController: _autosaveController=' +
          _autosaveController.toString() +
          ', this: ' +
          this.toString(),
    );
    if (_autosaveController != null) {
      _autosaveController!.resetTimer(true);
      WidgetsBinding.instance.removeObserver(_autosaveController!);
      print('WidgetsBinding.instance.removeObserver: ' + _autosaveController.toString());
      _autosaveController!.flush();
      _autosaveController = null;
    }
  }

  static AutosaveState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<AutosaveState>();
  }
}

mixin AutosavePartHandler<N, V> implements AutosavePartSpecs<N> {
  @override
  ReferTo<AutosavePartSpecs> getSpecs() => ReferTo(this);

  bool savePart(N note, V value) {
    throw UnimplementedError();
  }

  @override
  bool saveContent(N note, PartSupplier supplier) {
    final item = supplier.getPart();
    final V value = supplier.get();
    print(
      '[AutosavePartState] Save content ' +
          supplier.toString() +
          ' for ' +
          item.toString() +
          ': ' +
          value.toString() +
          ' to ' +
          note.toString(),
    );
    return savePart(note, value);
  }
}

mixin AutosavePartState<T extends StatefulWidget> on State<T> {
  /// [AutosaveController] to which this Part attaches.
  AutosaveController? _autosaveController;

  AutosaveController? getAutosaveController() => _autosaveController;

  PartSupplier? _partSupplier;

  @mustCallSuper
  @override
  void initState() {
    print('[AutosavePartState] initState()');
    final _autosaveState = AutosaveState.maybeOf(context);
    print('[AutosavePartState] lookup up parent AutosaveState: ' + (_autosaveState?.toString() ?? 'null'));
    _autosaveController = _autosaveState?.getAutosaveController();
    print('[AutosavePartState] lookup up AutosaveController from AutosaveState: ' + _autosaveController.toString());
    super.initState();
  }

  @mustCallSuper
  @override
  void dispose() {
    print('[AutosavePartState] dispose(): ' + this.toString());
    cleanupAutosavePart();
    super.dispose();
  }

  /* void Function() setupAutosavePart<V>(Part part, V Function()? pullCallback) {
    print('[AutosavePartState] setupAutosavePart: Create pull supplier for ' + part.toString() + ', ' + pullCallback.toString());
    _partSupplier = PartSupplier<V>(part: part, pullCallback: pullCallback);
    print('[AutosavePartState] attaching ' + _partSupplier.toString() + ' to ' + _autosaveController.toString());
    _autosaveController?.attachPart(_partSupplier);
    return pullChanges;
  }

  void Function(V?) setupAutosavePart<V>(Part part) {
    print('[AutosavePartState] setupAutosavePart: Create push supplier for ' + part.toString());
    _partSupplier = PartSupplier<V>(part: part);
    print('[AutosavePartState] attaching ' + _partSupplier.toString() + ' to ' + _autosaveController.toString());
    _autosaveController?.attachPart(_partSupplier);
    return pushChanges;
  } */

  ReferTo<AutosavePartSpecs>? getSpecs();

  void setupAutosavePart<P, V>(P part, [V Function()? pullCallback]) {
    print('[AutosavePartState] setupAutosavePart for ' + part.toString() + ', pullCallback=' + pullCallback.toString());
    _partSupplier = PartSupplier<P, V>(part: part, pullCallback: pullCallback, specs: getSpecs());
    print('[AutosavePartState] attaching ' + _partSupplier.toString() + ' to ' + _autosaveController.toString());
    _autosaveController?.attachPart(_partSupplier!);
  }

  void cleanupAutosavePart() {
    print(
      '[AutosavePartState] cleanupAutosavePart: _partSupplier=' +
          _partSupplier.toString() +
          ', _autosaveController=' +
          _autosaveController.toString(),
    );
    if (_partSupplier != null) {
      print('[AutosavePartState] detaching ' + _partSupplier.toString() + ' from ' + _autosaveController.toString());
      _autosaveController?.detachPart(_partSupplier!);
    }
  }

  /// onChange callback for push [PartSupplier].
  void pushChanges<V>(V val) {
    print('[AutosavePartState] on pushChanges: ' + val.toString() + ', _partSupplier: ' + _partSupplier.toString());
    if (_partSupplier != null) {
      _partSupplier!.pushCallback.call(val);
      _autosaveController?.partChanged(_partSupplier!);
    }
  }

  /// onChange callback for pull [PartSupplier].
  void pullChanges() {
    print('[AutosavePartState] on pullChanges, _partSupplier: ' + _partSupplier.toString());
    if (_partSupplier != null) {
      _partSupplier!.onPullChange.call();
      _autosaveController?.partChanged(_partSupplier!);
    }
  }
}
