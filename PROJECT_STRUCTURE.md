# Project Structure - Clean Architecture

## 📁 Feature-First Folder Structure

```
lib/
├── main.dart                           # App entry point + Hive initialization
├── app/
│   ├── app.dart                        # MaterialApp configuration
│   ├── theme/                          # App theme
│   └── routes/                         # Navigation routes
│
├── core/                               # Shared utilities (framework-independent)
│   ├── error/
│   │   └── failures.dart               # Failure classes for error handling
│   ├── usecases/
│   │   └── usecase.dart                # Base UseCase class
│   └── utils/
│       ├── either.dart                 # Either type for functional error handling
│       └── password_hasher.dart        # Password hashing utility
│
├── features/                           # Feature modules
│   ├── auth/                           # Authentication feature
│   │   ├── data/                       # Data layer (implementation)
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart      # Hive operations
│   │   │   │   └── auth_remote_datasource.dart     # API stub
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart                 # Hive model
│   │   │   │   └── user_model.g.dart               # Generated Hive adapter
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart       # Repository implementation
│   │   │
│   │   ├── domain/                     # Domain layer (business logic)
│   │   │   ├── entities/
│   │   │   │   └── user.dart                       # User entity
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart            # Repository interface
│   │   │   └── usecases/
│   │   │       ├── register_usecase.dart           # Registration logic
│   │   │       ├── login_usecase.dart              # Login logic
│   │   │       ├── logout_usecase.dart             # Logout logic
│   │   │       ├── get_current_user_usecase.dart   # Get user logic
│   │   │       └── check_auth_status_usecase.dart  # Auth check logic
│   │   │
│   │   └── presentation/               # Presentation layer (UI + state)
│   │       ├── pages/
│   │       │   ├── login_page.dart                 # Login UI
│   │       │   └── register_page.dart              # Registration UI
│   │       ├── state/
│   │       │   └── auth_state.dart                 # Auth state definition
│   │       ├── notifiers/
│   │       │   └── auth_notifier.dart              # State management
│   │       └── providers/
│   │           └── auth_providers.dart             # Riverpod providers
│   │
│   └── splash/                         # Splash feature
│       └── presentation/
│           └── pages/
│               └── splash_page.dart                # Splash screen + auth check
│
└── [Other existing folders...]
```

---

## 🎯 Layer Responsibilities

### **Core Layer**
- **Purpose**: Shared, reusable utilities
- **Dependencies**: None (pure Dart)
- **Contents**:
  - Error handling (`Failure` classes)
  - Functional types (`Either`)
  - Base classes (`UseCase`)
  - Utilities (password hashing, validators, etc.)

### **Domain Layer** (Business Logic)
- **Purpose**: Define business rules and contracts
- **Dependencies**: Core only
- **No**: Flutter, packages, external frameworks
- **Contents**:
  - **Entities**: Pure business objects (User)
  - **Repository Interfaces**: Contracts for data access
  - **Use Cases**: Single-responsibility business operations

### **Data Layer** (Implementation)
- **Purpose**: Implement data access and persistence
- **Dependencies**: Domain, external packages (Hive, HTTP)
- **Contents**:
  - **Models**: Data transfer objects with serialization
  - **Data Sources**: Local (Hive) and Remote (API) implementations
  - **Repository Implementations**: Concrete implementations of domain contracts

### **Presentation Layer** (UI)
- **Purpose**: User interface and state management
- **Dependencies**: Domain, Flutter, Riverpod
- **Contents**:
  - **Pages**: UI screens
  - **Widgets**: Reusable UI components
  - **State**: State classes (AuthState)
  - **Notifiers**: State management logic (AuthNotifier)
  - **Providers**: Dependency injection configuration

---

## 🔄 Data Flow

### User Action → State Update
```
User Interaction (UI)
        ↓
Notifier Method Call
        ↓
Use Case Execution
        ↓
Repository Method
        ↓
Data Source Operation (Hive/API)
        ↓
Return Either<Failure, Result>
        ↓
Update State (StateNotifier)
        ↓
UI Rebuild (Consumer/watch)
```

### Example: Login Flow
```
LoginPage.onTap()
  → ref.read(authNotifierProvider.notifier).login()
    → LoginUseCase.call()
      → AuthRepository.login()
        → AuthLocalDataSource.getUserByEmail()
        → PasswordHasher.verifyPassword()
        → Return Either<Failure, User>
      → Return to UseCase
    → AuthNotifier updates state
  → UI watches authNotifierProvider
→ Navigate to Dashboard
```

---

## 📦 Dependencies Between Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Pages, Widgets, State, Notifiers) │
│        Depends on: Domain           │
└─────────────────┬───────────────────┘
                  │
                  ↓
┌─────────────────────────────────────┐
│           Domain Layer              │
│   (Entities, Repositories, UseCases)│
│        Depends on: Core             │
└─────────────────┬───────────────────┘
                  ↑
                  │ implements
                  │
┌─────────────────────────────────────┐
│            Data Layer               │
│ (Models, DataSources, Repositories) │
│    Depends on: Domain + Packages    │
└─────────────────────────────────────┘
```

**Key Rules:**
- ✅ Presentation can import Domain
- ✅ Data can import Domain
- ❌ Domain CANNOT import Data or Presentation
- ❌ Domain CANNOT import Flutter or packages
- ✅ Data implements Domain interfaces

---

## 🧩 Feature Modules

Each feature follows the same structure:

### Minimal Feature (No data persistence)
```
feature_name/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

### Simple Feature (With state)
```
feature_name/
├── domain/
│   └── models/           # If no entities needed
└── presentation/
    ├── pages/
    ├── state/
    ├── notifiers/
    └── providers/
```

### Complete Feature (Full Clean Architecture)
```
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    ├── state/
    ├── notifiers/
    └── providers/
```

---

## 🏗️ Implemented Features

### ✅ 1. Splash Feature
**Structure:**
```
splash/
└── presentation/
    └── pages/
        └── splash_page.dart
```
**Responsibility:**
- Show app logo
- Check authentication status
- Navigate to Login or Dashboard

---

### ✅ 2. Authentication Feature
**Structure:**
```
auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   └── user_model.g.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── register_usecase.dart
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       ├── get_current_user_usecase.dart
│       └── check_auth_status_usecase.dart
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    ├── state/
    │   └── auth_state.dart
    ├── notifiers/
    │   └── auth_notifier.dart
    └── providers/
        └── auth_providers.dart
```
**Responsibility:**
- User registration
- User login/logout
- Authentication state management
- Password hashing and validation

---

## 📦 Package Organization

### Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.6.1     # State management
  hive: ^2.2.3                 # Local database
  hive_flutter: ^1.1.0         # Hive Flutter integration
  dartz: ^0.10.1               # Functional programming (Either)
  crypto: ^3.0.3               # Password hashing
  equatable: ^2.0.7            # Value comparison

dev_dependencies:
  hive_generator: ^2.0.1       # Hive code generation
  build_runner: ^2.4.13        # Code generation runner
```

### Purpose of Each Package
- **flutter_riverpod**: Dependency injection + state management
- **hive/hive_flutter**: Local NoSQL database with type adapters
- **dartz**: Either type for functional error handling
- **crypto**: SHA256 password hashing
- **equatable**: Easy value comparison for entities/states
- **hive_generator**: Generate Hive TypeAdapters
- **build_runner**: Run code generators

---

## 🔐 Security Considerations

### Password Storage
- ❌ NEVER store plain text passwords
- ✅ Hash passwords using `PasswordHasher` (SHA256)
- ✅ Store only hashed password in `UserModel`
- ✅ Hash is never exposed to domain layer

### Authentication State
- ✅ User ID stored in Hive `auth` box
- ✅ Cleared on logout
- ✅ Checked on app start (splash screen)

### Data Validation
- ✅ Validation in use cases (domain layer)
- ✅ Form validation in UI (presentation layer)
- ✅ Data integrity checks in repository

---

## 🧪 Testing Structure (Future)

```
test/
├── core/
│   ├── utils/
│   │   └── either_test.dart
│   └── error/
│       └── failures_test.dart
├── features/
│   └── auth/
│       ├── data/
│       │   ├── models/
│       │   │   └── user_model_test.dart
│       │   ├── datasources/
│       │   │   └── auth_local_datasource_test.dart
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       ├── register_usecase_test.dart
│       │       └── login_usecase_test.dart
│       └── presentation/
│           ├── notifiers/
│           │   └── auth_notifier_test.dart
│           └── pages/
│               └── login_page_test.dart
└── widget_test.dart
```

---

## 🚀 Adding a New Feature

### Steps:
1. **Create feature folder** in `lib/features/`
2. **Domain layer** (if needed):
   - Define entities
   - Create repository interface
   - Write use cases
3. **Data layer** (if needed):
   - Create models with serialization
   - Implement data sources (local/remote)
   - Implement repository
4. **Presentation layer**:
   - Define state class
   - Create notifier/state manager
   - Build UI pages/widgets
   - Set up Riverpod providers
5. **Wire everything** in providers file

### Example: Adding "Profile" Feature
```
lib/features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_local_datasource.dart
│   ├── models/
│   │   └── profile_model.dart
│   └── repositories/
│       └── profile_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── profile.dart
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── get_profile_usecase.dart
│       └── update_profile_usecase.dart
└── presentation/
    ├── pages/
    │   └── profile_page.dart
    ├── state/
    │   └── profile_state.dart
    ├── notifiers/
    │   └── profile_notifier.dart
    └── providers/
        └── profile_providers.dart
```

---

## 📚 Best Practices

1. **Single Responsibility**: Each class/file has one job
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Immutability**: Use immutable state and entities
4. **Separation of Concerns**: Clear boundaries between layers
5. **Type Safety**: Use strong typing (Either, sealed classes)
6. **Testability**: Write testable code with dependency injection
7. **Naming Conventions**:
   - Entities: `User`, `Profile`
   - Models: `UserModel`, `ProfileModel`
   - Repositories: `AuthRepository`, `AuthRepositoryImpl`
   - Use Cases: `RegisterUseCase`, `LoginUseCase`
   - States: `AuthState`, `ProfileState`
   - Notifiers: `AuthNotifier`, `ProfileNotifier`

---

## 🔧 Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Generate Hive adapters (if models changed)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (continuous generation)
flutter pub run build_runner watch

# Clean build
flutter clean
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Check for errors
flutter analyze
```

---

## 📖 References

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Flutter Architecture Samples](https://fluttersamples.com/)
