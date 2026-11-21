import 'package:flutter_test/flutter_test.dart';
import 'package:sport/core/theme/app_colors.dart';

void main() {
  test('tokens de marca definidos', () {
    expect(AppColors.brand, isNot(AppColors.performanceGold));
    expect(AppColors.statusGreen, isNot(AppColors.brand));
  });
}
