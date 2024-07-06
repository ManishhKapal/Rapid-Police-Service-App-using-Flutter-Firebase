import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> signInWithEmail({
    required String email,
    required String password,
    // required String username,
  }) async {
    emit(const AuthLoading());

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // UserCredential userCredential =
      //     await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      emit(const AuthSignedIn());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(const AuthError('User not found'));
      } else if (e.code == 'wrong-password') {
        emit(const AuthError('Wrong Password'));
      }
    }

    // try {
    //   final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    //       email: email,
    //       password: password
    //   );
    //   emit(const AuthSignedIn());
    // } on FirebaseAuthException catch (e) {
    //   if (e.code == 'user-not-found') {
    //     print('No user found for that email.');
    //   } else if (e.code == 'wrong-password') {
    //     print('Wrong password provided for that user.');
    //   }
    // }

    // emit(const AuthSignedIn());
  }

  Future<void> signUpWithEmail({
    required String email,
    required String username,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      // 1. Create User
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update username
      userCredential.user!.updateDisplayName(username);

      // Todo : Write data to cloud firestore
      // 3. Write user to user collection
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore
          .collection("police_officers")
          .doc(userCredential.user!.uid)
          .set({
        "email": email,
        "username": username,
      });

      emit(const AuthSignedUp());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(const AuthError('The password provided is too weak'));
      } else if (e.code == 'email-already-in-use') {
        emit(const AuthError('The email provided is already in use'));
      }
    } catch (e) {
      emit(const AuthError('An error has occured'));
    }
  }
}
