import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shuttle_spirites/screens/paymentscreen.dart';
import 'package:shuttle_spirites/screens/summary_screen.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

// Contact model
class AppContact {
  final String id;
  final String name;
  final String phone;
  final String email;

  AppContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });
}

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
      if (query.isEmpty) {
        filteredContacts = List.from(contacts);
      } else {
        filteredContacts =
            contacts
                .where(
                  (contact) =>
                      contact.name.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      contact.phone.contains(query) ||
                      contact.email.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
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
    // First check if permission is already granted
    bool hasPermission = await FlutterContacts.requestPermission();

    if (hasPermission) {
      _showContactPicker();
    } else {
      // Fallback to permission_handler for more control
      final permission = await Permission.contacts.request();
      if (permission.isGranted) {
        _showContactPicker();
      } else if (permission.isDenied) {
        _showPermissionDeniedDialog();
      } else if (permission.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'This app needs access to your contacts to add them to your shuttle list.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _requestContactPermission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text(
              'Contact permission is permanently denied. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
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
      // Get contacts with properties (name, phone, email)
      final List<Contact> phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      setState(() {
        isLoadingContacts = false;
      });

      if (phoneContacts.isEmpty) {
        _showNoContactsDialog();
        return;
      }

      // Filter contacts that have at least a name and phone number
      final validContacts =
          phoneContacts
              .where(
                (contact) =>
                    contact.displayName.isNotEmpty && contact.phones.isNotEmpty,
              )
              .toList();

      if (validContacts.isEmpty) {
        _showNoContactsDialog();
        return;
      }

      _showContactSelectionDialog(validContacts);
    } catch (e) {
      setState(() {
        isLoadingContacts = false;
      });
      _showErrorDialog('Failed to load contacts: $e');
    }
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('No Contacts'),
            content: const Text(
              'No contacts with phone numbers found on your device.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
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
      for (Contact contact in selectedContacts) {
        final phone =
            contact.phones.isNotEmpty ? contact.phones.first.number : '';
        final email =
            contact.emails.isNotEmpty ? contact.emails.first.address : '';

        // Check if contact already exists
        bool exists = contacts.any(
          (existingContact) =>
              existingContact.name == contact.displayName &&
              existingContact.phone == phone,
        );

        if (!exists && contact.displayName.isNotEmpty && phone.isNotEmpty) {
          contacts.add(
            AppContact(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  contact.displayName,
              name: contact.displayName,
              phone: phone,
              email: email,
            ),
          );
        }
      }
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

// Updated HomePage widget
class HomePage extends StatelessWidget {
  final List<AppContact> contacts;
  final List<AppContact> filteredContacts;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final bool isLoadingContacts;

  const HomePage({
    super.key,
    required this.contacts,
    required this.filteredContacts,
    required this.searchController,
    required this.onSearchChanged,
    required this.isLoadingContacts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Box
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: Icon(Icons.search, color: Color(0xFFA855F7)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Contact count
        Text(
          'Total Contacts: ${contacts.length}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA855F7),
          ),
        ),
        const SizedBox(height: 10),

        // Contacts list
        Expanded(
          child:
              isLoadingContacts
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFA855F7)),
                        SizedBox(height: 20),
                        Text('Loading contacts...'),
                      ],
                    ),
                  )
                  : filteredContacts.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchController.text.isEmpty
                              ? Icons.person_add
                              : Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          searchController.text.isEmpty
                              ? 'No contacts yet'
                              : 'No contacts found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          searchController.text.isEmpty
                              ? 'Tap the + button to add contacts'
                              : 'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFA855F7),
                            child: Text(
                              contact.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.phone),
                              if (contact.email.isNotEmpty) Text(contact.email),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              // You can add more actions here like edit/delete
                            },
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

// Contact Selection Dialog
class ContactSelectionDialog extends StatefulWidget {
  final List<Contact> contacts;
  final Function(List<Contact>) onContactsSelected;

  const ContactSelectionDialog({
    super.key,
    required this.contacts,
    required this.onContactsSelected,
  });

  @override
  State<ContactSelectionDialog> createState() => _ContactSelectionDialogState();
}

class _ContactSelectionDialogState extends State<ContactSelectionDialog> {
  List<Contact> selectedContacts = [];
  List<Contact> filteredContacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredContacts = List.from(widget.contacts);
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContacts = List.from(widget.contacts);
      } else {
        filteredContacts =
            widget.contacts
                .where(
                  (contact) => contact.displayName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Contacts'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Search box
            TextField(
              controller: searchController,
              onChanged: _filterContacts,
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Selected count
            Text('Selected: ${selectedContacts.length}'),
            const SizedBox(height: 10),
            // Contacts list
            Expanded(
              child:
                  filteredContacts.isEmpty
                      ? const Center(child: Text('No contacts found'))
                      : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          final isSelected = selectedContacts.contains(contact);
                          final phone =
                              contact.phones.isNotEmpty
                                  ? contact.phones.first.number
                                  : 'No phone';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFA855F7),
                              child: Text(
                                contact.displayName.isNotEmpty
                                    ? contact.displayName
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(contact.displayName),
                            subtitle: Text(phone),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedContacts.add(contact);
                                  } else {
                                    selectedContacts.remove(contact);
                                  }
                                });
                              },
                              activeColor: const Color(0xFFA855F7),
                            ),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedContacts.remove(contact);
                                } else {
                                  selectedContacts.add(contact);
                                }
                              });
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              selectedContacts.isEmpty
                  ? null
                  : () {
                    widget.onContactsSelected(selectedContacts);
                    Navigator.of(context).pop();
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA855F7),
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Selected'),
        ),
      ],
    );
  }
}
