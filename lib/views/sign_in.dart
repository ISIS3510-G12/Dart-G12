import 'package:dart_g12/views/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const users = {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
  'lauracarretero12@gmail.com': '04052004',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: \${data.name}, Password: \${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: \${data.name}, Password: \${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/andes.jpg', // Ruta de la imagen
              fit: BoxFit.cover,
            ),
          ),
          // Pantalla de login
          
          Center(
            child: FlutterLogin(
              theme: LoginTheme(
                pageColorLight: Colors.transparent,
                pageColorDark: Colors.transparent,
                errorColor: Color(0xFFEA1D5D),
                titleStyle: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'Quicksand',
                  letterSpacing: 4,
                ),
                bodyStyle: const TextStyle(
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
                textFieldStyle: const TextStyle(
                  color: Color(0xFFEA1D5D),
                  shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
                ),
                buttonStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                cardTheme: CardTheme(
                  color: Color(0xFF050F2C),
                  elevation: 5,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                inputTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  errorStyle: const TextStyle(
                    backgroundColor: Color(0xFFEA1D5D),
                    color: Colors.white,
                  ),
                  labelStyle: const TextStyle(fontSize: 12),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF2E1F54), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFEA1D5D), width: 5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFEA1D5D), width: 7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFEA1D5D), width: 8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 5),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                buttonTheme: LoginButtonTheme(
                  splashColor: Colors.purple,
                  backgroundColor: Color(0xFFEA1D5D),
                  highlightColor: Colors.lightGreen,
                  elevation: 9.0,
                  highlightElevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              headerWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Find Your Way Around",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA1D5D),
                    ),
                  ),
                  const SizedBox(height: 5), // Espaciado opcional
                  const Text(
                    "Your interactive campus map at a glance",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              onLogin: _authUser,
              onSignup: _signupUser,
              onRecoverPassword: _recoverPassword,
              loginProviders: <LoginProvider>[
                LoginProvider(
                  icon: FontAwesomeIcons.google,
                  label: 'Google',
                  callback: () async {
                    debugPrint('start google sign in');
                    await Future.delayed(loginTime);
                    debugPrint('stop google sign in');
                    return null;
                  },
                ),
                LoginProvider(
                  icon: FontAwesomeIcons.facebookF,
                  label: 'Facebook',
                  callback: () async {
                    debugPrint('start facebook sign in');
                    await Future.delayed(loginTime);
                    debugPrint('stop facebook sign in');
                    return null;
                  },
                ),
                LoginProvider(
                  icon: FontAwesomeIcons.linkedinIn,
                  callback: () async {
                    debugPrint('start linkedin sign in');
                    await Future.delayed(loginTime);
                    debugPrint('stop linkedin sign in');
                    return null;
                  },
                ),
                LoginProvider(
                  icon: FontAwesomeIcons.githubAlt,
                  callback: () async {
                    debugPrint('start github sign in');
                    await Future.delayed(loginTime);
                    debugPrint('stop github sign in');
                    return null;
                  },
                ),
              ],
              onSubmitAnimationCompleted: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ));
              },
            ),
          )
        ],
      ),
    );
  }
}
