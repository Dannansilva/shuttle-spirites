import 'package:flutter/material.dart';
import '../models/app_contact.dart';

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
                  ? _buildEmptyState()
                  : _buildContactsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchController.text.isEmpty ? Icons.person_add : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            searchController.text.isEmpty
                ? 'No contacts yet'
                : 'No contacts found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            searchController.text.isEmpty
                ? 'Tap the + button to add contacts'
                : 'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
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
                _showContactOptions(context, contact);
              },
            ),
          ),
        );
      },
    );
  }

  void _showContactOptions(BuildContext context, AppContact contact) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFFA855F7)),
                  title: const Text('Edit Contact'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add edit functionality here
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Contact'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add delete functionality here
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFFA855F7)),
                  title: const Text('Call Contact'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add call functionality here
                  },
                ),
              ],
            ),
          ),
    );
  }
}
