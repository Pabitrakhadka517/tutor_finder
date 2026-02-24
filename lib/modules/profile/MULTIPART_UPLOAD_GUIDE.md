# Profile Module - Multipart Upload Handling

## Overview

This document explains how to handle multipart file uploads for profile images in the Profile Module, including best practices for image validation, compression, and error handling.

## Architecture Flow

```
UI Screen → BLoC → Use Case → Repository → Remote Data Source → API
    ↓         ↓        ↓          ↓             ↓              ↓
  Image    Event    Domain      Domain        Dio          Backend
  Picker   Emitted  Validation  Logic      FormData       Endpoint
```

## Implementation Details

### 1. Image Selection and Validation (UI Layer)

```dart
// ProfileEditScreen._pickImage()
Future<void> _pickImage() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,        // Compress to 1024px max width
    maxHeight: 1024,       // Compress to 1024px max height
    imageQuality: 85,      // Compress to 85% quality
  );

  if (image != null) {
    final file = File(image.path);
    final error = ProfileValidators.validateImageFile(file);
    
    if (error != null) {
      // Show validation error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _selectedImage = file);
  }
}
```

### 2. Domain Layer Validation

```dart
// ProfileValidators.validateImageFile()
static String? validateImageFile(File file) {
  // Check file exists
  if (!file.existsSync()) return 'File does not exist';
  
  // Check file size (max 5MB)
  final sizeInMB = file.lengthSync() / (1024 * 1024);
  if (sizeInMB > 5) return 'File size must be less than 5MB';
  
  // Check file extension
  final extension = file.path.split('.').last.toLowerCase();
  if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
    return 'Only JPG, PNG, and WebP images are supported';
  }
  
  return null; // Valid
}
```

### 3. Use Case Processing

```dart
// UpdateProfileUsecase.call()
Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) async {
  // Frontend validation
  if (params.name.isEmpty) return Left(ValidationFailure('Name is required'));
  
  if (params.profileImagePath != null) {
    final file = File(params.profileImagePath!);
    final imageError = ProfileValidators.validateImageFile(file);
    if (imageError != null) return Left(ValidationFailure(imageError));
  }
  
  // Validate tutor fields if provided
  if (params.tutorFields != null) {
    // ... tutor validation logic
  }
  
  return repository.updateProfile(params);
}
```

### 4. Repository Implementation

```dart
// ProfileRepositoryImpl.updateProfile()
Future<Either<Failure, ProfileEntity>> updateProfile(UpdateProfileParams params) async {
  try {
    // Call remote API
    final profileDto = await remoteDatasource.updateProfile(params);
    
    // Map to entity
    final profileEntity = ProfileMapper.dtoToEntity(profileDto);
    
    // Cache locally
    await localDatasource.cacheProfile(ProfileMapper.entityToHiveModel(profileEntity));
    
    return Right(profileEntity);
  } catch (e) {
    return Left(_mapExceptionToFailure(e));
  }
}
```

### 5. Remote Data Source - Multipart Implementation

```dart
// ProfileRemoteDatasourceImpl.updateProfile()
Future<ProfileDto> updateProfile(UpdateProfileParams params) async {
  final formData = FormData();
  
  // Add text fields
  formData.fields.addAll([
    MapEntry('name', params.name),
    if (params.phone != null) MapEntry('phone', params.phone!),
    if (params.speciality != null) MapEntry('speciality', params.speciality!),
    if (params.address != null) MapEntry('address', params.address!),
    // Add tutor fields if provided
    if (params.tutorFields?.bio != null) 
      MapEntry('bio', params.tutorFields!.bio!),
    if (params.tutorFields?.hourlyRate != null)
      MapEntry('hourlyRate', params.tutorFields!.hourlyRate.toString()),
    // ... other tutor fields
  ]);
  
  // Add image file if provided
  if (params.profileImagePath != null) {
    final file = File(params.profileImagePath!);
    final fileName = file.path.split('/').last;
    
    formData.files.add(
      MapEntry(
        'profileImage',
        await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType('image', _getImageType(fileName)),
        ),
      ),
    );
  }
  
  final response = await networkClient.put(
    '/profile/update',
    data: formData,
    options: Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ),
  );
  
  return ProfileDto.fromJson(response.data['data']);
}

String _getImageType(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'jpeg';
    case 'png':
      return 'png';
    case 'webp':
      return 'webp';
    default:
      return 'jpeg';
  }
}
```

## Error Handling

### Common Upload Errors

1. **Network Errors**
   - Connection timeout
   - Server unavailable
   - Request timeout

2. **Validation Errors**
   - File too large
   - Invalid file type
   - Missing required fields

3. **Server Errors**
   - Authentication failed
   - Insufficient permissions
   - Server storage full

### Error Mapping

```dart
Failure _mapExceptionToFailure(Exception exception) {
  if (exception is DioException) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure('Connection timeout. Please try again.');
      
      case DioExceptionType.connectionError:
        return NetworkFailure('No internet connection. Please check your connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message = exception.response?.data['message'] ?? 'Server error occurred';
        
        if (statusCode == 413) return ValidationFailure('File too large');
        if (statusCode == 415) return ValidationFailure('Unsupported file type');
        if (statusCode == 401) return AuthFailure('Authentication failed');
        
        return ServerFailure(message);
      
      default:
        return ServerFailure('Upload failed. Please try again.');
    }
  }
  
  return ServerFailure('Unexpected error occurred');
}
```

## Testing Strategies

### 1. Unit Tests

```dart
group('ProfileRemoteDatasource - updateProfile', () {
  test('should create proper FormData with image file', () async {
    // Arrange
    final params = UpdateProfileParams(
      name: 'John Doe',
      profileImagePath: '/path/to/image.jpg',
    );
    
    // Act
    await datasource.updateProfile(params);
    
    // Assert
    verify(() => mockDio.put(
      '/profile/update',
      data: any(named: 'data', that: isA<FormData>()),
      options: any(named: 'options'),
    ));
  });
  
  test('should handle file upload errors properly', () async {
    // Test various error scenarios
  });
});
```

### 2. Integration Tests

```dart
testWidgets('should upload profile image successfully', (tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());
  
  // Mock image picker
  when(() => mockImagePicker.pickImage(source: any(named: 'source')))
      .thenAnswer((_) async => XFile('test_image.jpg'));
  
  // Act
  await tester.tap(find.byIcon(Icons.camera_alt));
  await tester.pumpAndSettle();
  
  // Assert
  expect(find.text('Profile updated successfully'), findsOneWidget);
});
```

## Performance Considerations

### 1. Image Optimization

- **Compression**: Use `ImagePicker` quality parameter (85% recommended)
- **Resizing**: Limit max dimensions (1024x1024px recommended)
- **Format**: Prefer WebP for better compression, fallback to JPEG

### 2. Progress Indication

```dart
// Show upload progress (optional)
formData.files.add(
  MapEntry(
    'profileImage',
    await MultipartFile.fromFile(
      file.path,
      filename: fileName,
      onUploadProgress: (sent, total) {
        final progress = sent / total;
        // Update progress indicator in UI
      },
    ),
  ),
);
```

### 3. Background Upload

For large files, consider implementing background upload using:
- WorkManager (Android)
- Background App Refresh (iOS) 
- Store failed uploads for retry

## Security Considerations

### 1. File Validation
- Always validate file type on both client and server
- Check file size limits
- Scan for malware (server-side)

### 2. Authentication
- Include authentication token in headers
- Validate user permissions server-side

### 3. Storage
- Use secure cloud storage (AWS S3, Google Cloud Storage)
- Implement proper access controls
- Generate signed URLs for image access

## Backend API Contract

### Request Format
```http
PUT /api/profile/update
Content-Type: multipart/form-data
Authorization: Bearer <token>

--boundary
Content-Disposition: form-data; name="name"

John Doe
--boundary
Content-Disposition: form-data; name="profileImage"; filename="image.jpg"
Content-Type: image/jpeg

<binary image data>
--boundary--
```

### Response Format
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": "user123",
    "name": "John Doe",
    "email": "john@example.com",
    "profileImage": "https://storage.example.com/profiles/user123/image.jpg",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "File too large",
  "errors": {
    "profileImage": ["File size must not exceed 5MB"]
  }
}
```

## Best Practices

1. **Always validate files** on both client and server
2. **Compress images** before upload to reduce bandwidth
3. **Show progress** for uploads that might take time
4. **Handle offline scenarios** - cache failed uploads for retry
5. **Implement retry logic** for network failures
6. **Use proper MIME types** for better server handling
7. **Clean up temporary files** after successful upload
8. **Test with various file types and sizes**
9. **Monitor upload performance** and optimize as needed
10. **Implement proper error messages** for better UX