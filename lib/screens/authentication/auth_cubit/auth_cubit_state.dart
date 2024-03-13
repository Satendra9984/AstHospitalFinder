part of 'auth_cubit_cubit.dart';

class AuthCubitInitial extends Equatable {
  final GoogleSignInAccount? user;
  final LoginStatus loginStatus;

  const AuthCubitInitial({
    this.user,
    this.loginStatus = LoginStatus.loggedOut,
  });

  AuthCubitInitial copyWith({
    GoogleSignInAccount? user,
    LoginStatus? loginStatus,
  }) {
    return AuthCubitInitial(
      user: user ?? this.user,
      loginStatus: loginStatus ?? this.loginStatus,
    );
  }

  @override
  List<Object?> get props => [
        user,
        loginStatus,
      ];
}

enum LoginStatus {
  initial,
  verifying,
  loggedOut,
  loggedIn,
}
