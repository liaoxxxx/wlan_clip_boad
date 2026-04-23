// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clip_sync_usb/windows/windows_server.dart';
import 'package:clip_sync_usb/android/android_client.dart';

void main() {
  testWidgets('Windows server loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WindowsClipboardServer());

    // Verify that the app title is displayed.
    expect(find.textContaining('剪贴板'), findsOneWidget);
  });
}
