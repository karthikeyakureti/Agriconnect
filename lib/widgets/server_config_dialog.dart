import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/colors.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';

void showServerConfigDialog(BuildContext context, {VoidCallback? onSaved}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ServerConfigBottomSheet(onSaved: onSaved),
  );
}

class _ServerConfigBottomSheet extends StatefulWidget {
  final VoidCallback? onSaved;
  const _ServerConfigBottomSheet({this.onSaved});

  @override
  State<_ServerConfigBottomSheet> createState() => _ServerConfigBottomSheetState();
}

class _ServerConfigBottomSheetState extends State<_ServerConfigBottomSheet> {
  late TextEditingController _urlController;
  bool _isTesting = false;
  bool? _testSuccess;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConstants.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testSuccess = null;
      _testMessage = null;
    });

    final success = await ApiClient.testConnection(url);

    if (!mounted) return;

    setState(() {
      _isTesting = false;
      _testSuccess = success;
      _testMessage = success
          ? 'Connected! AgriConnect backend is online.'
          : 'Could not reach server. Verify backend is running on port 8000 and phone is on same Wi-Fi.';
    });
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    await StorageService.setServerUrl(url);

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Server updated to: $url'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onSaved?.call();
  }

  Future<void> _resetToDefault() async {
    await StorageService.resetServerUrl();
    if (!mounted) return;
    setState(() {
      _urlController.text = ApiConstants.defaultBaseUrl;
      _testSuccess = null;
      _testMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardLightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dns_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backend Server Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Configure API endpoint for phone testing',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Help info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorderGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For real phones, connect to the same Wi-Fi and use PC Wi-Fi IP (http://${ApiConstants.defaultLocalIp}:8000). For desktop/web, use http://127.0.0.1:8000.',
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Input field
            const Text(
              'Server URL',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'http://${ApiConstants.defaultLocalIp}:8000',
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: const Icon(Icons.link, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _urlController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick presets
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildPresetChip(
                  label: 'Mobile Data (4G/5G) / Live Cloud',
                  url: ApiConstants.publicApiUrl,
                ),
                _buildPresetChip(
                  label: 'PC Wi-Fi (${ApiConstants.defaultLocalIp})',
                  url: 'http://${ApiConstants.defaultLocalIp}:${ApiConstants.defaultPort}',
                ),
                _buildPresetChip(
                  label: 'Localhost (127.0.0.1)',
                  url: 'http://127.0.0.1:${ApiConstants.defaultPort}',
                ),
                _buildPresetChip(
                  label: 'Emulator (10.0.2.2)',
                  url: 'http://10.0.2.2:${ApiConstants.defaultPort}',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Test connection result
            if (_testMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testSuccess == true
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _testSuccess == true ? AppColors.success : AppColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess == true ? Icons.check_circle : Icons.error_outline,
                      color: _testSuccess == true ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testSuccess == true ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            Row(
              children: [
                // Test Connection Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check_rounded, color: AppColors.primary, size: 20),
                    label: Text(
                      _isTesting ? 'Testing...' : 'Test Connection',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save & Connect',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reset to default
            Center(
              child: TextButton(
                onPressed: _resetToDefault,
                child: const Text(
                  'Reset to System Default',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip({required String label, required String url}) {
    final isSelected = _urlController.text == url;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: TextStyle(
        fontSize: 11,
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.shade100,
      onSelected: (_) {
        setState(() {
          _urlController.text = url;
          _testSuccess = null;
          _testMessage = null;
        });
      },
    );
  }
}
