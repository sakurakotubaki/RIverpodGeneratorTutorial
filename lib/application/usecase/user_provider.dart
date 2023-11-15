import 'package:rivepod_basic/application/repository/user_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/user.dart';
part 'user_provider.g.dart';

@riverpod
Future<List<User>> fetchUser(FetchUserRef ref) async {
  final users = ref.read(userServiceProvider);
  return await users.fetchUsers();
}
