// lib/widgets/contact_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
  }

  void _selectAllContacts() {
    setState(() {
      selectedContacts = List.from(filteredContacts);
    });
  }

  void _deselectAllContacts() {
    setState(() {
      selectedContacts.clear();
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

            // Selection controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected: ${selectedContacts.length}'),
                Row(
                  children: [
                    TextButton(
                      onPressed: _selectAllContacts,
                      child: const Text('Select All'),
                    ),
                    TextButton(
                      onPressed: _deselectAllContacts,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ],
            ),
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
                                _toggleContactSelection(contact);
                              },
                              activeColor: const Color(0xFFA855F7),
                            ),
                            onTap: () {
                              _toggleContactSelection(contact);
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
