import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../products/product_detail_screen.dart';
import '../orders/orders_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  final bool isFarmerBrowsing;

  const BuyerMarketplaceScreen({super.key, this.isFarmerBrowsing = false});

  @override
  State<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Vegetables', 'Fruits', 'Grains', 'Pulses', 'Other'];

  // Filter state
  double? _minPrice;
  double? _maxPrice;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchMarketplaceProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterDialog() {
    final minCtrl = TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    final maxCtrl = TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');
    final locCtrl = TextEditingController(text: _selectedLocation ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                    'Filter Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),

              const Text('Price Range (₹/kg)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Min ₹', prefixText: '₹'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Max ₹', prefixText: '₹'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Warangal, Nashik',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                          _selectedLocation = null;
                        });
                        Navigator.pop(ctx);
                        Provider.of<ProductProvider>(context, listen: false)
                            .fetchMarketplaceProducts();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = double.tryParse(minCtrl.text);
                          _maxPrice = double.tryParse(maxCtrl.text);
                          _selectedLocation = locCtrl.text.isNotEmpty ? locCtrl.text : null;
                        });
                        Navigator.pop(ctx);
                        Provider.of<ProductProvider>(context, listen: false).fetchMarketplaceProducts(
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                          location: _selectedLocation,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFarmerBrowsing) {
      return _buildMarketplaceContent();
    }

    final pages = [
      _buildMarketplaceContent(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceContent() {
    final productProvider = Provider.of<ProductProvider>(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await productProvider.fetchMarketplaceProducts(
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            location: _selectedLocation,
          );
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Top App Bar with Branding and Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.eco_rounded, color: AppColors.primary, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'AgriConnect',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cardLightGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorderGreen),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Direct from Farm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Available Products',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Fresh harvest directly from verified local farmers.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar & Filter Button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => productProvider.setSearchQuery(val),
                            decoration: InputDecoration(
                              hintText: 'Search tomatoes, onions, grains...',
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        productProvider.setSearchQuery('');
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: (_minPrice != null || _maxPrice != null || _selectedLocation != null)
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (_minPrice != null || _maxPrice != null || _selectedLocation != null)
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              color: (_minPrice != null || _maxPrice != null || _selectedLocation != null)
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                            onPressed: _openFilterDialog,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Horizontal Categories Scroll
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, idx) {
                          final cat = _categories[idx];
                          return CategoryChip(
                            label: cat,
                            isSelected: productProvider.selectedCategory == cat,
                            onTap: () => productProvider.setCategory(cat),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Products Grid
            if (productProvider.isLoading && productProvider.products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (productProvider.products.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: 'No produce found',
                  description: 'Try adjusting your search query, category, or price filters.',
                  buttonText: 'Reset Filters',
                  onButtonPressed: () {
                    _searchController.clear();
                    setState(() {
                      _minPrice = null;
                      _maxPrice = null;
                      _selectedLocation = null;
                    });
                    productProvider.setCategory('All');
                    productProvider.setSearchQuery('');
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productProvider.products[index];
                      return ProductCard(
                        product: product,
                        isFarmerOwner: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        onContact: () {
                          if (product.farmer != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  recipientId: product.farmer!.id,
                                  recipientName: product.farmer!.name,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                    childCount: productProvider.products.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
