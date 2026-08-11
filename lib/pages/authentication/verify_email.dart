import"package:flutter/material.dart";

class VerifyEmail extends StatefulWidget{
  const VerifyEmail({super.key});

  @override State<VerifyEmail> createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("VerifyEmail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}