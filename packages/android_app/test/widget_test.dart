// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clip_sync_android/android_client.dart';

void main() {
  testWidgets('Android client loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AndroidVoiceClient());

    // Verify that the app title is displayed.
    expect(find.textContaining('语音'), findsOneWidget);
  });
}
