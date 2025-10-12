import 'package:cloud_firestore/cloud_firestore.dart';

class Newsletter {
  final String id;
  final String title;
  final String body;
  final DateTime publishDate;
  final DateTime createdAt;
  final String authorEmail;
  final bool isPublished;
  final List<String> tags;

  Newsletter({
    required this.id,
    required this.title,
    required this.body,
    required this.publishDate,
    required this.createdAt,
    required this.authorEmail,
    this.isPublished = true,
    this.tags = const [],
  });

  factory Newsletter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Newsletter(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      publishDate: (data['publish_date'] as Timestamp).toDate(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      authorEmail: data['author_email'] ?? '',
      isPublished: data['is_published'] ?? true,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'publish_date': Timestamp.fromDate(publishDate),
      'created_at': Timestamp.fromDate(createdAt),
      'author_email': authorEmail,
      'is_published': isPublished,
      'tags': tags,
    };
  }

  Newsletter copyWith({
    String? title,
    String? body,
    DateTime? publishDate,
    bool? isPublished,
    List<String>? tags,
  }) {
    return Newsletter(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      publishDate: publishDate ?? this.publishDate,
      createdAt: createdAt,
      authorEmail: authorEmail,
      isPublished: isPublished ?? this.isPublished,
      tags: tags ?? this.tags,
    );
  }
}

class Subscriber {
  final String id;
  final String email;
  final DateTime subscribedAt;
  final bool isActive;
  final Map<String, bool> preferences;

  Subscriber({
    required this.id,
    required this.email,
    required this.subscribedAt,
    this.isActive = true,
    this.preferences = const {},
  });

  factory Subscriber.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscriber(
      id: doc.id,
      email: data['email'] ?? '',
      subscribedAt: (data['subscribed_at'] as Timestamp).toDate(),
      isActive: data['is_active'] ?? true,
      preferences: Map<String, bool>.from(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'subscribed_at': Timestamp.fromDate(subscribedAt),
      'is_active': isActive,
      'preferences': preferences,
    };
  }
}
