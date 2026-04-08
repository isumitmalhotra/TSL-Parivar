import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../models/product_models.dart';

/// Product Catalog Screen - Shows all TSL products in a beautiful grid
class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ProductCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<TslProduct> get _filteredProducts {
    if (_selectedCategory == null) return TslProductCatalog.allProducts;
    return TslProductCatalog.getByCategory(_selectedCategory!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _filteredProducts[index];
                  return _buildProductCard(product, index);
                },
                childCount: _filteredProducts.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF1B5E20),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: Text(
                  'Build with the best. Build with TSL.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Our Products',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _buildFilterChip('All', null),
          ...ProductCategory.values.map(
            (category) => _buildFilterChip(category.displayName, category),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ProductCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildProductCard(TslProduct product, int index) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.6),
          ((index * 0.1) + 0.4).clamp(0.4, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => context.push('/products/${product.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: product.category.color.withValues(alpha: 0.08),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          product.imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                product.category.icon,
                                size: 48,
                                color: product.category.color
                                    .withValues(alpha: 0.3),
                              ),
                            );
                          },
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.category.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            product.category.icon,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Product info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.tagline,
                        style: AppTypography.caption.copyWith(
                          color: product.category.color,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View Details',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}

