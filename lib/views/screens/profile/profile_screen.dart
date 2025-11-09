import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_text_field.dart';
import '../auth/login_screen.dart';
import '../pro_upgrade/pro_upgrade_screen.dart';

/// Profile Screen - Complete
/// Features: Edit profile, Change password, Delete account
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Text(
                'Profile',
                style: AppTextStyles.h3(),
              ),

              const SizedBox(height: 32),

              // Avatar with edit button
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryStart.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        authViewModel.displayName[0].toUpperCase(),
                        style: AppTextStyles.h1(color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Change avatar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Avatar change coming soon!'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: AppColors.primaryStart,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                authViewModel.displayName,
                style: AppTextStyles.h3(),
              ),

              const SizedBox(height: 4),

              // Email
              if (authViewModel.email != null)
                Text(
                  authViewModel.email!,
                  style: AppTextStyles.bodyMedium(),
                ),

              const SizedBox(height: 8),

              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: authViewModel.isPro
                      ? AppColors.successGradient
                      : authViewModel.isGuest
                      ? null
                      : AppColors.primaryGradient,
                  color: authViewModel.isGuest
                      ? AppColors.guest.withOpacity(0.2)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  border: authViewModel.isGuest
                      ? Border.all(color: AppColors.guest)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      authViewModel.isPro
                          ? Icons.star
                          : authViewModel.isGuest
                          ? Icons.person_outline
                          : Icons.verified_user,
                      size: 16,
                      color: authViewModel.isGuest
                          ? AppColors.guest
                          : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      authViewModel.getTierDescription().toUpperCase(),
                      style: AppTextStyles.labelMedium(
                        color: authViewModel.isGuest
                            ? AppColors.guest
                            : Colors.white,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Account actions
              _buildActionsList(context, authViewModel, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsList(
      BuildContext context,
      AuthViewModel authViewModel,
      bool isDark,
      ) {
    return Column(
      children: [
        // Edit Profile
        _buildActionTile(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your name and details',
          onTap: () => _showEditProfileDialog(context, authViewModel),
          isDark: isDark,
        ),

        const SizedBox(height: 12),

        // Change Password (only for email users)
        if (!authViewModel.isGuest && authViewModel.hasPasswordProvider())
          _buildActionTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => _showChangePasswordDialog(context, authViewModel),
            isDark: isDark,
          ),

        const SizedBox(height: 12),

        // Upgrade to Pro (if not pro)
        if (!authViewModel.isPro)
          _buildActionTile(
            icon: Icons.star_outline,
            title: 'Upgrade to Pro',
            subtitle: 'Unlock unlimited poems',
            gradient: AppColors.successGradient,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProUpgradeScreen(),
                ),
              );
            },
            isDark: isDark,
          ),

        const SizedBox(height: 12),

        // Sign Out
        _buildActionTile(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Log out of your account',
          onTap: () => _showSignOutDialog(context, authViewModel),
          isDark: isDark,
        ),

        const SizedBox(height: 12),

        // Delete Account
        _buildActionTile(
          icon: Icons.delete_forever,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          iconColor: AppColors.error,
          textColor: AppColors.error,
          onTap: () => _showDeleteAccountDialog(context, authViewModel),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColor,
    Color? textColor,
    Gradient? gradient,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: gradient == null
              ? Border.all(
            color: (isDark
                ? AppColors.darkSurfaceLight
                : AppColors.lightSurfaceDark)
                .withOpacity(0.5),
          )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gradient != null
                    ? Colors.white.withOpacity(0.2)
                    : (iconColor ?? AppColors.primaryStart).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: gradient != null
                    ? Colors.white
                    : iconColor ?? AppColors.primaryStart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge(
                      color: gradient != null
                          ? Colors.white
                          : textColor ??
                          (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(
                      color: gradient != null
                          ? Colors.white.withOpacity(0.8)
                          : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: gradient != null
                  ? Colors.white
                  : (isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context,
      AuthViewModel authViewModel,
      ) {
    final nameController = TextEditingController(
      text: authViewModel.displayName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Name',
              controller: nameController,
              prefixIcon: const Icon(Icons.person),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final success = await authViewModel.updateDisplayName(name);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context,
      AuthViewModel authViewModel,
      ) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'New Password',
                controller: newPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm Password',
                controller: confirmPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await authViewModel.updatePassword(
                  newPassword: newPasswordController.text,
                  confirmPassword: confirmPasswordController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else if (authViewModel.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authViewModel.error!),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(
      BuildContext context,
      AuthViewModel authViewModel,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await authViewModel.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context,
      AuthViewModel authViewModel,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'This action cannot be undone. All your poems and data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show final confirmation
              final deleteController = TextEditingController();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Are you absolutely sure?'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'This action cannot be undone. Type DELETE to confirm account deletion.',
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Type DELETE',
                            controller: deleteController,
                            onChanged: (value) {
                              setState(() {}); // Rebuild to update button state
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            deleteController.dispose();
                            Navigator.pop(context, false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: deleteController.text.trim() == 'DELETE'
                              ? () {
                                  deleteController.dispose();
                                  Navigator.pop(context, true);
                                }
                              : null, // Disabled when text doesn't match
                          child: Text(
                            'Delete Forever',
                            style: TextStyle(
                              color: deleteController.text.trim() == 'DELETE'
                                  ? AppColors.error
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );

              if (confirmed == true && context.mounted) {
                final success = await authViewModel.deleteAccount();
                if (success && context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}