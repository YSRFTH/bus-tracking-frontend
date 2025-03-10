import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mr. Hasan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0164326045',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 204),
                    ),
                  ),
                ],
              ),
            ),
            const _ProfileSection(
              title: 'Account',
              items: [
                _ProfileItem(
                  icon: Icons.person_outline,
                  title: 'Profile Details',
                  onTap: null,
                ),
                _ProfileItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: null,
                ),
                _ProfileItem(
                  icon: Icons.history,
                  title: 'Trip History',
                  onTap: null,
                ),
                _ProfileItem(
                  icon: Icons.favorite_outline,
                  title: 'Saved Places',
                  onTap: null,
                ),
              ],
            ),
            const _ProfileSection(
              title: 'Settings',
              items: [
                _ProfileItem(
                  icon: Icons.language,
                  title: 'Language',
                  onTap: null,
                ),
                _ProfileItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  onTap: null,
                ),
                _ProfileItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: null,
                ),
              ],
            ),
            const _ProfileSection(
              title: 'Support',
              items: [
                _ProfileItem(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: null,
                ),
                _ProfileItem(
                  icon: Icons.phone_outlined,
                  title: '999 Assistance',
                  onTap: null,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle sign out
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;

  const _ProfileSection({
    required this.title,
    required this.items,
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
        ...items,
        const Divider(),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }
} 