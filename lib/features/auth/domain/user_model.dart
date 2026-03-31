import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// FitCraft user profile stored in Supabase `profiles` table.
@freezed
abstract class UserModel with _$UserModel {
  factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  const UserModel._();

  @override
  @JsonKey(name: 'display_name')
  String get displayName => throw UnimplementedError();
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw UnimplementedError();
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw UnimplementedError();
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw UnimplementedError();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
