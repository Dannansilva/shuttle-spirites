import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome to Shuttle Sprites',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('This is the home screen.', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Color(0xFFA855F7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          child: GNav(
            backgroundColor: Color(0xFFA855F7),
            color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black,
            gap: 5,
            padding: EdgeInsetsGeometry.all(10),
            onTabChange: (index) {
              print(index);
            },
            tabs: [
              GButton(icon: Icons.home, text: 'home'),
              GButton(icon: Icons.calendar_month, text: 'payment'),
              GButton(icon: Icons.analytics, text: 'summary'),
            ],
          ),
        ),
      ),
    );
  }
}
