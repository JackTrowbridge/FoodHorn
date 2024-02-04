import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodhorn/firebase_options.dart';
import 'package:foodhorn/src/core/services/CachedDeviceRepository.dart';
import 'package:foodhorn/src/core/services/CachedVideoRepository.dart';
import 'package:foodhorn/src/features/home/pages/home_page.dart';
import 'package:foodhorn/src/features/upload/pages/video_form.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeApp();
}

void _initializeApp() async{
  await _initializeFirebase();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CachedVideoProvider()),
    ChangeNotifierProvider(create: (context) => DeviceProvider()),
  ],
    child: CupertinoApp(
      routes: {
        '/': (context) => Home(),
        '/video_form': (context) => VideoForm(),
      },
    ),
  ));
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}