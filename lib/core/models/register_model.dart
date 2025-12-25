// ariana - untuk ID aku bingung pake apa engga
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // Factory untuk mengubah JSON dari API Laravel menjadi objek User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], 
      name: json['name'], 
      email: json['email']);
  }

  // Method tambahan jika kamu perlu mengirim data User kembali ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'name': name, 
      'email': email};
  }
}
