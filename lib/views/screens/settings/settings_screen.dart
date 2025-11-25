import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/settings_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settingsViewModel.isDarkMode,
            onChanged: (value) {
              settingsViewModel.toggleTheme();
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable push notifications'),
            value: settingsViewModel.notificationsEnabled,
            onChanged: (value) {
              settingsViewModel.setNotificationsEnabled(value);
            },
          ),
          const Divider(),
          // Show sync option only for logged in users
          if (authViewModel.isAuthenticated && !authViewModel.isGuest)
            ListTile(
              leading: authViewModel.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              title: const Text('Sync Poems'),
              subtitle: Text(
                authViewModel.getLastSyncTime() != null
                    ? 'Last synced: ${authViewModel.getLastSyncTime()}'
                    : 'Download your poems from the cloud',
              ),
              onTap: authViewModel.isLoading
                  ? null
                  : () async {
                      final success = await authViewModel.syncPoemsFromCloud();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Poems synced successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
            ),
          if (authViewModel.isAuthenticated && !authViewModel.isGuest)
            const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('Version ${settingsViewModel.appVersion}'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}