import"package:flutter/material.dart";

class Login extends StatefulWidget{
  const Login({super.key});

  @override State<Login> createState() => LoginState();
}

class LoginState extends State<Login>{

  @override Widget build(BuildContext context){
    //won't return new scaffold, just a container of content to be the body of the scaffold custom widget declared in the main to hold the same appbar for all screens
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      child: Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}