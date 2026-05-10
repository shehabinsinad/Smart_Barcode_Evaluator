# 🍱 Smart Barcode Evaluator

> A Flutter mobile app that scans food product barcodes and gives you a **personalised health score** based on your body metrics, allergies, and medical conditions.

---

## 📸 Screenshots

> **Add screenshots here.** Recommended images to include:
> 1. **Landing / Login screen** — shows the app's branding
> 2. **Scanner screen** — camera view with the barcode overlay
> 3. **Results screen** — the animated score gauge + nutrition breakdown
> 4. **Scan History screen** — the list of past scans with colour-coded scores
> 5. **Profile / Preferences screen** — where the user sets height, weight, allergies, conditions
>
> Place them in `assets/screenshots/` and link them like:
> ```md
> ![Results Screen](assets/screenshots/results.png)
> ```

---

## ✨ Features

| Feature | Description |
|---|---|
| 📷 **Barcode Scanner** | Camera-based scanning powered by Google ML Kit |
| 🌐 **Nutrition Lookup** | Pulls live data from the Open Food Facts API |
| 🧮 **Health Score** | Personalised 0–100 score calculated per user profile |
| ⚠️ **Allergen Alerts** | Instant warning if a product matches a user allergen |
| 📜 **Scan History** | All scans stored in Firestore with swipe-to-delete + Undo |
| 👤 **User Profiles** | Height, weight, BMI, allergies, health conditions |
| 🌙 **Dark / Light Mode** | System-aware theme with manual toggle |
| 🔐 **Firebase Auth** | Email/password sign-up and sign-in with friendly error messages |

---

## 🧮 Scoring Algorithm

The score starts at **100** and deductions are applied based on the product's nutritional content and the user's profile.

| Factor | Condition | Penalty |
|---|---|---|
| 🚨 Allergen | Product contains a user allergen | Score → **0** immediately |
| 🔥 Calories | Every 50 kcal above 200 kcal/100g | −5 pts |
| 🍬 Sugar | Every 5 g above 10 g/100g | −3 pts |
| ⚖️ BMI (overweight > 25) | — | −5 pts |
| ⚖️ BMI (underweight < 18.5) | — | −3 pts |
| 🥩 Low protein + high carbs | Protein < 10 g **and** carbs > 30 g | −3 pts |
| 🩺 Diabetes | Sugar > 15 g/100g | −10 pts |
| 🩺 Hypertension | Fat > 10 g/100g | −5 pts |

**Score bands:**

| Score | Rating | Color |
|---|---|---|
| 71 – 100 | Excellent | 🟢 Green |
| 61 – 70 | Good | 🟢 Light green |
| 41 – 60 | Fair | 🟡 Amber |
| 31 – 40 | Poor | 🟠 Orange |
| 0 – 30 | Bad | 🔴 Red |

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3 / Dart
- **Backend:** Firebase Authentication + Cloud Firestore
- **Nutrition API:** [Open Food Facts](https://world.openfoodfacts.org/) (free, no key required)
- **Barcode Scanning:** Google ML Kit (`google_mlkit_barcode_scanning`)
- **State Management:** Provider
- **Animations:** `flutter_animate`
- **Other packages:** `share_plus`, `mobile_scanner`

---

## 📂 Project Structure

```
lib/
├── components/         # Reusable UI widgets (ScoreGauge, CustomCard, …)
├── constants/          # Shared scoring thresholds (HealthScoringConstants)
├── providers/          # ThemeProvider (dark/light mode)
├── screens/            # All app screens
├── services/           # Firebase & API service layer
│   ├── auth_service.dart
│   ├── health_scoring_service.dart
│   ├── history_service.dart
│   ├── product_service.dart
│   └── user_service.dart
├── theme/              # AppColors, AppTheme
└── utils/              # ValidationHelper, PageTransitions
```

---

## 🗄️ Firestore Schema

```
users/
  └── {userId}/
        ├── name            : string
        ├── email           : string
        ├── height          : string   (cm)
        ├── weight          : string   (kg)
        ├── allergies       : string   (comma-separated)
        ├── conditions      : string   (comma-separated)
        └── scanHistory/
              └── {scanId}/
                    ├── productName : string
                    ├── healthScore : number
                    ├── calories    : number
                    ├── protein     : number
                    ├── carbs       : number
                    ├── fat         : number
                    ├── sugars      : number
                    ├── allergens   : string
                    └── timestamp   : string (ISO-8601)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.x installed
- Android Studio / VS Code with Flutter plugin
- A Firebase project (free Spark plan is sufficient)

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/shehabinsinad/Smart_Barcode_Evaluator.git
cd Smart_Barcode_Evaluator
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase**

This repo intentionally excludes Firebase config files. You need to generate your own:

```bash
# Install FlutterFire CLI if you haven't already
dart pub global activate flutterfire_cli

# Connect to your Firebase project
flutterfire configure
```

This will generate:
- `lib/firebase_options.dart`
- `android/app/google-services.json`

Use `lib/firebase_options_example.dart` as a reference for the expected structure.

**4. Enable Firebase services**

In the [Firebase Console](https://console.firebase.google.com/):
- Enable **Authentication** → Email/Password
- Enable **Cloud Firestore** (start in test mode, then apply security rules)

**5. Run the app**
```bash
flutter run
```

---

## 🔒 Security

The following files contain credentials and are **excluded from version control** via `.gitignore`:

| File | Reason |
|---|---|
| `lib/firebase_options.dart` | Contains Firebase API key |
| `android/app/google-services.json` | Contains Firebase project credentials |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase credentials |
| `android/local.properties` | Local SDK paths |
| `.env` / `.env.*` | Any future environment variables |

> **Note:** The Open Food Facts API is completely free and requires no API key.

---

## 👥 Team

Mini-project developed at **MES College of Engineering** (2024) as part of the B.Tech curriculum.

**Modules I built:**
- Health scoring algorithm and all penalty logic
- Firebase Authentication integration + friendly error handling
- User profile management (health metrics, allergen selection)
- Scan history (Firestore persistence, swipe-to-delete, undo)
- Dark/light theme system
- Full UI polish (score gauge, custom snackbar, animations)

---

## 📄 License

Academic mini-project. No commercial use intended.
