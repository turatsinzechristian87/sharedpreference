import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:raissangarambe/main.dart';

class SignupPage extends StatelessWidget {
  // Define FocusNode instances
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signup(BuildContext context) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save additional user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'username': _usernameController.text,
        'email': _emailController.text,
      });

      // Navigate to MyApp or home screen after successful signup
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()), // Replace with your desired screen
    );

    // Show success message (optional)
    Fluttertoast.showToast(msg: 'Signup successful!');
  } on FirebaseAuthException catch (e) {
    // Handle signup error
    Fluttertoast.showToast(msg: e.message ?? 'Signup failed');
  }
}

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
        backgroundColor: theme.primaryColor, // Use primary color from theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Signup Page',
              style: TextStyle(fontSize: 24, color: theme.primaryColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Username TextFormField
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: usernameFocusNode.hasFocus ? theme.primaryColor : Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: TextFormField(
                controller: _usernameController,
                focusNode: usernameFocusNode,
                style: TextStyle(color: Colors.black), // Text color
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.black), // Label color
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Email TextFormField
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: emailFocusNode.hasFocus ? theme.primaryColor : Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: TextFormField(
                controller: _emailController,
                focusNode: emailFocusNode,
                style: TextStyle(color: Colors.black), // Text color
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black), // Label color
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Password TextFormField
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: passwordFocusNode.hasFocus ? theme.primaryColor : Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: TextFormField(
                controller: _passwordController,
                focusNode: passwordFocusNode,
                obscureText: true,
                style: TextStyle(color: Colors.black), // Text color
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black), // Label color
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _signup(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
              ),
              child: Text(
                'Signup',
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Login Page
                Navigator.pop(context);
              },
              child: Text(
                'Go to Login',
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
