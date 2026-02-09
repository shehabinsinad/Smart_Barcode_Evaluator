# Smart Barcode Evaluator - Nutrition Analysis App

A Flutter mobile app that scans product barcodes and provides personalized health scores based on user profiles.

## 📋 Overview

Smart Barcode Evaluator helps users make informed food choices by analyzing nutritional information against their personal health profile (BMI, allergies, medical conditions).

## ✨ Features

- **Barcode Scanning** - Camera-based barcode detection using ML Kit
- **Nutritional Data Retrieval** - Integration with Open Food Facts API
- **Personalized Health Scoring** - Algorithm calculates 0-100 score based on user profile
- **Allergen Detection** - Automatic flagging of user-specific allergens
- **Scan History** - Firebase Firestore storage of past scans

## 🎯 How It Works

1. User scans product barcode with camera
2. App fetches nutritional data from Open Food Facts API
3. Health scoring algorithm analyzes:
   - Calories (baseline: 200kcal)
   - Sugar content (baseline: 10g)
   - Fat content (baseline: 15g)
   - Allergen matching
   - BMI-based penalties
4. Personalized score (0-100) displayed with color-coded rating
5. Scan saved to user's history in Firestore

## 🧮 Scoring Algorithm

**Base score:** 100

**Deductions:**
- **Allergens:** If product contains user's allergen → Score = 0 (immediate)
- **Calories:** -5 points per 50kcal above 200kcal
- **Sugar:** -2 points per 5g above 10g
- **Fat:** -3 points per 10g above recommended limit
- **BMI penalty:** 
  - Overweight (BMI > 25): -5 points
  - Underweight (BMI < 18.5): -3 points

**Example:**
```
Product: Chocolate bar (300 kcal, 20g sugar, 15g fat)
User: BMI 27 (overweight), no allergies

Calculation:
100 - 10 (calories) - 4 (sugar) - 0 (fat) - 5 (BMI) = 81/100
```

## 🛠️ Tech Stack

- **Frontend:** Flutter, Dart
- **Backend:** Firebase (Authentication, Firestore)
- **APIs:** Open Food Facts REST API
- **ML:** ML Kit Barcode Scanning
- **State Management:** Provider pattern

## 👥 Team Project - My Contribution

This was a **4-person mini-project**. I implemented:

- **Health scoring algorithm** (penalty calculations, BMI integration)
- **Firebase integration** (Authentication, Firestore database schema)
- **User profile management** (health data input, allergen selection)
- **Scan history feature** (Firestore queries, data persistence)

**Other modules** (barcode scanning UI, API integration, frontend design) were developed by teammates.

## 📂 Database Schema (Firestore)
```
users/
  └── {userId}/
      ├── name: string
      ├── email: string
      ├── height: number
      ├── weight: number
      ├── bmi: number
      ├── allergies: array
      ├── healthConditions: array
      └── scanHistory/
          └── {scanId}/
              ├── productName: string
              ├── barcode: string
              ├── nutritionalData: object
              ├── calculatedScore: number
              └── timestamp: timestamp
```

## 🚀 Setup Instructions

1. Clone the repository
```bash
git clone https://github.com/shehabinsinad/Smart_Barcode_Evaluator.git
cd Smart_Barcode_Evaluator
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Add Firebase configuration files
- Update `lib/firebase_options.dart`

4. Run the app
```bash
flutter run
```

## 📝 Learning Outcomes

- Designing and implementing custom algorithms
- Working with REST APIs and JSON parsing
- Firebase backend integration (Auth, Firestore)
- Mobile app state management
- Team collaboration using Git

## 📄 License

Mini-project developed at MES College of Engineering (2024).
