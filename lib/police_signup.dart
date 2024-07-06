import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rps/bloc/auth_cubit.dart';

class PoliceSignUp extends StatefulWidget {
  const PoliceSignUp({super.key});

  @override
  State<PoliceSignUp> createState() => _PoliceSignUpState();
}

class _PoliceSignUpState extends State<PoliceSignUp> {

  bool isLoading = false;

  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('police_officers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  String _email = "";
  String _username = "";
  String _password = "";

  late final FocusNode _usernameFocusNode;
  late final FocusNode _passwordFocusNode;

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      //  Invalid
      return;
    }

    _formKey.currentState!.save();

    context.read<AuthCubit>().signUpWithEmail(
        email: _email, username: _username, password: _password);
  }

  @override
  void initState() {
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((event) {
      print('Token updated');
    });
    storeNotificationToken();
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (prevState, currentState) {
              if (currentState is AuthSignedUp) {
                Navigator.pushNamed(context, 'policehome');
              }
              if (currentState is AuthError) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).errorColor,
                    content: Text(
                      currentState.message,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                // physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(15.0),

                children: [
                  Image.asset(
                    'assets/police.png',
                    width: 150,
                    height: 150,
                  ),

                  //Email Id
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _email = value!.trim();
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_usernameFocusNode),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Enter Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide email';
                      }

                      if (value.length < 4) {
                        return 'Please provide longer email';
                      }
                      return null;
                    },
                  ),

                  //Username
                  TextFormField(
                    // keyboardType: TextInputType.emailAddress,
                    // textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _username = value!.trim();
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Enter Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide username';
                      }

                      if (value.length < 4) {
                        return 'Please provide longer username';
                      }
                      return null;
                    },
                  ),

                  // Password
                  TextFormField(
                    focusNode: _passwordFocusNode,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    onFieldSubmitted: (_) => _submit(),
                    onSaved: (value) {
                      _password = value!.trim();
                    },
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Enter Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide password';
                      }

                      if (value.length < 4) {
                        return 'Please provide longer password';
                      }
                      return null;
                    },
                  ),

                  ElevatedButton(
                    onPressed: () {
                      _submit();
                    },
                    child: const Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'policelogin');
                    },
                    child: const Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
