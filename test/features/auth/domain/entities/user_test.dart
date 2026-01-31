import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_finder/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    final tUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'Test User',
      role: UserRole.student,
      token: 'token',
      refreshToken: 'refresh',
      createdAt: DateTime(2023, 1, 1),
    );

    // Test 1: Equality support
    test('should be equal when props are the same', () {
      final tUser2 = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.student,
        token: 'token',
        refreshToken: 'refresh',
        createdAt: DateTime(2023, 1, 1),
      );
      expect(tUser, equals(tUser2));
    });

    // Test 2: CopyWith
    test('copyWith should return a valid copy with updated values', () {
      final updatedUser = tUser.copyWith(name: 'New Name');
      expect(updatedUser.name, 'New Name');
      expect(updatedUser.email, tUser.email);
      expect(updatedUser.id, tUser.id);
    });

    // Test 3: Default Role
    test('should have default role as student when not provided', () {
      final user = User(
        id: '2',
        email: 'email@test.com',
        name: 'name',
        createdAt: DateTime.now(),
      );
      expect(user.role, UserRole.student);
    });

    // Test 4: CopyWith Null/Empty
    test(
      'copyWith should return object with same values if no arguments passed',
      () {
        final copy = tUser.copyWith();
        expect(copy, equals(tUser));
      },
    );

    // Test 5: Props Logic
    test('props should contain all properties for Equatable', () {
      expect(tUser.props, [
        '1',
        'test@example.com',
        'Test User',
        UserRole.student,
        'token',
        'refresh',
        DateTime(2023, 1, 1),
      ]);
    });
  });
}
