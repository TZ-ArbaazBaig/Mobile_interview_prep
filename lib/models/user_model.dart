class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.imageUrl,
  });

  String get fullName {
    if (firstName == null && lastName == null) return email.split('@').first;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'image_url': imageUrl,
    };
  }
}
