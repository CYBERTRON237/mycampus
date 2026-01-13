import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/features/messaging/data/datasources/messaging_remote_datasource.dart';
import '../lib/features/messaging/data/repositories/messaging_repository_impl.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'messaging_search_test.mocks.dart';

void main() {
  group('Messaging Search Tests', () {
    late MockClient mockClient;
    late MessagingRemoteDataSourceImpl dataSource;
    late MessagingRepositoryImpl repository;

    setUp(() {
      mockClient = MockClient();
      dataSource = MessagingRemoteDataSourceImpl(
        client: mockClient,
        baseUrl: 'http://127.0.0.1/mycampus',
        authToken: 'test_token',
      );
      repository = MessagingRepositoryImpl(
        remoteDataSource: dataSource,
        currentUserId: '1',
      );
    });

    group('Search Users by Name', () {
      test('should return users when search is successful', () async {
        // Arrange
        const query = 'john';
        final mockResponse = '''
        {
          "success": true,
          "data": [
            {
              "id": "2",
              "first_name": "John",
              "last_name": "Doe",
              "email": "john@example.com",
              "profile_photo_url": null,
              "profile_picture": null,
              "phone": "1234567890",
              "primary_role": "student"
            }
          ]
        }
        ''';

        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await repository.searchUsers(query);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (error) => fail('Expected success but got error: $error'),
          (users) {
            expect(users.length, 1);
            expect(users.first.name, 'John Doe');
            expect(users.first.phone, '1234567890');
          },
        );
      });

      test('should handle empty search query', () async {
        // Act
        final result = await repository.searchUsers('');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error, contains('Failed to search users')),
          (users) => fail('Expected error but got users'),
        );
      });

      test('should handle API error response', () async {
        // Arrange
        const query = 'john';
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Server Error', 500));

        // Act
        final result = await repository.searchUsers(query);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error, contains('Failed to search users')),
          (users) => fail('Expected error but got users'),
        );
      });
    });

    group('Search Users by Phone', () {
      test('should return users when phone search is successful', () async {
        // Arrange
        const phone = '1234567890';
        final mockResponse = '''
        {
          "success": true,
          "data": [
            {
              "id": "2",
              "first_name": "Jane",
              "last_name": "Smith",
              "email": "jane@example.com",
              "profile_photo_url": null,
              "profile_picture": null,
              "phone": "1234567890",
              "primary_role": "teacher"
            }
          ]
        }
        ''';

        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await repository.searchUsersByPhone(phone);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (error) => fail('Expected success but got error: $error'),
          (users) {
            expect(users.length, 1);
            expect(users.first.name, 'Jane Smith');
            expect(users.first.phone, '1234567890');
          },
        );
      });

      test('should handle empty phone number', () async {
        // Act
        final result = await repository.searchUsersByPhone('');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error, contains('Failed to search users by phone')),
          (users) => fail('Expected error but got users'),
        );
      });

      test('should handle phone search API error', () async {
        // Arrange
        const phone = '1234567890';
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result = await repository.searchUsersByPhone(phone);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error, contains('Failed to search users by phone')),
          (users) => fail('Expected error but got users'),
        );
      });
    });

    group('URL Construction Tests', () {
      test('should construct correct search URL for name search', () async {
        // Arrange
        const query = 'john';
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"success": true, "data": []}', 200));

        // Act
        await repository.searchUsers(query);

        // Assert
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should construct correct search URL for phone search', () async {
        // Arrange
        const phone = '1234567890';
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"success": true, "data": []}', 200));

        // Act
        await repository.searchUsersByPhone(phone);

        // Assert
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });
  });
}
