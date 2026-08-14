import 'package:cleanclip/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CleanClip app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CleanClipApp()));
    await tester.pump(const Duration(seconds: 4));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
