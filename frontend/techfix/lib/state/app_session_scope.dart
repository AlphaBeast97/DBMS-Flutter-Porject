/// Provides scoped access to [AppSession] via [InheritedNotifier].
///
/// Any child widget can call `AppSessionScope.of(context)` to retrieve
/// the nearest [AppSession] and automatically rebuild when it changes.
import 'package:flutter/material.dart';
import 'package:techfix/state/app_session.dart';

class AppSessionScope extends InheritedNotifier<AppSession> {
  const AppSessionScope({
    super.key,
    required AppSession session,
    required Widget child,
  }) : super(notifier: session, child: child);

  /// Retrieves the [AppSession] from the widget tree.
  /// Asserts that the scope exists (must be placed above screens).
  static AppSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSessionScope>();
    assert(scope != null, 'AppSessionScope not found in widget tree.');
    return scope!.notifier!;
  }
}
