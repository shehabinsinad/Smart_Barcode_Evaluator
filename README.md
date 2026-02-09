# Food Scanner App

A sophisticated Flutter application that empowers users to make healthier food choices. By scanning product barcodes, users get instant access to detailed nutritional information and a personalized health score based on their dietary preferences.

## Features

-   **Smart Barcode Scanning**: Instantly scan food products using the device camera.
-   **Personalized Health Score**: clear, color-coded health score (0-100) calculated based on nutritional value and your specific dietary needs.
-   **Detailed Nutrition Facts**: comprehensive breakdown of calories, fats, carbs, proteins, and more.
-   **Dietary Preferences**: Set your preferences (Vegan, Gluten-Free, Keto, etc.) to get tailored alerts and scoring.
-   **History**: Keep track of all your scanned products for easy reference.
-   **Premium UI/UX**: A modern, clean, and animated interface with a focus on user experience.
-   **Authentication**: Secure login and signup powered by Firebase.

## Technology Stack

-   **Frontend**: Flutter (Dart)
-   **Backend/Auth**: Firebase (Auth, Firestore)
-   **Scanning**: `mobile_scanner`
-   **State Management**: `provider`
-   **UI Components**: `flutter_animate`, `lottie`, `shimmer`, `google_fonts`

## Getting Started

### Prerequisites

-   Flutter SDK installed (version >=3.0.0)
-   Dart SDK installed
-   Firebase project set up

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/shehabinsinad/food-scanner-app.git
    cd food-scanner-app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration:**
    -   Ensure you have your `firebase_options.dart` configured or placed in `lib/`.
    -   (Or follow the Firebase CLI setup if needed).

4.  **Run the app:**
    ```bash
    flutter run
    ```

## Usage

1.  **Sign Up/Login**: Create an account to save your preferences and history.
2.  **Set Preferences**: Choose your dietary goals and restrictions.
3.  **Scan**: Tap the scan button and point your camera at a food barcode.
4.  **View Results**: Analyze the health score and nutritional breakdown.

## Screenshots

*(Add your app screenshots here)*
