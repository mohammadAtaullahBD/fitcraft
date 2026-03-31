import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_action_state.freezed.dart';

@freezed
abstract class AuthActionState with _$AuthActionState {
  const factory AuthActionState.idle() = _Idle;
  const factory AuthActionState.loading() = _Loading;
  const factory AuthActionState.success([String? message]) = _Success;
  const factory AuthActionState.error(String message) = _Error;
}
