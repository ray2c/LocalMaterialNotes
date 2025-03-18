import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

import '../../../common/enums/autosave_parts.dart';
import '../../../models/note/note.dart';
import '../../../providers/notifiers/notifiers.dart';
import '../autosave_controller.dart';

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
  // ignore: inference_failure_on_instance_creation
  ConsumerState<TextEditor> createState() => TextEditorState();
}

/// [State] of the text editor.
class TextEditorState<N extends Note, V, T extends TextEditor> extends ConsumerState<T>
    with AutosavePartState, AutosavePartHandler<N, V> {
  /// Focus node of the note content text editor.
  late FocusNode editorFocusNode;

  /// Function to be called by [AutosaveController] to supply the current latest content.
  V? Function()? onPullChanges() => null;

  @mustCallSuper
  @override
  void initState() {
    super.initState();

    editorFocusNode = FocusNode(debugLabel: 'Editor focus node');
    editorFocusNode.addListener(_onFocusChanged);
    widget.setupFocusNode?.call(editorFocusNode);

    setupAutosavePart(Part.body, onPullChanges());
  }

  @mustCallSuper
  @override
  void dispose() {
    editorFocusNode.removeListener(_onFocusChanged);
    widget.setupFocusNode?.call(null);
    editorFocusNode.dispose();

    super.dispose();
  }

  void _onFocusChanged() {
    editorHasFocusNotifier.value = editorFocusNode.hasPrimaryFocus;
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
