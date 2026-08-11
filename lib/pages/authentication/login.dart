import"package:flutter/material.dart";

class Login extends StatefulWidget{
  const Login({super.key});

  @override State<Login> createState() => LoginState();
}

class LoginState extends State<Login>{

  @override Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      )
    );
  }
}