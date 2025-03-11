// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../preferences/preference_key.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    final showScrollbars = PreferenceKey.showScrollbars.preferenceOrDefault;

    switch (axisDirectionToAxis(details.direction)) {
      case Axis.horizontal:
        return child;
      case Axis.vertical:
        assert(details.controller != null);

        final themeData = Theme.of(context);
        return Theme(
          data: themeData.copyWith(
            scrollbarTheme: themeData.scrollbarTheme.copyWith(
              thumbVisibility: showScrollbars ? WidgetStateProperty.all(true) : null,
              trackVisibility: showScrollbars ? WidgetStateProperty.all(true) : null,
              thickness: WidgetStateProperty.all(16.0),
              radius: Radius.circular(16.0),
              interactive: true,
              crossAxisMargin: 4.0,
            ),
          ),
          child: Scrollbar(
            controller: details.controller,
            child: showScrollbars ? Padding(padding: const EdgeInsetsDirectional.only(end: 20.0), child: child) : child,
          ),
        );
    }
  }
}
