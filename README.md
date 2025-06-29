# vPay: Versatile Payment & Earn-Now Platform

## Overview/Vision

vPay aims to create a mobile-first ecosystem connecting users (primarily students) with hyperlocal micro-tasks and short-term job opportunities. The platform focuses on seamless peer-to-peer payments and community engagement. It addresses fragmentation in micro-task marketplaces, complex payment flows, and inefficient task discovery.

[For comprehensive project details, see the original detailed documentation](./docs/project_details.md).

## Table of Contents

* [Core Features](#core-features)
* [Tech Stack](#tech-stack)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Cloning](#cloning)
  * [Environment Variables](#environment-variables)
  * [Dependencies](#dependencies)
* [Building the Project](#building-the-project)
  * [Android](#android)
  * [iOS](#ios)
  * [Web](#web)
* [Running Tests](#running-tests)
* [Project Structure](#project-structure)
* [Platform Support](#platform-support)
* [UI/UX](#uiux)
* [Future Roadmap](#future-roadmap)
* [Further Documentation](#further-documentation)
* [Contributing](#contributing)
* [License](#license)

## Core Features

vPay offers a rich set of features to facilitate micro-task management and payments, including:

* User Account Management with achievements and personalization.
* Robust Authentication: Email/password, social login UI, biometric auth.
* Task Management: Creation, discovery, filtering, real-time updates.
* Integrated Payments (currently UPI-based) and chat.
* Notification system and User Profiles.

[For a detailed breakdown of all features, implemented and planned, see our Features Overview](./docs/features_overview.md).

## Tech Stack

vPay is built with a modern, scalable tech stack:

* **Primary Framework:** Flutter (Dart) for cross-platform UI.
* **Backend:** Supabase for database, authentication, and real-time features.
* **State Management:** Flutter Riverpod for reactive and testable state.

[Read more about our Technical Architecture](./docs/technical_architecture.md).

## Getting Started

### Prerequisites

* Flutter SDK (version constraint: `>=3.0.0 <4.0.0`). Download from [flutter.dev](https://flutter.dev).
* An IDE like Android Studio or VS Code with Flutter & Dart plugins.
* Platform-specific build tools (Android SDK/NDK, Xcode for iOS, etc., depending on your target platforms).

### Cloning

```bash
git clone https://github.com/joker0210G/vPay.git
cd vpay
```

### Environment Variables

This project uses a `.env` file for managing environment-specific configurations such as API keys for backend services.

1. In the root of the project, copy the example file: `cp .env.example .env`
2. Open the newly created `.env` file and populate it with your actual Supabase URL, Supabase Anon Key, and any other required Firebase configuration details.

### Dependencies

Fetch the project dependencies by running the following command in the project root:

```bash
flutter pub get
```

## Building the Project

### Android

To build an APK for release:

```bash
flutter build apk --release
```

To build an App Bundle for release (recommended for Google Play Store):

```bash
flutter build appbundle --release
```

### iOS

To build an iOS application for release (requires a macOS environment with Xcode configured):

```bash
flutter build ios --release
```

### Web

To build the web application:

```bash
flutter build web
```

The output will be in the `build/web` directory.

## Running Tests

To run the available automated tests (unit, widget tests):

```bash
flutter test
```

## Project Structure

The project follows a feature-first architecture, organizing code by features (e.g., auth, tasks) within `lib/features/`. Shared utilities, models, and configurations are located in `lib/shared/`. Supabase client initialization is in `lib/shared/config/supabase_config.dart`.

[Learn about our Development Operations, version control, and coding practices.](./docs/development_operations.md)

## Platform Support

vPay is a cross-platform application built with Flutter, supporting mobile (Android, iOS), Web, and desktop environments (Windows, macOS, Linux).

[See Detailed Platform Specifics and Configuration](./docs/platform_specifics.md).

## UI/UX

The app utilizes Material Design 3 principles, featuring custom light and dark themes. Key fonts include Poppins and Righteous.

[View our complete UI/UX Guide and Color Palette](./docs/ui_ux_guide.md
).

## Future Roadmap

We have an extensive list of planned features and improvements, including advanced payment options, enhanced task management, AI-powered functionalities, and broader community features.

[Explore the full Future Roadmap in our Features Overview document](./docs/features_overview.md#future-roadmap-post-mvp-and-long-term-vision).

## Further Documentation

For more in-depth information, please explore the following documents within the `./docs` folder:

* `project_details`: The original comprehensive project documentation.
* `technical_architecture`: Detailed breakdown of the architecture and stack.
* `features_overview`: Complete list of implemented, planned, and future features.
* `platform_specifics`: Information on configurations for each supported platform.
* `ui_ux_guide`: Design principles, theming, fonts, and color palette.
* `development_operations`: Version control, testing, CI/CD, and deployment practices.

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](./CONTRIBUTING.md) for more information on how to get involved.

## License

This project is licensed under the Apache License Version 2.0. See the [LICENSE](./LICENSE.md) file for details.
