/// Data class for the signup form.
class SignupFormData {
  const SignupFormData({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.newsletter,
    required this.volume,
    this.gender,
    this.birthDate,
  });

  final String name;
  final String username;
  final String email;
  final String password;
  final bool newsletter;
  final String? gender;
  final DateTime? birthDate;
  final double volume;

  @override
  String toString() =>
      'SignupFormData(name: $name, username: $username, email: $email, '
      'newsletter: $newsletter, gender: $gender, '
      'birthDate: $birthDate, volume: $volume)';
}
