import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../role_selection/role_selection_screen.dart';
import '../orders/orders_screen.dart';
import 'edit_profile_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    await auth.refreshProfile();
    await orderProvider.fetchOrders();
    if (auth.currentUser != null && auth.isFarmer) {
      await productProvider.fetchFarmerProducts(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isFarmer = auth.isFarmer;

    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final totalListings = productProvider.farmerProducts.length;
    final activeListings = productProvider.farmerProducts.where((p) => p.isActive).length;
    final completedOrders = orderProvider.orders.where((o) => o.isDelivered).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isFarmer ? 'Farmer Profile' : 'Buyer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Log Out',
            onPressed: () => _confirmLogout(context, auth),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Profile Card (Image, Name, Role badge, Location, Email)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardLightGreen,
                          border: Border.all(color: AppColors.primary, width: 2.5),
                          image: user?.profileImage != null && user!.profileImage!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                            ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cardLightGreen,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorderGreen),
                    ),
                    child: Text(
                      isFarmer ? 'Verified Farmer' : 'Verified Buyer',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        user?.location ?? 'Location not specified',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email_outlined, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          user.phone!,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    isFarmer ? '$totalListings' : '${orderProvider.orders.length}',
                    isFarmer ? 'Total Products' : 'Total Orders',
                    Icons.inventory_2_outlined,
                  ),
                  Container(height: 36, width: 1, color: AppColors.divider),
                  _buildStatItem(
                    isFarmer ? '$activeListings' : '${orderProvider.orders.where((o) => o.isPending).length}',
                    isFarmer ? 'Active Listings' : 'Pending',
                    Icons.trending_up,
                  ),
                  Container(height: 36, width: 1, color: AppColors.divider),
                  _buildStatItem(
                    '$completedOrders',
                    'Completed',
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Menu Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    subtitle: 'Manage personal and farm details',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.divider),
                  _buildMenuTile(
                    icon: isFarmer ? Icons.receipt_long_outlined : Icons.shopping_bag_outlined,
                    title: isFarmer ? 'Incoming Orders' : 'My Orders',
                    subtitle: isFarmer ? 'Manage orders from buyers' : 'Track your purchases and receipts',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.divider),
                  _buildMenuTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Support & Helpdesk',
                    subtitle: 'AgriConnect helpline 1800-FARM-DIRECT',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SupportScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.divider),
                  _buildMenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences, server IP, notifications',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.divider),
                  _buildMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    subtitle: 'Sign out of this device',
                    textColor: AppColors.error,
                    iconColor: AppColors.error,
                    onTap: () => _confirmLogout(context, auth),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatItem(String count, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textLight),
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of AgriConnect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
