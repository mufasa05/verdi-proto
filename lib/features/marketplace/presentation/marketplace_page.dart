import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/mock_app_data.dart';
import '../../../state/cart_state.dart';
import '../../../state/app_state.dart';
import '../../../state/chat_state.dart';
import '../../../widgets/cart_drawer.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage>
    with SingleTickerProviderStateMixin {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Grains',
    'Vegetables',
    'Fruits',
    'Equipment',
    'Livestock',
    'Processed product',
    'Others',
  ];

  String _selectedLocation = 'All';
  String _selectedType = 'All';
  String _selectedPriceRange = 'All';
  late List<MarketplaceProduct> _allProducts;

  @override
  void initState() {
    super.initState();
    _allProducts = List.from(MockAppData.products);
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MarketplaceProduct> get _filteredProducts {
    final search = _searchController.text.trim().toLowerCase();
    final tab = _categories[_tabController.index];

    return _allProducts.where((p) {
      final matchesSearch = search.isEmpty ||
          p.name.toLowerCase().contains(search) ||
          p.description.toLowerCase().contains(search) ||
          p.seller.toLowerCase().contains(search) ||
          p.location.toLowerCase().contains(search);

      final matchesTab = tab == 'All' || p.category == tab;
      final matchesLocation =
          _selectedLocation == 'All' || p.location == _selectedLocation;
      final matchesType = _selectedType == 'All' || p.category == _selectedType;

      final priceValue =
          double.tryParse(p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

      final matchesPrice = switch (_selectedPriceRange) {
        'Under \$0.50' => priceValue < 0.50,
        '\$0.50 - \$1.00' => priceValue >= 0.50 && priceValue <= 1.00,
        'Above \$1.00' => priceValue > 1.00,
        _ => true,
      };

      return matchesSearch &&
          matchesTab &&
          matchesLocation &&
          matchesType &&
          matchesPrice;
    }).toList();
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = _categories[1]; // default Grains

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('List New Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Product Name', hintText: 'e.g. Soybeans'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .where((c) => c != 'All')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedCategory = v);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price', hintText: 'e.g. 0.35/kg'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity Available', hintText: 'e.g. 200 kg available'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price = priceController.text.trim();
                    final qty = quantityController.text.trim();
                    final desc = descController.text.trim();

                    if (name.isEmpty || price.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill Name and Price fields.')),
                      );
                      return;
                    }

                    final newProduct = MarketplaceProduct(
                      name: name,
                      category: selectedCategory,
                      description: desc.isEmpty ? 'High-quality agricultural product listed on Verdi.' : desc,
                      price: price.startsWith('\$') ? price : '\$$price',
                      seller: 'Mufasa Farm',
                      location: 'Chiredzi',
                      quantity: qty.isEmpty ? '100 kg available' : qty,
                      distance: '0.0 km',
                      imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80',
                    );

                    setState(() {
                      _allProducts.insert(0, newProduct);
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name listed successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Submit Listing'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _gridCount(double width) {
    if (width >= 1100) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  void _openCart() {
    Scaffold.of(context).openEndDrawer();
  }

  void _showProductDetails(BuildContext context, MarketplaceProduct product, VoidCallback onAddToCart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: product.imageUrl.startsWith('assets/')
                      ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                      : CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    product.distance,
                    style: const TextStyle(color: muted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.price,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: green,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black12),
              const SizedBox(height: 12),
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: dark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.description,
                style: GoogleFonts.inter(fontSize: 14, color: muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black12),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 20, color: muted),
                  const SizedBox(width: 8),
                  Text(
                    'Seller: ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: dark),
                  ),
                  Text(product.seller, style: const TextStyle(color: muted)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 20, color: muted),
                  const SizedBox(width: 8),
                  Text(
                    'Location: ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: dark),
                  ),
                  Text('${product.location} • ${product.quantity}', style: const TextStyle(color: muted)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(chatProvider.notifier).startOrGetThread(
                          product.seller,
                          'Inquiries about ${product.name}',
                          'Hello! I saw your listing for ${product.name} on the marketplace. Is it still available?',
                        );
                    ref.read(appStateProvider.notifier).setNavIndex(2); // Go to Chats
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat with Seller'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: green),
                        foregroundColor: green,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onAddToCart();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).itemCount;
    final products = _filteredProducts;

    return Scaffold(
      endDrawer: const CartDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth > 1100;
            final crossAxisCount = _gridCount(constraints.maxWidth);
            final isMobile = constraints.maxWidth < 700;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Marketplace',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: isMobile ? 22 : 26,
                                  fontWeight: FontWeight.w800,
                                  color: dark,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _showAddProductDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('List Product'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: green,
                                side: const BorderSide(color: green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Badge(
                              label: Text('$cartCount'),
                              isLabelVisible: cartCount > 0,
                              backgroundColor: green,
                              child: IconButton(
                                onPressed: _openCart,
                                icon: const Icon(Icons.shopping_cart_outlined),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.black12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover produce, connect with buyers, and move faster.',
                          style: GoogleFonts.inter(color: muted),
                        ),
                        const SizedBox(height: 16),
                        _SearchBar(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        _FilterRow(
                          selectedLocation: _selectedLocation,
                          selectedType: _selectedType,
                          selectedPriceRange: _selectedPriceRange,
                          onLocationChanged: (v) =>
                              setState(() => _selectedLocation = v),
                          onTypeChanged: (v) =>
                              setState(() => _selectedType = v),
                          onPriceRangeChanged: (v) =>
                              setState(() => _selectedPriceRange = v),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: green,
                            unselectedLabelColor: muted,
                            indicatorColor: green,
                            tabs: _categories.map((e) => Tab(text: e)).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: isMobile ? 385 : 350,
                          ),
                          itemBuilder: (context, index) {
                            return _ProductCard(
                              product: products[index],
                              onAddToCart: () {
                                ref.read(cartProvider.notifier).addItem(
                                      CartItem(
                                        id:
                                            '${products[index].name}-${products[index].seller}',
                                        name: products[index].name,
                                        price: products[index].price,
                                        quantity: 1,
                                        imageUrl: products[index].imageUrl,
                                      ),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${products[index].name} added to cart',
                                    ),
                                  ),
                                );
                              },
                              onViewDetails: () {
                                _showProductDetails(context, products[index], () {
                                  ref.read(cartProvider.notifier).addItem(
                                        CartItem(
                                          id:
                                              '${products[index].name}-${products[index].seller}',
                                          name: products[index].name,
                                          price: products[index].price,
                                          quantity: 1,
                                          imageUrl: products[index].imageUrl,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${products[index].name} added to cart',
                                      ),
                                    ),
                                  );
                                });
                              },
                              onChatWithOwner: () {
                                ref.read(chatProvider.notifier).startOrGetThread(
                                      products[index].seller,
                                      'Inquiries about ${products[index].name}',
                                      'Hello! I saw your listing for ${products[index].name} on the marketplace. Is it still available?',
                                    );
                                ref.read(appStateProvider.notifier).setNavIndex(2);
                              },
                              isMobile: isMobile,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: green),
                              foregroundColor: green,
                            ),
                            child: const Text('Load More'),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                if (desktop)
                  SizedBox(
                    width: 360,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: _DesktopPanel(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search products, sellers, or locations',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String selectedLocation;
  final String selectedType;
  final String selectedPriceRange;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onPriceRangeChanged;

  const _FilterRow({
    required this.selectedLocation,
    required this.selectedType,
    required this.selectedPriceRange,
    required this.onLocationChanged,
    required this.onTypeChanged,
    required this.onPriceRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _dropdownChip(
          'Location',
          selectedLocation,
          onLocationChanged,
          const ['All', 'Chiredzi', 'Masvingo', 'Mutare', 'Harare', 'Bulawayo', 'Gwanda'],
        ),
        _dropdownChip(
          'Category',
          selectedType,
          onTypeChanged,
          const [
            'All',
            'Grains',
            'Vegetables',
            'Fruits',
            'Equipment',
            'Livestock',
            'Processed product',
            'Others',
          ],
        ),
        _dropdownChip('Type', 'All', (_) {}, const ['All']),
        _dropdownChip(
          'Price Range',
          selectedPriceRange,
          onPriceRangeChanged,
          const ['All', 'Under \$0.50', '\$0.50 - \$1.00', 'Above \$1.00'],
        ),
      ],
    );
  }

  Widget _dropdownChip(
    String label,
    String current,
    ValueChanged<String> onChanged,
    List<String> values,
  ) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) =>
          values.map((v) => PopupMenuItem(value: v, child: Text(v))).toList(),
      child: Chip(
        label: Text('$label: $current'),
        avatar: const Icon(Icons.filter_alt_outlined, size: 18),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  final VoidCallback onAddToCart;
  final VoidCallback onViewDetails;
  final VoidCallback onChatWithOwner;
  final bool isMobile;

  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    required this.onViewDetails,
    required this.onChatWithOwner,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isMobile ? 122 : 140,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product.imageUrl.startsWith('assets/')
                        ? Image.asset(
                            product.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        product.distance,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _MarketplacePageState.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: _MarketplacePageState.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.price,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _MarketplacePageState.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.seller} • ${product.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.quantity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    const Spacer(),
                    if (isMobile)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onAddToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _MarketplacePageState.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Add',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: onChatWithOwner,
                            icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.blue),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          OutlinedButton(
                            onPressed: onViewDetails,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _MarketplacePageState.green,
                              side: const BorderSide(color: _MarketplacePageState.green),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.info_outline, size: 16),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onAddToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _MarketplacePageState.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Add to Cart'),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: onChatWithOwner,
                            icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.blue),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            onPressed: onViewDetails,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _MarketplacePageState.green,
                              side: const BorderSide(color: _MarketplacePageState.green),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Details'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidePanelCard(
            title: 'Recommended for You',
            child: Column(
              children: MockAppData.products.take(3).map((p) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: p.imageUrl.startsWith('assets/')
                        ? Image.asset(
                            p.imageUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: p.imageUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                  ),
                  title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(p.location, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SidePanelCard(
            title: 'Market Demand',
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const labels = ['G', 'V', 'F', 'E', 'L'];
                          if (value.toInt() < 0 || value.toInt() >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 84),
                        FlSpot(1, 79),
                        FlSpot(2, 72),
                        FlSpot(3, 61),
                        FlSpot(4, 53),
                      ],
                      isCurved: true,
                      barWidth: 3,
                      color: _MarketplacePageState.green,
                      belowBarData: BarAreaData(
                        show: true,
                        color: _MarketplacePageState.green.withValues(alpha: 0.12),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SidePanelCard(
            title: 'Demand Stats',
            child: Column(
              children: const [
                _DemandStat(label: 'Grains', value: '84%', buyers: '1.2k buyers'),
                _DemandStat(label: 'Vegetables', value: '79%', buyers: '980 buyers'),
                _DemandStat(label: 'Fruits', value: '72%', buyers: '740 buyers'),
                _DemandStat(label: 'Equipment', value: '61%', buyers: '520 buyers'),
                _DemandStat(label: 'Livestock', value: '53%', buyers: '410 buyers'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemandStat extends StatelessWidget {
  final String label;
  final String value;
  final String buyers;

  const _DemandStat({
    required this.label,
    required this.value,
    required this.buyers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Text(buyers, style: const TextStyle(fontSize: 12, color: _MarketplacePageState.muted)),
        ],
      ),
    );
  }
}

class _SidePanelCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SidePanelCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _MarketplacePageState.dark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}