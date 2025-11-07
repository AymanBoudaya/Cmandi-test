import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utils/popups/loaders.dart';

class LocationController extends GetxController {
  static LocationController get instance {
    try {
      return Get.find<LocationController>();
    } catch (e) {
      return Get.put(LocationController(), permanent: true);
    }
  }

  final RxBool isLocationEnabled = false.obs;
  final RxBool isCheckingPermission = false.obs;
  final String _storageKey = 'location_enabled';
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadLocationPreference();
  }

  /// Charger la préférence de géolocalisation depuis le stockage local
  Future<void> _loadLocationPreference() async {
    try {
      final stored = _storage.read<bool>(_storageKey);
      if (stored != null) {
        isLocationEnabled.value = stored;
        // Vérifier l'état réel si l'utilisateur a activé la localisation
        if (stored) {
          await _checkLocationServiceStatus();
        }
      } else {
        // Par défaut, la géolocalisation est désactivée
        isLocationEnabled.value = false;
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la préférence de localisation: $e');
      isLocationEnabled.value = false;
    }
  }

  /// Vérifier l'état réel des services de localisation
  Future<bool> _checkLocationServiceStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Si les services sont désactivés au niveau du système, désactiver dans l'app
        if (isLocationEnabled.value) {
          isLocationEnabled.value = false;
          await _saveLocationPreference(false);
        }
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des services de localisation: $e');
      return false;
    }
  }

  /// Sauvegarder la préférence de géolocalisation
  Future<void> _saveLocationPreference(bool enabled) async {
    try {
      await _storage.write(_storageKey, enabled);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la préférence de localisation: $e');
    }
  }

  /// Activer ou désactiver la géolocalisation
  Future<void> toggleLocation(bool enabled) async {
    try {
      isCheckingPermission.value = true;

      if (enabled) {
        // Activer la géolocalisation
        await _enableLocation();
      } else {
        // Désactiver la géolocalisation
        await _disableLocation();
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de modifier les paramètres de localisation: $e',
      );
      // Revenir à l'état précédent en cas d'erreur
      isLocationEnabled.value = !enabled;
    } finally {
      isCheckingPermission.value = false;
    }
  }

  /// Activer la géolocalisation
  Future<void> _enableLocation() async {
    try {
      // Vérifier si les services de localisation sont activés au niveau du système
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        // Demander à l'utilisateur d'activer les services de localisation
        TLoaders.warningSnackBar(
          title: 'Services de localisation désactivés',
          message: 'Veuillez activer les services de localisation dans les paramètres de votre appareil.',
        );
        isLocationEnabled.value = false;
        await _saveLocationPreference(false);
        return;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Demander la permission
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          TLoaders.warningSnackBar(
            title: 'Permission refusée',
            message: 'La permission de localisation est nécessaire pour utiliser cette fonctionnalité.',
          );
          isLocationEnabled.value = false;
          await _saveLocationPreference(false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        TLoaders.warningSnackBar(
          title: 'Permission définitivement refusée',
          message: 'Veuillez activer la permission de localisation dans les paramètres de l\'application.',
        );
        isLocationEnabled.value = false;
        await _saveLocationPreference(false);
        return;
      }

      // Si on arrive ici, les permissions sont accordées
      // Tester en obtenant une position (optionnel, pour vérifier que tout fonctionne)
      try {
        await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        // Si on ne peut pas obtenir la position, ce n'est pas grave
        // La permission est accordée, on peut activer
        debugPrint('Impossible d\'obtenir la position immédiatement: $e');
      }

      // Activer la géolocalisation
      isLocationEnabled.value = true;
      await _saveLocationPreference(true);
      TLoaders.successSnackBar(
        message: 'Géolocalisation activée avec succès',
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'activation de la localisation: $e');
      isLocationEnabled.value = false;
      await _saveLocationPreference(false);
      rethrow;
    }
  }

  /// Désactiver la géolocalisation
  Future<void> _disableLocation() async {
    try {
      isLocationEnabled.value = false;
      await _saveLocationPreference(false);
      TLoaders.successSnackBar(
        message: 'Géolocalisation désactivée',
      );
    } catch (e) {
      debugPrint('Erreur lors de la désactivation de la localisation: $e');
      rethrow;
    }
  }

  /// Obtenir la position actuelle (utilisé par d'autres parties de l'application)
  Future<Position?> getCurrentPosition() async {
    // Vérifier si la géolocalisation est activée dans les préférences
    if (!isLocationEnabled.value) {
      return null;
    }

    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Obtenir la position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }
}

