import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/colors.dart';
import '../core/constants/api_constants.dart';
import '../models/order_model.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isFarmer;
  final Function(String newStatus)? onStatusChanged;
  final VoidCallback? onContactUser;

  const OrderCard({
    super.key,
    required this.order,
    required this.isFarmer,
    this.onStatusChanged,
    this.onContactUser,
  });

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&q=80';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '${ApiConstants.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final formattedDate = order.createdAt != null
        ? dateFormat.format(order.createdAt!)
        : 'Recent';

    final counterpartName = isFarmer
        ? (order.buyer?.name ?? 'Buyer')
        : (order.farmer?.name ?? 'Farmer');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: AppColors.primaryDark.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order ID & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.cardLightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const Divider(height: 20, color: AppColors.divider),

            // Middle: Product Image, Details & Quantity
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _resolveImageUrl(order.product?.imageUrl),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.cardLightGreen,
                      child: const Icon(Icons.agriculture, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.product?.name ?? 'Farm Produce',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.quantity.toStringAsFixed(0)} kg | ₹${order.product?.pricePerKg.toStringAsFixed(0) ?? '-'}/kg',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isFarmer ? "Buyer" : "Farmer"}: $counterpartName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${order.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Timestamp & Contact Shortcut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                if (onContactUser != null)
                  InkWell(
                    onTap: onContactUser,
                    child: const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Message',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Actions row (Confirm, Deliver, Cancel)
            if (isFarmer && order.isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onStatusChanged?.call('CANCELLED'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => onStatusChanged?.call('CONFIRMED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Confirm Order', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else if (isFarmer && order.isConfirmed) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onStatusChanged?.call('DELIVERED'),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Mark as Delivered', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ] else if (!isFarmer && order.isPending) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onStatusChanged?.call('CANCELLED'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel Order', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
