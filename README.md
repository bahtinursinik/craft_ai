# Craft AI 🧠✨

**Craft AI** is a cross-platform mobile application that leverages **Generative AI** to transform available resources into personalized actionable plans. Whether it's ingredients in a fridge or fitness equipment in a room, the app uses **Google Gemini 2.0 Flash** to craft the perfect recipe or workout routine.

> **Technical Showcase:** This project demonstrates **production-grade Flutter engineering**, focusing on Scalability, Maintainability, and Clean Architecture.

---

## 🏗️ Technical Architecture & Design Decisions

This project is built on strict software engineering principles, moving beyond simple state management to a robust, testable architecture.

### 1. Clean Architecture + MVVM
The codebase is structured to enforce **Separation of Concerns**:
* **Presentation Layer (MVVM):** `ViewModels` manage state and business logic, completely decoupled from the UI (`Views`). This ensures the UI is "dumb" and purely reactive.
* **Domain Layer:** Contains abstract definitions (Interfaces) to ensure the business logic doesn't depend on specific external libraries.
* **Data Layer:** Handles API calls (Firebase Vertex AI) and data transformations (Models), hidden behind Repository implementations.

### 2. Dependency Injection (DI)
Instead of tight coupling, the project uses **GetIt** as a Service Locator.
* **Why?** It allows for swapping real services with mock implementations during testing and creates a singleton management system for expensive resources like `GeminiService` and `AuthService`.

### 3. AI Engineering (Prompt Engineering)
Integration with **Firebase Vertex AI (Gemini 2.0)** goes beyond simple API calls:
* **Context-Aware System Prompts:** Dynamic prompt generation based on user locale (TR/EN) and selected mode (Fitness/Food).
* **JSON Enforcement:** Strict instructions to force the AI to return structured JSON data, ensuring type safety in the Dart layer.
* **Multimodal Input:** Handles both text descriptions and raw image bytes (Uint8List) for visual analysis.

---

## 🎨 UI/UX Engineering

This project avoids "Magic Numbers" and hardcoded styles, implementing a reusable Design System.

* **Centralized Dimension System (`AppDimens`):**
    * All padding, margins, radius, and gaps are defined in a static `AppDimens` class (e.g., `AppDimens.p16`, `AppDimens.gapH24`).
    * *Benefit:* Ensures pixel-perfect consistency across screens and allows for global design updates from a single file.
* **Atomic Widget Design:**
    * UI components like `CleanCard`, `CustomButton`, and `CustomTextField` are built as reusable atoms.
    * *Benefit:* Reduces code duplication and centralizes styling logic.
* **Glassmorphism & Advanced Animations:**
    * Uses `BackdropFilter` with `ImageFilter.blur` for modern visual depth.
    * Implements `AnimationController` for continuous state-aware animations (e.g., "Breathing" loading icons).
* **Skeleton Loading:**
    * Utilizes `skeletonizer` to provide a perceived performance boost, mimicking the actual layout structure during asynchronous data fetching.

---

## 🧪 Testing Strategy

The project maintains a high standard of reliability through a multi-layered testing approach using `flutter_test` and `mocktail`.

* **Unit Tests:** comprehensive coverage for `ViewModels`, `Repositories`, and `Models`.
    * *Focus:* Verifying business logic, JSON parsing, and error handling.
* **Widget Tests:** Verifies that reusable components render correctly and respond to user interactions.
* **Mocking:** External dependencies (Firebase Auth, Vertex AI) are mocked to ensure tests are fast, deterministic, and runnable offline.
🌍 Localization (L10n)
The app is fully localized for English (en) and Turkish (tr).

Dynamic Locale Handling: The app automatically detects the system locale or respects user preference.

AI Localization: The languageCode is passed directly to the AI Service prompt context. This ensures that Gemini generates content (recipes/workouts) in the same language as the UI, providing a seamless experience.

## 🛠️ Tech Stack
Framework: Flutter (Dart)

State Management: Provider

AI Model: Google Gemini 2.0 Flash (via firebase_vertexai)

Authentication: Firebase Auth

Architecture: MVVM, Clean Architecture, Repository Pattern

DI: GetIt

Testing: Mocktail, Flutter Test

Utilities: Skeletonizer, Flutter Gen, Equatable

📸 Project Showcase


<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/b0f8abf8-7994-4010-a258-f8af4731869a" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/8aa4fd20-ba65-4e19-a87f-4b22ce5e34b2" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/695e22e0-7c09-466e-bb08-c98a18285b5a" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/87012077-9de9-40a8-b19e-8f139555d08e" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/4f530b29-6d93-43b1-91ab-d256de9ef368" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/963f949f-0ab2-482c-bba6-c4a6244bd1e6" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/35e9011a-826e-4412-bfdd-cfb5a6757049" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/b8ae31e1-f102-4d69-b851-8aec4dd14e1e" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/6f1866d2-9e2a-46f9-a4e6-1fa570fd049b" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/22fccf70-b862-4129-979f-f05ef676cee7" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/f4317ff6-c743-4643-883c-d87bd7689b7c" />
<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/ca24aca1-3016-47e4-bfe9-2ddae53fce0d" />

```bash
# Run the full test suite
flutter test

# Check test coverage
flutter test --coverage


