# Schéma de Base de Données - Kreyòl+

## Vue d'ensemble

La base de données SQLite de Kreyòl+ est créée automatiquement au premier lancement de l'application. Toutes les tables sont initialisées dans la méthode `_onCreate` de `DatabaseService`.

## Tables et Schéma

### 1. Tableau USERS
Stocke les identifiants d'utilisateurs et mots de passe hachés.

```sql
CREATE TABLE users (
    username TEXT PRIMARY KEY,
    passwordHash TEXT NOT NULL
);
```

**Colonnes**:
- `username` (TEXT, PRIMARY KEY): Identifiant unique de l'utilisateur
- `passwordHash` (TEXT, NOT NULL): SHA-256 du mot de passe

**Exemple**:
```
username     | passwordHash
-------------|------------------------------------
jean         | abc123def456...
marie        | xyz789uvw012...
```

---

### 2. Tableau LESSONS
Contient toumes les leçons de l'application.

```sql
CREATE TABLE lessons (
    id INTEGER PRIMARY KEY,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    audioPath TEXT NOT NULL,
    orderNum INTEGER NOT NULL
);
```

**Colonnes**:
- `id` (INTEGER, PRIMARY KEY): Identifiant unique de la leçon
- `category` (TEXT, NOT NULL): Catégorie (Vocabulaire, Expression, Phrase courante, Grammaire)
- `title` (TEXT, NOT NULL): Titre de la leçon
- `content` (TEXT, NOT NULL): Contenu textuel
- `audioPath` (TEXT, NOT NULL): Chemin relatif au fichier audio
- `orderNum` (INTEGER, NOT NULL): Ordre d'affichage dans la catégorie

**Exemple**:
```
id | category    | title      | content  | audioPath              | orderNum
---|-------------|------------|----------|--------|-----------|-----|
1  | Vocabulaire | Bonjour    | Bonjou   | audio/vocabulaire/bonjou.mp3 | 1
2  | Vocabulaire | Merci      | Mèsi     | audio/vocabulaire/mesi.mp3   | 2
11 | Expression  | Lave men...| C'est... | audio/expression/lave_men... | 1
```

**Total**: 40 leçons (10 par catégorie)

---

### 3. Tableau QUESTIONS
Stocke les questions de quiz.

```sql
CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    type TEXT NOT NULL,
    category TEXT NOT NULL,
    lessonId INTEGER NOT NULL,
    text TEXT NOT NULL,
    audioPath TEXT,
    options TEXT NOT NULL,
    correctIndex INTEGER NOT NULL,
    FOREIGN KEY(lessonId) REFERENCES lessons(id)
);
```

**Colonnes**:
- `id` (INTEGER, PRIMARY KEY): Identifiant unique
- `type` (TEXT, NOT NULL): Type de quiz ('textuel' ou 'oral')
- `category` (TEXT, NOT NULL): Catégorie
- `lessonId` (INTEGER, NOT NULL): Référence à la leçon associée
- `text` (TEXT, NOT NULL): Énoncé de la question
- `audioPath` (TEXT, NULLABLE): Chemin audio (pour quiz oral)
- `options` (TEXT, NOT NULL): JSON array des options
- `correctIndex` (INTEGER, NOT NULL): Index de la réponse correcte

**Format options**:
Les options sont stockées en JSON encodé:
```
["Option 1", "Option 2", "Option 3", "Option 4"]
```

**Exemple**:
```
id | type    | category    | lessonId | text           | audioPath | options                    | correctIndex
---|---------|-------------|----------|----------------|-----------|-----|--
1  | textuel | Vocabulaire | 2        | Comment dit... | NULL      | ["Mèsi","Wi","Dlo","Kay"] | 0
17 | oral    | Vocabulaire | 1        | Écoutez...     | audio/... | ["Bonjour","Merci","Oui","Eau"] | 0
```

**Total**: 32 questions (16 textuelles + 16 orales)

---

### 4. Tableau USER_PROGRESS
Suit la progression de chaque utilisateur.

```sql
CREATE TABLE user_progress (
    username TEXT NOT NULL,
    lessonId INTEGER NOT NULL,
    completed INTEGER NOT NULL,
    score INTEGER NOT NULL DEFAULT 0,
    completedAt TEXT,
    PRIMARY KEY(username, lessonId),
    FOREIGN KEY(username) REFERENCES users(username),
    FOREIGN KEY(lessonId) REFERENCES lessons(id)
);
```

**Colonnes**:
- `username` (TEXT, NOT NULL): Utilisateur associé
- `lessonId` (INTEGER, NOT NULL): Leçon complétée
- `completed` (INTEGER, NOT NULL): 1 = complétée, 0 = non complétée
- `score` (INTEGER, DEFAULT 0): Points obtenus au quiz
- `completedAt` (TEXT, NULLABLE): Timestamp ISO8601 de complétude

**Clé Primaire Composite**: (username, lessonId)

**Exemple**:
```
username | lessonId | completed | score | completedAt
---------|----------|-----------|-------|------------------
jean     | 1        | 1         | 80    | 2026-07-07T10:15:00.000
jean     | 2        | 1         | 90    | 2026-07-07T10:30:00.000
marie    | 1        | 0         | 0     | NULL
```

---

### 5. Tableau BADGES
Définit les badges disponibles dans l'application.

```sql
CREATE TABLE badges (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    iconPath TEXT NOT NULL,
    unlockCondition INTEGER NOT NULL
);
```

**Colonnes**:
- `id` (INTEGER, PRIMARY KEY): Identifiant du badge
- `title` (TEXT, NOT NULL): Nom du badge
- `description` (TEXT, NOT NULL): Description
- `iconPath` (TEXT, NOT NULL): Chemin à l'icône (actuellement vide)
- `unlockCondition` (INTEGER, NOT NULL): Nombre de leçons pour débloquer

**Badges prédéfinis**:
```
id | title              | description                    | iconPath | unlockCondition
---|--------------------|------------------------------------|----------|----
1  | Première leçon     | Complétez votre première leçon | (empty)  | 1
2  | Persévérant        | Complétez 5 leçons             | (empty)  | 5
3  | Constant           | Complétez 10 leçons            | (empty)  | 10
4  | Maître de kreyòl   | Complétez toutes les leçons    | (empty)  | 40
```

**Total**: 4 badges

---

### 6. Tableau USER_BADGES
Suit l'état de déblocage des badges pour chaque utilisateur.

```sql
CREATE TABLE user_badges (
    username TEXT NOT NULL,
    badgeId INTEGER NOT NULL,
    isUnlocked INTEGER NOT NULL,
    unlockedAt TEXT,
    PRIMARY KEY(username, badgeId),
    FOREIGN KEY(username) REFERENCES users(username),
    FOREIGN KEY(badgeId) REFERENCES badges(id)
);
```

**Colonnes**:
- `username` (TEXT, NOT NULL): Utilisateur
- `badgeId` (INTEGER, NOT NULL): Badge
- `isUnlocked` (INTEGER, NOT NULL): 1 = débloqué, 0 = verrouillé
- `unlockedAt` (TEXT, NULLABLE): Timestamp ISO8601 du déblocage

**Clé Primaire Composite**: (username, badgeId)

**Exemple**:
```
username | badgeId | isUnlocked | unlockedAt
---------|---------|-----------|------------------
jean     | 1       | 1         | 2026-07-07T10:15:00.000
jean     | 2       | 1         | 2026-07-07T11:30:00.000
jean     | 3       | 0         | NULL
marie    | 1       | 0         | NULL
```

---

## Flux de Données

### Initialisation de la Base de Données

1. **Création des tables** (première exécution)
   ```
   → users
   → lessons
   → questions
   → user_progress
   → badges
   → user_badges
   ```

2. **Charge des données initiales** (depuis JSON)
   ```
   → Lessons.json → table lessons (40 lignes)
   → Quiz-textuel.json → table questions (16 lignes)
   → Quiz-oral.json → table questions (16 lignes)
   → Création des 4 badges par défaut → table badges
   ```

### Flux d'Utilisation

1. **Inscription**
   ```
   User → AuthProvider.signup() → DatabaseService.createUser()
   → INSERT INTO users VALUES (username, passwordHash)
   ```

2. **Connexion**
   ```
   User → AuthProvider.login() → DatabaseService.getUser()
   → SELECT ... FROM users WHERE username = ?
   ```

3. **Complétude de Leçon**
   ```
   User complète leçon → ProgressProvider.completeLesson()
   → DatabaseService.saveProgress()
   → INSERT/UPDATE user_progress
   → Vérifier déblocage badges
   → INSERT/UPDATE user_badges si conditions remplies
   ```

4. **Récupération de Progression**
   ```
   View demande progression → ProgressProvider.loadUserProgress()
   → DatabaseService.getUserProgress()
   → SELECT * FROM user_progress WHERE username = ?
   → SELECT COUNT WHERE completed = 1
   → SELECT SUM(score)
   ```

---

## Requêtes Principales

### Authentification
```sql
-- Vérifier l'existence d'un utilisateur
SELECT * FROM users WHERE username = ?

-- Créer un utilisateur
INSERT INTO users VALUES (?, ?)
```

### Leçons
```sql
-- Obtenir toutes les leçons
SELECT * FROM lessons ORDER BY orderNum

-- Obtenir leçons par catégorie
SELECT * FROM lessons WHERE category = ? ORDER BY orderNum

-- Obtenir une leçon
SELECT * FROM lessons WHERE id = ?
```

### Questions
```sql
-- Obtenir questions pour une leçon
SELECT * FROM questions WHERE lessonId = ?

-- Obtenir questions par type
SELECT * FROM questions WHERE type = ?
```

### Progression
```sql
-- Obtenir toute la progression d'un utilisateur
SELECT * FROM user_progress WHERE username = ?

-- Obtenir progression pour une leçon
SELECT * FROM user_progress WHERE username = ? AND lessonId = ?

-- Compter leçons complétées
SELECT COUNT(*) FROM user_progress WHERE username = ? AND completed = 1

-- Total des points
SELECT SUM(score) FROM user_progress WHERE username = ?
```

### Badges
```sql
-- Obtenir tous les badges
SELECT * FROM badges

-- Vérifier badge débloqué
SELECT * FROM user_badges WHERE username = ? AND badgeId = ? AND isUnlocked = 1

-- Obtenir badges débloqués
SELECT b.* FROM badges b
INNER JOIN user_badges ub ON b.id = ub.badgeId
WHERE ub.username = ? AND ub.isUnlocked = 1
```

---

## Données Initiales Chargées

### Depuis lessons.json (40 leçons)
- Vocabulaire (id 1-10): Bonjou, Mèsi, Souple, Wi, Non, Dlo, Kay, Manje, Zanmi, Timoun
- Expression (id 11-20): Proverbes créoles
- Phrase courante (id 21-30): Expressions usuelles
- Grammaire (id 31-40): Règles grammaticales

### Depuis quiz-textuel.json (16 questions)
- Questions à choix multiples sans audio
- Réponses textuelles uniquement

### Depuis quiz-oral.json (16 questions)
- Questions avec fichiers audio
- Options à sélectionner après écoute

---

## Optimisations & Indexes

### Index Actuels
- PRIMARY KEY sur chaque table (implicite)
- FOREIGN KEYS pour intégrité referentielle

### Index Recommandés pour Amélioration Future
```sql
CREATE INDEX idx_lessons_category ON lessons(category);
CREATE INDEX idx_user_progress_username ON user_progress(username);
CREATE INDEX idx_questions_lessonId ON questions(lessonId);
CREATE INDEX idx_user_badges_username ON user_badges(username);
```

---

## Limitations et Considérations

1. **Taille de la base**: Environ 1-2 MB pour données initiales
2. **Performances**: Optimisée pour petit nombre d'utilisateurs concurrents
3. **Offline-first**: Pas de synchronisation distance, données locales uniquement
4. **Migration**: Pas de versioning de schéma (version 1 uniquement)

---

## Sauvegarde et Restauration

### Emplacement de la Base de Données
- **Android**: `/data/data/com.kreyolplus/databases/kreyol_plus.db`
- **Accès via Device File Explorer** dans Android Studio

### Export de Données
```bash
# Via adb
adb pull /data/data/com.kreyolplus/databases/kreyol_plus.db

# La base peut être ouverte avec SQLite Browser
```

---

## Sécurité

- **Mots de passe**: SHA-256 hachés, jamais stockés en clair
- **Données de progress**: Locales à l'appareil
- **Aucun PII**: Pas d'informations personnelles sensibles
- **SQLite Encryption**: À implémenter pour versions futures

---

## Documentation Supplémentaire

Pour plus de détails sur l'accès à la base de données, voir:
- `lib/services/database_service.dart` - Implémentation SQLite
- `lib/models/` - Modèles de données
- `lib/providers/progress_provider.dart` - Logique de progression

---

**Dernière mise à jour**: 7 juillet 2026
**Version de l'app**: 1.0.0
**Schéma BD**: v1.0

