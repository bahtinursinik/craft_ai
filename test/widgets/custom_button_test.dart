import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_resource_ai/core/widgets/common_widgets.dart';

void main() {
  group('CustomButton Widget Tests', () {

    testWidgets('should display correct text and handle taps', (WidgetTester tester) async {
      var isPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Sign In',
              onTap: () {
                isPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);

      await tester.tap(find.byType(CustomButton));

      await tester.pump();

      expect(isPressed, true);
    });

    testWidgets('should show CircularProgressIndicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Sign In',
              isLoading: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      expect(find.text('Sign In'), findsNothing);
    });
  });
}