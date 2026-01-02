# Authentication Feature - Clean Architecture Implementation

## Overview
This document explains the complete authentication implementation using Clean Architecture principles, Riverpod for state management, and Hive for local storage.

---

## 🏗️ Architecture Layers

### 1. **Domain Layer** (Business Logic - Framework Independent)
Located in: `lib/features/auth/domain/`

#### Entities
- **User** (`entities/user.dart`)
  - Pure Dart class representing user in business logic
  - Properties: `id`, `email`, `name`, `createdAt`
  - Uses Equatable for value comparison

#### Repository Interface
- **AuthRepository** (`repositories/auth_repository.dart`)
  - Abstract contract that data layer must implement
  - Methods:
    - `register()` - Register new user
    - `login()` - Authenticate user
    - `logout()` - Clear authentication
    - `getCurrentUser()` - Get logged-in user
    - `isAuthenticated()` - Check auth status

#### Use Cases
Each use case encapsulates a single business operation:

1. **RegisterUseCase** - Validates and registers new user
2. **LoginUseCase** - Validates and authenticates user
3. **LogoutUseCase** - Logs out current user
4. **GetCurrentUserUseCase** - Retrieves authenticated user
5. **CheckAuthStatusUseCase** - Checks if user is logged in

**Pattern**: Each use case follows the Command pattern and returns `Either<Failure, Result>`

---

### 2. **Data Layer** (Implementation Details)
Located in: `lib/features/auth/data/`

#### Models
- **UserModel** (`models/user_model.dart`)
  - Extends `User` entity
  - Adds Hive annotations for persistence
  - Includes `hashedPassword` field (never exposed to domain)
  - Has methods: `toEntity()`, `fromEntity()`, `toJson()`, `fromJson()`
  - Generated adapter: `user_model.g.dart`

#### Data Sources

**Local Data Source** (`datasources/auth_local_datasource.dart`)
- Uses Hive for local storage
- Two boxes:
  - `users` - Stores all registered users (keyed by email)
  - `auth` - Stores current user ID
- Methods:
  - `saveUser()` - Store user in Hive
  - `getUserByEmail()` - Retrieve user by email
  - `getCurrentUser()` - Get logged-in user
  - `removeCurrentUser()` - Clear auth state
  - `emailExists()` - Check duplicate registration
  - `setCurrentUserId()` - Persist logged-in user
  - `getCurrentUserId()` - Get logged-in user ID

**Remote Data Source** (`datasources/auth_remote_datasource.dart`)
- **STUB IMPLEMENTATION** - For future API integration
- All methods throw `UnimplementedError`
- Ready for HTTP client injection (Dio/http)

#### Repository Implementation
- **AuthRepositoryImpl** (`repositories/auth_repository_impl.dart`)
  - Implements `AuthRepository` interface
  - Coordinates between local and remote data sources
  - Currently only uses local data source
  - Handles:
    - Password hashing using `PasswordHasher`
    - Email duplication check
    - User session management
    - Error handling and conversion to domain Failures

---

### 3. **Presentation Layer** (UI & State Management)
Located in: `lib/features/auth/presentation/`

#### State
- **AuthState** (`state/auth_state.dart`)
  - Represents authentication state
  - Status enum: `initial`, `loading`, `authenticated`, `unauthenticated`, `error`
  - Properties: `status`, `user`, `errorMessage`
  - Immutable with `copyWith()` method

#### Notifier
- **AuthNotifier** (`notifiers/auth_notifier.dart`)
  - Extends `StateNotifier<AuthState>`
  - Manages authentication state changes
  - Methods:
    - `checkAuthStatus()` - Check if user is logged in
    - `register()` - Register new user
    - `login()` - Authenticate user
    - `logout()` - Sign out user
    - `clearError()` - Reset error state

#### Providers
- **auth_providers.dart** - Riverpod provider definitions
  ```
  Data Source Providers
         ↓
  Repository Provider
         ↓
  UseCase Providers
         ↓
  AuthNotifier Provider (StateNotifier)
  ```

#### Pages
- **LoginPage** (`pages/login_page.dart`)
  - Email & password form
  - Form validation
  - Navigation to register page
  - Listens to auth state for errors

- **RegisterPage** (`pages/register_page.dart`)
  - Name, email, password, confirm password form
  - Form validation (including password match)
  - Navigation back to login
  - Listens to auth state for errors

---

## 🔐 Password Security

**PasswordHasher** (`lib/core/utils/password_hasher.dart`)
- Uses SHA256 from `crypto` package
- Methods:
  - `hashPassword()` - Convert plain password to hash
  - `verifyPassword()` - Check password against stored hash
- Passwords are **NEVER** stored in plain text
- Hash is stored in `UserModel.hashedPassword`

---

## 🎯 Authentication Flow

### Registration Flow
```
1. User fills registration form → RegisterPage
2. Form validation
3. User taps Register button
4. AuthNotifier.register() called
5. RegisterUseCase validates input
6. AuthRepository.register() called
7. Check if email exists (emailExists())
8. Hash password (PasswordHasher)
9. Create UserModel
10. Save to Hive (saveUser())
11. Set as current user (setCurrentUserId())
12. Return User entity
13. AuthNotifier updates state → AuthState.authenticated
14. UI navigates to Dashboard
```

### Login Flow
```
1. User fills login form → LoginPage
2. Form validation
3. User taps Login button
4. AuthNotifier.login() called
5. LoginUseCase validates input
6. AuthRepository.login() called
7. Get user by email (getUserByEmail())
8. Verify password (PasswordHasher.verifyPassword())
9. If valid: Set as current user (setCurrentUserId())
10. Return User entity
11. AuthNotifier updates state → AuthState.authenticated
12. UI navigates to Dashboard
```

### Splash Screen Flow
```
1. App starts → SplashPage displayed
2. Show logo and loading indicator
3. Wait 2 seconds (for UX)
4. AuthNotifier.checkAuthStatus() called
5. CheckAuthStatusUseCase checks if user is logged in
6. If yes:
   - GetCurrentUserUseCase retrieves user
   - AuthState.authenticated
   - Navigate to Dashboard
7. If no:
   - AuthState.unauthenticated
   - Navigate to LoginPage
```

### Logout Flow
```
1. User taps logout button
2. AuthNotifier.logout() called
3. LogoutUseCase executed
4. AuthRepository.logout() called
5. Remove current user from storage (removeCurrentUser())
6. AuthState.unauthenticated
7. Navigate to LoginPage
```

---

## 🔗 Riverpod Provider Wiring

### Dependency Injection Hierarchy
```dart
// 1. Data Source Providers (Leaf dependencies)
authLocalDataSourceProvider → AuthLocalDataSourceImpl()
authRemoteDataSourceProvider → AuthRemoteDataSourceImpl()

// 2. Repository Provider (depends on data sources)
authRepositoryProvider → AuthRepositoryImpl(
  localDataSource: ref.read(authLocalDataSourceProvider),
  remoteDataSource: ref.read(authRemoteDataSourceProvider),
)

// 3. Use Case Providers (depend on repository)
registerUseCaseProvider → RegisterUseCase(authRepository)
loginUseCaseProvider → LoginUseCase(authRepository)
logoutUseCaseProvider → LogoutUseCase(authRepository)
getCurrentUserUseCaseProvider → GetCurrentUserUseCase(authRepository)
checkAuthStatusUseCaseProvider → CheckAuthStatusUseCase(authRepository)

// 4. State Notifier Provider (depends on use cases)
authNotifierProvider → AuthNotifier(
  registerUseCase,
  loginUseCase,
  logoutUseCase,
  getCurrentUserUseCase,
  checkAuthStatusUseCase,
)
```

### Usage in UI
```dart
// Reading state
final authState = ref.watch(authNotifierProvider);

// Calling methods
ref.read(authNotifierProvider.notifier).login(email: '', password: '');

// Listening to changes
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  if (next.status == AuthStatus.error) {
    // Show error
  }
});
```

---

## 📦 Hive Setup

### Initialization (`main.dart`)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with Flutter
  await Hive.initFlutter();
  
  // Register type adapters
  Hive.registerAdapter(UserModelAdapter());
  
  // Start app with Riverpod
  runApp(ProviderScope(child: MyApp()));
}
```

### Boxes Used
1. **users** (Box<UserModel>)
   - Key: email (String)
   - Value: UserModel
   - Purpose: Store all registered users

2. **auth** (Box<dynamic>)
   - Key: 'currentUserId' (String)
   - Value: User ID (String)
   - Purpose: Persist login state

---

## ✅ Clean Architecture Boundaries

### Rules Enforced
1. ✅ **Domain layer has NO dependencies**
   - No Flutter imports
   - No Hive imports
   - Pure Dart only

2. ✅ **Domain defines contracts, Data implements**
   - `AuthRepository` interface in domain
   - `AuthRepositoryImpl` in data

3. ✅ **Data models ≠ Domain entities**
   - `UserModel` (data) extends `User` (domain)
   - Conversion via `toEntity()` and `fromEntity()`

4. ✅ **Presentation depends on domain, not data**
   - `AuthNotifier` uses `User` entity, not `UserModel`
   - Uses use cases, not repository directly

5. ✅ **Error handling via Either pattern**
   - `Either<Failure, Result>`
   - Left = Failure, Right = Success
   - Type-safe error handling

---

## 🧪 Testing Strategy (Future)

### Domain Layer Tests
- Test use cases with mock repository
- Test entity equality
- Test validation logic

### Data Layer Tests
- Test repository implementation with mock data sources
- Test model serialization/deserialization
- Test password hashing

### Presentation Layer Tests
- Test AuthNotifier state transitions
- Test widget interactions
- Test navigation logic

---

## 🚀 Running the App

### Setup
```bash
# Install dependencies
flutter pub get

# Run build_runner (if you regenerate Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### First Run Flow
1. Splash screen appears
2. No user is authenticated
3. Navigates to Login page
4. Tap "Register" to create account
5. Fill form and submit
6. Automatically logged in
7. Navigates to Dashboard

### Subsequent Runs
1. Splash screen appears
2. Checks Hive for current user ID
3. User found → Navigate to Dashboard
4. User not found → Navigate to Login

---

## 📝 Key Design Decisions

1. **Why Either instead of try-catch?**
   - Type-safe error handling
   - Forces explicit error handling
   - Functional programming pattern

2. **Why separate Entity and Model?**
   - Domain independence
   - Data layer can change without affecting business logic
   - Multiple data sources can map to same entity

3. **Why StateNotifier instead of ChangeNotifier?**
   - Immutable state
   - Type-safe
   - Better with Riverpod
   - Easier to test

4. **Why Hive instead of SharedPreferences?**
   - Type-safe with adapters
   - Better performance
   - Can store complex objects
   - Query capabilities

5. **Why Use Cases?**
   - Single Responsibility Principle
   - Reusable business logic
   - Easy to test
   - Clear separation of concerns

---

## 🔄 Future Enhancements

1. **API Integration**
   - Implement `AuthRemoteDataSource`
   - Add HTTP client (Dio)
   - Implement token-based authentication
   - Sync local and remote data

2. **Enhanced Security**
   - Use bcrypt instead of SHA256
   - Add salt to password hashing
   - Implement JWT token storage
   - Add biometric authentication

3. **Features**
   - Email verification
   - Password reset
   - Remember me option
   - Social login (Google, Facebook)

4. **State Management**
   - Add loading states for individual operations
   - Implement optimistic updates
   - Add retry logic for failed operations

---

## 📚 Related Files

- Core utilities: `lib/core/`
  - `utils/either.dart` - Either type implementation
  - `error/failures.dart` - Failure classes
  - `usecases/usecase.dart` - UseCase base class
  - `utils/password_hasher.dart` - Password hashing utility

- Features:
  - Auth: `lib/features/auth/`
  - Splash: `lib/features/splash/`

- App setup:
  - `lib/main.dart` - Entry point with Hive initialization
  - `lib/app/app.dart` - MaterialApp configuration
