// lib/models/app_contact.dart
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

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email};
  }

  // Create from JSON
  factory AppContact.fromJson(Map<String, dynamic> json) {
    return AppContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Create a copy with updated values
  AppContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
  }) {
    return AppContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'AppContact(id: $id, name: $name, phone: $phone, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppContact &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ phone.hashCode ^ email.hashCode;
  }
}
