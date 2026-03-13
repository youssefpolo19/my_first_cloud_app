import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScaffold()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.string(
                '''<svg width="120" height="120" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="10" y="10" width="80" height="80" rx="20" stroke="#C0C0C0" stroke-width="4"/><path d="M30 50L45 65L70 35" stroke="#C0C0C0" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/></svg>''',
                width: 120, height: 120,
              ),
              const SizedBox(height: 30),
              const Text("Routiny Pro", style: TextStyle(fontSize: 28, color: Color(0xFFC0C0C0), fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Text("Ultimate CEO Edition", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}