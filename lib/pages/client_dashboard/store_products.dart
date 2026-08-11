import"package:flutter/material.dart";

class StoreProducts extends StatefulWidget{
  const StoreProducts({super.key});

  @override State<StoreProducts> createState() => StoreProductsState();
}

class StoreProductsState extends State<StoreProducts>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("StoreProducts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}