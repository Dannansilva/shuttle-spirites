import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shuttle_spirites/models/app_contact.dart';
import 'package:shuttle_spirites/screens/paymentscreen.dart';
import 'package:shuttle_spirites/screens/summary_screen.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shuttle_spirites/services/contact_services.dart';
import 'package:shuttle_spirites/services/permission_service.dart';
import 'package:shuttle_spirites/widgets/contact_selection_dialog.dart';
import 'package:shuttle_spirites/widgets/home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'Dannan';
  int _selectedIndex = 0;
  List<AppContact> contacts = [];
  List<AppContact> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoadingContacts = false;

  // List of pages to be displayed
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize pages
    _pages = [
      HomePage(
        contacts: contacts,
        filteredContacts: filteredContacts,
        searchController: searchController,
        onSearchChanged: _filterContacts,
        isLoadingContacts: isLoadingContacts,
      ),
      const PaymentPage(),
      const SummaryPage(),
    ];

    // Initialize with empty contacts list
    filteredContacts = List.from(contacts);
  }

  void _filterContacts(String query) {
    setState(() {
      filteredContacts = ContactService.filterContacts(contacts, query);
      // Update the home page with new filtered contacts
      _pages[0] = HomePage(
        contacts: contacts,
        filteredContacts: filteredContacts,
        searchController: searchController,
        onSearchChanged: _filterContacts,
        isLoadingContacts: isLoadingContacts,
      );
    });
  }

  Future<void> _requestContactPermission() async {
    final permissionStatus = await ContactService.getPermissionStatus();

    if (permissionStatus.isGranted) {
      _showContactPicker();
      return;
    }

    final hasPermission = await ContactService.requestContactPermission();

    if (hasPermission) {
      _showContactPicker();
    } else {
      final currentStatus = await ContactService.getPermissionStatus();
      if (currentStatus.isDenied) {
        PermissionService.showPermissionDeniedDialog(
          context,
          _requestContactPermission,
        );
      } else if (currentStatus.isPermanentlyDenied) {
        PermissionService.showPermissionPermanentlyDeniedDialog(context);
      }
    }
  }

  Future<void> _showContactPicker() async {
    setState(() {
      isLoadingContacts = true;
      _pages[0] = HomePage(
        contacts: contacts,
        filteredContacts: filteredContacts,
        searchController: searchController,
        onSearchChanged: _filterContacts,
        isLoadingContacts: isLoadingContacts,
      );
    });

    try {
      final List<Contact> phoneContacts =
          await ContactService.getDeviceContacts();

      setState(() {
        isLoadingContacts = false;
      });

      if (phoneContacts.isEmpty) {
        PermissionService.showNoContactsDialog(context);
        return;
      }

      _showContactSelectionDialog(phoneContacts);
    } catch (e) {
      setState(() {
        isLoadingContacts = false;
      });
      PermissionService.showErrorDialog(context, e.toString());
    }
  }

  void _showContactSelectionDialog(List<Contact> phoneContacts) {
    showDialog(
      context: context,
      builder:
          (context) => ContactSelectionDialog(
            contacts: phoneContacts,
            onContactsSelected: (List<Contact> selectedContacts) {
              _addSelectedContacts(selectedContacts);
            },
          ),
    );
  }

  void _addSelectedContacts(List<Contact> selectedContacts) {
    setState(() {
      // Convert device contacts to app contacts
      final newAppContacts = ContactService.convertToAppContacts(
        selectedContacts,
      );

      // Add contacts avoiding duplicates
      contacts = ContactService.addMultipleContacts(contacts, newAppContacts);

      // Update filtered contacts
      _filterContacts(searchController.text);
    });
  }

  void _addContact() {
    _requestContactPermission();
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
      // Floating Action Button (only show on home screen)
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: _addContact,
                backgroundColor: const Color(0xFFA855F7),
                child: const Icon(Icons.person_add, color: Colors.white),
              )
              : null,
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
