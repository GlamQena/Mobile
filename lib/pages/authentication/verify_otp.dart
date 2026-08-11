import"package:flutter/material.dart";

class VerifyOTP extends StatefulWidget{
  const VerifyOTP({super.key});

  @override State<VerifyOTP> createState() => VerifyOTPState();
}

class VerifyOTPState extends State<VerifyOTP>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("VerifyOTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}