// ignore_for_file: file_names
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';
// import '../models/authentication/FirebaseAuthServiceModel.dart';
import '../models/authentication/AuthServiceModel.dart';
import '../views/auth_pages/login_page_view.dart';
import '../main_view.dart';

class AuthRedirectController extends StatelessWidget {
  const AuthRedirectController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authServiceProvider = Provider.of<AuthServiceModel>(context);
    return StreamBuilder<UserData?>(
      stream: authServiceProvider.onAuthStateChanged(),
      builder: (_, AsyncSnapshot<UserData?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200.withOpacity(0.5)),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Center(child: Text("Something went wrong!"));
        } else {
          final user = snapshot.data;
          if (user != null) {
            // Go to HomePage
            return const MainView();
          }
          return const LoginPageView();
        }
      },
    );
  }
}
