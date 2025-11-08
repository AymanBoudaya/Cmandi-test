# Guide de Migration vers la Structure MVC Organisée

## Vue d'Ensemble

Ce guide vous aidera à migrer votre codebase actuelle vers la structure MVC proposée de manière progressive et sûre.

## Étapes de Migration

### Phase 1 : Préparation

1. **Créer la nouvelle structure de dossiers**
   ```bash
   # Créer les dossiers principaux
   mkdir -p lib/core/{constants,theme,utils,bindings}
   mkdir -p lib/data/{repositories,services}
   mkdir -p lib/shared/{widgets,styles}
   ```

2. **Sauvegarder le code actuel**
   - Créer une branche Git : `git checkout -b refactor/mvc-structure`
   - Commit initial : `git commit -am "Before MVC refactoring"`

### Phase 2 : Migration du Core

#### Étape 2.1 : Déplacer les constantes et utilitaires

```bash
# Déplacer les constantes
mv lib/utils/constants/* lib/core/constants/
mv lib/utils/theme/* lib/core/theme/
mv lib/utils/* lib/core/utils/  # (sauf constants et theme)
```

#### Étape 2.2 : Mettre à jour les imports

Rechercher et remplacer dans tous les fichiers :
- `import 'package:caferesto/utils/constants/` → `import 'package:caferesto/core/constants/`
- `import 'package:caferesto/utils/theme/` → `import 'package:caferesto/core/theme/`
- `import 'package:caferesto/utils/` → `import 'package:caferesto/core/utils/`

### Phase 3 : Migration des Features

#### Étape 3.1 : Module Authentication

```bash
# Créer la structure
mkdir -p lib/features/authentication/{models,controllers,views,bindings}

# Déplacer les fichiers
mv lib/features/authentication/controllers/* lib/features/authentication/controllers/
mv lib/features/authentication/screens/* lib/features/authentication/views/
```

**Structure cible :**
```
lib/features/authentication/
├── controllers/
│   ├── login/
│   ├── signup/
│   └── onboarding/
├── views/
│   ├── login/
│   ├── signup/
│   └── onboarding/
└── bindings/
    └── authentication_binding.dart
```

#### Étape 3.2 : Module Shop

```bash
# Créer la structure
mkdir -p lib/features/shop/{models,controllers,views,bindings}
mkdir -p lib/features/shop/models/{product,cart,order,category,brand,establishment,banner}
mkdir -p lib/features/shop/controllers/{product,cart,order,category,brand,establishment,home,search,navigation}
mkdir -p lib/features/shop/views/{product,cart,order,category,brand,establishment,home,favorites,search}
```

**Déplacer les modèles :**
```bash
mv lib/features/shop/models/product_model.dart lib/features/shop/models/product/
mv lib/features/shop/models/produit_model.dart lib/features/shop/models/product/
mv lib/features/shop/models/cart_item_model.dart lib/features/shop/models/cart/
mv lib/features/shop/models/order_model.dart lib/features/shop/models/order/
# ... etc
```

**Déplacer les contrôleurs :**
```bash
mv lib/features/shop/controllers/product/* lib/features/shop/controllers/product/
mv lib/features/shop/controllers/panier_controller.dart lib/features/shop/controllers/cart/
# ... etc
```

**Déplacer les vues :**
```bash
mv lib/features/shop/screens/product_details/* lib/features/shop/views/product/
mv lib/features/shop/screens/cart/* lib/features/shop/views/cart/
mv lib/features/shop/screens/order/* lib/features/shop/views/order/
# ... etc
```

#### Étape 3.3 : Module Personalization

```bash
# Créer la structure
mkdir -p lib/features/personalization/{models,controllers,views,bindings}
mkdir -p lib/features/personalization/views/{profile,settings,address,dashboard,brands,categories,establishments}

# Déplacer les fichiers
mv lib/features/personalization/models/* lib/features/personalization/models/
mv lib/features/personalization/controllers/* lib/features/personalization/controllers/
mv lib/features/personalization/screens/* lib/features/personalization/views/
```

#### Étape 3.4 : Module Notification

```bash
# Créer la structure
mkdir -p lib/features/notification/{models,controllers,views,bindings}

# Déplacer les fichiers
mv lib/features/notification/models/* lib/features/notification/models/
mv lib/features/notification/controllers/* lib/features/notification/controllers/
mv lib/features/notification/screens/* lib/features/notification/views/
```

### Phase 4 : Migration des Composants Partagés

```bash
# Créer la structure
mkdir -p lib/shared/widgets/{appbar,buttons,cards,images,layouts,list_tiles,shimmer,loaders,success_screen}
mkdir -p lib/shared/styles

# Déplacer les widgets communs
mv lib/common/widgets/appbar/* lib/shared/widgets/appbar/
mv lib/common/widgets/brands/* lib/shared/widgets/cards/
mv lib/common/widgets/categories/* lib/shared/widgets/cards/
mv lib/common/widgets/products/product_cards/* lib/shared/widgets/cards/
mv lib/common/widgets/images/* lib/shared/widgets/images/
mv lib/common/widgets/layouts/* lib/shared/widgets/layouts/
mv lib/common/widgets/list_tiles/* lib/shared/widgets/list_tiles/
mv lib/common/widgets/shimmer/* lib/shared/widgets/shimmer/
mv lib/common/widgets/success_screen/* lib/shared/widgets/success_screen/

# Déplacer les styles
mv lib/common/styles/* lib/shared/styles/
```

### Phase 5 : Mise à Jour des Imports

#### Script de remplacement automatique (à adapter selon vos besoins)

```dart
// Exemples de remplacements à faire :

// Core
'package:caferesto/utils/constants/' → 'package:caferesto/core/constants/'
'package:caferesto/utils/theme/' → 'package:caferesto/core/theme/'
'package:caferesto/utils/' → 'package:caferesto/core/utils/'

// Shared
'package:caferesto/common/widgets/' → 'package:caferesto/shared/widgets/'
'package:caferesto/common/styles/' → 'package:caferesto/shared/styles/'

// Features - Shop
'package:caferesto/features/shop/models/' → 'package:caferesto/features/shop/models/'
'package:caferesto/features/shop/controllers/' → 'package:caferesto/features/shop/controllers/'
'package:caferesto/features/shop/screens/' → 'package:caferesto/features/shop/views/'

// Features - Authentication
'package:caferesto/features/authentication/screens/' → 'package:caferesto/features/authentication/views/'

// Features - Personalization
'package:caferesto/features/personalization/screens/' → 'package:caferesto/features/personalization/views/'
```

### Phase 6 : Création des Bindings par Module

#### Exemple : `lib/features/shop/bindings/shop_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/product/produit_controller.dart';
import '../controllers/cart/panier_controller.dart';
import '../controllers/order/order_controller.dart';
// ... autres imports

class ShopBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers du module shop
    Get.lazyPut(() => ProduitController(), fenix: true);
    Get.lazyPut(() => PanierController(), fenix: true);
    Get.lazyPut(() => OrderController(), fenix: true);
    // ... autres controllers
  }
}
```

#### Exemple : `lib/features/authentication/bindings/authentication_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/login/login_controller.dart';
import '../controllers/signup/signup_controller.dart';
// ... autres imports

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers du module authentication
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => SignupController());
    // ... autres controllers
  }
}
```

### Phase 7 : Mise à Jour de `general_binding.dart`

```dart
import 'package:get/get.dart';
import '../features/shop/bindings/shop_binding.dart';
import '../features/authentication/bindings/authentication_binding.dart';
import '../features/personalization/bindings/personalization_binding.dart';
import '../features/notification/bindings/notification_binding.dart';

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    // Initialiser les bindings de chaque module
    ShopBinding().dependencies();
    AuthenticationBinding().dependencies();
    PersonalizationBinding().dependencies();
    NotificationBinding().dependencies();
    
    // Ou garder les bindings globaux ici si nécessaire
  }
}
```

## Checklist de Migration

### Avant de commencer
- [ ] Créer une branche Git dédiée
- [ ] Faire un backup complet du projet
- [ ] Documenter les dépendances entre modules

### Pendant la migration
- [ ] Migrer le Core (constants, theme, utils)
- [ ] Migrer les Features (un module à la fois)
- [ ] Migrer les composants partagés
- [ ] Mettre à jour tous les imports
- [ ] Créer les bindings par module
- [ ] Tester chaque module après migration

### Après la migration
- [ ] Vérifier que l'application compile sans erreurs
- [ ] Tester toutes les fonctionnalités
- [ ] Nettoyer les anciens fichiers
- [ ] Mettre à jour la documentation
- [ ] Faire un commit final

## Commandes Utiles

### Rechercher tous les imports à mettre à jour

```bash
# Trouver tous les fichiers qui importent depuis l'ancien chemin
grep -r "package:caferesto/utils/" lib/
grep -r "package:caferesto/common/" lib/
grep -r "package:caferesto/features/shop/screens/" lib/
```

### Vérifier les erreurs de compilation

```bash
flutter analyze
flutter pub get
flutter run
```

## Notes Importantes

1. **Migration Progressive** : Ne pas tout migrer en une fois. Faire module par module.

2. **Tests** : Tester chaque module après sa migration avant de passer au suivant.

3. **Git** : Faire des commits fréquents pour pouvoir revenir en arrière si nécessaire.

4. **Documentation** : Mettre à jour la documentation au fur et à mesure.

5. **Équipe** : Si vous travaillez en équipe, coordonnez-vous pour éviter les conflits.

## Problèmes Courants et Solutions

### Problème : Imports cassés
**Solution** : Utiliser l'IDE pour refactoriser automatiquement les imports, ou utiliser un script de remplacement.

### Problème : Controllers non trouvés
**Solution** : Vérifier que les bindings sont correctement configurés et que les controllers sont bien dans les bons dossiers.

### Problème : Widgets non trouvés
**Solution** : Vérifier que les widgets partagés sont bien dans `shared/widgets/` et que les imports sont corrects.

## Support

Si vous rencontrez des problèmes lors de la migration, consultez :
- Le fichier `PROPOSED_STRUCTURE.md` pour la structure complète
- Les fichiers de bindings existants pour des exemples
- La documentation GetX pour les bindings

