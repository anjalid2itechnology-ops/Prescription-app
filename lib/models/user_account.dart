enum StaffRole { doctor, pharmacist }

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final StaffRole role;
  final String? specialty;
  final String atSign;
  final String createdAt;
  final int avatarIndex;
  final String? photoPath;
  final String? token;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.specialty,
    required this.atSign,
    required this.createdAt,
    this.avatarIndex = 0,
    this.photoPath,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "role": role.name,
        "specialty": specialty,
        "atSign": atSign,
        "avatarIndex": avatarIndex,
        "photoPath": photoPath,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json["_id"] ?? json["id"] ?? "",
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        passwordHash: json["passwordHash"] ?? "",
        role: StaffRole.values.firstWhere((r) => r.name == json["role"], orElse: () => StaffRole.doctor),
        specialty: json["specialty"],
        atSign: json["atSign"] ?? "",
        createdAt: json["createdAt"] ?? "",
        avatarIndex: json["avatarIndex"] ?? 0,
        photoPath: json["photoPath"],
        token: json["token"],
      );
}

