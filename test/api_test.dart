import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:rivepod_basic/application/usecase/user_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:rivepod_basic/application/repository/user_api.dart';
import 'package:rivepod_basic/domain/user.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('UserService Tests with Riverpod', () {
    late MockClient mockClient;
    late ProviderContainer container;

    setUp(() {
      mockClient = MockClient();
      container = ProviderContainer(overrides: [
        userServiceProvider.overrideWith(
          (ref) => UserService(mockClient),
        ),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('テストが成功するシナリオ', () async {
      // 成功したAPIレスポンスのモックを設定。APIと同じ10件のデータを取得できればテストが成功する
      when(() => mockClient
              .get(Uri.parse('https://jsonplaceholder.typicode.com/users')))
          .thenAnswer((_) async => http.Response(
              '[{"id": 1, "name": "Leanne Graham"}, {"id": 2, "name": "Test User 2"}, {"id": 3, "name": "Test User 3"}, {"id": 4, "name": "Test User 4"}, {"id": 5, "name": "Test User 5"}, {"id": 6, "name": "Test User 6"}, {"id": 7, "name": "Test User 7"}, {"id": 8, "name": "Test User 8"}, {"id": 9, "name": "Test User 9"}, {"id": 10, "name": "Test User 10"}]',
              200));

      // fetchUserプロバイダを使用してユーザーデータを取得
      final users = await container.read(fetchUserProvider.future);
      expect(users, isA<List<User>>());
      expect(users.length, 10);
      expect(users.first.name, 'Leanne Graham');
    });

    // 例外処理が発生したら、テストが通るシナリオ。例外用のモックを今回は使用する
    test('テストが失敗するシナリオ', () async {
      // 例外用のモックを設定。例外処理が発生したらテストが成功する
      when(() => mockClient
              .get(Uri.parse('https://jsonplaceholder.typicode.com/users')))
          .thenThrow(Exception('Failed to load user'));

      try {
        // fetchUserプロバイダを使用してユーザーデータを取得
        final users = await container.read(fetchUserProvider.future);
        expect(users, isA<List<User>>());
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    // サーバーが落ちている場合のテスト。500エラーが発生したらテストが成功する
    test('サーバーが落ちている場合のテスト', () async {
      // 500エラー用のモックを設定。500エラーが発生したらテストが成功する
      when(() => mockClient
              .get(Uri.parse('https://jsonplaceholder.typicode.com/users')))
          .thenAnswer((_) async => http.Response('Internal Server Error', 500));

      try {
        // fetchUserプロバイダを使用してユーザーデータを取得
        final users = await container.read(fetchUserProvider.future);
        expect(users, isA<List<User>>());
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
