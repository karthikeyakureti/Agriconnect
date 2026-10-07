import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agriconnect/main.dart';
import 'package:agriconnect/providers/auth_provider.dart';
import 'package:agriconnect/providers/product_provider.dart';
import 'package:agriconnect/providers/order_provider.dart';
import 'package:agriconnect/providers/chat_provider.dart';

void main() {
  testWidgets('AgriConnect smoke test renders app', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const AgriConnectApp(),
      ),
    );

    // Initial splash frame
    expect(find.text('AgriConnect'), findsOneWidget);

    // Advance fake timer to resolve splash delay
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
