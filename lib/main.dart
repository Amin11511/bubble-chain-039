import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/bubble_chain_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF04061A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BubbleChainApp());
}

class BubbleChainApp extends StatelessWidget {
  const BubbleChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Bubble Chain',
      debugShowCheckedModeBanner: false,
      home: BubbleChainGame(),
    );
  }
}
