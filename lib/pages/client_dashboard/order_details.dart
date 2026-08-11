import"package:flutter/material.dart";

class OrderDetails extends StatefulWidget{
  const OrderDetails({super.key});

  @override State<OrderDetails> createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetails>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("OrderDetails", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}