import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? productToEdit;

  const AddEditProductScreen({super.key, this.productToEdit});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _imageUrlController;

  String _selectedCategory = 'Vegetables';
  final List<String> _categories = ['Vegetables', 'Fruits', 'Grains', 'Pulses', 'Other'];

  // Quick preset farm images for convenient demo experience
  final List<Map<String, String>> _sampleImages = [
    {
      'label': 'Tomatoes',
      'url': 'https://images.unsplash.com/photo-1546470427-0d4db154ceb7?w=600&q=80'
    },
    {
      'label': 'Onions',
      'url': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&q=80'
    },
    {
      'label': 'Potatoes',
      'url': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&q=80'
    },
    {
      'label': 'Chillies',
      'url': 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&q=80'
    },
    {
      'label': 'Fruits',
      'url': 'https://images.unsplash.com/photo-1541344999736-83eca872f242?w=600&q=80'
    },
    {
      'label': 'Grains',
      'url': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&q=80'
    },
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.productToEdit;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _quantityController = TextEditingController(text: edit != null ? edit.quantity.toStringAsFixed(0) : '');
    _priceController = TextEditingController(text: edit != null ? edit.pricePerKg.toStringAsFixed(0) : '');
    _descriptionController = TextEditingController(text: edit?.description ?? '');
    _locationController = TextEditingController(text: edit?.location ?? '');
    _imageUrlController = TextEditingController(
      text: edit?.imageUrl ?? _sampleImages[0]['url']!,
    );

    if (edit != null && _categories.contains(edit.category)) {
      _selectedCategory = edit.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    bool success;
    if (widget.productToEdit != null) {
      success = await productProvider.updateProduct(
        id: widget.productToEdit!.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: quantity,
        pricePerKg: price,
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        location: _locationController.text.trim(),
      );
    } else {
      success = await productProvider.addProduct(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: quantity,
        pricePerKg: price,
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : auth.currentUser?.location,
        farmerId: auth.currentUser?.id ?? 0,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.productToEdit != null
                ? 'Product updated successfully!'
                : 'Product listing submitted successfully!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Failed to save product'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Preview Box
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.cardLightGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorderGreen, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _imageUrlController.text.isNotEmpty
                        ? Image.network(
                            _imageUrlController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.primary),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.primary),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Quick image selection carousel
                const Text(
                  'Select Sample Produce Photo:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sampleImages.length,
                    itemBuilder: (context, idx) {
                      final item = _sampleImages[idx];
                      final isSelected = _imageUrlController.text == item['url'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(item['label']!),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _imageUrlController.text = item['url']!;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Product Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'e.g. Fresh Tomatoes',
                  prefixIcon: Icons.grass_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity (kg) & Expected Price (₹/kg) in two columns
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _quantityController,
                        label: 'Quantity (kg)',
                        hint: 'e.g. 500',
                        prefixIcon: Icons.scale_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter quantity';
                          if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Invalid kg';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: _priceController,
                        label: 'Price (₹/kg)',
                        hint: 'e.g. 18',
                        prefixIcon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter price';
                          if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Invalid price';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Farm Location
                CustomTextField(
                  controller: _locationController,
                  label: 'Farm Location',
                  hint: 'e.g. Warangal, Telangana',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'e.g. Fresh and organically grown. Harvested directly from our farm.',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                // Submit Button
                CustomButton(
                  text: isEditing ? 'Update Listing' : 'Submit Product',
                  isLoading: productProvider.isLoading,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
