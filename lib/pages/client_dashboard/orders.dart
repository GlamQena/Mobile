import"package:flutter/material.dart";

class Orders extends StatefulWidget{
  const Orders({super.key});

  @override State<Orders> createState() => OrdersState();
}

class OrdersState extends State<Orders>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}