import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Firestore rules require the server-owned suite access mirror', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('function hasWinFlowzAppAccess(userId)'));
    expect(rules, contains(r'/documents/suiteAccess/$(userId)'));
    expect(rules, contains('products.winflowz_app.active == true'));
    expect(rules, contains('match /suiteAccess/{uid}'));
    expect(rules, contains('allow read, write: if false;'));
  });
}
