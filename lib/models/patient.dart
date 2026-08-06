class Patient {
  final String id;
  final String name;
  final String phoneNumber;
  final int age;
  final String gender;
  final String doctorAtSign; // now stores doctor MongoDB id
  final String createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    required this.doctorAtSign,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "phoneNumber": phoneNumber,
        "age": age,
        "gender": gender,
        "doctorAtSign": doctorAtSign,
      };

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json["_id"] ?? json["id"] ?? "",
        name: json["name"] ?? "",
        phoneNumber: json["phoneNumber"] ?? "",
        age: json["age"] ?? 0,
        gender: json["gender"] ?? "",
        doctorAtSign: json["doctorAtSign"] ?? "",
        createdAt: json["createdAt"] ?? "",
      );
}
