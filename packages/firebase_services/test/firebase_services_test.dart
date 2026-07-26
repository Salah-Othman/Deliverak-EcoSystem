import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_services/firebase_services.dart';

void main() {
  test('FirebaseAuthService can be instantiated', () {
    expect(() => FirebaseAuthService(), returnsNormally);
  });
}
