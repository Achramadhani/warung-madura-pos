import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:toko_rajawali/input_manual_page.dart';

void main() {
  testWidgets('Input manual page renders expected controls',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: InputManualPage(),
      ),
    );

    expect(find.text('Input Manual'), findsOneWidget);
    expect(find.text('Masukkan Barcode'), findsOneWidget);
    expect(find.text('Cari Produk'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
