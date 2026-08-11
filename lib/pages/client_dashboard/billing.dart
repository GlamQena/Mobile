import"package:flutter/material.dart";

class Billing extends StatefulWidget{
  const Billing({super.key});

  @override State<Billing> createState() => BillingState();
}

class BillingState extends State<Billing>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("Billing", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}