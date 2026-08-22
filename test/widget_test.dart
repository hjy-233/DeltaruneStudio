import 'package:flutter_test/flutter_test.dart';

import 'package:deltarune_studio/main.dart';

void main() {
  testWidgets('boots the editor shell', (tester) async {
    await tester.pumpWidget(const DeltaruneStudioShell());

    expect(find.text('Deltarune Studio'), findsOneWidget);
    expect(
      find.text('Editor runtime is ready for the new architecture.'),
      findsOneWidget,
    );
  });
}
