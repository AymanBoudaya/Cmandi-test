import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../../common/widgets/products/product_cards/product_card_vertical.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/search_controller.dart';

import '../../../models/category_model.dart';
import '../../../models/etablissement_model.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final ResearchController controller = Get.put(ResearchController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = true;

  @override
  void initState() {
    super.initState();
    controller.fetchAllProducts(reset: true);

    _scrollController.addListener(() {
      // Pagination logic
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !controller.isPaginating.value &&
          controller.query.value.isEmpty &&
          controller.hasMore.value) {
        controller.fetchAllProducts();
      }
    });

    // Lier le controller de texte
    _searchController.addListener(() {
      controller.onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? AppColors.black : AppColors.white,
      appBar: TAppBar(
        title: Text(
          'Recherche',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? AppColors.eerieBlack : AppColors.light,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                border: Border.all(
                  color: dark ? AppColors.darkGrey : AppColors.grey,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit, établissement...',
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                  prefixIcon: Icon(
                    Iconsax.search_normal_1,
                    color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                  ),
                  suffixIcon: Obx(() => controller.query.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Iconsax.close_circle,
                            color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            controller.clearSearch();
                          },
                        )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.defaultSpace,
                    vertical: AppSizes.md,
                  ),
                ),
              ),
            ),
          ),

          // Filters Section
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
              child: Column(
                children: [
                  _buildActiveFilters(dark),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Row(
                    children: [
                      Expanded(child: _buildCategoryFilter(dark)),
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      Expanded(child: _buildEtablissementFilter(dark)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  _buildSortFilter(dark),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                ],
              ),
            ),

          // Product Grid
          Expanded(
            child: _buildProductGrid(screenWidth, dark),
          ),
        ],
      ),
    );
  }

  // Filtres actifs avec badges
  Widget _buildActiveFilters(bool dark) {
    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: dark ? AppColors.eerieBlack : AppColors.light,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
          border: Border.all(
            color: dark ? AppColors.darkGrey : AppColors.grey,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtres actifs:',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (controller.query.value.isNotEmpty)
                  _buildFilterChip(
                    label: 'Recherche: "${controller.query.value}"',
                    onRemove: controller.clearSearch,
                    dark: dark,
                  ),
                if (controller.selectedCategory.value != null)
                  _buildFilterChip(
                    label: 'Catégorie: ${controller.selectedCategoryName}',
                    onRemove: controller.clearCategoryFilter,
                    dark: dark,
                  ),
                if (controller.selectedEtablissement.value != null)
                  _buildFilterChip(
                    label:
                        'Établissement: ${controller.selectedEtablissementName}',
                    onRemove: controller.clearEtablissementFilter,
                    dark: dark,
                  ),
                if (controller.selectedSort.value.isNotEmpty)
                  _buildFilterChip(
                    label: 'Tri: ${controller.selectedSort.value}',
                    onRemove: controller.clearSortFilter,
                    dark: dark,
                  ),
                _buildClearAllChip(dark),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    required bool dark,
  }) {
    return Chip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      deleteIcon: Icon(
        Iconsax.close_circle,
        size: 16,
        color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
      ),
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      side: BorderSide(
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildClearAllChip(bool dark) {
    return InkWell(
      onTap: controller.clearAllFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.trash,
              size: 14,
              color: AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              'Tout effacer',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filtre catégorie avec objets
  Widget _buildCategoryFilter(bool dark) {
    return Obx(() => DropdownButtonFormField<CategoryModel>(
          value: controller.selectedCategory.value,
          decoration: InputDecoration(
            labelText: 'Catégorie',
            filled: true,
            fillColor: dark ? AppColors.eerieBlack : AppColors.light,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? AppColors.darkGrey : AppColors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? AppColors.darkGrey : AppColors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
          ),
          isExpanded: true,
          dropdownColor: dark ? AppColors.eerieBlack : AppColors.white,
          style: Theme.of(context).textTheme.bodyMedium,
          items: [
            DropdownMenuItem<CategoryModel>(
              value: null,
              child: Text(
                'Toutes les catégories',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...controller.categories.map((category) {
              return DropdownMenuItem<CategoryModel>(
                value: category,
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: controller.onCategorySelected,
        ));
  }

  // Filtre établissement avec objets
  Widget _buildEtablissementFilter(bool dark) {
    return Obx(() => DropdownButtonFormField<Etablissement>(
          value: controller.selectedEtablissement.value,
          decoration: InputDecoration(
            labelText: 'Établissement',
            filled: true,
            fillColor: dark ? AppColors.eerieBlack : AppColors.light,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? AppColors.darkGrey : AppColors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? AppColors.darkGrey : AppColors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
          ),
          dropdownColor: dark ? AppColors.eerieBlack : AppColors.white,
          isExpanded: true,
          style: Theme.of(context).textTheme.bodyMedium,
          items: [
            DropdownMenuItem<Etablissement>(
              value: null,
              child: Text(
                'Tous les établissements',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...controller.etablissements.map((etablissement) {
              return DropdownMenuItem<Etablissement>(
                value: etablissement,
                child: Text(
                  etablissement.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: controller.onEtablissementSelected,
        ));
  }

  // Filtre tri
  Widget _buildSortFilter(bool dark) {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedSort.value.isEmpty
              ? null
              : controller.selectedSort.value,
          decoration: InputDecoration(
            labelText: 'Trier par',
            filled: true,
            fillColor: dark ? AppColors.eerieBlack : AppColors.light,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? AppColors.darkGrey : AppColors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? AppColors.darkGrey : AppColors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
          ),
          dropdownColor: dark ? AppColors.eerieBlack : AppColors.white,
          style: Theme.of(context).textTheme.bodyMedium,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Aucun tri',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ...['Prix ↑', 'Prix ↓', 'Nom A-Z', 'Popularité'].map((sort) {
              return DropdownMenuItem<String>(
                value: sort,
                child: Text(
                  sort,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }),
          ],
          onChanged: controller.onSortSelected,
        ));
  }

  // Grille de produits
  Widget _buildProductGrid(double screenWidth, bool dark) {
    return Obx(() {
      if (controller.isLoading.value && controller.searchResults.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.searchResults.isEmpty) {
        return _buildEmptyState(dark);
      }

      return SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO : Nombre de résultats
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
              decoration: BoxDecoration(
                color: dark ? AppColors.eerieBlack : AppColors.light,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                border: Border.all(
                  color: dark ? AppColors.darkGrey : AppColors.grey,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.searchResults.length} produit(s) trouvé(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (controller.hasActiveFilters)
                    Icon(
                      Iconsax.info_circle,
                      size: 16,
                      color: dark ? AppColors.darkGrey : AppColors.darkerGrey,
                    ),
                ],
              ),
            ),

            GridLayout(
              itemCount: controller.searchResults.length,
              itemBuilder: (_, index) {
                return ProductCardVertical(
                  product: controller.searchResults[index],
                );
              },
              crossAxisCount: TDeviceUtils.getCrossAxisCount(screenWidth),
              mainAxisExtent: TDeviceUtils.getMainAxisExtent(screenWidth),
            ),
            const SizedBox(height: AppSizes.spaceBtwSections),

            /// Pagination loader
            if (controller.isPaginating.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.defaultSpace),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      );
    });
  }

  // État vide amélioré
  Widget _buildEmptyState(bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal_1,
              size: 80,
              color: dark ? AppColors.darkGrey : AppColors.grey,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              'Aucun produit trouvé',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems / 2),
            Obx(() {
              if (controller.hasActiveFilters) {
                return Column(
                  children: [
                    Text(
                      'Essayez de modifier vos filtres de recherche',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    ElevatedButton.icon(
                      onPressed: controller.clearAllFilters,
                      icon: const Icon(Iconsax.trash),
                      label: const Text('Réinitialiser les filtres'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                );
              } else {
                return Text(
                  'Aucun produit ne correspond à votre recherche',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
