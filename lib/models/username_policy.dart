class UsernamePolicy {
  const UsernamePolicy();

  static const Set<String> _reservedUsernames = {'slevie'};

  bool canAssign(String username) {
    return !_reservedUsernames.contains(_normalize(username));
  }

  bool isReserved(String username) {
    return !canAssign(username);
  }

  String? validate(String username) {
    if (isReserved(username)) {
      return 'This username is not available.';
    }

    return null;
  }

  String _normalize(String username) {
    return username.trim().toLowerCase();
  }
}
