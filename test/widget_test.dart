import 'package:flutter_test/flutter_test.dart';

import 'package:deltarune_studio/app/deltarune_studio_app.dart';

void main() {
  testWidgets('boots the editor shell', (tester) async {
    await tester.pumpWidget(const DeltaruneStudioApp());

    expect(find.text('Deltarune Studio'), findsOneWidget);
    expect(find.text('No project is open.'), findsOneWidget);
  });
}
