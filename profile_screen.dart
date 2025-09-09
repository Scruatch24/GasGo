// lib/screens/driver/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = AuthService();
    final user = authService.currentUser;
    final provider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with user info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E88E5),
                      Color(0xFF1976D2),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Profile picture
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Icon(
                          Icons.person,
                          size: 48,
                          color: Color(0xFF1E88E5),
                        )
                            : null,
                      ),
                    ),

                    SizedBox(height: 16),

                    // User name
                    Text(
                      user?.displayName ?? user?.email?.split('@')[0] ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 4),

                    // User email
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: 8),

                    // User type badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.driver ?? 'Driver',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Menu items
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Language settings
                    _buildMenuItem(
                      icon: Icons.language,
                      title: l10n.language ?? 'Language',
                      subtitle: L10n.getLanguageName(provider.locale.languageCode),
                      onTap: () => _showLanguageDialog(context, provider),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),

                    // My reviews
                    _buildMenuItem(
                      icon: Icons.rate_review,
                      title: l10n.myReviews ?? 'My Reviews',
                      subtitle: l10n.viewYourReviews ?? 'View and manage your reviews',
                      onTap: () {
                        // TODO: Navigate to reviews screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Coming in Phase 2')),
                        );
                      },
                    ),

                    // Notifications
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: l10n.notifications ?? 'Notifications',
                      subtitle: l10n.manageNotifications ?? 'Manage price alerts and updates',
                      onTap: () {
                        // TODO: Navigate to notifications settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Coming in Phase 2')),
                        );
                      },
                    ),

                    // Help & Support
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: l10n.helpSupport ?? 'Help & Support',
                      subtitle: l10n.getHelp ?? 'Get help and contact support',
                      onTap: () {
                        _showHelpDialog(context, l10n);
                      },
                    ),

                    // About
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: l10n.about ?? 'About',
                      subtitle: l10n.appInfo ?? 'App version and information',
                      onTap: () {
                        _showAboutDialog(context, l10n);
                      },
                    ),

                    SizedBox(height: 24),

                    // Statistics cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.favorite,
                            value: '0', // TODO: Get from database
                            label: l10n.favoriteStations ?? 'Favorite Stations',
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.rate_review,
                            value: '0', // TODO: Get from database
                            label: l10n.reviewsGiven ?? 'Reviews Given',
                            color: Color(0xFFFF7043),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Sign out button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _signOut(context, authService),
                        icon: Icon(Icons.logout, color: Colors.red),
                        label: Text(
                          l10n.signOut ?? 'Sign Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF1E88E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Color(0xFF1E88E5),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9E9E9E)),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: L10n.all.map((locale) {
              return RadioListTile<Locale>(
                title: Text(L10n.getLanguageName(locale.languageCode)),
                value: locale,
                groupValue: provider.locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    provider.setLocale(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.helpSupport ?? 'Help & Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.helpText ?? 'Need help? Contact us:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('📧 support@lpgfinder.ge'),
              SizedBox(height: 8),
              Text('📞 +995 XXX XXX XXX'),
              SizedBox(height: 16),
              Text(
                l10n.commonIssues ?? 'For common issues, check our FAQ section.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: 'LPG Finder GE',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.local_gas_station,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        Text(
          l10n.aboutText ??
              'Find the best LPG prices in Georgia. Compare prices, read reviews, and discover new stations near you.',
        ),
      ],
    );
  }

  void _signOut(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authService.signOut();
              },
              child: Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}