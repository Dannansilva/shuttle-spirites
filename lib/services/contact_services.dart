// lib/services/contact_service.dart
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_contact.dart';

class ContactService {
  // Request permission to access contacts
  static Future<bool> requestContactPermission() async {
    // First check if permission is already granted
    bool hasPermission = await FlutterContacts.requestPermission();

    if (hasPermission) {
      return true;
    } else {
      // Fallback to permission_handler for more control
      final permission = await Permission.contacts.request();
      return permission.isGranted;
    }
  }

  // Check permission status
  static Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.contacts.status;
  }

  // Get all contacts from device
  static Future<List<Contact>> getDeviceContacts() async {
    try {
      // Get contacts with properties (name, phone, email)
      final List<Contact> phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have at least a name and phone number
      final validContacts =
          phoneContacts
              .where(
                (contact) =>
                    contact.displayName.isNotEmpty && contact.phones.isNotEmpty,
              )
              .toList();

      return validContacts;
    } catch (e) {
      throw Exception('Failed to load contacts: $e');
    }
  }

  // Convert device contacts to app contacts
  static List<AppContact> convertToAppContacts(List<Contact> deviceContacts) {
    return deviceContacts.map((contact) {
      final phone =
          contact.phones.isNotEmpty ? contact.phones.first.number : '';
      final email =
          contact.emails.isNotEmpty ? contact.emails.first.address : '';

      return AppContact(
        id:
            DateTime.now().millisecondsSinceEpoch.toString() +
            contact.displayName,
        name: contact.displayName,
        phone: phone,
        email: email,
      );
    }).toList();
  }

  // Filter contacts based on search query
  static List<AppContact> filterContacts(
    List<AppContact> contacts,
    String query,
  ) {
    if (query.isEmpty) {
      return List.from(contacts);
    }

    return contacts
        .where(
          (contact) =>
              contact.name.toLowerCase().contains(query.toLowerCase()) ||
              contact.phone.contains(query) ||
              contact.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Check if contact already exists in the list
  static bool contactExists(
    List<AppContact> existingContacts,
    AppContact newContact,
  ) {
    return existingContacts.any(
      (existingContact) =>
          existingContact.name == newContact.name &&
          existingContact.phone == newContact.phone,
    );
  }

  // Add multiple contacts to existing list (avoiding duplicates)
  static List<AppContact> addMultipleContacts(
    List<AppContact> existingContacts,
    List<AppContact> newContacts,
  ) {
    final updatedContacts = List<AppContact>.from(existingContacts);

    for (AppContact contact in newContacts) {
      if (!contactExists(updatedContacts, contact) &&
          contact.name.isNotEmpty &&
          contact.phone.isNotEmpty) {
        updatedContacts.add(contact);
      }
    }

    return updatedContacts;
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
