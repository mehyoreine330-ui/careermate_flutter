// Basic smoke test for CareerMate's shared UI shell.
//
// This intentionally does NOT pump the full `CareerMateApp` widget tree:
// `providers/auth_provider.dart` reads `Supabase.instance.client`, which
// throws unless `Supabase.initialize(...)` has already run — there's no
// mock Supabase setup in this test target yet. Wire one up (e.g. via
// `Supabase.initialize` against a local/test project, or a fake
// SupabaseClient override on the ProviderScope) before expanding this
// into a real app-level test.
//
// This file previously still had the counter-app template's smoke test
// (`MyApp`, tapping `Icons.add`, expecting '0'/'1'), which doesn't exist in
// this project and failed `flutter analyze`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careermate_flutter/widgets/app_background.dart';

void main() {
  testWidgets('AppBackground renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: AppBackground(
            child: Center(child: Text('CareerMate')),
          ),
        ),
      ),
    );

    expect(find.text('CareerMate'), findsOneWidget);
  });
}
