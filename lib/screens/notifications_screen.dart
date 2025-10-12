import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  final Map<String, dynamic>? notificationData;
  
  const NotificationsScreen({super.key, this.notificationData});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Column(
        children: [
          // Show notification data if opened from push notification
          if (widget.notificationData != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Opened from Notification',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${widget.notificationData!['type'] ?? 'General'}',
                    style: GoogleFonts.roboto(fontSize: 12),
                  ),
                  if (widget.notificationData!['message'] != null)
                    Text(
                      'Message: ${widget.notificationData!['message']}',
                      style: GoogleFonts.roboto(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
          
          // Notifications list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getNotificationsStream(authService.currentUser?.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading notifications',
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                final notifications = snapshot.data?.docs ?? [];
                
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll see stock updates and recommendations here',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final data = notification.data() as Map<String, dynamic>;
                    
                    return _buildNotificationCard(
                      context,
                      notification.id,
                      data,
                      isDark,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: authService.isAdmin ? FloatingActionButton(
        onPressed: _showCreateNotificationDialog,
        child: const Icon(Icons.add),
        tooltip: 'Send Notification',
      ) : null,
    );
  }
  
  Widget _buildNotificationCard(
    BuildContext context,
    String notificationId,
    Map<String, dynamic> data,
    bool isDark,
  ) {
    final isRead = data['is_read'] ?? false;
    final type = data['type'] ?? 'general';
    final title = data['title'] ?? 'Notification';
    final body = data['body'] ?? '';
    final timestamp = (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case 'recommendation':
        iconData = Icons.trending_up;
        iconColor = Colors.green;
        break;
      case 'newsletter':
        iconData = Icons.newspaper;
        iconColor = Colors.blue;
        break;
      case 'performance':
        iconData = Icons.bar_chart;
        iconColor = Colors.orange;
        break;
      case 'system':
        iconData = Icons.settings;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      child: InkWell(
        onTap: () => _markAsRead(notificationId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.roboto(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(timestamp),
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Stream<QuerySnapshot> _getNotificationsStream(String? userId) {
    if (userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots();
  }
  
  Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }
  
  Future<void> _markAllAsRead() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    
    if (userId == null) return;
    
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();
      
      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'is_read': true});
      }
      
      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark notifications as read'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showCreateNotificationDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String selectedType = 'general';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'recommendation', child: Text('Recommendation')),
                DropdownMenuItem(value: 'newsletter', child: Text('Newsletter')),
                DropdownMenuItem(value: 'performance', child: Text('Performance')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) => selectedType = value ?? 'general',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                await _sendNotificationToAllUsers(
                  titleController.text.trim(),
                  bodyController.text.trim(),
                  selectedType,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _sendNotificationToAllUsers(String title, String body, String type) async {
    try {
      // Get all users
      final users = await _firestore.collection('users').get();
      final batch = _firestore.batch();
      
      for (final user in users.docs) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'user_id': user.id,
          'title': title,
          'body': body,
          'type': type,
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification sent to ${users.docs.length} users'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send notification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
