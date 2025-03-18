import 'package:flutter/material.dart';
import 'package:flutter_checklist/checklist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/note/note.dart';
import '../../../../models/note/note_status.dart';
import '../../../../providers/notes/notes_provider.dart';
import '../../../../providers/notifiers/notifiers.dart';
import '../text_editor.dart';

/// Checklist editor.
class ChecklistEditor extends TextEditor {
  /// Editor allowing to edit the checklist content of a [ChecklistNote].
  const ChecklistEditor({
    super.key,
    required this.note,
    required super.isNewNote,
    required super.readOnly,
    super.setupFocusNode,
  });

  /// The note to display.
  final ChecklistNote note;

  /// Called when an item of the checklist changes with the new [checklistLines].
  void onChecklistChanged(WidgetRef ref, List<ChecklistLine> checklistLines) {
    ChecklistNote newNote =
        note
          ..checkboxes = checklistLines.map((checklistLine) => checklistLine.toggled).toList()
          ..texts = checklistLines.map((checklistLine) => checklistLine.text).toList();

    ref.read(notesProvider(status: NoteStatus.available, label: currentLabelFilter).notifier).edit(newNote);
  }

  @override
  ConsumerState<ChecklistEditor> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends TextEditorState<ChecklistNote, List<ChecklistLine>, ChecklistEditor> {
  @override
  bool savePart(ChecklistNote note, List<ChecklistLine> checklistLines) {
    note
      ..checkboxes = checklistLines.map((checklistLine) => checklistLine.toggled).toList()
      ..texts = checklistLines.map((checklistLine) => checklistLine.text).toList();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Checklist(
            lines: widget.note.checklistLines,
            enabled: !widget.readOnly,
            autofocusFirstLine: widget.isNewNote,
            onChanged: pushChanges,
          ),
        ),
      ],
    );
  }
}
