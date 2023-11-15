# rivepod_basic

## flutter_riverpodの依存関係を追加する
```bash
flutter pub add \
flutter_riverpod \
riverpod_annotation \
dev:riverpod_generator \
dev:build_runner \
dev:custom_lint \
dev:riverpod_lint
```

## Freezedの依存関係を追加する
```bash
flutter pub add \
  freezed_annotation \
  --dev build_runner \
  --dev freezed \
  json_annotation \
  --dev json_serializable
```

## Freezedでモデルクラスを作成する方法
公式にも載っている方法だと、requiredが使用例として紹介されている。引数が必須になるので、
必ずパラメーターに値を渡さなければならない。
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

@freezed
class NoteModel with _$NoteModel {
  const factory NoteModel({
    required String id,
    required String body,
    required DateTime createdAt,
  }) = _NoteModel;

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
}
```

引数入れなくても良い場面があって、初期値を最初から入れておけば良いときは、
int型なら`@Default(0)`String型なら`@Default('')`をつける。

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String email,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json)
      => _$UserFromJson(json);
}
```

エイリアス(別名)を使いたい場面があったとしたら、@JsonKey(name: 'user_name') と
いった感じで使う。

[参考になりそうな記事](https://zenn.dev/joo_hashi/articles/afec11fe63ae3f)
```dart
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    @Default(0) @JsonKey(name: 'id') int postId,// APIのIDが数字なので、int型にしてる
    @Default('') @JsonKey(name: 'title') String postTitle,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) =>
      _$PostFromJson(json);
}
```

## riverpod generatorを使用する
今回は、FutureProviderを使用して外部APIからHTTP GETメソッドを使用して、データを非同期に取得する。

[参考になりそうなZennの本](https://zenn.dev/joo_hashi/articles/afec11fe63ae3f)
## FutureProviderの使用例
generatorを使用しない例
```dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rivepod_basic/domain/user.dart';
// 今回使用する機能を抽象クラスとして定義します
abstract class IUserService {
  Future<List<User>> fetchUsers();
}

/* IUserServiceというインターフェースを実装したクラスを作成します
インターフェースとは、クラスが実装しなければならないメソッドを定義したものです。他の専門用語だと、外の世界と接続するための窓口とも言われます。
*/
class UserService implements IUserService {
  // テストのときに、モックを引数で渡すので必要
  final http.Client client;
  UserService(this.client);
  // httpパッケージを使用して外部APIからデータを取得します
  @override
  Future<List<User>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      // サーバーが200 OKを返した場合、JSONを解析してUserModelに変換します
      var jsonData = jsonDecode(response.body) as List;// as Listとするのは、jsonDecodeの戻り値がList<dynamic>型であるため
      // リストの要素をUserModelに変換して返却します
      return jsonData.map((user) => User.fromJson(user)).toList();
    } else {
      // サーバーがエラーレスポンスを返した場合は、例外をスローします
      throw Exception('Failed to load user');
    }
  }
}

// 今までの書き方
final userServiceProvider = Provider((ref) {
  // 引数を書かないとエラーが出る
  return UserService(http.Client());
});

final userFutureProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final users = ref.read(userServiceProvider);
  return await users.fetchUsers();
});
```

## generatorを使用した例
プロバイダーではなくて、関数を定義して、コードを書きコマンドを実行するとプロバイダーのファイルが自動生成される。
`@riverpod`とつけると、状態が破棄される。破棄したくないときは、`@Riverpod(keepAlive: true)`とアノテーションをつける。

```dart
import 'package:rivepod_basic/application/repository/user_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/user.dart';
part 'user_provider.g.dart';

@riverpod
Future<List<User>> fetchUser(FetchUserRef ref) async {
  final users = ref.read(userServiceProvider);
  return await users.fetchUsers();
}
```
