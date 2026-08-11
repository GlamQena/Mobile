import"package:flutter/material.dart";

class ResetPassword extends StatefulWidget{
  const ResetPassword({super.key});

  @override State<ResetPassword> createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("ResetPassword", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}