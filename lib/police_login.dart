import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rps/bloc/auth_cubit.dart';
import 'police_signup.dart';
import 'police_home.dart';

class PoliceLogin extends StatefulWidget {
  const PoliceLogin({super.key});

  @override
  State<PoliceLogin> createState() => _PoliceLoginState();
}

class _PoliceLoginState extends State<PoliceLogin> {

  bool isLoading = false;

  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('police_officers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  String _email = "";

  // String _username = "";
  String _password = "";

  late final FocusNode _passowrdFocusNode;

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      //  Invalid
      return;
    }

    _formKey.currentState!.save();

    context
        .read<AuthCubit>()
        .signInWithEmail(email: _email, password: _password);
    //Todo : Authenticate with email and password
    //Todo : If verified go to posts screen
  }

  @override
  void initState() {
    _passowrdFocusNode = FocusNode();
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((event) { 
      print('Token updated');
    });
    storeNotificationToken();
  }

  @override
  void dispose() {
    _passowrdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Police Page"),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (prevState, currState) {
              if (currState is AuthError) {
                // ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).errorColor,
                    content: Text(
                      currState.message,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                    duration: const Duration(
                      seconds: 2,
                    ),
                  ),
                );
              }

              if (currState is AuthSignedIn) {
                Navigator.pushNamed(context, 'policehome');
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

                  //Emaill
                  TextFormField(
                    // keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _email = value!.trim();
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passowrdFocusNode),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Enter Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide Email';
                      }

                      if (value.length < 4) {
                        return 'Please provide longer email';
                      }
                      return null;
                    },
                  ),

                  //Password
                  TextFormField(
                    focusNode: _passowrdFocusNode,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSaved: (value) {
                      _password = value!.trim();
                    },
                    onFieldSubmitted: (_) => _submit(),
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
                    onPressed: () => _submit(),
                    child: const Text('Log In'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'policesignup');
                    },
                    child: const Text('Sign up'),
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
