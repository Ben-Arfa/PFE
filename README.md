# KIWO

Plateforme Flutter pour la gestion d'elevage avicole.

Fonctionnalites principales:
- Authentification Firebase (email/mot de passe)
- Gestion des roles (admin et utilisateur)
- Gestion metier de l'elevage (types, batiments, lots, suivi quotidien)
- Tableau de bord et administration
- Theme clair/sombre persistant

## Stack technique

- Flutter (Dart)
- Firebase Core
- Firebase Auth
- Cloud Firestore
- GoRouter
- Architecture par fonctionnalites avec couches data/domain/presentation

## Structure du projet

- lib/main.dart: point d'entree, initialisation Firebase et theme
- lib/app: bootstrap applicatif et DI
- lib/features/auth: authentification et profil
- lib/features/admin: operations d'administration
- lib/features/farm_management: gestion metier de l'elevage
- lib/features/home: ecran principal utilisateur
- firestore.rules: regles de securite Firestore

## Prerequis

- Flutter SDK >= 3.24.0
- Dart SDK >= 3.9.2
- Projet Firebase configure

## Installation

1. Installer les dependances:

```bash
flutter pub get
```

2. Verifier la configuration Firebase:
- android/app/google-services.json
- lib/firebase_options.dart

3. Lancer l'application:

```bash
flutter run
```

## Qualite et validation

Lancer l'analyse statique:

```bash
flutter analyze
```

Lancer les tests:

```bash
flutter test
```

## Regles Firestore

Les regles sont dans firestore.rules et couvrent:
- Acces proprietaire/admin aux donnees utilisateur
- Gestion securisee des profils
- Acces aux collections metier (config, types, batiments, lots, suivi)

Pour deployer les regles:

```bash
firebase deploy --only firestore:rules
```

## Notes

- Le projet contient des dependances preparees pour Riverpod, mais l'etat principal est encore gere via services/use cases/singletons.
- Le module farm_management est fonctionnel mais volumineux; un refactoring en sous-ecrans/widgets est recommande.
