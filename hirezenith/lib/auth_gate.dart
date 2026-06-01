import 'package:flutter/material.dart';
import 'package:hirezenith/home.dart';
import 'package:hirezenith/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthGate extends StatefulWidget{
  const AuthGate({super.key});

  @override
  State<StatefulWidget> createState() => _AuthGateState();
  
}

class _AuthGateState extends State<AuthGate>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final session = snapshot.data?.session;
        if (session != null){
          return const Home();
        }
        else{
          return const Login();
        }
      },
    );
  }
  
}