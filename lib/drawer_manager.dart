import 'package:flutter/foundation.dart';

/// A global ChangeNotifier to manage closing the drawer from anywhere in the app.
///
/// This is used to signal to the active page that it should close its drawer,
/// for example, when a new tab is selected in the bottom navigation bar.
class DrawerManager extends ChangeNotifier {
  /// Notifies listeners to close the drawer.
  void closeDrawer() {
    notifyListeners();
  }
}

/// The global singleton instance of the DrawerManager.
final drawerManager = DrawerManager();
