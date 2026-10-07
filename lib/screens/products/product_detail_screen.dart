import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/api_constants.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import '../chat/chat_screen.dart';
import '../orders/orders_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '${ApiConstants.baseUrl}$url';
  }

  Future<void> _handlePlaceOrder(double selectedQty) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.placeOrder(
      productId: widget.product.id,
      quantity: selectedQty,
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Text('Order Confirmed!'),
            ],
          ),
          content: Text(
            'Your order for ${selectedQty.toStringAsFixed(0)} kg of ${widget.product.name} has been placed directly with ${widget.product.farmer?.name ?? "the farmer"}.\n\nOrder ID has been generated.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
              child: const Text('View My Orders'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'Failed to place order'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openPlaceOrderModal() {
    final maxQty = widget.product.quantity;
    if (maxQty <= 0) return;

    double selectedQty = maxQty >= 10.0 ? 10.0 : maxQty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final totalPrice = selectedQty * widget.product.pricePerKg;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Place Direct Order',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),

                  // Product snippet
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _resolveImageUrl(widget.product.imageUrl),
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${widget.product.pricePerKg.toStringAsFixed(0)}/kg • Max ${widget.product.quantity.toStringAsFixed(0)} kg',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  const Text(
                    'Select Quantity (kg)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: selectedQty > 1
                            ? () {
                                setModalState(() {
                                  final step = selectedQty > 10 ? 5.0 : 1.0;
                                  selectedQty = (selectedQty - step).clamp(1.0, maxQty);
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline, size: 30, color: AppColors.primary),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardLightGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorderGreen),
                          ),
                          child: Center(
                            child: Text(
                              '${selectedQty.toStringAsFixed(0)} kg',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedQty < maxQty
                            ? () {
                                setModalState(() {
                                  final step = (maxQty - selectedQty >= 5.0 && selectedQty >= 5.0) ? 5.0 : 1.0;
                                  selectedQty = (selectedQty + step).clamp(1.0, maxQty);
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline, size: 30, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Quantity Badges
                  Wrap(
                    spacing: 8,
                    children: [10.0, 25.0, 50.0, 100.0].where((q) => q <= maxQty).map((q) {
                      return ActionChip(
                        label: Text('${q.toStringAsFixed(0)} kg'),
                        onPressed: () => setModalState(() => selectedQty = q),
                        backgroundColor: selectedQty == q ? AppColors.primary : Colors.white,
                        labelStyle: TextStyle(
                          color: selectedQty == q ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Price Summary Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedQty.toStringAsFixed(0)} kg × ₹${widget.product.pricePerKg.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            Text(
                              '₹${totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: AppColors.divider),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount Payable',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '₹${totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirm Order Button
                  CustomButton(
                    text: 'Confirm & Place Order',
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handlePlaceOrder(selectedQty);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isFarmerOwner = auth.isFarmer && auth.currentUser?.id == widget.product.farmerId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Large Hero Product Image in SliverAppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _resolveImageUrl(widget.product.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cardLightGreen,
                      child: const Center(
                        child: Icon(Icons.eco, size: 80, color: AppColors.primary),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardLightGreen,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorderGreen),
                        ),
                        child: Text(
                          widget.product.category,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      StatusBadge(status: widget.product.status),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Title
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price & Quantity Highlights
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price per kg',
                              style: TextStyle(fontSize: 12, color: AppColors.textLight),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${widget.product.pricePerKg.toStringAsFixed(0)}/kg',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 36, width: 1, color: AppColors.divider),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Available Stock',
                              style: TextStyle(fontSize: 12, color: AppColors.textLight),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.product.quantity.toStringAsFixed(0)} kg',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Farmer Information Card
                  const Text(
                    'FARMER INFORMATION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cardLightGreen,
                            border: Border.all(color: AppColors.primaryLight, width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.person, color: AppColors.primary, size: 30),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.farmer?.name ?? 'Ramesh Kumar',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.product.location ?? 'Warangal, Telangana',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cardLightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star, size: 14, color: AppColors.accentGold),
                              SizedBox(width: 3),
                              Text('4.9', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Section
                  const Text(
                    'PRODUCT DESCRIPTION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      widget.product.description ??
                          'Fresh agricultural produce directly from the farm. Naturally grown with safe farming practices.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Contact Farmer Button
              Expanded(
                child: CustomButton(
                  text: 'Contact Farmer',
                  isOutlined: true,
                  icon: Icons.chat_bubble_outline,
                  onPressed: () {
                    final targetId = widget.product.farmerId;
                    final targetName = widget.product.farmer?.name ?? 'Farmer';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          recipientId: targetId,
                          recipientName: targetName,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isFarmerOwner) ...[
                const SizedBox(width: 12),
                // Place Order Button
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Place Order',
                    icon: Icons.shopping_bag_outlined,
                    onPressed: widget.product.isActive ? _openPlaceOrderModal : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
