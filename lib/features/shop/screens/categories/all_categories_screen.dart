import 'package:caferesto/common/widgets/appbar/appbar.dart';
import 'package:caferesto/common/widgets/categories/category_card.dart';
import 'package:caferesto/common/widgets/layouts/grid_layout.dart';
import 'package:caferesto/common/widgets/shimmer/category_shimmer.dart';
import 'package:caferesto/features/shop/controllers/category_controller.dart';
import 'package:caferesto/features/shop/models/category_model.dart';
import 'package:caferesto/features/shop/screens/sub_category/sub_categories.dart';
import 'package:caferesto/utils/constants/colors.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/device/device_utility.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final categoryController = CategoryController.instance;

  @override
  void initState() {
    super.initState();
    // S'assurer que les catégories sont chargées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categoryController.allCategories.isEmpty && !categoryController.isLoading.value) {
        categoryController.fetchCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        title: const Text('Toutes les catégories'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilters(context, categoryController, dark),

          // Liste des catégories
          Expanded(
            child: Obx(() {
              if (categoryController.isLoading.value) {
                return const TCategoryShimmer();
              }

              final filteredCategories = _getFilteredCategories(categoryController);

              if (filteredCategories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        categoryController.searchQuery.value.isNotEmpty
                            ? 'Aucune catégorie trouvée'
                            : 'Aucune catégorie disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final screenWidth = MediaQuery.of(context).size.width;

              return RefreshIndicator(
                onRefresh: () => categoryController.refreshCategories(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.defaultSpace),
                  child: GridLayout(
                    itemCount: filteredCategories.length,
                    crossAxisCount: TDeviceUtils.getCrossAxisCount(screenWidth),
                    mainAxisExtent: 80,
                    itemBuilder: (_, index) {
                      final category = filteredCategories[index];
                      return CategoryCard(
                        showBorder: true,
                        category: category,
                        onTap: () => Get.to(
                          () => SubCategoriesScreen(category: category),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    CategoryController controller,
    bool dark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkContainer : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) => controller.updateSearch(value),
            decoration: InputDecoration(
              hintText: 'Rechercher une catégorie...',
              prefixIcon: const Icon(Iconsax.search_normal),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.updateSearch(''),
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                borderSide: BorderSide(
                  color: dark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                borderSide: BorderSide(
                  color: dark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: dark ? AppColors.dark : Colors.grey.shade100,
            ),
          ),

          const SizedBox(height: AppSizes.spaceBtwItems),

          // Filtres
          Row(
            children: [
              Icon(
                Iconsax.filter,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Filtres:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),

              // Bouton Toutes
              Obx(() {
                final isAllSelected =
                    controller.selectedFilter.value == CategoryFilter.all;
                return _buildFilterButton(
                  context,
                  'Toutes',
                  isAllSelected,
                  dark,
                  onTap: () => controller.updateFilter(CategoryFilter.all),
                );
              }),

              const SizedBox(width: AppSizes.xs),

              // Bouton Populaires
              Obx(() {
                final isFeaturedSelected =
                    controller.selectedFilter.value == CategoryFilter.featured;
                return _buildFilterButton(
                  context,
                  'Populaires',
                  isFeaturedSelected,
                  dark,
                  icon: Icons.star,
                  onTap: () =>
                      controller.updateFilter(CategoryFilter.featured),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    bool isSelected,
    bool dark, {
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (dark ? AppColors.darkContainer : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (dark ? Colors.grey.shade700 : Colors.grey.shade400),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (dark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (dark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryModel> _getFilteredCategories(CategoryController controller) {
    // Obtenir toutes les catégories (principales et sous-catégories)
    final all = controller.allCategories;
    
    // Appliquer le filtre "featured" si nécessaire
    final filtered = controller.selectedFilter.value == CategoryFilter.featured
        ? all.where((c) => c.isFeatured).toList()
        : all;

    // Appliquer la recherche
    if (controller.searchQuery.value.isEmpty) {
      return filtered;
    }

    final query = controller.searchQuery.value.toLowerCase();
    return filtered
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }
}

