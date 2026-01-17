// user_model.dart - Updated version (country completely removed)
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final String? farmProfileId;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.profileImageUrl,
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
      'username': username,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'state': state, // Only state, no country
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

    // HANDLE BACKWARD COMPATIBILITY:
    // Check for 'fullName' field (old) and fallback to 'username'
    String username = data['username'] ?? '';
    if (username.isEmpty && data['fullName'] != null) {
      username = data['fullName'];
    }

    return UserModel(
      id: id,
      email: data['email'] ?? '',
      username: username,
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      state: data['state'], // Only state, no country fallback
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEmailVerified: data['isEmailVerified'] ?? false,
      farmProfileId: data['farmProfileId'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle backward compatibility for username
    String username = map['username'] ?? '';
    if (username.isEmpty && map['fullName'] != null) {
      username = map['fullName'];
    }

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: username,
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      state: map['state'], // Only state, no country
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isEmailVerified: map['isEmailVerified'] ?? false,
      farmProfileId: map['farmProfileId'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? farmProfileId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      state: state ?? this.state, // Only state
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      farmProfileId: farmProfileId ?? this.farmProfileId,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username)';
  }
}