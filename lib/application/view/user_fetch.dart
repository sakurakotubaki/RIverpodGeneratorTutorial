import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivepod_basic/application/usecase/user_provider.dart';

class UserFetch extends ConsumerWidget {
  const UserFetch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Fetch'),
      ),
      body: const APIData(),
    );
  }
}

class APIData extends ConsumerWidget {
  const APIData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(fetchUserProvider);
    // Dart3では、whenではなくて、switchが今後推奨されるらしい？
    // https://riverpod.dev/ja/docs/providers/future_provider
    return switch (users) {
      AsyncError(:final error) => Text('Error: $error'),
      AsyncData(:final value) => ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(value[index].name),
              subtitle: Text(value[index].email),
            );
          },
        ),
      // AsyncLoading() => const CircularProgressIndicator(),を_に変更できる
      _ => const CircularProgressIndicator(),
    };
  }
}
