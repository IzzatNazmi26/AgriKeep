// user_model.dart - Updated version
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username; // We'll use this as the display name
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? country;
  final String? state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final String? farmProfileId;

  UserModel({
    required this.id,
    required this.email,
    required this.username, // Required field
    this.phoneNumber,
    this.profileImageUrl,
    this.country,
    this.state,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.farmProfileId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username, // Only username, no fullName
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'country': country,
      'state': state,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isEmailVerified': isEmailVerified,
      'farmProfileId': farmProfileId,
    };
  }

  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    // Handle timestamps
    dynamic createdAtData = data['createdAt'];
    dynamic updatedAtData = data['updatedAt'];

    DateTime createdAt;
    DateTime updatedAt;

    if (createdAtData is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtData);
    } else if (createdAtData != null && createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else {
      createdAt = DateTime.now();
    }

    if (updatedAtData is int) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(updatedAtData);
    } else if (updatedAtData != null && updatedAtData is Timestamp) {
      updatedAt = updatedAtData.toDate();
    } else {
      updatedAt = DateTime.now();
    }

    return UserModel(
      id: id,
      email: data['email'] ?? '',
      username: data['username'] ?? '', // Changed from fullName to username
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      country: data['country'],
      state: data['state'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEmailVerified: data['isEmailVerified'] ?? false,
      farmProfileId: data['farmProfileId'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '', // Changed from fullName to username
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      country: map['country'],
      state: map['state'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isEmailVerified: map['isEmailVerified'] ?? false,
      farmProfileId: map['farmProfileId'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username, // Changed from fullName
    String? phoneNumber,
    String? profileImageUrl,
    String? country,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? farmProfileId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username, // Changed from fullName
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      country: country ?? this.country,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      farmProfileId: farmProfileId ?? this.farmProfileId,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username)'; // Removed fullName
  }
}