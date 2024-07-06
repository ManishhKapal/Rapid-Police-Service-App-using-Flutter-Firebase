import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rps/bloc/auth_cubit.dart';
import 'package:rps/home.dart';
import 'package:rps/otp.dart';
import 'package:rps/phone.dart';
import 'package:rps/police_home.dart';
import 'package:rps/police_login.dart';
import 'package:rps/police_signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  runApp(BlocProvider<AuthCubit>(
    create: (context) => AuthCubit(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'phone',
      routes: {
        'phone' : (context) => MyPhone(),
        'otp' : (context) => MyOtp(),
        'userHome' : (context) => UserHome(),
        'policelogin' : (context) => PoliceLogin(),
        'policesignup' : (context) => PoliceSignUp(),
        'policehome' : (context) => PoliceHomePage(),
      },
    ),
  ));
}