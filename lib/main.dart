import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodhorn/firebase_options.dart';
import 'package:foodhorn/src/features/home/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebase();
  runApp(const HomePage());
}

void _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
