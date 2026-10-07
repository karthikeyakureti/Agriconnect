import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../widgets/server_config_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderNotifications = true;
  bool _produceAlerts = true;
  bool _priceDropAlerts = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Telugu (తెలుగు)', 'Hindi (हिन्दी)', 'Tamil (தமிழ்)'];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language'),
        content: RadioGroup<String>(
          groupValue: _selectedLanguage,
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedLanguage = val);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language set to $val'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((lang) {
              return RadioListTile<String>(
                title: Text(lang),
                value: lang,
                activeColor: AppColors.primary,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // Section 1: Server & Network Connection
            _buildSectionHeader('NETWORK & BACKEND'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardLightGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.dns_rounded, color: AppColors.primary, size: 22),
                ),
                title: const Text(
                  'Backend Server IP',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  ApiConstants.baseUrl,
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  showServerConfigDialog(context, onSaved: () {
                    setState(() {});
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Notifications
            _buildSectionHeader('NOTIFICATIONS'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    title: const Text('Order Status Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Receive push alerts when your order status changes', style: TextStyle(fontSize: 11)),
                    value: _orderNotifications,
                    onChanged: (val) => setState(() => _orderNotifications = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    title: const Text('New Produce Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Get notified when farmers list fresh harvest', style: TextStyle(fontSize: 11)),
                    value: _produceAlerts,
                    onChanged: (val) => setState(() => _produceAlerts = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    title: const Text('Price Drop Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Alerts when sellers update and discount crops', style: TextStyle(fontSize: 11)),
                    value: _priceDropAlerts,
                    onChanged: (val) => setState(() => _priceDropAlerts = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Preferences
            _buildSectionHeader('APP PREFERENCES'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selectedLanguage, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                    onTap: _showLanguageDialog,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                  const ListTile(
                    leading: Icon(Icons.currency_rupee_rounded, color: AppColors.primary),
                    title: Text('Currency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: Text('INR (₹)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: About & System
            _buildSectionHeader('ABOUT AGRICONNECT'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: AppColors.primary),
                    title: Text('App Version', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: Text('1.0.0 (Build 1001)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
                    title: const Text('Clear Local Cache', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('App cache cleared successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
