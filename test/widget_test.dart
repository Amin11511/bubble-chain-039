import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:day_039_bubble_chain/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Bubble Chain boots and shows hint + chips', (tester) async {
    await tester.pumpWidget(const BubbleChainApp());
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump(const Duration(milliseconds: 60));

    expect(find.text('Tap a bubble to start the chain'), findsOneWidget);
    expect(find.text('CHAIN x0'), findsOneWidget);
    expect(find.text('BEST 0 · x0'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Tap in empty area is a no-op (doesn\'t throw)', (tester) async {
    await tester.pumpWidget(const BubbleChainApp());
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(const Offset(4, 4));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
