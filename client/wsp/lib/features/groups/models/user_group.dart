class UserGroup {
  const UserGroup({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.role,
    required this.memberCount,
  });

  final int id;
  final String name;
  final String inviteCode;
  final String role;
  final int memberCount;

  bool get isOwner => role == 'OWNER';

  String get roleLabel => isOwner ? 'Właściciel' : 'Członek';

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String,
      role: json['role'] as String,
      memberCount: json['memberCount'] as int,
    );
  }
}
