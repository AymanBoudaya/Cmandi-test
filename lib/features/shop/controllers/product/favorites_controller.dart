import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../utils/local_storage/storage_utility.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/produit_model.dart';
import '../../models/etablissement_model.dart';
import '../../../../data/repositories/product/produit_repository.dart';



class FavoritesController extends GetxController {
  static FavoritesController get instance => Get.find<FavoritesController>();

  final RxList<String> favoriteIds = <String>[].obs;
  final RxList<ProduitModel> favoriteProducts = <ProduitModel>[].obs;
  final RxBool isLoading = false.obs;

  final String _storageKey = 'favorites';
  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    // Le chargement sera déclenché par l'écran si nécessaire
  }

  /// Load favorites IDs from local storage and fetch product details
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final raw = TLocalStorage.instance().readData(_storageKey);
      if (raw != null && (raw as String).isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        favoriteIds.assignAll(decoded.cast<String>());
      } else {
        favoriteIds.clear();
      }
      await _loadFavoriteProducts();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Erreur', message: 'Impossible de charger les favoris');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFavoriteProducts() async {
    favoriteProducts.clear();
    if (favoriteIds.isEmpty) return;

    try {
      final products = await ProduitRepository.instance.getProductsByIds(favoriteIds);
      
      // Charger l'établissement pour chaque produit si manquant avec gestion d'erreur
      // (même logique que fetchFeaturedProducts dans ProduitController)
      final productsWithEtab = <ProduitModel>[];
      for (final produit in products) {
        try {
          ProduitModel finalProduct = produit;
          if (produit.etablissement == null &&
              produit.etablissementId.isNotEmpty) {
            finalProduct = await _loadEtablissementForProduct(produit);
          }
          productsWithEtab.add(finalProduct);
        } catch (e) {
          debugPrint(
              'Erreur lors du chargement de l\'établissement pour le produit ${produit.id}: $e');
          // Ajouter le produit même si l'établissement n'a pas pu être chargé
          productsWithEtab.add(produit);
        }
      }

      // Keep order consistent with favoriteIds
      final Map<String, ProduitModel> mapById = { 
        for (var p in productsWithEtab) p.id: p 
      };
      final ordered = favoriteIds
          .map((id) => mapById[id])
          .whereType<ProduitModel>()
          .toList();
      favoriteProducts.assignAll(ordered);
    } catch (e) {
      debugPrint('Erreur lors du chargement des produits favoris: $e');
      TLoaders.errorSnackBar(
          title: 'Erreur', message: 'Impossible de charger les produits favoris');
    }
  }

  /// Charge l'établissement pour un produit si manquant
  /// (même logique que _loadEtablissementForProduct dans ProduitController)
  Future<ProduitModel> _loadEtablissementForProduct(
      ProduitModel produit) async {
    if (produit.etablissement != null || produit.etablissementId.isEmpty) {
      return produit;
    }

    try {
      final etabResponse = await _supabase
          .from('etablissements')
          .select('*')
          .eq('id', produit.etablissementId)
          .single();

      final etab = Etablissement.fromJson(etabResponse);
      return produit.copyWith(etablissement: etab);
    } catch (e) {
      debugPrint('Erreur chargement établissement pour produit: $e');
    }
    return produit;
  }

  /// Persist favorite ids locally
  Future<void> _saveFavorites() async {
    try {
      final encoded = jsonEncode(favoriteIds);
      await TLocalStorage.instance().saveData(_storageKey, encoded);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Erreur', message: 'Impossible de sauvegarder les favoris');
    }
  }

  bool isFavourite(String productId) {
    return favoriteIds.contains(productId);
  }

  /// Toggle favorite status and keep product list in sync
  Future<void> toggleFavoriteProduct(String productId) async {
    try {
      if (favoriteIds.contains(productId)) {
        favoriteIds.remove(productId);
        favoriteProducts.removeWhere((p) => p.id == productId);
        TLoaders.customToast(message: 'Produit retiré des favoris');
      } else {
        favoriteIds.add(productId);
        TLoaders.customToast(message: 'Produit ajouté aux favoris');
        try {
          var fetched = await ProduitRepository.instance.getProductById(productId);
          if (fetched != null) {
            // S'assurer que l'établissement est chargé (même si getProductById le charge déjà)
            if (fetched.etablissement == null &&
                fetched.etablissementId.isNotEmpty) {
              fetched = await _loadEtablissementForProduct(fetched);
            }
            final insertIndex = favoriteIds.indexOf(productId);
            if (insertIndex >= 0 && insertIndex <= favoriteProducts.length) {
              favoriteProducts.insert(insertIndex, fetched);
            } else {
              favoriteProducts.add(fetched);
            }
          } else {
            await _loadFavoriteProducts();
          }
        } catch (_) {
          await _loadFavoriteProducts();
        }
      }
      await _saveFavorites();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Erreur', message: 'Action impossible');
    }
  }

  /// Clear all favorites. Returns true if success
  Future<bool> clearAllFavorites() async {
    try {
      isLoading.value = true;
      favoriteIds.clear();
      favoriteProducts.clear();
      await _saveFavorites();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}