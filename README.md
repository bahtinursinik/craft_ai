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

```bash
# Run the full test suite
flutter test

# Check test coverage
flutter test --coverage
