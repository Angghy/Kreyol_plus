# Guide de Démarrage Rapide - Kreyòl+

## Configuration Initiale

### 1. Cloner le projet et installer les dépendances

```bash
cd C:\Users\miche\AndroidStudioProjects\kreyol_plus
flutter pub get
```

### 2. Vérifier l'installation Flutter

```bash
flutter doctor
flutter --version
dart --version
```

## Compilation et Déploiement

### Option A: Build APK (Android)

#### Debug (rapide, pour développement)
```bash
flutter build apk --debug
```
Sortie: `build/app/outputs/apk/debug/app-debug.apk`

#### Release (optimisé, pour production)
```bash
flutter build apk --release
```
Sortie: `build/app/outputs/apk/release/app-release.apk`

### Option B: Run sur Émulateur/Appareil

```bash
# Lister les appareils disponibles
flutter devices

# Exécuter l'app en debug
flutter run -d <device_id>

# Exemple: flutter run -d emulator-5554
```

### Option C: Web (pour test rapide)

```bash
flutter run -d web-server
# Accédez à http://localhost:8080
```

## Tests

### Analyser le code
```bash
flutter analyze
```

### Exécuter les tests unitaires
```bash
flutter test test/unit_tests.dart
```

### Tests complets
```bash
flutter test
```

## Points de Contrôle de Compilation

### 1. Dépendances
✓ provider (6.1.0+)
✓ sqflite (2.3.0+)
✓ audioplayers (6.1.0+)
✓ crypto (3.0.3+)
✓ path (1.8.3+)

### 2. Assets
✓ `assets/images/` - Images de l'application
✓ `assets/audios/` - Fichiers MP3 (vocabulaire, expression, phrase_courante, grammaire)
✓ `assets/data/` - JSONs (lessons.json, quiz-oral.json, quiz-textuel.json)

### 3. Structure du Code
✓ `lib/main.dart` - Point d'entrée
✓ `lib/models/` - Modèles de données
✓ `lib/services/` - Services (DB, Audio, Auth)
✓ `lib/providers/` - Gestion d'état
✓ `lib/views/` - Écrans
✓ `lib/widgets/` - Composants réutilisables
✓ `lib/theme/` - Thème et couleurs

### 4. Configuration
✓ `pubspec.yaml` - Dépendances et assets
✓ `analysis_options.yaml` - Linting Dart
✓ `android/app/` - Configuration Android

## Troubleshooting

### Erreur: "No devices detected"
```bash
flutter emulators
flutter emulators --launch emulator_name
```

### Erreur: "Gradle build failed"
```bash
flutter clean
flutter pub get
flutter build apk
```

### Erreur: "Assets not found"
- Vérifiez que le chemin dans `pubspec.yaml` est correct
- Vérifiez que les fichiers existent dans `assets/`
- Exécutez: `flutter pub get && flutter clean && flutter build apk`

### Erreur: "Database error"
- La base de données SQLite est créée automatiquement au premier lancement
- Si erreur persiste: Clear l'app et relancez

## Structure des Données

### Base SQLite Auto-Générée
Tables créées automatiquement au premier lancement:
- users
- lessons (chargées depuis lessons.json)
- questions (chargées depuis quiz-*.json)
- user_progress
- badges

### Données Initiales
- 40 leçons (10 par catégorie)
- 16 questions textuelles
- 16 questions orales
- 4 badges

## Performance & Optimisation

### Bien configurer l'émulateur
- CPU cores: 4+
- RAM: 2GB+
- Internal storage: 2GB+

### Mesurer la performance
```bash
flutter run
# Dans le shell Flutter:
> l        # Toggle log
> p        # Performance overlay
> a        # Dart DevTools
```

## Préparation Production

### Vérifications avant mise en ligne

1. **Version de l'app**
   - Mettre à jour `version:` dans `pubspec.yaml`
   - Format: X.Y.Z+buildNumber

2. **Tests**
   ```bash
   flutter test
   flutter analyze
   ```

3. **Build pour production**
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

4. **Signature APK** (instruction Android)
   ```bash
   jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
     -keystore path/to/keystore.jks \
     app-release.apk alias_name
   ```

## Déploiement Google Play Store

1. Créer un compte développeur Google Play
2. Créer une nouvelle appli
3. Générer l'APK signé
4. Uploader l'APK
5. Remplir la description et les captures d'écran
6. Lancer la version

## Notes Importantes

- **Licence**: Tous les droits réservés
- **Langage**: Français / Créole Haïtien
- **Plateforme cible**: Android 7.0+
- **iOS support**: Futur développement
- **Dark mode**: À implémenter

## Documentation Supplémentaire

- README_BUILD.md - Architecture détaillée
- Cahier des charges: local_things/cc.md
- Conception technique: local_things/dct.md
- Wireframes: local_things/wireframe/

## Support & Contributions

Pour les bugs, suggestions ou contributions:
1. Vérifier les issues existantes
2. Poster une nouvelle issue avec reproduction steps
3. Proposer une PR avec les changes

---

**Kreyòl+ v1.0.0** - Application d'apprentissage du créole haïtien

