import 'package:almari/views/login.dart';
import 'package:almari/views/swiping_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var userGender = ''.obs;

  Future<void> signup(
      String username, String email, String password, String gender) async {
    try {
      // Check if username already exists
      QuerySnapshot usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw 'Username already exists';
      }

      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Get the user ID (UID)
      String uid = userCredential.user!.uid;

      // Save additional information to Firestore
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email.trim(),
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.to(() => LoginPage());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred';
      }

      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login(String username, String password) async {
    try {
      // First, get the user document by username
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        Get.snackbar('Error', 'Username not found!',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Get the email and gender from the user document
      String email = userQuery.docs.first.get('email') as String;
      String gender = userQuery.docs.first.get('gender') as String;

      // Store gender in state
      userGender.value = gender;

      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      Get.snackbar('Success', 'Logged in successfully!',
          snackPosition: SnackPosition.BOTTOM);

      // Navigate to swiping screen after login
      Get.to(() => SwipingScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
