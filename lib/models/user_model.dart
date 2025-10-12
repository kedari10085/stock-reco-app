class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final SubscriptionType subscriptionType;
  final DateTime? subscriptionExpiryDate;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.subscriptionType,
    this.subscriptionExpiryDate,
    required this.createdAt,
  });

  bool get isPremium => subscriptionType == SubscriptionType.premium;
  bool get isSubscriptionActive {
    if (subscriptionType == SubscriptionType.free) return true;
    if (subscriptionExpiryDate == null) return false;
    return subscriptionExpiryDate!.isAfter(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'subscriptionType': subscriptionType.toString(),
      'subscriptionExpiryDate': subscriptionExpiryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.toString() == json['subscriptionType'],
      ),
      subscriptionExpiryDate: json['subscriptionExpiryDate'] != null
          ? DateTime.parse(json['subscriptionExpiryDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    SubscriptionType? subscriptionType,
    DateTime? subscriptionExpiryDate,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum SubscriptionType { free, premium }
