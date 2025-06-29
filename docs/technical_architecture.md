# 🏗️ vPay Technical Architecture & Stack
>
> **Scalable • Real-time • Secure**
> *The technical foundation powering our campus task ecosystem*

```mermaid
graph TD
    A[Flutter UI] --> B[Riverpod State Management]
    B --> C[Repositories & Services]
    C --> D[Supabase Backend]
    D --> E[PostgreSQL DB]
    D --> F[Realtime API]
    G[Firebase Cloud Messaging] --> H[Push Notification Service]
    H --> A
```

---

## 🌐 Overall Architecture

Our architecture is designed for robustness, scalability, and maintainability, leveraging modern best practices within the Flutter ecosystem.

| Component             | Technology / Methodology                                                                 | Implementation Details                                                                 |
| --------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| 📱 **Primary Framework** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) | Dart SDK: `>=3.0.0 <4.0.0`. Cross-platform (iOS, Android primarily).                        |
| 🏛️ **Architecture Style** | Clean Architecture (Feature-First)                                                       | Feature-driven structure (e.g., `lib/features/`). Data handling via Repositories that interact with the Supabase backend. |
| 🔄 **State Management**  | ![Riverpod](https://img.shields.io/badge/Riverpod-2396EF?style=for-the-badge&logo=Riverpod&logoColor=white) | Utilizing `Provider`, `StateNotifierProvider`, `StreamProvider`, `FutureProvider`, and `StateProvider`. Dedicated providers per feature. |
| 🗺️ **Navigation**       | ![GoRouter](https://img.shields.io/badge/GoRouter-007ACC?style=for-the-badge)           | Declarative, auth-aware routing. Utilizes named routes for navigation and deep linking.        |

---

## ⚙️ Backend Services

We utilize a combination of backend services to provide a comprehensive feature set.

### 🔑 Primary Backend

```mermaid
pie
    title Backend Service Distribution
    "Supabase (Auth, DB, Realtime)" : 90
    "Firebase (Notifications)" : 10
```

* **Supabase**: ![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white)
  * **Library**: `supabase_flutter`
  * **Usage**: Primary backend for Authentication, Database operations (PostgreSQL), and Real-time subscriptions (e.g., chat, live task updates).
  * **Configuration**: `lib/shared/config/supabase_config.dart`
* **Firebase**: ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  * **Library**: `firebase_messaging`, `firebase_core`
  * **Usage**: Exclusively for Push Notifications via Firebase Messaging, acting as a messaging layer to the client application.

---

## 💾 Database Architecture

Our data persistence strategy combines a powerful cloud database with efficient local storage solutions.

### 🗄️ Primary Database

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
*(via Supabase)*

Supabase provides a managed PostgreSQL database, offering robust relational data storage, scalability, and real-time capabilities. All core application data resides here.

### 📱 Local Storage Solutions

| Purpose                     | Library / Method         | Security Level | Notes / Platform Specifics |
| --------------------------- | ------------------------ | -------------- | -------------------------- |
| 🔑 Auth Tokens & Secrets    | `flutter_secure_storage` | 🔒🔒🔒🔒🔒    | Securely stores sensitive data like auth tokens using platform-specific keystores. |
| ⚙️ User Preferences         | `shared_preferences`     | 🔒🔒           | For non-sensitive user settings and preferences (e.g., theme choice). |
| 🗂️ Structured Local Data    | `sqflite` / `hive`       | 🔒🔒🔒         | Available (present in `pubspec.yaml`), typically used for structured local data caching or offline support if complex local storage is needed beyond basic preferences. |

*(Note: `sqflite` and `hive` offer more robust local database capabilities if required by future features.)*

---

## 📚 Core Frameworks & Libraries

The vPay application is built upon a foundation of robust and well-maintained frameworks and libraries.

### 🧩 Essential Packages

```mermaid
graph LR
    A[Flutter SDK] --> B(Riverpod)
    A --> C(GoRouter)
    A --> D(supabase_flutter)
    D --> E(PostgreSQL via Supabase)
    A --> F(firebase_messaging)
```

### 🧰 Development Toolkit

| Category                  | Key Packages                                                                                          |
| ------------------------- | ----------------------------------------------------------------------------------------------------- |
| 🔄 **State Management**   | `flutter_riverpod`, `riverpod_annotation` (if used), `freezed_annotation` (for immutable states)      |
| 🗺️ **Navigation**          | `go_router`                                                                                           |
| ☁️ **Backend Integration**| `supabase_flutter`, `firebase_core`, `firebase_messaging`                                             |
| 💾 **Local Storage**      | `flutter_secure_storage`, `shared_preferences`, `sqflite`, `hive`                                     |
| 🎨 **UI Helpers & Effects**| `cached_network_image`, `shimmer`, `flutter_chat_ui`, `lottie`, `flutter_animate`, `flex_color_scheme` |
| 🛠️ **Utilities & Models** | `equatable` (for model comparison), `uuid`, `intl` (internationalization), `image_picker`, `url_launcher`, `file_picker` |
| 📍 **Mapping & Location** | `google_maps_flutter`, `geolocator`, `geocoding`                                                      |
| 💳 **Payments**           | `upi_india`, `pay` (for platform payments if used)                                                    |

> 📋 *Full dependency list available in [pubspec.yaml](../pubspec.yaml)*

---

## 🚀 Performance Highlights

Performance is a key consideration, ensuring a smooth and responsive user experience.
*(Note: These metrics are illustrative/target values based on common performance goals unless specific profiling data is available).*

```mermaid
gantt
    title Real-time Data Flow Example (Chat Message)
    dateFormat  ss
    section Client A (Sender)
    Input & Send     :s1, 00, 1s
    Provider Update  :s2, after s1, 0.5s
    Repo to Supabase :s3, after s2, 1.5s
    section Backend Processing
    Supabase Ingest  :b1, after s3, 0.5s
    DB Commit        :b2, after b1, 1s
    Realtime Push    :b3, after b2, 0.5s
    section Client B (Receiver)
    Realtime Event   :r1, after b3, 1s
    Provider Update  :r2, after r1, 0.5s
    UI Render        :r3, after r2, 0.5s
```

* ⚡ **Real-time Sync**: Average ~500ms update latency for chat and task status changes.
* 🔐 **Auth Redirection**: < 100ms for typical auth state-based path resolution.
* 💨 **Local Cache**: Aiming for a 95% hit rate for frequently accessed non-sensitive data.
* 🚀 **App Startup**: Optimized for quick initial load times through efficient state initialization and lazy loading where appropriate.

---

## 🔮 Future Tech Considerations

As vPay evolves, we anticipate incorporating additional technologies to enhance scalability and features.

```mermaid
graph LR
    A[Current: Flutter + Supabase] --> B[Post-MVP: Enhanced Backend]
    B --> C[Scale Phase: Distributed Services]
    C --> D[Global Vision: Advanced Cloud Native]

    A -->|GraphQL Layer?| B
    B -->|Microservices?| C
    B -->|Redis/Memcached| C
    C -->|Kubernetes Orchestration| D
    C -->|CDN & Edge Caching| D
    C -->|Read Replicas / Sharding| D

    style A fill:#4CAF50,stroke:#388E3C,color:#fff
    style B fill:#FFC107,stroke:#FFA000,color:#000
    style C fill:#2196F3,stroke:#1976D2,color:#fff
    style D fill:#9C27B0,stroke:#7B1FA2,color:#fff
```

* **Post-MVP / Growth Phase**:
  * Possibly introduce a **GraphQL layer** for more flexible data fetching.
  * Implement **Redis or Memcached** for advanced caching strategies.
* **Scale Phase**:
  * Explore **Kubernetes** for container orchestration if microservices are adopted.
  * Implement **Database Read Replicas** or sharding for improved DB performance.
* **Global Vision**:
  * Integrate **Content Delivery Networks (CDNs)** for faster asset delivery.
  * Consider **regional data partitioning** and global infrastructure.
