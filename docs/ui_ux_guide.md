# UI/UX Design Guide

This document outlines the User Interface (UI) and User Experience (UX) design principles, theming strategy, styling conventions, and the specific color palette adopted for the vPay application.

## Design Philosophy

* **Simplicity:** Clean, uncluttered interfaces with a focus on core task flows to minimize cognitive load.
* **Mobile-First:** Designed and optimized primarily for mobile experiences (iOS and Android).
* **Intuitive Navigation:** Easy switching between posting/finding tasks, profiles, active jobs, and other key sections.
* **Transparency:** Clearly display important information like task prices, locations, and platform fees.
* **Streamlined Flows:** Straightforward processes for posting, accepting, completing, and approving tasks, including clear, integrated payment steps.
* **Location Prominence:** Location is a central element in task discovery and posting.

## Design System & Theming

* **Framework:** Material Design 3.
  * Indicated by `uses-material-design: true` in `pubspec.yaml`.
  * `ThemeData(useMaterial3: true)` is likely used in `lib/shared/theme/app_theme.dart`.
* **Cupertino Styling:** Cupertino widgets (for iOS-style elements) were mentioned as an option for platform-specific adaptation on iOS, though Material Design is the primary system.
* **Custom Themes:**
  * Light and Dark themes are defined in `lib/shared/theme/app_theme.dart`.
  * Theme colors are sourced from `lib/shared/theme/app_colors.dart`.
  * The application supports system theme mode (adapting to the OS's light/dark setting).

## Fonts

* Custom fonts are configured in `pubspec.yaml` and used throughout the application:
  * **Poppins:** Used for general text, with various weights (Regular, Medium, SemiBold, Bold).
    * `assets/fonts/Poppins-Regular.ttf`
    * `assets/fonts/Poppins-Medium.ttf`
    * `assets/fonts/Poppins-SemiBold.ttf`
    * `assets/fonts/Poppins-Bold.ttf`
  * **Righteous:** Used for specific display elements or branding accents.
    * `assets/fonts/Righteous-Regular.ttf`

## Key UI Packages & Components

* **`cached_network_image`:** For efficient loading and caching of network images (e.g., user avatars, task images).
* **`shimmer`:** Used to display loading state indicators, providing a better user experience while data is being fetched.
* **`flutter_chat_ui`:** Provides a pre-built set of widgets and utilities for creating the chat/messaging interface.
* **`lottie` & `flutter_animate`:** Used for incorporating rich animations (e.g., achievement unlocks, loading sequences).

## Responsive Design

* Planning documents indicated the use of `MediaQuery`, `LayoutBuilder`, and potentially `flutter_screenutil` to ensure the application adapts to various screen sizes and orientations effectively.

## Color Palette

### Primary Brand Colors

* **Primary:** `#001C3C` (Deep Blue)
* **Primary Dark:** `#001428` (Darker Deep Blue)
* **Primary Light:** `#002B5C` (Lighter Deep Blue)

### Secondary Brand Colors

* **Secondary:** `#50EDFE` (Bright Cyan)
* **Secondary Dark:** `#00D6E9` (Darker Cyan)
* **Secondary Light:** `#7FF4FF` (Lighter Cyan)

### Accent Colors

* **Accent:** `#2F89FC` (Bright Blue)
* **Accent Dark:** `#1877F2` (Darker Bright Blue)
* **Link Blue:** `#2F89FC` (Same as Accent, for hyperlinks)

### Status Colors

* **Success:** `#00C853` (Green)
* **Warning:** `#FFB300` (Amber)
* **Error:** `#FF3D00` (Red)
* **Info:** `#2196F3` (Blue)

### Light Theme Neutral Colors

* **Background:** `#F8F9FA` (Very Light Gray)
* **Surface:** `#FFFFFF` (White)
* **Text Primary:** `#1A1A1A` (Near Black)
* **Text Secondary:** `#757575` (Medium Gray)
* **Divider:** `#E0E0E0` (Light Gray)

### Dark Theme Neutral Colors

* **Background:** `#121212` (Very Dark Gray, Near Black)
* **Surface:** `#1E1E1E` (Dark Gray)
* **Text Primary:** `#FFFFFF` (White)
* **Text Secondary:** `#B3B3B3` (Light Gray)
* **Divider:** `#323232` (Medium Dark Gray)

### Opacity Colors (Black)

* **Black 05:** `#0D000000` (5% opacity black)
* **Black 10:** `#1A000000` (10% opacity black)
* **Black 20:** `#33000000` (20% opacity black)
* **Black 50:** `#80000000` (50% opacity black)
* **Black 70:** `#B3000000` (70% opacity black)
* **Black 80:** `#CC000000` (80% opacity black)

### Opacity Colors (White)

* **White 05:** `#0DFFFFFF` (5% opacity white)
* **White 10:** `#1AFFFFFF` (10% opacity white)
* **White 20:** `#33FFFFFF` (20% opacity white)
* **White 50:** `#80FFFFFF` (50% opacity white)
* **White 70:** `#B3FFFFFF` (70% opacity white)
* **White 80:** `#CCFFFFFF` (80% opacity white)
