import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Clear all notifications
            },
          ),
        ],
      ),
      body: ListView(
        children: const [
          _NotificationGroup(
            title: 'New',
            notifications: [
              _NotificationItem(
                icon: Icons.location_on,
                title: 'You have reached your destination.',
                time: '2 min ago',
                isRead: false,
              ),
              _NotificationItem(
                icon: Icons.directions_bus,
                title: 'Your selected bus is reaching at your location.',
                time: '5 min ago',
                isRead: false,
              ),
            ],
          ),
          _NotificationGroup(
            title: 'Earlier',
            notifications: [
              _NotificationItem(
                icon: Icons.info_outline,
                title: 'Your selected route looks busy, you may choose other available routes to reach your destination.',
                time: '2 hours ago',
                isRead: true,
              ),
              _NotificationItem(
                icon: Icons.warning_amber,
                title: 'Route 13 is experiencing delays due to traffic.',
                time: '1 day ago',
                isRead: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  final String title;
  final List<_NotificationItem> notifications;

  const _NotificationGroup({
    required this.title,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...notifications,
        const Divider(),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final bool isRead;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isRead
            ? Colors.grey.withValues(red: 158, green: 158, blue: 158, alpha: 51)
            : Theme.of(context).colorScheme.primary.withValues(red: 210, green: 180, blue: 140, alpha: 51),
        child: Icon(
          icon,
          color: isRead
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(time),
      onTap: () {
        // Handle notification tap
      },
    );
  }
} 