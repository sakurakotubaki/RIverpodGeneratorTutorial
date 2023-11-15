import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivepod_basic/domain/user.dart';

List<User> users = const [
  User(
    id: 1,
    name: 'Taro Yamada',
    email: 'taro.jp',
  ),
  User(
    id: 2,
    name: 'Hanako Yamada',
    email: 'hanako.jp',
  ),
  User(
    id: 3,
    name: 'Jiro Yamada',
    email: 'jiro.jp',
  ),
  User(
    id: 4,
    name: 'Sachiko Yamada',
    email: 'sachiko.jp',
  ),
  User(
    id: 5,
    name: 'Saburo Yamada',
    email: 'saburo.jp',
  ),
];

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text('${user.name} ${user.email}'),
          );
        },
      ),
    );
  }
}
