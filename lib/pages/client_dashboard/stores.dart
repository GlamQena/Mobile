import"package:flutter/material.dart";

class Stores extends StatefulWidget{
  const Stores({super.key});

  @override State<Stores> createState() => StoresState();
}

class StoresState extends State<Stores>{

  @override Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Text("Stores", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      )
    );
  }
}