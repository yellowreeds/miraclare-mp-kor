// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupModel _$SignupModelFromJson(Map<String, dynamic> json) => SignupModel(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      birthDate: json['birth_date'] as String,
      gender: json['gender'] as String,
      address: json['address'] as String,
      detailAddress: json['detail_address'] as String,
    );

Map<String, dynamic> _$SignupModelToJson(SignupModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'phone': instance.phone,
      'birth_date': instance.birthDate,
      'gender': instance.gender,
      'address': instance.address,
      'detail_address': instance.detailAddress,
    };
