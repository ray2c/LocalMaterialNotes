// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../common/constants/paddings.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/extensions/build_context_extension.dart';
import '../../../common/extensions/color_extension.dart';
import '../../../common/extensions/date_time_extensions.dart';
import '../../../models/note/note.dart';

import '../autosave_controller.dart';

/// Status display for [AutosaveController]. (WIP)
/// TO-DO: Cleanup
class AutosaveStatus extends ConsumerStatefulWidget {
  /// Display status of the autosave controller.
  const AutosaveStatus({super.key, required this.note, required this.isNewNote, this.controller});

  /// The note to display.
  final Note note;

  /// Whether the note was just created.
  final bool isNewNote;

  /// [AutosaveController] from which status is listened.
  final AutosaveController? controller;

  @override
  ConsumerState<AutosaveStatus> createState() => _AutosaveStatusState();
}

class _AutosaveStatusState extends ConsumerState<AutosaveStatus> with DebounceTimer {
  /// Internal notifier to show the status of the [AutosaveController] listening to.
  final ValueNotifier _status = ValueNotifier<int>(-1);

  final debounceDuration = Duration(seconds: 5);
  debounceCallback() => onSeenTimeout;

  /// Whether the last transient message has timed out.
  bool _seen = false;

  /// Whether a coundown to timeout the transient message is pending.
  bool _timeoutPending = false;

  /// Notifier of the upstream [AutosaveController].
  ValueNotifier? _controllerNotifier;

  @override
  void initState() {
    _setupController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AutosaveStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _cleanupController(oldWidget);
      _setupController();
    }
  }

  @override
  void dispose() {
    resetTimer(true);
    _cleanupController(widget);
    _status.dispose();
    super.dispose();
  }

  void _setupController() {
    _controllerNotifier = widget.controller?.getAutosaveNotifier();
    _controllerNotifier?.addListener(onStatusChanged);
    if (_controllerNotifier != null) {
      // do an initial update to the current status
      onStatusChanged();
    }
  }

  void _cleanupController(AutosaveStatus oldWidget) {
    _controllerNotifier?.removeListener(onStatusChanged);
    _controllerNotifier = null;
    _seen = false;
    _timeoutPending = false;
  }

  void onStatusChanged() {
    if (_controllerNotifier == null) {
      print('[AutosaveStatus] onStatusChanged called but _controllerNotifier is null');
      return;
    }
    final newStatus = _controllerNotifier!.value;
    print(
      '[AutosaveStatus] onStatusChanged: fetched status ' +
          newStatus.toString() +
          ' from ' +
          _controllerNotifier.toString(),
    );
    switch (newStatus) {
      case 1:
        _seen = false;
        cancelTimer();
        _status.value = newStatus;
        break;
      case 0:
        if (_seen) {
          print(
            '[AutosaveStatus] Skip updating _status to ' + newStatus.toString() + ' since _seen is ' + _seen.toString(),
          );
        } else {
          print(
            '[AutosaveStatus] Scheduling timeout after message has been built once since _seen is ' + _seen.toString(),
          );
          _timeoutPending = true;
          _status.value = newStatus;
        }
        break;
      default:
        print('[AutosaveStatus] onStatusChanged: received unrecognized status from upstream: ' + newStatus.toString());
        break;
    }
    print(
      '[AutosaveStatus] post onStatusChanged: newStatus: ' +
          newStatus.toString() +
          ', _seen: ' +
          _seen.toString() +
          ', _timeoutPending: ' +
          _timeoutPending.toString(),
    );
  }

  void onSeenTimeout() {
    print('[AutosaveStatus] Seen timeout, setting _seen = true');
    _seen = true;
    _status.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    final labelMediumTextTheme = Theme.of(context).textTheme.labelMedium;
    final labelMediumColor = labelMediumTextTheme?.color?.subdued;
    var dateStyle = labelMediumTextTheme?.copyWith(color: labelMediumColor);
    return Padding(
      padding: Paddings.pageHorizontal,
      child: ValueListenableBuilder(
        valueListenable: _status,
        builder: (context, state, child) {
          late String? label;
          late IconData? icon;
          switch (state) {
            case 1:
              label = context.l.autosave_status_edited;
              icon = Icons.edit_note;
              break;
            case 0:
              label = context.l.autosave_status_saved;
              icon = Icons.done;

              if (_timeoutPending) {
                _seen = false;
                _timeoutPending = false;
                WidgetsBinding.instance.scheduleFrameCallback((_) {
                  print('[AutosaveStatus] Resetting seen timer');
                  resetTimer();
                });
              }
              break;
            default:
              if (widget.isNewNote && !_seen) {
                label = null;
                icon = null;
              } else {
                label = widget.note.editedTime.yMMMMd_at_Hm(context);
                icon = Icons.edit;
              }
          }
          return Row(
            children: [
              if (icon != null) ...[Icon(icon, color: labelMediumColor, size: Sizes.iconSmall.size), Gap(8.0)],
              if (label != null) Text(label, style: dateStyle),
            ],
          );
        },
      ),
    );
  }
}
