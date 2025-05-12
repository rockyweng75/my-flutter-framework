import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_flutter_framework/database/hive_repository.dart';

class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
  factory User.fromMap(Map<String, dynamic> map) =>
      User(name: map['name'], age: map['age']);
  Map<String, dynamic> toMap() => {'name': name, 'age': age};
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final testDir = Directory.systemTemp.createTempSync();
    Hive.init(testDir.path);
    await HiveRepository.openBox('testBox');
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('testBox');
  });

  test('put/get 基本型別', () async {
    await HiveRepository.put('testBox', 'key1', 'value1');
    final value = HiveRepository.get('testBox', 'key1');
    expect(value, 'value1');
  });

  test('putModel/getAsModel 測試', () async {
    final user = User(name: 'Tom', age: 20);
    await HiveRepository.putModel('testBox', 'user', user.toMap);
    final result = HiveRepository.getAsModel<User>(
      'testBox',
      'user',
      fromMap: User.fromMap,
    );
    expect(result, isA<User>());
    expect(result?.name, 'Tom');
    expect(result?.age, 20);
  });

  test('delete 測試', () async {
    await HiveRepository.put('testBox', 'key2', 'toDelete');
    await HiveRepository.delete('testBox', 'key2');
    final value = HiveRepository.get('testBox', 'key2');
    expect(value, null);
  });
}
