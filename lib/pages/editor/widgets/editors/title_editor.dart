import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/paddings.dart';
import '../../../../common/enums/autosave_parts.dart';
import '../../../../common/extensions/build_context_extension.dart';
import '../../../../common/preferences/preference_key.dart';
import '../../../../models/note/note.dart';
import '../../../../models/note/note_status.dart';
import '../../../../providers/notes/notes_provider.dart';
import '../../../../providers/notifiers/notifiers.dart';
import '../../autosave_controller.dart';

/// Title editor.
class TitleEditor extends ConsumerStatefulWidget {
  /// Text field allowing to edit the title of a note.
  const TitleEditor({
    super.key,
    required this.readOnly,
    required this.isNewNote,
    required this.onSubmitted,
    this.controller,
  });

  /// Whether the page is read only.
  final bool readOnly;

  /// Whether the note was just created.
  final bool isNewNote;

  /// Called when the title is submitted.
  final VoidCallback onSubmitted;

  /// Controller of the title of the note.
  final TextEditingController? controller;

  @override
  ConsumerState<TitleEditor> createState() => _TitleEditorState();
}

class _TitleEditorState extends ConsumerState<TitleEditor> with AutosavePartState, AutosavePartHandler<Note, String> {
  @override
  bool savePart(Note note, String newTitle) {
    note.title = newTitle;
    return true;
  }

  /// Saves the [newTitle] of the [note] in the database.
  void onChanged(Note? note, String? newTitle) {
    if (note == null || newTitle == null) {
      return;
    }

    note.title = newTitle;

    ref.read(notesProvider(status: NoteStatus.available, label: currentLabelFilter).notifier).edit(note);
  }

  @override
  void initState() {
    super.initState();

    // ignore: inference_failure_on_function_invocation
    setupAutosavePart(Part.title);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.pageHorizontal,
      child:
          widget.controller == null
              ? ValueListenableBuilder(
                valueListenable: currentNoteNotifier,
                builder: (context, currentNote, child) {
                  final titleController = TextEditingController(text: currentNote?.title);
                  return _textField(context, titleController, (text) => onChanged(currentNote, text));
                },
              )
              : _textField(context, widget.controller, pushChanges),
    );
  }

  Widget _textField(BuildContext context, TextEditingController? titleController, void Function(String)? onChanged) {
    final focusTitleOnNewNote = PreferenceKey.focusTitleOnNewNote.preferenceOrDefault;
    final biggerTitles = PreferenceKey.biggerTitles.preferenceOrDefault;

    var titleStyle = biggerTitles ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.titleLarge;

    return TextField(
      readOnly: widget.readOnly,
      autofocus: widget.isNewNote && focusTitleOnNewNote,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      style: titleStyle,
      decoration: InputDecoration.collapsed(hintText: context.l.hint_title),
      controller: titleController,
      onChanged: onChanged,
      onSubmitted: (_) => widget.onSubmitted(),
    );
  }
}
