# Paiement Facilite App

Application mobile Flutter de gestion de paiements échelonnés (clients, prestataires, échéanciers, mensualités, notifications, QR codes).

## 1. Description du projet

- Authentification par API (`/api/auth/login`, `/api/auth/register`).
- Gestion de clients, prestataires, échéanciers, mensualités, alertes push locales.
- Génération et affichage de QR code pour valider un paiement.
- Export PDF d’échéancier.
- Backend supposé disponible sur `http://10.0.2.2:8080/api` (émulateur Android) pour le dev local.

## 2. Architecture

- `lib/main.dart` : point d’entrée.
- `lib/core/constants/api_config.dart` : `ApiConfig.baseUrl` centralisée.
- `lib/services` : services réseau (API) et logique de données.
- `lib/models` : objets métier.
- `lib/screens` : interface utilisateur.

## 3. Prérequis

- Flutter SDK (version 3+ recommandé)
- Dart SDK inclus dans Flutter
- Android Studio (AVD) ou un téléphone Android/iOS
- (optionnel) Visual Studio Code ou IDE JetBrains

## 4. Installation

1. Cloner le repo :
   ```bash
   git clone[ <url-du-repo>](https://github.com/macherkiJawher/Taksit.git)
   cd paiement_facilite_app
   ```
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. Configurer l’URL backend :
   - `lib/core/constants/api_config.dart` existe avec :
     `static const String baseUrl = "http://10.0.2.2:8080/api";`
   - Pour vrai appareil Android : `http://<IP-machine>:8080/api`.
   - Pour iOS simulé : `http://localhost:8080/api` 

## 5. Exécution

### Avec émulateur Android Studio (zéro)

#### 5.1 Installer Android Studio + Flutter

1. Télécharger et installer Android Studio :
   - https://developer.android.com/studio
2. Pendant l’installation, cocher la case pour installer le SDK Android, les outils de ligne de commande et un émulateur (Android Virtual Device).
3. Installer Flutter :
   - https://docs.flutter.dev/get-started/install
4. Dans `Android Studio` > `Configure` > `SDK Manager` :
   - Vérifier que `Android SDK Platform 33` (ou version récente) est installé.
   - Installer `Android SDK Platform-Tools` et `Android SDK Build-Tools`.

#### 5.2 Configurer le plugin Flutter

1. Ouvrir Android Studio > `Plugins` > rechercher `Flutter`.
2. Installer `Flutter` + `Dart`.
3. Redémarrer Android Studio.

#### 5.3 Créer un émulateur Android (AVD)

1. Ouvrir `AVD Manager` (icône en haut à droite ou `Tools` > `Device Manager`).
2. `Create Virtual Device`.
3. Choisir un device (ex. Pixel 6) > `Next`.
4. Choisir une image système (API 33 ou 34) > `Download` si nécessaire > `Next`.
5. Configurer et `Finish`.
6. Démarrer l’émulateur via le bouton `Play` dans AVD Manager.

#### 5.4 Lancer l’app sur l’émulateur

1. Dans le terminal du projet :
   ```bash
   flutter doctor
   ```
   - Vérifier qu’il n’y a pas d’erreur critique.
   - `flutter doctor --android-licenses` et accepter si nécessaire.
2. Vérifier l’émulateur connecté :
   ```bash
   flutter devices
   ```
3. Lancer :
   ```bash
   flutter run
   ```

### Avec téléphone Android réel

1. Activer le mode développeur et débogage USB.
2. Connecter le téléphone au PC.
3. Vérifier l’appareil:
   ```bash
   flutter devices
   ```
4. Lancer l’app:
   ```bash
   flutter run
   ```

## 6. Commandes utiles

- `flutter clean`
- `flutter pub get`


## 7. Personnalisation backend

- `lib/services/*` utilisent souvent : `ApiConfig.baseUrl`.
- Les chemins sont construits comme :
  - `ApiConfig.baseUrl + '/clients'`
  - `ApiConfig.baseUrl + '/echeanciers'`
  - `ApiConfig.baseUrl + '/mensualites'`

## 8. Notes

- Si l’application se bloque sur une requête réseau : vérifier l’URL backend, le CORS (pour web) et le serveur en marche.
- Pour production, changer `ApiConfig.baseUrl` vers l’URL publique du backend.
