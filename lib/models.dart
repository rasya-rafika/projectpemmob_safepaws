// User roles enum
enum UserRole {
  admin,
  user,
}

// User class to store user data
class User {
  final String username;
  final String password;
  final UserRole role;

  User({required this.username, required this.password, required this.role});
}