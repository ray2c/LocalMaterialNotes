import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/actions/notes/add.dart';
import '../../../common/actions/notes/pop.dart';
import '../../../common/constants/constants.dart';
import '../../../common/extensions/build_context_extension.dart';
import '../../../models/note/types/note_type.dart';
import '../../../providers/notifiers/notifiers.dart';

/// Floating action button to add a note.
class AddNoteFab extends ConsumerStatefulWidget {
  /// Default constructor.
  const AddNoteFab({super.key});

  @override
  ConsumerState<AddNoteFab> createState() => _AddNoteFabState();
}

class _AddNoteFabState extends ConsumerState<AddNoteFab> {
  NoteType? _newNoteType;

  void onOpen() {
    canPopNotifier.update();
  }

  void onClose() {
    canPopNotifier.update();

    if (_newNoteType != null) {
      addNote(context, ref, noteType: _newNoteType!);
      _newNoteType = null;
    }
  }

  void onPressed(NoteType noteType) {
    _newNoteType = noteType;

    if (NoteType.available.length == 1) {
      onClose();
    } else {
      closeAddNoteFabIfOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableNotesTypes = NoteType.available;

    return availableNotesTypes.length == 1
        ? FloatingActionButton(
          tooltip: context.l.tooltip_fab_add_note,
          onPressed: () => onPressed(availableNotesTypes.first),
          child: const Icon(Icons.add),
        )
        : ExpandableFab(
          key: addNoteFabKey,
          type: ExpandableFabType.up,
          childrenAnimation: ExpandableFabAnimation.none,
          distance: 64,
          overlayStyle: ExpandableFabOverlayStyle(blur: 10.0),
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            heroTag: '<open add note FAB hero tag>',
            child: const Icon(Icons.add),
          ),
          closeButtonBuilder: RotateFloatingActionButtonBuilder(
            heroTag: '<close add note FAB hero tag>',
            child: const Icon(Icons.close),
          ),
          afterOpen: onOpen,
          afterClose: onClose,
          children: [
            if (availableNotesTypes.contains(NoteType.plainText))
              Row(
                children: [
                  Text(NoteType.plainText.title(context)),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: '<add plain text note hero tag>',
                    tooltip: context.l.tooltip_fab_add_plain_text_note,
                    onPressed: () => onPressed(NoteType.plainText),
                    child: Icon(NoteType.plainText.icon),
                  ),
                ],
              ),
            if (availableNotesTypes.contains(NoteType.markdown))
              Row(
                children: [
                  Text(NoteType.markdown.title(context)),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: '<add markdown note hero tag>',
                    tooltip: context.l.tooltip_fab_add_markdown_note,
                    onPressed: () => onPressed(NoteType.markdown),
                    child: Icon(NoteType.markdown.icon),
                  ),
                ],
              ),
            if (availableNotesTypes.contains(NoteType.richText))
              Row(
                children: [
                  Text(NoteType.richText.title(context)),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: '<add rich text note hero tag>',
                    tooltip: context.l.tooltip_fab_add_rich_text_note,
                    onPressed: () => onPressed(NoteType.richText),
                    child: Icon(NoteType.richText.icon),
                  ),
                ],
              ),
            if (availableNotesTypes.contains(NoteType.checklist))
              Row(
                children: [
                  Text(NoteType.checklist.title(context)),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: '<add checklist note hero tag>',
                    tooltip: context.l.tooltip_fab_add_checklist_note,
                    onPressed: () => onPressed(NoteType.checklist),
                    child: Icon(NoteType.checklist.icon),
                  ),
                ],
              ),
          ],
        );
  }
}
