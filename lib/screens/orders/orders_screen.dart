import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../chat/chat_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Pending', 'Confirmed', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final selectedTab = _tabs[_tabController.index];
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.setStatusFilter(selectedTab);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final isFarmer = auth.isFarmer;

    final filteredList = orderProvider.filteredOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isFarmer ? 'Incoming Orders' : 'My Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await orderProvider.fetchOrders();
        },
        color: AppColors.primary,
        child: orderProvider.isLoading && orderProvider.orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : filteredList.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No ${orderProvider.selectedStatus.toLowerCase()} orders',
                    description: isFarmer
                        ? 'Incoming customer orders will appear here as soon as buyers purchase your produce.'
                        : 'You haven\'t placed any orders matching this filter yet.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final order = filteredList[index];
                      return OrderCard(
                        order: order,
                        isFarmer: isFarmer,
                        onStatusChanged: (newStatus) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await orderProvider.updateOrderStatus(order.id, newStatus);
                          if (success) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Order status updated to $newStatus'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        onContactUser: () {
                          final partner = isFarmer ? order.buyer : order.farmer;
                          if (partner != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  recipientId: partner.id,
                                  recipientName: partner.name,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
