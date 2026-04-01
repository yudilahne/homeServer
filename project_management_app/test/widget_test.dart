import 'package:flutter_test/flutter_test.dart';

import 'package:project_management_app/app.dart';

void main() {
  testWidgets('app loads splash or login screen', (tester) async {
    await tester.pumpWidget(const ProjectPulseApp());

    expect(find.byType(ProjectPulseApp), findsOneWidget);
  });
}
