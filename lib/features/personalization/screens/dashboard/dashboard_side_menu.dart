import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../shop/controllers/etablissement_controller.dart';
import '../../../shop/screens/order/gerant_order_management_screen.dart';
import '../../../shop/screens/product_reviews/list_produit_screen.dart';
import '../../controllers/user_controller.dart';
import '../categories/category_manager_screen.dart';
import '../brands/mon_etablissement_screen.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../shop/models/statut_etablissement_model.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../navigation_menu.dart';
import 'admin_dashboard_screen.dart';
import 'gerant_dashboard_screen.dart';

/// Menu latéral pour les dashboards Admin et Gérant
class DashboardSideMenu extends StatelessWidget {
  final String currentRoute;
  final bool isAdmin;

  const DashboardSideMenu({
    super.key,
    required this.currentRoute,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final userController = Get.find<UserController>();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkContainer : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête du menu
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: dark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.menu_board,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    isAdmin ? 'Menu Admin' : 'Menu Gérant',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des options du menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Dashboard
                _buildMenuItem(
                  context: context,
                  icon: Iconsax.chart_2,
                  title: isAdmin ? 'Dashboard Admin' : 'Dashboard Gérant',
                  isSelected: currentRoute == 'dashboard',
                  onTap: () {
                    Navigator.pop(context); // Fermer le drawer
                    if (isAdmin) {
                      Get.offAll(() => AdminDashboardScreen());
                    } else {
                      Get.offAll(() => GerantDashboardScreen());
                    }
                  },
                  dark: dark,
                ),

                // Gérer commandes (Gérant seulement, pas pour Admin)
                if (!isAdmin && userController.user.value.role == 'Gérant')
                  _buildMenuItem(
                    context: context,
                    icon: Iconsax.shopping_bag,
                    title: 'Gérer commandes',
                    isSelected: currentRoute == 'orders',
                    onTap: () async {
                      Navigator.pop(context); // Fermer le drawer
                      final etab = await EtablissementController.instance
                          .getEtablissementUtilisateurConnecte();
                      if (etab == null ||
                          etab.statut != StatutEtablissement.approuve) {
                        TLoaders.errorSnackBar(
                          message:
                              'Accès désactivé tant que votre établissement n\'est pas approuvé.',
                        );
                        return;
                      }
                      Get.to(() => GerantOrderManagementScreen());
                    },
                    dark: dark,
                  ),

                // Gérer catégorie (Admin seulement)
                if (isAdmin)
                  _buildMenuItem(
                    context: context,
                    icon: Iconsax.category,
                    title: 'Gérer catégorie',
                    isSelected: currentRoute == 'categories',
                    onTap: () {
                      Navigator.pop(context); // Fermer le drawer
                      Get.to(() => CategoryManagementPage());
                    },
                    dark: dark,
                  ),

                // Gérer établissement
                if (isAdmin || userController.user.value.role == 'Gérant')
                  _buildMenuItem(
                    context: context,
                    icon: Iconsax.home,
                    title: 'Gérer établissement',
                    isSelected: currentRoute == 'establishments',
                    onTap: () {
                      Navigator.pop(context); // Fermer le drawer
                      Get.to(() => MonEtablissementScreen());
                    },
                    dark: dark,
                  ),

                // Gérer produit
                if (isAdmin || userController.user.value.role == 'Gérant')
                  _buildMenuItem(
                    context: context,
                    icon: Iconsax.bag_tick_2,
                    title: 'Gérer produit',
                    isSelected: currentRoute == 'products',
                    onTap: () async {
                      Navigator.pop(context); // Fermer le drawer
                      if (!isAdmin) {
                        final etab = await EtablissementController.instance
                            .getEtablissementUtilisateurConnecte();
                        if (etab == null ||
                            etab.statut != StatutEtablissement.approuve) {
                          TLoaders.errorSnackBar(
                            message:
                                'Accès désactivé tant que votre établissement n\'est pas approuvé.',
                          );
                          return;
                        }
                      }
                      Get.to(() => ListProduitScreen());
                    },
                    dark: dark,
                  ),

                // Interface Client (pour Admin et Gérant)
                if (isAdmin || userController.user.value.role == 'Gérant')
                  _buildMenuItem(
                    context: context,
                    icon: Iconsax.user,
                    title: 'Interface Client',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context); // Fermer le drawer
                      Get.offAll(() => const NavigationMenu());
                    },
                    dark: dark,
                  ),

                const Divider(height: 32),

                // Logout (pour Admin et Gérant)
                if (isAdmin || userController.user.value.role == 'Gérant')
                  _buildMenuItem(
                    context: context,
                    icon: Iconsax.logout,
                    title: 'Déconnexion',
                    isSelected: false,
                    onTap: () async {
                      Navigator.pop(context); // Fermer le drawer
                      // Demander confirmation avant de déconnecter
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text('Déconnexion'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir vous déconnecter ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: const Text(
                                'Déconnexion',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await AuthenticationRepository.instance.logout();
                        } catch (e) {
                          TLoaders.errorSnackBar(
                            title: 'Erreur',
                            message: 'Erreur lors de la déconnexion: $e',
                          );
                        }
                      }
                    },
                    dark: dark,
                    isDanger: true,
                  ),

                // Retour au menu principal (pour les autres cas)
                if (!isAdmin && userController.user.value.role != 'Gérant')
                  _buildMenuItem(
                    context: context,
                    icon: Iconsax.arrow_left,
                    title: 'Retour au menu',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context); // Fermer le drawer
                      Get.back();
                    },
                    dark: dark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool dark,
    bool isDanger = false,
  }) {
    final color = isDanger
        ? Colors.red
        : (isSelected ? AppColors.primary : Colors.grey);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDanger
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
          border: isSelected
              ? Border.all(
                  color: isDanger
                      ? Colors.red.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            if (isSelected)
              Icon(
                Iconsax.arrow_right_3,
                color: color,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
