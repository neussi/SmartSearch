# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### En Cours
- Développement des écrans principaux
- Implémentation de la recherche multimodale
- Intégration avec le backend

## [1.0.0] - 2025-01-03

### Ajouté
- Structure initiale du projet Flutter
- Configuration de l'architecture Provider
- Modèles de données (Product, User, CartItem, Category, SearchResult)
- Services API (ApiService, AuthService, ProductService, SearchService, CartService)
- Providers (AuthProvider, ProductProvider, SearchProvider, CartProvider)
- Configuration du thème Material Design
- Système de routing
- Utilitaires (validators, helpers, constants)
- Widgets réutilisables (CustomButton, LoadingWidget)
- Documentation complète (README, ARCHITECTURE, API_INTEGRATION, CONTRIBUTING)
- Configuration Git (.gitignore, .gitattributes)
- Licence MIT
- Tests de base

### Configuration
- Flutter SDK 3.0+
- Packages essentiels (Provider, HTTP, Dio, Image Picker, etc.)
- Analyse statique du code
- Conventions de formatage

---

## Format de Version

- **MAJOR** : Changements incompatibles de l'API
- **MINOR** : Ajout de fonctionnalités rétrocompatibles
- **PATCH** : Corrections de bugs rétrocompatibles

## Types de Changements

- **Ajouté** : Nouvelles fonctionnalités
- **Modifié** : Changements de fonctionnalités existantes
- **Déprécié** : Fonctionnalités qui seront supprimées
- **Supprimé** : Fonctionnalités supprimées
- **Corrigé** : Corrections de bugs
- **Sécurité** : Corrections de vulnérabilités
