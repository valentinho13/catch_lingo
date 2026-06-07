import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import 'app_theme.dart';

class CatchLingoApp extends StatelessWidget {
  const CatchLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatchLingo',
      debugShowCheckedModeBanner: false,
      theme: CatchLingoTheme.light(),
      home: const HomeScreen(),
    );
  }
}
