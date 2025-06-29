# Development & Operations Guide

This document outlines key aspects of the development lifecycle for the vPay project, including version control, code quality standards, dependency management, testing strategies, CI/CD practices, deployment procedures, and environment configuration.

## Version Control

* **System:** Git is the standard version control system.
* **Branching Strategy:** A branching strategy such as GitFlow (with `main`, `develop`, and feature branches) is recommended and likely followed.
  * `main`: Stable releases.
  * `develop`: Integration branch for upcoming release features.
  * `feature/*`: Individual branches for new features or bug fixes.
  * Hotfix and release branches as needed.

## Code Quality & Linting

* **Static Analysis:** The `flutter_lints` package is used for static analysis to enforce code style and identify potential issues.
* **Configuration:** Linting rules are configured in the `analysis_options.yaml` file at the project root. Adherence to these rules helps maintain code consistency and quality.

## Dependency Management

* **File:** All project dependencies (Flutter packages) are managed via the `pubspec.yaml` file.
* **Fetching Dependencies:** Use `flutter pub get` to fetch or update dependencies.
* **Key Libraries:** Refer to `pubspec.yaml` for a complete list. The original project documentation also listed key libraries relevant at that time.

## Testing Strategies

The project outlines a multi-faceted testing approach:

* **Flutter Testing (Client-Side):**
  * **Unit Tests:** For testing individual functions, methods, or classes (e.g., business logic in providers, utility functions).
  * **Widget Tests:** For testing individual Flutter widgets in isolation, verifying UI rendering and interaction.
  * **Integration Tests:** For testing complete features or user flows, running on a device or emulator.
* **Backend Testing:**
  * If custom backend logic exists (e.g., Supabase Edge Functions written in TypeScript/JavaScript), testing frameworks like Jest or Supertest would be applicable.
  * For Python-based backend components (if any), Pytest would be suitable.
* **API Testing:**
  * Tools like Postman are recommended for testing API endpoints, especially during development and integration phases.
* **Physical Device Testing:**
  * Services like Firebase Test Lab were mentioned as potential options for testing on a wide range of physical devices.
* **Test Files:**
  * Basic test files were noted for iOS (`RunnerTests.swift`) and macOS (`RunnerTests.swift`) in the native runner projects, likely for testing native plugin integrations or app setup. Flutter tests are primarily located in the `test/` directory of the project.

## Continuous Integration & Continuous Deployment (CI/CD)

* **Potential Tools:** GitHub Actions and Codemagic were mentioned as CI/CD tools that could be used for automating builds, tests, and deployments.
* **Setup:** Specific CI/CD pipeline configurations would reside in files like `.github/workflows/main.yml` for GitHub Actions or `codemagic.yaml` for Codemagic.

## Deployment

* **Mobile:** Standard procedures for deploying to the Apple App Store (for iOS) and Google Play Store (for Android) are outlined in Flutter and platform-specific documentation. This includes building release versions, managing signing certificates, and adhering to store guidelines.
* **Web:** Deploying the web build involves hosting the static files generated in the `build/web` directory on a web server or hosting platform.
* **Desktop:** Desktop deployment involves creating installers or packages appropriate for each operating system (Windows, macOS, Linux).

## Environment Configuration

* Sensitive information like API keys (Supabase URL/Key, Firebase config) should be managed via environment variables, typically using a `.env` file that is not committed to version control.
* A `.env.example` file should be provided as a template.

This guide serves as a reference for maintaining consistent development practices and operational stability.
