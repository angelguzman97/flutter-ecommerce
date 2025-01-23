import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class CheckAuthStatusScreen extends StatelessWidget {
  const CheckAuthStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2,),
      ),
    );
  }
}