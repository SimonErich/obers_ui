/// Data class for the multi-step registration wizard.
class RegistrationData {
  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
    required this.newsletter,
    required this.theme,
    required this.notificationTags,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String password;
  final bool newsletter;
  final String theme;
  final List<String> notificationTags;

  @override
  String toString() =>
      'RegistrationData(firstName: $firstName, lastName: $lastName, '
      'email: $email, username: $username, newsletter: $newsletter, '
      'theme: $theme, tags: $notificationTags)';
}
