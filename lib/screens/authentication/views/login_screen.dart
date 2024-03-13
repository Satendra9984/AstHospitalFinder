import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearby_hospital_locator/screens/authentication/auth_cubit/auth_cubit_cubit.dart';
import 'package:nearby_hospital_locator/screens/locator/views/locator_home.dart';

class LoginPage extends StatelessWidget {
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthCubitCubit>().logout().then(
                (value) {
                  Navigator.pop(context);
                },
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubitCubit, AuthCubitInitial>(
        listener: (context, state) {
          if (state.loginStatus == LoginStatus.initial) {
            context.read<AuthCubitCubit>().googleLogIn();
          }
          if (state.loginStatus == LoginStatus.loggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => LocatorHomeScreen()),
            );
          }
        },
        builder: (context, state) {
          if (state.loginStatus == LoginStatus.verifying) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(
                    Icons.local_hospital_rounded,
                    size: 120.0,
                    color: Colors.red,
                  ),
                  const Text(
                    'Welcome to\nHospital Locator',
                    style: TextStyle(
                      fontSize: 42.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    'Sign In With',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AuthCubitCubit>().googleLogIn(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.grey.shade800,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/google-logo.png',
                          height: 28.0,
                        ),
                        const SizedBox(width: 10.0),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// https://dribbble.com/shots/23643858-Money-Manager-Onboarding-Screen