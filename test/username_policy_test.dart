import 'package:catch_lingo/models/username_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = UsernamePolicy();

  test('does not allow Slevie to be assigned', () {
    expect(policy.canAssign('Slevie'), isFalse);
    expect(policy.isReserved('Slevie'), isTrue);
    expect(policy.validate('Slevie'), 'This username is not available.');
  });

  test('blocks Slevie case-insensitively and ignores surrounding spaces', () {
    expect(policy.canAssign('slevie'), isFalse);
    expect(policy.canAssign('SLEVIE'), isFalse);
    expect(policy.canAssign('  Slevie  '), isFalse);
  });

  test('allows other usernames', () {
    expect(policy.canAssign('Stevie'), isTrue);
    expect(policy.canAssign('Valen'), isTrue);
    expect(policy.validate('Valen'), isNull);
  });
}
