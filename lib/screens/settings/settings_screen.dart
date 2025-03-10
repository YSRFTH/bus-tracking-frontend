import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _useHighContrastMode = false;
  bool _enableNotifications = true;
  bool _saveSearchHistory = true;
  double _textScaleFactor = 1.0;
  String _selectedLanguage = 'English';
  bool _isLoading = true;

  final List<String> _availableLanguages = [
    'English',
    'French',
    'Spanish',
    'Arabic',
    'Hindi',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _useHighContrastMode = prefs.getBool('useHighContrastMode') ?? false;
      _enableNotifications = prefs.getBool('enableNotifications') ?? true;
      _saveSearchHistory = prefs.getBool('saveSearchHistory') ?? true;
      _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('useHighContrastMode', _useHighContrastMode);
    await prefs.setBool('enableNotifications', _enableNotifications);
    await prefs.setBool('saveSearchHistory', _saveSearchHistory);
    await prefs.setDouble('textScaleFactor', _textScaleFactor);
    await prefs.setString('selectedLanguage', _selectedLanguage);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme throughout the app'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
            },
          ),
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Increase contrast for better visibility'),
            value: _useHighContrastMode,
            onChanged: (value) {
              setState(() => _useHighContrastMode = value);
            },
          ),
          ListTile(
            title: const Text('Text Size'),
            subtitle: Text('${(_textScaleFactor * 100).round()}%'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: _textScaleFactor,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: '${(_textScaleFactor * 100).round()}%',
                onChanged: (value) {
                  setState(() => _textScaleFactor = value);
                },
              ),
            ),
          ),
          
          // Language section
          _buildSectionHeader('Language'),
          ListTile(
            title: const Text('App Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          
          // Privacy section
          _buildSectionHeader('Privacy'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive updates about bus arrivals and delays'),
            value: _enableNotifications,
            onChanged: (value) {
              setState(() => _enableNotifications = value);
            },
          ),
          SwitchListTile(
            title: const Text('Save Search History'),
            subtitle: const Text('Remember your recent searches'),
            value: _saveSearchHistory,
            onChanged: (value) {
              setState(() => _saveSearchHistory = value);
            },
          ),
          ListTile(
            title: const Text('Clear Search History'),
            leading: const Icon(Icons.history),
            onTap: () {
              _showClearHistoryDialog();
            },
          ),
          ListTile(
            title: const Text('Clear Cache'),
            leading: const Icon(Icons.cleaning_services),
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          
          // About section
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description),
            onTap: () {
              // Navigate to terms of service
            },
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
          
          // Save button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableLanguages.length,
              itemBuilder: (context, index) {
                final language = _availableLanguages[index];
                return RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Search History'),
          content: const Text('Are you sure you want to clear your search history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Clear search history
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search history cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text('Are you sure you want to clear the app cache? This will remove all saved routes and schedules.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Clear cache
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
} 