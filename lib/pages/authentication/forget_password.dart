import"package:flutter/material.dart";

class ForgetPassword extends StatefulWidget{
  const ForgetPassword({super.key});

  @override State<ForgetPassword> createState() => ForgetPasswordState();
}

class ForgetPasswordState extends State<ForgetPassword>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("ForgetPassword", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}