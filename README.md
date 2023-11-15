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
