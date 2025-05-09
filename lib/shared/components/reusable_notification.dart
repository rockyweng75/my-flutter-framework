import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/utils/print_type.dart';

class ReusableNotification {
  static ReusableNotification? _instance;
  final BuildContext _context;
  final List<OverlayEntry> _overlayEntries = [];
  
  // Store the overlay state to prevent accessing it after widget disposal
  OverlayState? _cachedOverlay;

  ReusableNotification._internal(this._context) {
    // Cache the overlay when the notification is created
    _cachedOverlay = Overlay.maybeOf(_context);
  }

  factory ReusableNotification(BuildContext context) {
    // We don't want to reuse the instance if the context has changed
    // as that could lead to using a stale context
    if (_instance == null || _instance!._context != context) {
      _instance = ReusableNotification._internal(context);
    }
    return _instance!;
  }

  // Creates a new instance with a fresh context (useful when context changes)
  static void updateInstance(BuildContext context) {
    _instance = ReusableNotification._internal(context);
  }

  // Safe method that can be called during widget lifecycle
  void show(String message, {PrintType type = PrintType.info, Duration duration = const Duration(seconds: 2)}) {
    // Try to use cached overlay first, if that fails, try to get it from context
    final overlay = _cachedOverlay ?? Overlay.maybeOf(_context);
    if (overlay == null) {
      debugPrint("Warning: Could not find Overlay. Notification not shown.");
      return;
    }

    double topOffset = 50.0;

    for (final entry in _overlayEntries) {
      topOffset += 60.0; // Each message moves down 60 pixels
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topOffset,
        left: 10.0,
        right: 10.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: PrintTypeUtil.getTypeColor(type),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                PrintTypeUtil.getTypeIcon(
                  type: type,
                  isLight: true,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ),
      ),
    );

    _overlayEntries.add(overlayEntry);
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      // Check if the entry is still in the list before removing
      if (_overlayEntries.contains(overlayEntry)) {
        overlayEntry.remove();
        _overlayEntries.remove(overlayEntry);
      }
    });
  }

  // Static method for convenience
  static void showNotification(
    BuildContext context, 
    String message, 
    {PrintType type = PrintType.info, 
    Duration duration = const Duration(seconds: 2)}
  ) {
    ReusableNotification(context).show(message, type: type, duration: duration);
  }
}