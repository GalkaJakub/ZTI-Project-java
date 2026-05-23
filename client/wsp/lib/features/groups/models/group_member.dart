class GroupMember {
  const GroupMember({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  final int id;
  final int userId;
  final String displayName;
  final String email;
  final String role;
  final DateTime joinedAt;

  bool get isOwner => role == 'OWNER';

  String get roleLabel => isOwner ? 'Właściciel' : 'Członek';

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

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as int,
      userId: json['userId'] as int,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}
