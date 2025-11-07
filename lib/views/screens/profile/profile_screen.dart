import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryStart,
              child: Text(
                authViewModel.displayName[0].toUpperCase(),
                style: AppTextStyles.h2(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              authViewModel.displayName,
              style: AppTextStyles.h3(),
            ),

            // Email
            if (authViewModel.email != null)
              Text(
                authViewModel.email!,
                style: AppTextStyles.bodyMedium(),
              ),

            const SizedBox(height: 8),

            // Tier badge
            Text(
              authViewModel.getTierDescription(),
              style: AppTextStyles.labelMedium(
                color: AppColors.primaryStart,
              ),
            ),

            const SizedBox(height: 32),

            // Placeholder options
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Upgrade to Pro'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await authViewModel.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}