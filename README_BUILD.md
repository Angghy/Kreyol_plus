# Kreyòl+ - Application Mobile d'Apprentissage du Créole Haïtien

## Vue d'ensemble

Kreyòl+ est une application mobile Flutter développée pour enseigner le créole haïtien de manière ludique et interactive. L'application utilise une base de données locale SQLite pour le stockage des données et suit une architecture MVC avec Provider pour la gestion d'état.

## Architecture Implémentée

### Structure MVC
- **Models** (`lib/models/`): Définitions des entités (Lesson, Question, User, UserProgress, Badge)
- **Views** (`lib/views/`): Écrans utilisateur (Login, Signup, Home, LessonList, Quiz, Progress, Profile)
- **Controllers/Providers** (`lib/providers/`): Gestion d'état et logique métier (AuthProvider, LessonProvider, ProgressProvider)
- **Services** (`lib/services/`): Couche d'accès aux données et services (DatabaseService, AudioService, AuthService)
- **Widgets** (`lib/widgets/`): Composants réutilisables (LessonCard, QuizOptionButton, ProgressBarWidget, BadgeTile)

### Dépendances Principales
- **provider** (6.1.0): Gestion d'état réactive
- **sqflite** (2.4.0): Base de données locale SQLite
- **path** (1.8.3): Gestion des chemins
- **audioplayers** (6.7.1): Lecture audio
- **crypto** (3.0.7): Hachage des mots de passe

## Fonctionnalités Implémentées

### 1. Authentification
- **Inscription**: Création de compte avec validation du mot de passe
- **Connexion**: Authentification avec vérification du mot de passe haché
- **Gestion de session**: Vérification de l'authentification au démarrage

### 2. Leçons
- **Liste des leçons**: Vue avec filtrage par catégorie
  - Vocabulaire (10 leçons)
  - Expression (10 leçons)
  - Phrase courante (10 leçons)
  - Grammaire (10 leçons)
- **Détail de leçon**: Affichage du contenu avec audio intégré
- **Support audio**: Lecture des fichiers MP3 depuis les assets

### 3. Quiz
- **Quiz Textuel**: Questions écrites avec options multiples
- **Quiz Oral**: Questions avec support audio
- **Feedback immédiat**: Retour correct/incorrect avec points
- **Scoring**: Calcul des points (10 points par bonne réponse)
- **Session de quiz**: Déroulement complet avec résumé final

### 4. Progression et Badges
- **Suivi de progression**: Pour chaque utilisateur et leçon
- **Calcul des scores**: Accumulation des points
- **Système de badges**: 4 badges avec déblocage progressif
  - Badge 1: Première leçon complétée
  - Badge 2: 5 leçons complétées
  - Badge 3: 10 leçons complétées
  - Badge 4: Toutes les leçons complétées (40)
- **Vue de progression**: Affichage des statistiques et badges

### 5. Interface Utilisateur
- **Thème Material 3**: Couleurs professionnelles (bleu primaire, vert secondaire, orange accentué)
- **Responsive Design**: Adaptation aux différentes tailles d'écran
- **Navigation**: Menu latéral avec accès rapide à tous les écrans
- **Animations**: Transitions fluides entre les écrans

## Écrans de l'Application

1. **Login** - Connexion utilisateur avec validation
2. **Signup** - Inscription avec confirmation de mot de passe
3. **Home** - Dashboard avec statistiques et accès aux catégories
4. **LessonList** - Liste des leçons par catégorie
5. **LessonDetail** - Affichage détaillé d'une leçon avec audio
6. **QuizList** - Sélection entre quiz textuel et oral
7. **QuizDetail** - Interface de quiz interactif
8. **Progress** - Vue de progression avec badges
9. **Profile** - Profil utilisateur et paramètres

## Base de Données

### Tables SQLite
- `users`: Stockage des utilisateurs avec mot de passe haché
- `lessons`: Contenu des leçons avec références audio
- `questions`: Questions de quiz avec options et réponses
- `user_progress`: Suivi de la progression par utilisateur
- `badges`: Définitions des badges
- `user_badges`: État du déblocage des badges par utilisateur

### Données Initiales
Les données JSON sont chargées au premier lancement:
- `assets/data/lessons.json`: 40 leçons
- `assets/data/quiz-textuel.json`: Questions écrites
- `assets/data/quiz-oral.json`: Questions orales

## Fichiers Audios

L'application inclut tous les fichiers MP3 pour:
- Vocabulaire (10 fichiers)
- Expression (10 fichiers)
- Phrase courante (10 fichiers)
- Grammaire (10 fichiers)

Chemin: `assets/audios/{categorie}/{nom_audio}.mp3`

## Thème et Palette de Couleur

- **Couleur primaire**: #1a73e8 (Bleu)
- **Couleur secondaire**: #34a853 (Vert)
- **Couleur accentée**: #fbbc04 (Orange)
- **Fond**: #f8f9fa (Gris clair)
- **Texte principal**: #202124 (Gris foncé)
- **Erreur**: #d33b27 (Rouge)

## Compilation et Exécution

### Prérequis
```bash
flutter create kreyol_plus
flutter pub get
```

### Compiler
```bash
# APK Release
flutter build apk --release

# APK Debug
flutter build apk --debug

# Pour Web
flutter build web
```

### Exécuter
```bash
# Émulateur/Appareil
flutter run

# Web
flutter run -d web-server
```

## Fonctionnalités Ajoutées au-delà des Spécifications

### 1. Sécurité Améliorée
- Hachage SHA-256 des mots de passe (peut être amélioré avec bcrypt)
- Validation des longueurs de mot de passe (minimum 6 caractères)

### 2. Expérience Utilisateur
- Menu de navigation latéral (Drawer) pour accès facile
- Indicateur de progression visuelle
- Feedback utilisateur avec snackbars et dialogues
- Indicateurs visuels pour les leçons complétées

### 3. Gestion d'État Avancée
- Provider pattern avec ChangeNotifier
- Providers séparés pour authentification, leçons et progression
- Mises à jour réactives de l'interface

### 4. Architecture Robuste
- Séparation claire des responsabilités (MVC)
- Services indépendants pour DB, Audio et Auth
- Gestion des erreurs et cas limite
- Logging intégré

## Structure des Fichiers du Projet

```
lib/
├── main.dart                 # Point d'entrée, setup providers
├── theme/
│   └── app_theme.dart       # Thème Material et couleurs
├── models/
│   ├── lesson.dart
│   ├── question.dart
│   ├── user.dart
│   ├── user_progress.dart
│   └── badge.dart
├── services/
│   ├── database_service.dart # Accès SQLite
│   ├── audio_service.dart    # Lecture audio
│   └── auth_service.dart     # Hachage/vérification
├── providers/
│   ├── auth_provider.dart
│   ├── lesson_provider.dart
│   └── progress_provider.dart
├── views/
│   ├── login_view.dart
│   ├── signup_view.dart
│   ├── home_view.dart
│   ├── lesson_list_view.dart
│   ├── lesson_detail_view.dart
│   ├── quiz_list_view.dart
│   ├── quiz_detail_view.dart
│   ├── progress_view.dart
│   └── profile_view.dart
└── widgets/
    ├── lesson_card.dart
    ├── quiz_option_button.dart
    ├── progress_bar_widget.dart
    └── badge_tile.dart
```

## Problèmes Connus et Améliorations Futures

### Problèmes Connus
- Le fichier `present_progressif,mp3.ogg` a une extension double (virgule au lieu de point)

### Améliorations Futures
- Support multilingue complet (FR, EN, ES)
- Synchronisation cloud Firebase
- Mode hors ligne avec synchronisation différée
- Système de points et classement
- Notifications de rappel
- Export des statistiques
- Éditeur de contenu pour les administrateurs

## Version de Flutter Requise

- Dart: ^3.10.4
- Flutter: Tout SDK compatible avec Dart 3.10.4

## Notes de Déploiement

### Android
- Package name: `com.kreyolplus`
- Version: 1.0.0
- Permissions minimales requises (aucune)

### iOS
- Support iPad et iPhone
- iOS 14.0 minimum

## Auteur & Licence

Kreyòl+ - Application académique développée dans le cadre d'un projet de Développement Mobile Avancé (Flutter)

Tous les droits réservés © 2026

