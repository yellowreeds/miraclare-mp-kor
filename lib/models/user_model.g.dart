// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      birthDate: json['birth_date'] as String,
      gender: json['gender'] as String,
      address: json['address'] as String,
      detailAddress: json['detail_address'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'birth_date': instance.birthDate,
      'gender': instance.gender,
      'address': instance.address,
      'detail_address': instance.detailAddress,
    };
