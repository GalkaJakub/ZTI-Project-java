class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final int id;
  final String email;
  final String displayName;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as int,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
    );
  }
}
