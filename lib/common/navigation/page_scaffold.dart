import 'package:flutter/material.dart';

/// [Scaffold] for pages.
class PageScaffold extends StatelessWidget {
  /// The [appBar] to be supplied to [Scaffold].
  final PreferredSizeWidget? appBar;

  /// The [body] to be supplied to [Scaffold].
  final Widget? body;

  /// The [drawer] to be supplied to [Scaffold].
  final Widget? drawer;

  /// The [floatingActionButton] to be supplied to [Scaffold].
  final Widget? floatingActionButton;

  /// The [floatingActionButtonLocation] to be supplied to [Scaffold].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// The [onDrawerChanged] callback to be supplied to [Scaffold].
  final void Function(bool)? onDrawerChanged;

  /// A [Scaffold] that wraps [body] inside a [SafeArea].
  /// Meant to be used as a drop-in replacement to [Scaffold] for convenience.
  const PageScaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.onDrawerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      onDrawerChanged: onDrawerChanged,
      body: body == null ? null : SafeArea(bottom: false, child: body!),
    );
  }
}
