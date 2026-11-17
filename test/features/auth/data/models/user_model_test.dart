import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/auth/data/models/user_model.dart';

void main() {
  test('preserva flags demo en round-trip', () {
    final user = UserModel.fromMap(const {
      'id': 7,
      'email': 'demo@hubsport.test',
      'demo_preview': true,
      'feature_flags': {'events': true, 'store': true, 'billing': false},
    });

    final restored = UserModel.fromMap(user.toMap());

    expect(restored.demoPreview, isTrue);
    expect(restored.featureFlags, {
      'events': true,
      'store': true,
      'billing': false,
    });
    expect(restored.canAccessDemoFeature('events'), isTrue);
    expect(restored.canAccessDemoFeature('billing'), isFalse);
    expect(restored.canAccessDemoFeature('unknown'), isFalse);
  });

  test('un usuario normal no obtiene features demo', () {
    const user = UserModel(
      id: 'normal',
      email: 'normal@hubsport.test',
      featureFlags: {'events': true},
    );

    expect(user.canAccessDemoFeature('events'), isFalse);
  });
}
