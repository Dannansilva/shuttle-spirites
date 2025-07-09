import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shuttle_spirites/screens/paymentscreen.dart';
import 'package:shuttle_spirites/screens/summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'Dannan';
  int _selectedIndex = 0;

  // List of pages to be displayed
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize pages
    _pages = [const HomePage(), const PaymentPage(), const SummaryPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting message and name
              const Text(
                "Welcome Back!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),

              // The content of the selected page
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        color: const Color(0xFFA855F7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          child: GNav(
            selectedIndex: _selectedIndex,
            backgroundColor: const Color(0xFFA855F7),
            color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black,
            gap: 8,
            padding: const EdgeInsets.all(16),
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.payment, text: 'Payment'),
              GButton(icon: Icons.analytics, text: 'Summary'),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate page widgets
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 80, color: Color(0xFFA855F7)),
          SizedBox(height: 20),
          Text(
            'Welcome to Shuttle Sprites',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('This is the home screen.', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
