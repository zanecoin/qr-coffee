// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Access _$AccessFromJson(Map<String, dynamic> json) => Access(
      access_token: json['access_token'] as String,
      token_type: json['token_type'] as String,
      expires_in: json['expires_in'] as String,
      grant_type: json['grant_type'] as String,
    );

Map<String, dynamic> _$AccessToJson(Access instance) => <String, dynamic>{
      'access_token': instance.access_token,
      'token_type': instance.token_type,
      'expires_in': instance.expires_in,
      'grant_type': instance.grant_type,
    };

ResponseData _$ResponseDataFromJson(Map<String, dynamic> json) => ResponseData(
      code: json['code'] as int,
      meta: json['meta'],
      data: json['data'] as List<dynamic>,
    );

Map<String, dynamic> _$ResponseDataToJson(ResponseData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'meta': instance.meta,
      'data': instance.data,
    };
