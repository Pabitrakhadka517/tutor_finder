# 🚀 Quick Start Guide

## Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- IDE (VS Code or Android Studio)

---

## 📦 Installation Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Adapters (Already done, but for future reference)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
```bash
flutter run
```

---

## 🎯 Testing the App

### First Time User Flow

#### 1. **Splash Screen**
- App opens showing "LearnMentor" logo
- Loading indicator appears
- After 2 seconds, navigates to Login (no user registered yet)

#### 2. **Registration**
- On Login page, tap "Register"
- Fill in the form:
  - **Full Name**: John Doe
  - **Email**: john@example.com
  - **Password**: password123
  - **Confirm Password**: password123
- Tap "Register" button
- Upon success:
  - User is automatically logged in
  - Navigates to Dashboard
  - Shows welcome message with user info

#### 3. **Dashboard**
- Displays: "Welcome to Dashboard!"
- Shows user name and email
- Has logout button in app bar

#### 4. **Logout**
- Tap logout icon in app bar
- Returns to Login page

#### 5. **Login**
- Fill in credentials:
  - **Email**: john@example.com
  - **Password**: password123
- Tap "Login" button
- Navigates to Dashboard

---

### Second Run Flow

#### 1. **Splash Screen**
- App opens showing "LearnMentor" logo
- Checks authentication status from Hive
- **If logged in**: Automatically navigates to Dashboard
- **If logged out**: Navigates to Login page

---

## ✅ Testing Scenarios

### Scenario 1: Successful Registration
1. Open app
2. Tap "Register"
3. Enter valid details
4. Tap "Register"
5. ✅ Should navigate to Dashboard

### Scenario 2: Duplicate Email Registration
1. Register with email: test@example.com
2. Logout
3. Try to register again with same email
4. ❌ Should show error: "Email already registered"

### Scenario 3: Successful Login
1. Register a user
2. Logout
3. Login with same credentials
4. ✅ Should navigate to Dashboard

### Scenario 4: Wrong Password
1. Register with email: test@example.com
2. Logout
3. Try to login with wrong password
4. ❌ Should show error: "Invalid email or password"

### Scenario 5: Login Persistence
1. Register and login
2. Close app (force close)
3. Reopen app
4. ✅ Should go directly to Dashboard (skip login)

### Scenario 6: Validation Errors
**Registration:**
- Empty name → "Please enter your name"
- Invalid email → "Please enter a valid email"
- Password < 6 chars → "Password must be at least 6 characters"
- Passwords don't match → "Passwords do not match"

**Login:**
- Empty email → "Please enter your email"
- Invalid email → "Please enter a valid email"
- Empty password → "Please enter your password"

---

## 🔐 Security Features

### Password Hashing
- Passwords are hashed using SHA256 before storage
- Plain text passwords are NEVER stored
- Test by checking Hive database:
  ```bash
  # On Android
  adb shell
  cd /data/data/com.example.tutor_finder/app_flutter/
  ls
  ```

### Authentication Persistence
- Current user ID stored in Hive
- Survives app restarts
- Cleared on logout

---

## 📱 UI Features

### Login Page
- Email input field
- Password input field with show/hide toggle
- Login button with loading state
- Link to registration page

### Register Page
- Name input field
- Email input field
- Password input field with show/hide toggle
- Confirm password field with show/hide toggle
- Register button with loading state
- Link back to login page

### Splash Page
- App logo (school icon)
- App name: "LearnMentor"
- Loading indicator
- Automatic navigation after auth check

### Dashboard (Placeholder)
- Welcome message
- User information display
- Logout button
- Placeholder text for future features

---

## 🛠️ Development Commands

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

### Check for Errors
```bash
flutter analyze
```

### Format Code
```bash
flutter format .
```

### Generate Code
```bash
# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on file changes)
flutter pub run build_runner watch
```

---

## 📊 Hive Database Inspection

### Boxes Created
1. **users** - Stores all registered users
2. **auth** - Stores current user session

### Inspect Data (During Development)
```dart
// Add this temporary code to inspect Hive data
void debugHive() async {
  final usersBox = await Hive.openBox<UserModel>('users');
  print('All users: ${usersBox.values.toList()}');
  
  final authBox = await Hive.openBox('auth');
  print('Current user ID: ${authBox.get('currentUserId')}');
}
```

---

## 🐛 Troubleshooting

### Issue: "Type 'UserModel' is not a subtype of type 'UserModel'"
**Solution:** Delete Hive boxes and restart
```dart
// Add to main() temporarily
await Hive.deleteBoxFromDisk('users');
await Hive.deleteBoxFromDisk('auth');
```

### Issue: Build fails with "No adapter found"
**Solution:** Regenerate Hive adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: App crashes on startup
**Solution:** Check if Hive is initialized
```dart
// Make sure this is in main()
await Hive.initFlutter();
Hive.registerAdapter(UserModelAdapter());
```

### Issue: Login persists after logout
**Solution:** Clear auth box
```dart
final authBox = await Hive.openBox('auth');
await authBox.clear();
```

---

## 📁 Key Files to Check

### Entry Point
- `lib/main.dart` - Hive initialization and app start

### Authentication Flow
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/splash/presentation/pages/splash_page.dart`

### State Management
- `lib/features/auth/presentation/providers/auth_providers.dart`
- `lib/features/auth/presentation/notifiers/auth_notifier.dart`
- `lib/features/auth/presentation/state/auth_state.dart`

### Business Logic
- `lib/features/auth/domain/usecases/`
- `lib/features/auth/domain/repositories/auth_repository.dart`

### Data Persistence
- `lib/features/auth/data/datasources/auth_local_datasource.dart`
- `lib/features/auth/data/models/user_model.dart`

---

## 🎨 Customization

### Change App Theme
Edit: `lib/app/theme/theme.dart`

### Change App Name
Edit: `lib/app/app.dart`
```dart
title: 'Your App Name',
```

### Change Primary Color
Edit: `lib/features/auth/presentation/pages/login_page.dart`
```dart
backgroundColor: Colors.blue, // Change to your color
```

---

## 📚 Next Steps

### Implement Dashboard Features
1. Create dashboard feature module
2. Add user profile management
3. Add main app functionality

### Add API Integration
1. Install `dio` package
2. Implement `AuthRemoteDataSource`
3. Add API endpoints
4. Implement token storage
5. Add token refresh logic

### Enhance Security
1. Use `flutter_secure_storage` for tokens
2. Implement biometric authentication
3. Add email verification
4. Implement password reset

### Add Testing
1. Write unit tests for use cases
2. Write widget tests for UI
3. Write integration tests for flows
4. Set up CI/CD

---

## 📖 Documentation

- [AUTHENTICATION_ARCHITECTURE.md](./AUTHENTICATION_ARCHITECTURE.md) - Detailed architecture explanation
- [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md) - Folder structure and organization
- [README.md](./README.md) - Project overview

---

## 🤝 Support

For issues or questions:
1. Check documentation files
2. Review code comments
3. Check Flutter/Riverpod/Hive documentation

---

## ✅ Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] Hive adapters generated
- [ ] App runs successfully
- [ ] Registration works
- [ ] Login works
- [ ] Logout works
- [ ] Login persistence works
- [ ] Validation errors show correctly
- [ ] Password hashing works
- [ ] Navigation flows correctly

---

**Happy Coding! 🎉**
