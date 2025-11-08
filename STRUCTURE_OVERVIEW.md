# Structure MVC - Vue d'Ensemble

## Architecture en Couches

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                        │
│  (main.dart, app.dart, navigation_menu.dart)                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      FEATURES LAYER                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Authentication│  │    Shop      │  │Personalization│    │
│  │              │  │              │  │              │      │
│  │ Models       │  │ Models       │  │ Models       │      │
│  │ Controllers  │  │ Controllers  │  │ Controllers  │      │
│  │ Views        │  │ Views        │  │ Views        │      │
│  │ Bindings     │  │ Bindings     │  │ Bindings     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Repositories (ProduitRepository, OrderRepository...) │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Services (API, Firebase, Supabase...)                 │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       CORE LAYER                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Constants    │  │ Theme        │  │ Utils         │    │
│  │ - Colors     │  │ - Light      │  │ - Helpers     │    │
│  │ - Sizes      │  │ - Dark       │  │ - Validators  │    │
│  │ - Enums      │  │ - Widgets    │  │ - Formatters  │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    SHARED LAYER                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Widgets (AppBar, Cards, Images, Layouts...)          │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Styles (Shadows, Spacing...)                          │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Structure par Module (Feature)

```
feature/
├── models/          # Modèles de données
│   └── [entity]_model.dart
│
├── controllers/     # Logique métier et état
│   └── [entity]_controller.dart
│
├── views/           # Interface utilisateur
│   ├── [entity]_screen.dart
│   └── widgets/
│       └── [entity]_widget.dart
│
└── bindings/        # Injection de dépendances
    └── [feature]_binding.dart
```

## Exemple : Module Shop

```
features/shop/
├── models/
│   ├── product/
│   │   ├── product_model.dart
│   │   └── produit_model.dart
│   ├── cart/
│   │   └── cart_item_model.dart
│   └── order/
│       └── order_model.dart
│
├── controllers/
│   ├── product/
│   │   ├── product_controller.dart
│   │   └── favorites_controller.dart
│   ├── cart/
│   │   └── panier_controller.dart
│   └── order/
│       └── order_controller.dart
│
├── views/
│   ├── product/
│   │   ├── product_list_screen.dart
│   │   ├── product_detail_screen.dart
│   │   └── widgets/
│   │       └── product_card.dart
│   ├── cart/
│   │   ├── cart_screen.dart
│   │   └── widgets/
│   │       └── cart_item_tile.dart
│   └── order/
│       ├── order_list_screen.dart
│       └── widgets/
│           └── order_card.dart
│
└── bindings/
    └── shop_binding.dart
```

## Flux de Données MVC

```
┌──────────┐         ┌──────────────┐         ┌──────────┐
│   View   │◄───────►│  Controller  │◄───────►│  Model   │
│ (Screen) │         │  (Business   │         │  (Data)  │
│          │         │   Logic)     │         │          │
└──────────┘         └──────────────┘         └──────────┘
     │                       │                       │
     │                       │                       │
     ▼                       ▼                       ▼
┌──────────┐         ┌──────────────┐         ┌──────────┐
│  Widgets │         │  Repository   │         │ Database │
│          │         │              │         │          │
└──────────┘         └──────────────┘         └──────────┘
```

## Avantages de cette Structure

### 1. Séparation des Responsabilités
- **Models** : Données et logique métier
- **Views** : Interface utilisateur uniquement
- **Controllers** : Coordination entre Models et Views

### 2. Modularité
- Chaque feature est indépendante
- Facile d'ajouter/supprimer des features
- Réutilisabilité maximale

### 3. Maintenabilité
- Code organisé et prévisible
- Facile de trouver les fichiers
- Réduit la complexité

### 4. Testabilité
- Tests unitaires facilités
- Mocking simplifié
- Isolation des composants

### 5. Scalabilité
- Structure claire pour grandir
- Facile d'ajouter de nouvelles features
- Pas de duplication de code

## Comparaison : Avant vs Après

### Avant (Structure Actuelle)
```
lib/
├── features/
│   └── shop/
│       ├── controllers/     # Mélangés
│       ├── models/          # Mélangés
│       └── screens/         # Mélangés
├── common/                   # Widgets communs
├── utils/                    # Utilitaires
└── data/                     # Repositories
```

### Après (Structure Proposée)
```
lib/
├── features/
│   └── shop/
│       ├── models/          # Organisés par domaine
│       ├── controllers/     # Organisés par domaine
│       ├── views/            # Organisés par domaine
│       └── bindings/         # Injection modulaire
├── shared/                  # Composants partagés
├── core/                     # Configuration centrale
└── data/                     # Couche d'accès aux données
```

## Prochaines Étapes

1. **Lire** : `PROPOSED_STRUCTURE.md` pour la structure complète
2. **Suivre** : `MIGRATION_GUIDE.md` pour migrer progressivement
3. **Tester** : Chaque module après migration
4. **Documenter** : Mettre à jour la documentation au fur et à mesure

## Ressources

- **Structure Complète** : Voir `PROPOSED_STRUCTURE.md`
- **Guide de Migration** : Voir `MIGRATION_GUIDE.md`
- **Documentation GetX** : https://pub.dev/packages/get

