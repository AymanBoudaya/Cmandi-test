# Proposition d'Organisation Hiérarchique MVC

## Structure Proposée

```
lib/
├── main.dart                          # Point d'entrée de l'application
├── app.dart                           # Configuration de l'application (GetMaterialApp)
├── navigation_menu.dart               # Menu de navigation principal
│
├── core/                              # Configuration et utilitaires centraux
│   ├── constants/                     # Constantes globales
│   │   ├── api_constants.dart
│   │   ├── colors.dart
│   │   ├── enums.dart
│   │   ├── image_strings.dart
│   │   ├── sizes.dart
│   │   └── text_strings.dart
│   │
│   ├── theme/                         # Thème de l'application
│   │   ├── theme.dart
│   │   └── widget_themes/
│   │       ├── appbar_theme.dart
│   │       ├── bottom_sheet_theme.dart
│   │       ├── checkbox_theme.dart
│   │       ├── chip_theme.dart
│   │       ├── elevated_button_theme.dart
│   │       ├── outlined_button_theme.dart
│   │       ├── text_field_theme.dart
│   │       └── text_theme.dart
│   │
│   ├── utils/                         # Utilitaires généraux
│   │   ├── device/
│   │   │   └── device_utility.dart
│   │   ├── exceptions/
│   │   │   ├── exceptions.dart
│   │   │   ├── firebase_exceptions.dart
│   │   │   ├── format_exceptions.dart
│   │   │   ├── platform_exceptions.dart
│   │   │   ├── supabase_auth_exceptions.dart
│   │   │   └── supabase_exception.dart
│   │   ├── formatters/
│   │   │   └── formatter.dart
│   │   ├── helpers/
│   │   │   ├── cloud_helper_functions.dart
│   │   │   ├── helper_functions.dart
│   │   │   ├── network_manager.dart
│   │   │   └── pricing_calculator.dart
│   │   ├── http/
│   │   │   └── http_client.dart
│   │   ├── local_storage/
│   │   │   └── storage_utility.dart
│   │   ├── logging/
│   │   │   └── logger.dart
│   │   ├── popups/
│   │   │   ├── full_screen_loader.dart
│   │   │   └── loaders.dart
│   │   ├── validators/
│   │   │   └── validation.dart
│   │   └── animations/
│   │       └── depth_transformer.dart
│   │
│   └── bindings/                      # GetX Bindings globaux
│       └── general_binding.dart
│
├── data/                              # Couche d'accès aux données
│   ├── repositories/                  # Repositories (accès aux données)
│   │   ├── address/
│   │   │   └── address_repository.dart
│   │   ├── authentication/
│   │   │   └── authentication_repository.dart
│   │   ├── brands/
│   │   │   └── brand_repository.dart
│   │   ├── categories/
│   │   │   └── category_repository.dart
│   │   ├── etablissement/
│   │   │   └── etablissement_repository.dart
│   │   ├── horaire/
│   │   │   └── horaire_repository.dart
│   │   ├── order/
│   │   │   └── order_repository.dart
│   │   ├── product/
│   │   │   └── produit_repository.dart
│   │   └── user/
│   │       └── user_repository.dart
│   │
│   └── services/                      # Services (API, Firebase, etc.)
│       └── (services si nécessaire)
│
├── features/                          # Modules fonctionnels (par domaine métier)
│   │
│   ├── authentication/                # Module d'authentification
│   │   ├── models/                    # Modèles de données
│   │   │   └── (modèles spécifiques à l'auth si nécessaire)
│   │   │
│   │   ├── controllers/               # Contrôleurs (logique métier)
│   │   │   ├── login/
│   │   │   │   ├── login_controller.dart
│   │   │   │   └── login_form_controller.dart
│   │   │   ├── signup/
│   │   │   │   ├── signup_controller.dart
│   │   │   │   ├── verify_email_controller.dart
│   │   │   │   └── verify_phone_controller.dart
│   │   │   └── onboarding/
│   │   │       └── onboarding_controller.dart
│   │   │
│   │   ├── views/                     # Vues (écrans et widgets)
│   │   │   ├── login/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── login_form.dart
│   │   │   │       └── login_header.dart
│   │   │   ├── signup/
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── signup_form.dart
│   │   │   │       └── verify_email_screen.dart
│   │   │   └── onboarding/
│   │   │       ├── onboarding_screen.dart
│   │   │       └── widgets/
│   │   │           └── onboarding_page.dart
│   │   │
│   │   └── bindings/                  # Bindings spécifiques au module
│   │       └── authentication_binding.dart
│   │
│   ├── shop/                          # Module boutique/e-commerce
│   │   ├── models/                    # Modèles de données
│   │   │   ├── product/
│   │   │   │   ├── product_model.dart
│   │   │   │   ├── produit_model.dart
│   │   │   │   ├── product_variation_model.dart
│   │   │   │   ├── product_attribute_model.dart
│   │   │   │   └── taille_prix_model.dart
│   │   │   ├── cart/
│   │   │   │   └── cart_item_model.dart
│   │   │   ├── order/
│   │   │   │   ├── order_model.dart
│   │   │   │   └── payment_method_model.dart
│   │   │   ├── category/
│   │   │   │   ├── category_model.dart
│   │   │   │   └── brand_category_model.dart
│   │   │   ├── brand/
│   │   │   │   └── brand_model.dart
│   │   │   ├── establishment/
│   │   │   │   ├── etablissement_model.dart
│   │   │   │   ├── horaire_model.dart
│   │   │   │   ├── jour_semaine.dart
│   │   │   │   └── statut_etablissement_model.dart
│   │   │   └── banner/
│   │   │       └── banner_model.dart
│   │   │
│   │   ├── controllers/               # Contrôleurs (logique métier)
│   │   │   ├── product/
│   │   │   │   ├── product_controller.dart
│   │   │   │   ├── produit_controller.dart
│   │   │   │   ├── all_products_controller.dart
│   │   │   │   ├── favorites_controller.dart
│   │   │   │   ├── images_controller.dart
│   │   │   │   ├── variation_controller.dart
│   │   │   │   └── share_controller.dart
│   │   │   ├── cart/
│   │   │   │   └── panier_controller.dart
│   │   │   ├── order/
│   │   │   │   ├── order_controller.dart
│   │   │   │   ├── order_list_controller.dart
│   │   │   │   └── checkout_controller.dart
│   │   │   ├── category/
│   │   │   │   └── category_controller.dart
│   │   │   ├── brand/
│   │   │   │   └── brand_controller.dart
│   │   │   ├── establishment/
│   │   │   │   ├── etablissement_controller.dart
│   │   │   │   └── horaire_controller.dart
│   │   │   ├── home/
│   │   │   │   ├── home_controller.dart
│   │   │   │   └── banner_controller.dart
│   │   │   ├── search/
│   │   │   │   ├── search_controller.dart
│   │   │   │   └── product_serach_controller.dart
│   │   │   └── navigation/
│   │   │       └── navigation_controller.dart
│   │   │
│   │   ├── views/                     # Vues (écrans et widgets)
│   │   │   ├── product/
│   │   │   │   ├── product_list_screen.dart
│   │   │   │   ├── product_detail_screen.dart
│   │   │   │   ├── product_reviews_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── product_card.dart
│   │   │   │       ├── product_image_slider.dart
│   │   │   │       ├── product_attributes.dart
│   │   │   │       └── product_quantity_controls.dart
│   │   │   ├── cart/
│   │   │   │   ├── cart_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── cart_item_tile.dart
│   │   │   │       ├── cart_bottom_section.dart
│   │   │   │       └── empty_cart_view.dart
│   │   │   ├── order/
│   │   │   │   ├── order_list_screen.dart
│   │   │   │   ├── order_detail_screen.dart
│   │   │   │   ├── order_tracking_screen.dart
│   │   │   │   ├── checkout_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── order_card.dart
│   │   │   │       ├── payment_tile.dart
│   │   │   │       └── time_slot_modal.dart
│   │   │   ├── category/
│   │   │   │   ├── category_list_screen.dart
│   │   │   │   ├── category_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── category_card.dart
│   │   │   ├── brand/
│   │   │   │   ├── brand_list_screen.dart
│   │   │   │   ├── brand_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── brand_card.dart
│   │   │   ├── establishment/
│   │   │   │   ├── establishment_list_screen.dart
│   │   │   │   ├── establishment_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── establishment_card.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── home_appbar.dart
│   │   │   │       ├── promo_slider.dart
│   │   │   │       └── search_overlay.dart
│   │   │   ├── favorites/
│   │   │   │   └── favorites_screen.dart
│   │   │   └── search/
│   │   │       └── search_screen.dart
│   │   │
│   │   └── bindings/                  # Bindings spécifiques au module
│   │       └── shop_binding.dart
│   │
│   ├── personalization/               # Module de personnalisation/profil
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   └── address_model.dart
│   │   │
│   │   ├── controllers/
│   │   │   ├── user_controller.dart
│   │   │   ├── address_controller.dart
│   │   │   ├── location_controller.dart
│   │   │   └── update_name_controller.dart
│   │   │
│   │   ├── views/
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── settings/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── address/
│   │   │   │   ├── address_list_screen.dart
│   │   │   │   ├── address_form_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── dashboard/
│   │   │   │   ├── admin_dashboard_screen.dart
│   │   │   │   ├── manager_dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── dashboard_side_menu.dart
│   │   │   ├── brands/
│   │   │   │   └── (écrans de gestion des marques)
│   │   │   ├── categories/
│   │   │   │   └── (écrans de gestion des catégories)
│   │   │   └── establishments/
│   │   │       └── (écrans de gestion des établissements)
│   │   │
│   │   └── bindings/
│   │       └── personalization_binding.dart
│   │
│   └── notification/                  # Module de notifications
│       ├── models/
│       │   └── notification_model.dart
│       │
│       ├── controllers/
│       │   └── notification_controller.dart
│       │
│       ├── views/
│       │   ├── notifications_screen.dart
│       │   └── widgets/
│       │       └── notification_tile.dart
│       │
│       └── bindings/
│           └── notification_binding.dart
│
└── shared/                            # Composants partagés entre modules
    ├── widgets/                       # Widgets réutilisables
    │   ├── appbar/
    │   │   ├── appbar.dart
    │   │   └── tabbar.dart
    │   ├── buttons/
    │   │   └── (boutons réutilisables)
    │   ├── cards/
    │   │   ├── brand_card.dart
    │   │   ├── category_card.dart
    │   │   └── product_card.dart
    │   ├── images/
    │   │   ├── circular_image.dart
    │   │   └── rounded_image.dart
    │   ├── layouts/
    │   │   └── grid_layout.dart
    │   ├── list_tiles/
    │   │   ├── settings_menu_tile.dart
    │   │   └── user_profile_tile.dart
    │   ├── shimmer/
    │   │   ├── shimmer_effect.dart
    │   │   └── (autres effets shimmer)
    │   ├── loaders/
    │   │   ├── animation_loader.dart
    │   │   └── circular_loader.dart
    │   └── success_screen/
    │       └── success_screen.dart
    │
    └── styles/                        # Styles partagés
        ├── shadows.dart
        └── spacing_styles.dart
```

## Principes d'Organisation

### 1. **Séparation par Couches (MVC)**
   - **Models** : Représentent les données et la logique métier
   - **Views** : Représentent l'interface utilisateur (écrans et widgets)
   - **Controllers** : Gèrent la logique de présentation et la communication entre Models et Views

### 2. **Organisation par Features (Modules)**
   - Chaque feature est un module indépendant
   - Chaque module contient ses propres models, controllers, views et bindings
   - Facilite la maintenance et la scalabilité

### 3. **Core (Configuration Centrale)**
   - Constantes, thème, utilitaires partagés
   - Bindings globaux
   - Configuration de l'application

### 4. **Data (Couche d'Accès aux Données)**
   - Repositories : Abstraction de l'accès aux données
   - Services : Services externes (API, Firebase, etc.)

### 5. **Shared (Composants Partagés)**
   - Widgets réutilisables entre plusieurs modules
   - Styles communs

## Avantages de cette Structure

1. **Clarté** : Chaque fichier a une place logique et prévisible
2. **Maintenabilité** : Facile de trouver et modifier le code
3. **Scalabilité** : Facile d'ajouter de nouvelles features
4. **Testabilité** : Séparation claire facilite les tests unitaires
5. **Réutilisabilité** : Composants partagés facilement accessibles
6. **Collaboration** : Structure claire pour le travail en équipe

## Migration Recommandée

1. **Phase 1** : Créer la nouvelle structure de dossiers
2. **Phase 2** : Déplacer les fichiers par module (un à la fois)
3. **Phase 3** : Mettre à jour les imports
4. **Phase 4** : Tester chaque module après migration
5. **Phase 5** : Nettoyer les anciens fichiers

## Notes Importantes

- Les `bindings/` dans chaque feature permettent une injection de dépendances modulaire
- Les `widgets/` dans chaque vue sont spécifiques à cette vue
- Les widgets dans `shared/widgets/` sont réutilisables partout
- Les `models/` peuvent être partagés entre features si nécessaire (dans ce cas, les mettre dans `shared/models/`)

