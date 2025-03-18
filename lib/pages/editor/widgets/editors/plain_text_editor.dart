import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/paddings.dart';
import '../../../../common/extensions/build_context_extension.dart';
import '../../../../models/note/note.dart';
import '../../../../models/note/note_status.dart';
import '../../../../providers/notes/notes_provider.dart';
import '../../../../providers/notifiers/notifiers.dart';
import '../text_editor.dart';

/// Plain text editor.
class PlainTextEditor extends TextEditor {
  /// Text editor allowing to edit the plain text content of a [PlainTextNote].
  const PlainTextEditor({
    super.key,
    required this.note,
    required super.isNewNote,
    required super.readOnly,
    required super.autofocus,
    super.setupFocusNode,
  });

  /// The note to display.
  final PlainTextNote note;

  @override
  ConsumerState<PlainTextEditor> createState() => _PlainTextEditorState();
}

class _PlainTextEditorState extends TextEditorState<PlainTextEditor> {
  late final TextEditingController contentTextController;

  @override
  void initState() {
    super.initState();

    contentTextController = TextEditingController(text: widget.note.content);
  }

  void onChanged(String content) {
    PlainTextNote note = widget.note..content = content;

    ref.read(notesProvider(status: NoteStatus.available, label: currentLabelFilter).notifier).edit(note);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.pageHorizontal,
      child: TextField(
        controller: contentTextController,
        focusNode: editorFocusNode,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        maxLines: null,
        expands: true,
        decoration: InputDecoration.collapsed(hintText: context.l.hint_content),
        spellCheckConfiguration: SpellCheckConfiguration(spellCheckService: DefaultSpellCheckService()),
        onChanged: onChanged,
      ),
    );
  }
}
