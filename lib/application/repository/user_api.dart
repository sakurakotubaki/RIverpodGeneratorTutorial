import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rivepod_basic/domain/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_api.g.dart';

// 今回使用する機能を抽象クラスとして定義します
abstract class IUserService {
  Future<List<User>> fetchUsers();
}

/* IUserServiceというインターフェースを実装したクラスを作成します
インターフェースとは、クラスが実装しなければならないメソッドを定義したものです。他の専門用語だと、外の世界と接続するための窓口とも言われます。
*/
class UserService implements IUserService {
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

// 状態を破棄しないときは、@Riverpod(keepAlive: true)を使う
@Riverpod(keepAlive: true)
UserService userService(UserServiceRef ref) {
  return UserService(http.Client());
}
