import 'package:dart_g12/views/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const users = {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
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
    return Future.delayed(loginTime).then((_) => null);
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/andes.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(horizontal: 60.0, vertical: 50.0),
            decoration: BoxDecoration(
              color: Color(0xFF050F2C),
              borderRadius: BorderRadius.circular(20.0),
            ),
            
            child: FlutterLogin(
              onLogin: _authUser,
              onSignup: _signupUser,
              onRecoverPassword: _recoverPassword,
              title: 'Find Your Way Around',
              
              theme: LoginTheme(
                primaryColor:Color(0xFF050F2C),
                accentColor: Colors.white,
                errorColor: Colors.red,
                titleStyle: TextStyle(
                  color: Color(0xFFEA1D5D),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                bodyStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textFieldStyle: TextStyle(
                  color: Colors.white,
                ),
                cardTheme: CardTheme(
                  color: Colors.transparent,
                  elevation: 0,
                ),
                inputTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  labelStyle: TextStyle(color: Color(0xFF6C757D)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEA1D5D), width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                buttonTheme: LoginButtonTheme(
                  splashColor: Color(0xFFEA1D5D),
                  backgroundColor: Color(0xFFEA1D5D),
                  highlightColor: Colors.white,
                  elevation: 5.0,
                  highlightElevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
