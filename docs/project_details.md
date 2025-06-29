# vPay: Comprehensive Project Resources Documentation

## 1. Project Overview

### Project Name: vPay

### Tagline: Versatile Payment & Earn-Now Platform

### Vision

 To create a mobile-first ecosystem connecting users (primarily students initially) with hyperlocal micro-tasks and short-term job opportunities, particularly within campus environments. The platform aims to enable seamless, secure peer-to-peer payments and foster community engagement by making value exchange frictionless and opportunities easily discoverable.

### Core Problem Addressed

 Fragmentation in micro-task marketplaces, complex payment flows for small tasks, underutilized student availability, and inefficient hyperlocal task discovery.

### Target Audience

 College students seeking flexible income, individuals needing help with small tasks, and local businesses requiring short-term assistance.

## 2. Technical Architecture & Stack

### Primary Framework

 Flutter (SDK Version specified in android/local.properties, Dart Language)

### Architecture Style

 Clean Architecture with feature-first project structure (lib/features/). Data handling uses Repositories interacting with Supabase backend.

### State Management

 Flutter Riverpod (flutter_riverpod) used throughout the app with StateNotifierProvider and Provider patterns. All features have dedicated providers (authProvider, tasksProvider, etc.).

### Backend

 Supabase (supabase_flutter) is the primary backend service. Configuration in lib/shared/config/supabase_config.dart.

### Real-time Services

- Supabase: Provides real-time database functionality
- Firebase: Only used for push notifications (firebase_messaging)

### Navigation

 GoRouter (go_router package) manages app navigation and redirection based on authentication state.

### Database

#### Primary

 Supabase (likely PostgreSQL backend)

#### Secondary/Optional

 Cloud Firestore

Local: flutter_secure_storage, shared_preferences, sqflite (iOS/macOS implementation present, mentioned as option), hive (mentioned as option).

## 3. Core Features & Modules

### Account

- **Purpose:** Manages user account settings, achievements, skills, testimonials, and personalization
- **Components:**
  - **data/:** Account data sources and repositories (achievements, skills, testimonials, themes)
  - **presentation/:** UI components for account screens and widgets
  - **providers/:** Riverpod providers for account state (avatar, theme, skills, testimonials)
- **Features:**
  - **Achievement System:**
    - Tracks user progress and unlocks achievements
    - Shows unlock animations with confetti effects
    - Awards XP and handles level progression
    - Displays achievement notifications
  - **Personalization:**
    - Theme customization (light/dark mode)
    - Animated avatar customization
  - **Skills Management:**
    - Displays user skills
    - Allows adding/removing skills
  - **Testimonials:**
    - Shows user testimonials
    - Allows submitting new testimonials

### Authentication

- **Purpose:** Handles user registration, login, and password reset
- **Components:** Email/Password sign-up (AuthRepository.signUp) and sign-in (AuthRepository.signIn) using Supabase Auth.

- **User session management** via authProvider monitoring Supabase auth state.

- **Password Reset**: Users can reset their password via email (AuthRepository.sendPasswordResetEmail).

- **Password Reset**: Users can reset their password via email (AuthRepository.sendPasswordResetEmail).

- **Social Login:** Planned but not yet implemented.
  - UI components for social login (Google, Facebook) are present in the login screen.
  - Biometric authentication via local_auth package is included for supported devices.

- **Google Sign-In**: Uses `google_sign_in` package.
- **Facebook Login**: Uses `flutter_facebook_auth` package.

- **Biometric Authentication**: Fingerprint/Face ID login via `local_auth`.

- Student ID verification planned.

## Home

- **Purpose:** Main dashboard screen showing task overview and quick actions

- **Components:**
  - `presentation/`: Dashboard UI components
  - `providers/`: Riverpod providers for home state

### Task Management

- **Model**: `TaskModel` defines task attributes (ID, title, description, creator/assignee IDs, amount, currency (default: 'USD'), timestamps, dueDate, status, category,location, tags).
  - Statuses include Pending, InProgress, Completed, Cancelled.
  - Categories are defined in `TaskCategory` enum (Academic Support, Campus Errands, Tech Help, Event Support, Other) with display names and icons.

- **Repository**: `TasksRepository` handles:
  - Streaming all tasks (`getTasks`)
  - Streaming tasks for a specific user (`getMyTasks`: tasks where user is creator or assignee)
  - Creating tasks with validation and automatic chat room creation when assigned (`createTask`)
  - Updating tasks (with transaction support) and creating chat room when assigned for the first time (`updateTask`)
  - Deleting tasks (with retry logic) (`deleteTask`)
  - Fetching a single task (`getTask`)
  - Real-time updates for a single task (`watchTask`)
  - Full-text search by title (`searchTasks`)
  - streaming, and filtering tasks via Supabase. Includes filtering by status, amount range, and potentially location.

- **State**: `tasksProvider` manages task lists, loading states, errors, and applied filters (`TaskFilter`).

- **UI**:
  - `task_list_screen.dart`: Displays tasks using `TaskCard`, includes refresh, filtering (via `TaskFilterDialog`), and navigation to create/detail screens.
  - `create_task_screen.dart`: Form for creating new tasks with validation for title, description, amount, currency, dueDate, category, and deadline selection.
  - `task_detail_screen.dart`: Shows comprehensive task details and provides options to apply (updating task status and assignee) or navigate to chat.
  - `my_tasks_screen.dart`: Displays tasks specific to the current user (created or assigned)
  - `ratings_screen.dart`: Shows task ratings and reviews

- **Categories**: As defined in the `TaskCategory` enum (Academic Support, Campus Errands, Tech Help, Event Support, Other)

### Ratings

- **Purpose**: Handles user ratings and reviews
- **Components**:
  - `data/`: Ratings data sources
  - `domain/`: Business logic for ratings
  - `providers/`: Riverpod providers for ratings state

### Payments

- **Model**: `PaymentModel` tracks payment details (ID, task ID, payer/payee IDs, amount, status, transaction ID, timestamps, failure reason). Statuses include Pending, Processing, Completed, Failed.
- **Repository**: `PaymentRepository` uses `upi_india` package to fetch available UPI apps and initiate transactions. It creates a payment record in Supabase, starts the UPI transaction, and updates the record based on the UPI response. Uses a placeholder UPI ID (`merchant@upi`).
- **State**: `paymentProvider` manages loading UPI apps, initiating payments, and tracking the current payment state.
- **UI**: `payment_screen.dart` displays task amount, lists available UPI apps for selection, and initiates the payment flow.
- **Other Gateways**: Razorpay and Stripe mentioned as possibilities.

### Chat & Communication

The chat feature is organized in the `lib/features/chat` directory with the following structure:

- **data/**: Contains data layer implementations
  - `chat_datasource.dart`: Defines the data source interface for chat (e.g., Supabase implementation)
  - `chat_entity.dart`: Defines the data entity for chat messages (mapping between model and database)
  - `chat_repository.dart`: Implements the repository pattern for chat, handling data operations (sending, receiving messages, etc.)
- **domain/**: Contains business logic models
  - `chat_list_item_model.dart`: Model for an item in the chat list (e.g., a conversation)
  - `chat_message_model.dart`: Model for a chat message (extends the base ChatMessage model with additional fields if needed)
  - `chat_view_model.dart`: View model for the chat screen (may be replaced by Riverpod providers)
- **presentation/**: Contains UI components
  - **screens/**:
    - `chat_detail_screen.dart`: Screen showing the chat messages for a specific task
    - `chat_screen.dart`: Main chat screen (might be the same as chat_detail_screen or a list of conversations)
  - **widget/**:
    - `chat_app_bar.dart`: Custom app bar for the chat screen
    - `chat_filter_bar.dart`: Widget for filtering chat conversations
    - `chat_header.dart`: Header for the chat screen
    - `chat_input.dart`: Input widget for typing and sending messages
    - `chat_list_item.dart`: Widget for an item in the chat list (a single conversation)
    - `message_bubble.dart`: Widget for displaying a message bubble in the chat
- **provider/**: Contains state management (Riverpod)
  - `chat_provider.dart`: Provider for chat-related state (e.g., list of messages, sending status)
  - `chat_state.dart`: Defines the state class for chat

#### Key Components

- **Model**: `ChatMessage` (defined in domain) defines the structure of a chat message (ID, task ID, sender/receiver IDs, message content, timestamp, read status).
- **Repository**: `ChatRepository` (in data layer) handles sending messages and streaming messages for a specific task ID from Supabase. Includes marking messages as read.
- **State Management**: `chatProvider` (a Riverpod family provider based on taskId) manages the stream of messages for a chat. The state is defined in `chat_state.dart`.
- **UI**:
  - `chat_screen.dart` (or `chat_detail_screen.dart`) provides the chat interface using custom widgets (like `message_bubble.dart` for message display and `chat_input.dart` for sending).
  - `chat_list_item.dart` is used in the chat list screen to show a summary of each conversation.

The chat is tightly integrated with tasks: each task has an associated chat room that is created when a task is assigned. The chat is accessed from the task detail screen.

### Notifications

- **Model**: `NotificationModel` (in `shared/models/notification_model.dart`) defines notification details (ID, user ID, title, message, type, task ID, timestamp, read status). Types include `TaskCreated`, `TaskAssigned`, `PaymentReceived`, `NewMessage`, `TaskCompleted`.
- **Repository**: `NotificationRepository` streams notifications for a user from Supabase and marks notifications as read.
- **Service**: `NotificationService` initializes and handles Firebase Messaging (background/foreground messages) and triggers local notifications (`flutter_local_notifications`).
- **State**: `notificationProvider` manages the list of notifications, loading state, and errors.
- **UI**: `notification_screen.dart` displays a list of notifications using `NotificationTile`, showing icons based on type and indicating read status.

### User Profiles

- **Model**: `UserModel` defines user attributes (ID, email, full name, avatar URL, phone, verification status).
- Profile data is fetched and potentially updated via `AuthRepository` interacting with the 'profiles' Supabase table.
- UI mentioned in documentation (`profile_screen.dart` code snippets) including stats, skills, and reviews.

### Location Services

- Uses `google_maps_flutter` for map display.
- Dependencies like `geolocator`, `geocoding` mentioned for location fetching and handling. Code snippets show intent to get current location and calculate distances.

## 4. Platform Support & Configuration

Cross-Platform Build: Flutter enables building for Android, iOS, Web, Windows, macOS, and Linux, with dedicated setup files present for each.

### Android

- Min SDK, Target SDK, Version Code/Name configured in `android/app/build.gradle.kts`.
- Application ID: `dev.vpay.vpay_flutter`.
- Permissions: `INTERNET` permission is standard. `PROCESS_TEXT` query added.
- **Plugins Registered**: `app_links`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `flutter_secure_storage`, `google_maps_flutter_android`, `image_picker_android`, `local_auth_android`, `path_provider_android`, `pay_android`, `qr_code_scanner`, `shared_preferences_android`, `sqflite_android`, `upi_india`, `url_launcher_android`.
- Gradle Version: `8.10.2`.

### iOS

- **Configuration:**
  - Build settings are configured via Xcode project files (`ios/Runner.xcworkspace`) and potentially `flutter_export_environment.sh`.
- **Plugins Registered (Illustrative List - may vary with updates):**
  - `app_links`
  - `firebase_core`, `firebase_messaging`
  - `flutter_local_notifications`
  - `flutter_secure_storage`
  - `maps_flutter_ios`
  - `image_picker_ios`
  - `local_auth_darwin` (for Touch ID, Face ID)
  - `path_provider_foundation`
  - `pay_ios` (likely for Apple Pay)
  - `qr_code_scanner`
  - `shared_preferences_foundation`
  - `sqflite_darwin`
  - `url_launcher_ios`

### Web

- **Configuration:**
  - Basic setup with `web/index.html` and `web/manifest.json`.
  - Flutter web support enables running the application in modern web browsers.

### Windows

- **Build System:** Uses CMake.
- **Runner:** Implements `Win32Window` for hosting the Flutter view.
- **Plugins Registered (Illustrative List - may vary with updates):**
  - `app_links`
  - `file_selector_windows`
  - `firebase_core` (limited functionality on desktop)
  - `flutter_secure_storage_windows`
  - `local_auth_windows`
  - `url_launcher_windows`

### macOS

- **Build System:** Uses CMake and Swift for the runner application.
- **Plugins Registered (Illustrative List - may vary with updates):**
  - `app_links`
  - `file_selector_macos`
  - `firebase_core`, `firebase_messaging` (macOS support for some Firebase services)
  - `flutter_local_notifications`
  - `flutter_secure_storage_macos`
  - `local_auth_darwin`
  - `path_provider_foundation`
  - `shared_preferences_foundation`
  - `sqflite_darwin`
  - `url_launcher_macos`

### Linux

- **Build System:** Uses CMake and C++ for the runner application.**

- **Application ID:** `dev.vpay.vpay_flutter` (same as Android, consistency for some services).
- **Plugins Registered (Illustrative List - may vary with updates):**
  - `app_links`
  - `file_selector_linux`
  - `flutter_secure_storage_linux`
  - `gtk` (for GTK integration)
  - `url_launcher_linux`

## 5. UI/UX & Design

- **Design System:** Material Design 3 (`uses-material-design: true` in `pubspec.yaml`, `ThemeData(useMaterial3: true)` in `app_theme.dart`). Cupertino widgets mentioned as option for iOS styling.
- **Theming:** Custom light and dark themes defined in `lib/shared/theme/app_theme.dart` using colors from `lib/shared/theme/app_colors.dart`. Supports system theme mode.
- **Fonts:** Custom fonts (Poppins, Righteous) configured in `pubspec.yaml`.
- **Key UI Packages:** `cached_network_image` for image handling, `shimmer` for loading states, `flutter_chat_ui` for messaging interface.
- **Responsive Design:** Planning documents mention using `MediaQuery`, `LayoutBuilder`, and `flutter_screenutil`.

## 6. Color Palette

### Primary Brand Colors

- **Primary:** `#001C3C`
- **Primary Dark:** `#001428`
- **Primary Light:** `#002B5C`

### Secondary Brand Colors

- **Secondary:** `#50EDFE`
- **Secondary Dark:** `#00D6E9`
- **Secondary Light:** `#7FF4FF`

### Accent Colors

- **Accent:** `#2F89FC`
- **Accent Dark:** `#1877F2`
- **Link Blue:** `#2F89FC`

### Status Colors

- **Success:** `#00C853`
- **Warning:** `#FFB300`
- **Error:** `#FF3D00`
- **Info:** `#2196F3`

### Light Theme Colors

- **Background:** `#F8F9FA`
- **Surface:** `#FFFFFF` (white)
- **Text Primary:** `#1A1A1A`
- **Text Secondary:** `#757575`
- **Divider:** `#E0E0E0`

### Dark Theme Colors

- **Background:** `#121212`
- **Surface:** `#1E1E1E`
- **Text Primary:** `#FFFFFF` (white)
- **Text Secondary:** `#B3B3B3`
- **Divider:** `#323232`

### Opacity Colors (Black)

- **Black 05:** `#0D000000` (5% opacity black)
- **Black 10:** `#1A000000` (10% opacity black)
- **Black 20:** `#33000000` (20% opacity black)
- **Black 50:** `#80000000` (50% opacity black)
- **Black 70:** `#B3000000` (70% opacity black)
- **Black 80:** `#CC000000` (80% opacity black)

### Opacity Colors (White)

- **White 05:** `#0DFFFFFF` (5% opacity white)
- **White 10:** `#1AFFFFFF` (10% opacity white)
- **White 20:** `#33FFFFFF` (20% opacity white)
- **White 50:** `#80FFFFFF` (50% opacity white)
- **White 70:** `#B3FFFFFF` (70% opacity white)
- **White 80:** `#CCFFFFFF` (80% opacity white)

## 7. Development & Operations

- **Version Control:** Git is standard. Branching strategy (`main`, `develop`, `feature` branches) recommended.

- **Code Quality:** `flutter_lints` package used for static analysis, configured in `analysis_options.yaml`.

- **Dependencies:** Managed via `pubspec.yaml`. Key libraries listed in previous documentation.

- **Testing:**
  - **Strategies outlined:** Unit, Widget, and Integration tests for Flutter; Backend testing (Jest/Supertest for Node, Pytest for Python); API testing (Postman); Physical device testing (Firebase Test Lab).
  - Basic test files present for iOS (`RunnerTests.swift`) and macOS (`RunnerTests.swift`).

- **CI/CD:** GitHub Actions and Codemagic mentioned as potential tools.

- **Deployment:** Standard procedures for App Store and Google Play outlined in documentation.

## 8. Environment Configuration

- Sensitive information like API keys (Supabase URL/Key, Firebase config) should be managed via environment variables, typically using a `.env` file that is not committed to version control.
- A `.env.example` file should be provided as a template.

## 9. Minimum Viable Product (MVP) Scope

- **Goal (MVP):** To develop a Minimum Viable Product (MVP) for a mobile application that serves as a unified platform for connecting users who need micro-tasks or short-term jobs completed (Requesters) with individuals willing to complete them (Workers).

- **Vision (MVP):** Address the core pain points of structural fragmentation, task matching inefficiency (specifically location/availability mismatch), payment friction (including multi-app fatigue and escrow delays), and establishing basic trust/reputation.

- **Target Platform (MVP):** Mobile (iOS and Android)

- **Development Framework (MVP):** Flutter

### 9.1. MVP Features

- **User Authentication and Profiles:**
  - **Description:** Allow users to register and log in. Create a basic user profile.
  - **Details:** Simple email/password registration and login. Basic profile: Name/Username, Profile Picture (optional), aggregate Rating display.
  - **Rationale:** Essential for identification, personalisation, trust.

- **Core Task Posting and Discovery:**
  - **Description:** Requesters create/publish tasks; Workers discover tasks.
  - **Details:**
    - **Task Posting (Requester):** Interface for Title, Description, Category (e.g., Data Entry, Local Errands), fixed Price, Task Location. Basic task templates.
    - **Task Discovery (Worker):** Browsable list/feed. Location-aware filtering/sorting. Filter by Category, Price. Display Title, Description, Price, Location, Requester profile/rating.
    - **Basic Worker Availability:**
  - **Description:** Workers indicate general unavailability.
  - **Details:** Simple toggle or basic time slot blocking on profile.
  - **Rationale:** Addresses worker schedule conflicts.

- **Integrated Digital Payment System:**
  - **Description:** Secure, in-app task payments.
  - **Details:**
    - **In-app Balance:** Digital wallet/account balance display.
    - **Escrow System:** Hold payment when Worker accepts task.
    - **Payment Release:** To Worker on Requester approval or auto-grace period. Aims for faster settlements.
    - **Funding Tasks:** Integrate with a single Payment Gateway API (e.g., Stripe) for Requesters to add funds or fund tasks directly.
    - **Transparent Fees:** Clearly show platform commission.
    - *Note: Payout (balance to external) can be manual/simplified in V1. UPI specifics, dynamic fees, biometric auth, complex reconciliation are out of MVP scope.*
  - **Rationale:** Addresses payment friction, multi-app fatigue, trust over cash.

- **Fundamental Trust and Reporting:**
  - **Description:** Basic rating and issue reporting.
  - **Details:**
    - **Basic Rating:** Post-completion, Worker/Requester rate (1-5 stars) and optional comment.
    - **Basic Reporting:** Simple interface for Workers to report Requesters (e.g., unfair rejection). Records for admin review (no automated dispute resolution in MVP).
    - **Basic Verification:** Confirmed email or phone number.
  - **Rationale:** Initial trust layer. Basic complaint channel.

- **In-App Communication:**
  - **Description:** Assigned Worker and Requester communicate about active tasks.
  - **Details:** Simple text-based messaging linked to accepted tasks.
  - **Rationale:** Facilitates coordination without sharing personal contacts.

- **Basic Task Workflow Management:**
  - **Description:** Core lifecycle actions for a task.
  - **Details:**
    - **Worker:** "Accept Task" (to "In Progress"), "Mark as Completed".
    - **Requester:** View accepted/completed tasks. "Approve Completion" or "Reject Completion" (triggers reporting).
  - **Rationale:** Defines task lifecycle steps for payment and feedback.
- **Basic Worker Availability:**
  - **Description:** Workers indicate general unavailability.
  - **Details:** Simple toggle or basic time slot blocking on profile.
  - **Rationale:** Addresses worker schedule conflicts.
- **Basic User Analytics:**
  - **Description:** Track basic user engagement metrics.
  - **Details:** Track user sign-ups, task creations, task completions, and payment transactions.
  - **Rationale:** Provides insights into app usage and identifies areas for improvement.  
- **Push Notifications:**
  - **Description:** Notify users of task updates, new messages, and important events.
  - **Details:** Use Firebase Cloud Messaging (FCM) for real-time notifications.- _ - - **Rationale:** Essential for keeping users informed about critical updates and promoting engagement.

### 9.2. Out of Scope for this MVP

- **Advanced Scheduling:**
  - **Description:** Allow users to schedule tasks for specific dates and times, including recurring tasks.
  - **Details:** Calendar integration, recurring task setup (daily, weekly, monthly), and time slot management.
  - **Rationale:** Provides greater flexibility for both Requesters and Workers.
- **Complex Trust and Reputation Systems:**
  - **Description:** Implement multidimensional trust metrics, cross-platform reputation portability, and complex dispute resolution.
  - **Details:**
    - **Multidimensional Trust Metrics:** Skill credibility, reliability indices, and cross-platform reputation portability (decentralized identifiers).
    - **Complex Dispute Resolution:** Automated systems for handling disputes.
  - **Rationale:** These features add significant complexity and are not essential for validating core problem/solution fit in MVP.
- **Community Features:**
  - **Description:** Integrated community forums, social features, and physical hubs.
  - **Details:**
    - **Community Forums:** Allow users to discuss tasks, share experiences, and build community.
    - **Social Features:** User profiles, following, and community engagement.    - **Physical Hubs:** Designated physical spaces for community interaction and support.
  - **Rationale:** Fosters a sense of belonging and facilitates offline interaction.
- **Integrated Upskilling Pathways:**
  - **Description:** Offer micro-credentials and learning resources within the platform.
  - **Details:** Provide access to courses, tutorials, and certifications relevant to common task categories.
  - **Rationale:** Empowers users to develop new skills and increase their earning potential.
- **Advanced Algorithmic Management Transparency:**
  - **Description:** Provide clear explanations for AI-driven decisions and formal recourse mechanisms.
  - **Details:** Users can understand why certain tasks are suggested or why their profile might be prioritized.
  - **Rationale:** Builds trust and ensures fairness in automated processes.
- **Cash Payment Handling:**
  - **Description:** Support cash payments for tasks.
  - **Details:** Allow Requesters to pay Workers directly in cash, with the platform facilitating the agreement.
  - **Rationale:** Provides flexibility for users who prefer cash transactions.
- **UPI-Specific Advanced Features:**
  - **Description:** Implement real-time external settlement, dynamic fees, and UPI-credit options.
  - **Details:** Leverage advanced UPI functionalities for more seamless and flexible payment experiences.
- **Direct Bank API Integrations:**
  - **Description:** Integrate with bank APIs for direct fund transfers and reconciliation.  
  - **Details:** Enable seamless and automated transfers between user accounts and the platform, and facilitate reconciliation of transactions.
  - **Rationale:** Streamlines financial operations and reduces manual effort.
- **Automated Worker Payout Features:**
  - **Description:** Implement automated payout features for Workers beyond in-app balance.
  - **Rationale:** Automating payouts reduces manual overhead and improves worker satisfaction.
- **Complex Identity Verification:**
  - **Description:** Implement advanced identity verification methods such as document scans and biometrics.
  - **Details:** Use technologies like facial recognition, ID document scanning, and biometric authentication for user verification.
  - **Rationale:** Enhances security and trust but adds complexity beyond basic email/phone verification.

- **Advanced Identity Verification:**
  - **Description:** Implement advanced identity verification methods such as document scans and biometrics.
  - **Details:** Use technologies like facial recognition, ID document scanning, and biometric authentication for user verification.
  - **Rationale:** Enhances security and trust but adds complexity beyond basic email/phone verification.
- **Predictive Task Allocation:**
  - **Description:** Implement AI-driven task matching beyond simple location/category filters.
  - **Rationale:** These features add significant complexity and are not essential for validating core problem/solution fit in MVP.
- **Advanced Analytics and Reporting:**
  - **Description:** Provide detailed user analytics dashboards and enterprise features.
  - **Details:**
    - **Detailed User Analytics:**
      - Comprehensive dashboards showing user engagement, task performance, and financial metrics.
    - **Rationale** : Provides insights into user behavior and platform performance.

- **Enterprise Features:**
      - Specialized features for campus organizations and businesses.
      - Bulk task posting capabilities.
      - Verified business status for enhanced trust.
      - Subscription packages for recurring needs.
      - Recruitment and talent sourcing features to connect businesses with skilled student workers.

## 9.3. Technical Architecture (MVP)

- **Frontend (Mobile Application):** Flutter (Dart) for cross-platform (iOS, Android).
- **Backend & Database:** Supabase (PostgreSQL) handles user data, tasks, messages, and auth logic. Firebase only used for push notifications.
- **Authentication:** Handled by backend service (e.g., Firebase Authentication). Simple email/password for MVP.
- **Storage:** Backend service's file storage (e.g., Firebase Storage) for optional profile pics, task media.
- **Payment Processing:** Integration with a single external Digital Payment Gateway API (e.g., Stripe). App interacts for Requester payments. Escrow/balance logic in app backend.
- **Location Services:** Flutter plugins (`geolocator`, `location`) for device GPS (with permission) for worker location, distance to tasks.
- **Push Notifications:** Services like Firebase Cloud Messaging (FCM) for event notifications (task accepted, new message, etc.).

## 9.4. Data Model (Conceptual MVP)

- **`users`**:
  - `id` (string, Unique Identifier)
  - `name` (string)
  - `email` (string, for authentication)
  - `phone_number` (string, optional)
  - `role` (string, 'worker' or 'requester')
  - `rating_avg` (number, aggregate rating)
  - `balance` (number, in-app currency/credit)
  - `is_worker_available` (boolean, simple availability toggle)

- **`tasks`**:
  - `id` (string, Unique Identifier)
  - `title` (string)
  - `description` (string)
  - `category` (string)
  - `price` (number)
  - `location` (geopoint/latitude/longitude)
  - `status` (string, e.g., 'open', 'accepted', 'completed', 'approved', 'disputed')
  - `requester_id` (string, foreign key to users)
  - `worker_id` (string, foreign key to users, nullable)
  - `posted_at` (timestamp)

- **`transactions`**:
  - `id` (string, Unique Identifier)
  - `task_id` (string, foreign key to tasks)
  - `amount` (number, task price +/- fees)
  - `type` (string, e.g., 'escrow_funded', 'escrow_released', 'payout_requested')
  - `status` (string, e.g., 'pending', 'completed', 'failed')
  - `timestamp` (timestamp)

- **`messages`**:
  - `id` (string, Unique Identifier)
  - `task_id` (string, foreign key to tasks)
  - `sender_id` (string, foreign key to users)
  - `content` (string)
  - `timestamp` (timestamp)

- **`ratings`**:
  - `id` (string, Unique Identifier)
  - `task_id` (string, foreign key to tasks)
  - `rater_id` (string, foreign key to users)
  - `ratee_id` (string, foreign key to users)
  - `score` (number, e.g., 1-5)
  - `comment` (string, optional)
  - `timestamp` (timestamp)

- **`reports`**:
  - `id` (string, Unique Identifier)
  - `task_id` (string, foreign key to tasks, optional)
  - `reporter_id` (string, foreign key to users)
  - `reported_user_id` (string, foreign key to users)
  - `reason` (string)
  - `timestamp` (timestamp)
  - `status` (string, e.g., 'open', 'reviewed', 'closed')

## 9.5. UI/UX Considerations (MVP)

- **Simplicity:** Clean, uncluttered interfaces, focus on core task flow.
- **Mobile-First:** Design and optimize for mobile.
- **Intuitive Navigation:** Easy switching between posting/finding tasks, profiles, active jobs.
- **Transparency:** Clearly display task price, location, fees.
- **Streamlined Flows:** Straightforward posting, accepting, completing, approving tasks. Clear, integrated payment steps.
- **Location Prominence:** Central element in task discovery/posting.

## 9.6. Technical Details and Dependencies (Initial Build - MVP)

- **Flutter SDK:** Specify target SDK version (e.g., Flutter 3.x.x).
- **Core Flutter Packages:** UI (material), state management (provider, flutter_bloc, or riverpod), navigation, HTTP (http or dio).
- **Backend-Specific Packages:**
  - `supabase_flutter` for Supabase integration
  - `firebase_core` and `firebase_messaging` for Firebase push notifications
- **Location Packages:** `geolocator` or `location`.
- **Payment Gateway SDK/Packages:** Official Flutter SDK or community package (e.g., `flutter_stripe`).
- **Other Potential Packages:** `cached_network_image`, `timeago`.

## 10. Future Roadmap & Potential (Post-MVP)

[Based on vPay Task Categories and Future Development Roadmap.pdf and other source material](features_overview.md)

### Feature Enhancements

- Scheduled/recurring tasks
- Task bundles
- Skill-based matching
- Advanced messaging features
- Dispute resolution system (more robust than MVP reporting)
- Multiple payment methods (beyond single gateway in MVP)
- Tipping functionality
- Enhanced verification methods (beyond basic email/phone)
- Task templates (more advanced)
- Implementing multidimensional trust metrics
- Exploring cross-platform reputation portability
- Integrating advanced scheduling and calendar features
- Automating worker payouts to external accounts

### Community Building

 Integrating community-building features or links to support resources

### Expansion

- Multi-campus networks
- Neighborhood/city-wide expansion

### Enterprise Solutions

- Business accounts
- Bulk task posting
- Verified business status
- Subscription packages
- Recruitment integration

### Advanced Tech

- AI task matching
- Automated scheduling
- Voice commands
- Task insurance
- Exploring integrated upskilling pathways
- Investigating privacy-preserving location tracking or verification methods
- Exploring predictive task allocation algorithms with attention to transparency

### Monetization Expansion

- Business subscriptions
- Verification badges (premium)
- Urgent task fees
- Insurance products
- Data insights (anonymized, aggregated)
- API access for third-party integrations
- White-labeling solutions

## 11. Rationale and Sources Summary (for MVP Design)

The MVP design is informed by addressing key pain points and leveraging trends:

- **Fragmentation:** A single "vPay" (or "MicroTask Connect" as per some document sections) app addresses multi-app juggling.
- **Location/Availability Mismatch:** Location-aware discovery and basic worker availability tackle inefficient matching, especially for students, leveraging location-aware engines.
- **Payment Friction:** Integrated digital payments with escrow reduce multi-app fatigue, offer security over cash, and aim for faster settlements.
- **Trust and Reputation:** Basic profiles, ratings, and reporting establish fundamental trust and a recourse channel.
- **UI/UX:** Simple, intuitive design combats "search tax" and multi-app cognitive load. Task templates aid requesters.
- **Technology (Flutter):** Chosen for efficient cross-platform mobile development. Backend choice (Firebase/Supabase) supports rapid MVP development and scalability.
