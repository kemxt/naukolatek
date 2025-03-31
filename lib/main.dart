import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:naukolatek/router/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Analiza wydatków',
      theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          platform: TargetPlatform.iOS,
          textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme)),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        platform: TargetPlatform.iOS,
      ),
      routerConfig: router,
    );
  }
}
