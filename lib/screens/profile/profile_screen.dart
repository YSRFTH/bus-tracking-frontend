import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Padding(
                padding: const EdgeInsets.only(top: 80.0, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'User Name',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '0164326045',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withAlpha(200),
                        fontWeight: FontWeight.w200,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            title: const Text('Profile'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
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
              _ProfileSection(
                title: 'Settings',
                items: [
                  const _ProfileItem(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: null,
                  ),
                  ProfileToggleItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: Provider.of<ThemeProvider>(context).isDarkMode,
                    onChanged: (bool newValue) {
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme();
                    },
                  ),
                  const _ProfileItem(
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ProfileSection({required this.title, required this.items, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  const _ProfileItem({required this.icon, required this.title, this.onTap});

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

class ProfileToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProfileToggleItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      // Switch will be displayed on the far right
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
