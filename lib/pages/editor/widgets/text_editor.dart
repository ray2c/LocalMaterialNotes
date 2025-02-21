import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

/// Text editor.
class TextEditor extends ConsumerStatefulWidget {
  /// Text editor allowing to edit the content of a note.
  const TextEditor({
    super.key,
    required this.isNewNote,
    required this.readOnly,
    this.autofocus = false,
    this.setupFocusNode,
  });

  /// Whether the note was just created.
  final bool isNewNote;

  /// Whether the text fields are read only.
  final bool readOnly;

  /// Whether the text field should request focus.
  final bool autofocus;

  /// Callback for setting up FocusNode.
  final void Function(FocusNode?)? setupFocusNode;

  @override
  ConsumerState<TextEditor> createState() => TextEditorState();
}

/// [State] of the text editor.
class TextEditorState<T extends TextEditor> extends ConsumerState<T> {
  /// Focus node of the note content text editor.
  late FocusNode editorFocusNode;

  @override
  void initState() {
    super.initState();

    editorFocusNode = FocusNode(debugLabel: 'Editor focus node');
    widget.setupFocusNode?.call(editorFocusNode);
  }

  @override
  void dispose() {
    widget.setupFocusNode?.call(null);
    editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
