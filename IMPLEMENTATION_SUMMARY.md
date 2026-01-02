# 🎓 Tutor Finder - Clean Architecture Implementation

A Flutter application built with **Clean Architecture**, **Riverpod** state management, and **Hive** local database, featuring authentication and splash screen functionality.

---

## ✨ Implemented Features

### 1. ✅ Splash Screen
- Beautiful loading screen with app logo
- Checks authentication status from local storage
- Automatic navigation:
  - **Authenticated** → Dashboard
  - **Unauthenticated** → Login

### 2. ✅ User Registration
- Full name, email, password input
- Form validation
- Password confirmation
- Email duplication check
- Secure password hashing (SHA256)
- Automatic login after registration

### 3. ✅ User Login
- Email and password authentication
- Credential validation from Hive
- Password verification
- Error handling for wrong credentials
- Session persistence

### 4. ✅ Authentication Persistence
- Login state saved to Hive
- Survives app restarts
- Automatic login on app launch

### 5. ✅ Logout
- Clear authentication state
- Navigate back to login
- Remove user session from storage

---

## 🏗️ Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│       Presentation Layer            │
│  (UI, State Management, Riverpod)   │
│                                     │
│  - Pages (Login, Register, Splash)  │
│  - State (AuthState)                │
│  - Notifiers (AuthNotifier)         │
│  - Providers (Riverpod)             │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│         Domain Layer                │
│     (Business Logic - Pure Dart)    │
│                                     │
│  - Entities (User)                  │
│  - Repository Interfaces            │
│  - Use Cases                        │
│    • RegisterUseCase                │
│    • LoginUseCase                   │
│    • LogoutUseCase                  │
│    • GetCurrentUserUseCase          │
│    • CheckAuthStatusUseCase         │
└────────────┬────────────────────────┘
             ↑
             │ implements
             │
┌─────────────────────────────────────┐
│          Data Layer                 │
│   (Implementation Details)          │
│                                     │
│  - Models (UserModel + Hive)        │
│  - Data Sources                     │
│    • Local (Hive) ✅                │
│    • Remote (API Stub) 🚧           │
│  - Repository Implementation        │
└─────────────────────────────────────┘
```

### Key Principles

✅ **Separation of Concerns** - Each layer has a single responsibility  
✅ **Dependency Rule** - Dependencies point inward (domain is independent)  
✅ **Testability** - Easy to test with dependency injection  
✅ **Scalability** - Easy to add new features  
✅ **Maintainability** - Clear code organization  

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.9.2+ |
| **State Management** | Riverpod 2.6.1 |
| **Local Database** | Hive 2.2.3 |
| **Error Handling** | Either/Failure Pattern (Dartz) |
| **Password Security** | SHA256 Hashing (Crypto) |
| **Value Comparison** | Equatable 2.0.7 |
| **Code Generation** | Hive Generator, Build Runner |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1     # State management
  hive: ^2.2.3                 # Local NoSQL database
  hive_flutter: ^1.1.0         # Hive Flutter integration
  dartz: ^0.10.1               # Functional programming
  crypto: ^3.0.3               # Password hashing
  equatable: ^2.0.7            # Value comparison

dev_dependencies:
  hive_generator: ^2.0.1       # Generate Hive adapters
  build_runner: ^2.4.13        # Code generation
```

---

## 📁 Project Structure

```
lib/
├── main.dart                           # Entry point + Hive setup
├── app/
│   └── app.dart                        # MaterialApp config
│
├── core/                               # Shared utilities
│   ├── error/failures.dart             # Failure classes
│   ├── usecases/usecase.dart           # Base UseCase
│   └── utils/
│       ├── either.dart                 # Either type
│       └── password_hasher.dart        # SHA256 hashing
│
└── features/
    ├── auth/                           # Authentication feature
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_local_datasource.dart
    │   │   │   └── auth_remote_datasource.dart (stub)
    │   │   ├── models/
    │   │   │   ├── user_model.dart
    │   │   │   └── user_model.g.dart (generated)
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/user.dart
    │   │   ├── repositories/auth_repository.dart
    │   │   └── usecases/
    │   │       ├── register_usecase.dart
    │   │       ├── login_usecase.dart
    │   │       ├── logout_usecase.dart
    │   │       ├── get_current_user_usecase.dart
    │   │       └── check_auth_status_usecase.dart
    │   └── presentation/
    │       ├── pages/
    │       │   ├── login_page.dart
    │       │   └── register_page.dart
    │       ├── state/auth_state.dart
    │       ├── notifiers/auth_notifier.dart
    │       └── providers/auth_providers.dart
    │
    └── splash/                         # Splash screen feature
        └── presentation/
            └── pages/splash_page.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2+
- Dart SDK
- IDE (VS Code or Android Studio)

### Installation

1. **Clone the repository**
   ```bash
   cd tutor_finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## 🎯 Usage Flow

### First Time User

1. **App Opens** → Splash Screen (2 seconds)
2. **No User Found** → Navigates to Login Page
3. **Tap "Register"** → Registration Page
4. **Fill Form**:
   - Name: John Doe
   - Email: john@example.com
   - Password: password123
   - Confirm Password: password123
5. **Tap "Register"** → User Created
6. **Auto Login** → Navigates to Dashboard
7. **Dashboard Shows**:
   - Welcome message
   - User name and email
   - Logout button

### Returning User

1. **App Opens** → Splash Screen
2. **Checks Hive** → User Found
3. **Auto Login** → Navigates to Dashboard
4. **No Login Required** ✅

### Manual Login

1. **Enter Credentials**:
   - Email: john@example.com
   - Password: password123
2. **Tap "Login"**
3. **Validation Success** → Navigates to Dashboard

---

## 🔐 Security Features

### Password Hashing
- ✅ SHA256 hashing algorithm
- ✅ Passwords NEVER stored in plain text
- ✅ Hash stored in Hive encrypted field
- ✅ Verification on login

### Authentication State
- ✅ Secure session storage in Hive
- ✅ Automatic session restoration
- ✅ Clean logout with session clear

### Input Validation
- ✅ Email format validation
- ✅ Password length validation (min 6 chars)
- ✅ Password confirmation match
- ✅ Duplicate email prevention

---

## 🧪 Testing Scenarios

### ✅ Test 1: Registration
- Open app → Register → Enter valid details → Success → Dashboard

### ✅ Test 2: Duplicate Email
- Register user → Logout → Register same email → Error shown

### ✅ Test 3: Login
- Register → Logout → Login with credentials → Dashboard

### ✅ Test 4: Wrong Password
- Register → Logout → Login with wrong password → Error shown

### ✅ Test 5: Persistence
- Login → Close app → Reopen → Automatic login to Dashboard

### ✅ Test 6: Validation
- Empty fields → Error messages
- Invalid email → Error message
- Short password → Error message
- Password mismatch → Error message

---

## 📚 Documentation

Comprehensive documentation is provided in the following files:

- **[QUICK_START.md](./QUICK_START.md)** - Step-by-step setup and testing guide
- **[AUTHENTICATION_ARCHITECTURE.md](./AUTHENTICATION_ARCHITECTURE.md)** - Detailed architecture explanation
- **[PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)** - Folder structure and organization

---

## 🎨 Features Breakdown

### State Management (Riverpod)

**AuthState** - Manages authentication state
```dart
enum AuthStatus {
  initial,      // App just started
  loading,      // Processing authentication
  authenticated,// User logged in
  unauthenticated, // User logged out
  error,        // Error occurred
}
```

**AuthNotifier** - Handles authentication actions
- `checkAuthStatus()` - Check if user is logged in
- `register()` - Register new user
- `login()` - Authenticate user
- `logout()` - Clear authentication

### Local Storage (Hive)

**Boxes:**
1. `users` - Stores all registered users (Box<UserModel>)
2. `auth` - Stores current user session

**Data Model:**
```dart
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0) String id;
  @HiveField(1) String email;
  @HiveField(2) String name;
  @HiveField(3) String hashedPassword;
  @HiveField(4) DateTime createdAt;
}
```

---

## 🔄 Authentication Flow Diagram

```
┌─────────────┐
│   Splash    │
└──────┬──────┘
       │
       ├─→ Check Auth Status
       │
       ├─→ User Found?
       │
   ┌───┴───┐
   │  YES  │          │   NO   │
   └───┬───┘          └───┬────┘
       │                  │
       ↓                  ↓
┌──────────────┐   ┌──────────┐
│  Dashboard   │   │  Login   │
└──────────────┘   └────┬─────┘
                        │
                        ├─→ New User? → Register
                        │
                        ├─→ Existing User? → Login
                        │
                        └─→ Success → Dashboard
```

---

## 🚧 Future Enhancements

### 🔜 Planned Features
- [ ] Dashboard implementation with real features
- [ ] API integration (Remote Data Source)
- [ ] JWT token authentication
- [ ] Email verification
- [ ] Password reset functionality
- [ ] Social login (Google, Facebook)
- [ ] Biometric authentication
- [ ] Profile management
- [ ] Unit and widget tests

### 🔧 Technical Improvements
- [ ] Use `flutter_secure_storage` for sensitive data
- [ ] Implement bcrypt for password hashing
- [ ] Add refresh token mechanism
- [ ] Implement proper logging
- [ ] Add analytics
- [ ] Set up CI/CD pipeline

---

## 🤝 Contributing

This is a demonstration project showcasing Clean Architecture principles in Flutter. Feel free to:
- Study the code structure
- Learn the patterns used
- Extend with new features
- Improve the implementation

---

## 📖 Learning Resources

### Clean Architecture
- [The Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)

### State Management
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter State Management Guide](https://docs.flutter.dev/data-and-backend/state-mgmt)

### Local Storage
- [Hive Documentation](https://docs.hivedb.dev/)
- [Flutter Data Persistence](https://docs.flutter.dev/cookbook/persistence)

---

## 📝 License

This project is for educational purposes.

---

## 👨‍💻 Architecture Highlights

### ✅ What Makes This Implementation Special?

1. **True Clean Architecture**
   - Domain layer is 100% framework-independent
   - No Flutter imports in business logic
   - Easy to port to other platforms

2. **Proper Dependency Injection**
   - All dependencies injected via Riverpod
   - No singletons or static dependencies
   - Fully testable code

3. **Type-Safe Error Handling**
   - Either<Failure, Result> pattern
   - No try-catch at UI level
   - Explicit error handling

4. **Immutable State**
   - All states are immutable
   - State changes via copyWith()
   - Predictable state management

5. **Feature-First Organization**
   - Each feature is self-contained
   - Easy to add/remove features
   - Clear boundaries

6. **Security Best Practices**
   - Password hashing
   - No plain text storage
   - Secure session management

---

## 📊 Code Quality

- ✅ No Flutter analyze warnings
- ✅ Consistent naming conventions
- ✅ Comprehensive documentation
- ✅ Clean separation of concerns
- ✅ SOLID principles applied
- ✅ DRY (Don't Repeat Yourself)

---

## 🎓 What You'll Learn

By studying this project, you'll understand:
1. How to structure a Flutter app with Clean Architecture
2. How to implement authentication with local storage
3. How to use Riverpod for state management
4. How to separate business logic from UI
5. How to handle errors functionally
6. How to persist data with Hive
7. How to hash passwords securely
8. How to organize code in feature modules

---

## 💡 Key Takeaways

1. **Clean Architecture isn't complicated** - It's just proper separation of concerns
2. **Riverpod makes DI easy** - No need for GetIt or other DI frameworks
3. **Hive is powerful** - Type-safe local storage with minimal boilerplate
4. **Either pattern is elegant** - Functional error handling is clear and explicit
5. **Feature-first scales well** - Easy to maintain as app grows

---

**Built with ❤️ using Flutter & Clean Architecture**

---

## 📞 Support

For questions or issues:
1. Check the documentation files
2. Review the code comments
3. Study the architecture diagrams
4. Refer to official Flutter/Riverpod/Hive docs

---

**Happy Learning! 🚀**
