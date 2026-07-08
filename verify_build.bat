@echo off
REM Script de vérification de compilation pour Kreyòl+
REM Vérifie que tous les pré-requis sont en place

echo ========================================
echo Kreyòl+ - Vérification de Compilation
echo ========================================
echo.

REM Vérifier Flutter
echo [1/6] Vérification de Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Flutter non trouvé. Veuillez installer Flutter.
    exit /b 1
) else (
    echo OK: Flutter trouvé
)
echo.

REM Vérifier Dart
echo [2/6] Vérification de Dart...
dart --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Dart non trouvé.
    exit /b 1
) else (
    echo OK: Dart trouvé
)
echo.

REM Vérifier pubspec.yaml
echo [3/6] Vérification de pubspec.yaml...
if not exist "pubspec.yaml" (
    echo ERREUR: pubspec.yaml non trouvé.
    exit /b 1
) else (
    echo OK: pubspec.yaml trouvé
)
echo.

REM Vérifier assets
echo [4/6] Vérification des assets...
if not exist "assets\data\lessons.json" (
    echo ERREUR: assets/data/lessons.json manquant
    exit /b 1
)
if not exist "assets\audios" (
    echo ERREUR: dossier assets/audios manquant
    exit /b 1
)
echo OK: Assets trouvés
echo.

REM Vérifier lib/main.dart
echo [5/6] Vérification de lib\main.dart...
if not exist "lib\main.dart" (
    echo ERREUR: lib/main.dart non trouvé
    exit /b 1
) else (
    echo OK: main.dart trouvé
)
echo.

REM Vérifier dépendances
echo [6/6] Téléchargement des dépendances...
call flutter pub get
if errorlevel 1 (
    echo ERREUR: Impossible de télécharger les dépendances
    exit /b 1
) else (
    echo OK: Dépendances installées
)
echo.

REM Analyse Dart
echo ========================================
echo Analyse du code Dart...
echo ========================================
call flutter analyze
echo.

echo ========================================
echo Vérification Terminée!
echo ========================================
echo.
echo Prochaines étapes:
echo 1. flutter build apk --debug     (pour tester)
echo 2. flutter run                   (pour exécuter)
echo 3. flutter test                  (pour tester unitairement)
echo.
echo Ou consultez QUICKSTART.md pour plus d'informations.
echo.

