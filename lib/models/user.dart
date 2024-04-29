import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String name;
  final int age;
  final String address;
  final String detailAddress;

  // 생성자
  User({
    required this.name,
    required this.age,
    required this.address,
    required this.detailAddress,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
