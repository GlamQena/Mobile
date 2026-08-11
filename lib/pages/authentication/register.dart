import"package:flutter/material.dart";

class Register extends StatefulWidget{
  const Register({super.key});

  @override State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}