import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_cubit_state.dart';

class AuthCubitCubit extends Cubit<AuthCubitInitial> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignIn get googleSignIn => _googleSignIn;

  AuthCubitCubit() : super(const AuthCubitInitial());

  Future googleLogIn() async {
    try {
      emit(
        state.copyWith(
          loginStatus: LoginStatus.verifying,
        ),
      );
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credentials);

      emit(
        state.copyWith(
          user: googleUser,
          loginStatus: LoginStatus.loggedIn,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      emit(
        state.copyWith(
          loginStatus: LoginStatus.loggedOut,
        ),
      );
    }
  }

  Future logout() async {
    try {
      await googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
      emit(
        state.copyWith(
          loginStatus: LoginStatus.loggedOut,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> close() {
    logout();
    return super.close();
  }
}
