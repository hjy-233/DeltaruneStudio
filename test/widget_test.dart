import 'package:deltarune_studio/app/deltarune_studio_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('boots the studio app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeltaruneStudioApp()));
    await tester.pump();

    expect(find.byType(DeltaruneStudioApp), findsOneWidget);
  });
}
