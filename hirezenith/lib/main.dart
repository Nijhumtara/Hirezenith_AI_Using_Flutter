import 'package:flutter/material.dart';
import 'package:hirezenith/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://ihgvaqwjerboajiunwid.supabase.co", 
    anonKey: "sb_publishable_91ViBF4znspmN8hicCvtag_YWI05hzY",
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme:ThemeData.light(),
      debugShowCheckedModeBanner: false,   
      home: const AuthGate(),
    );
  }
}

