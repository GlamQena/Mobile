import"package:flutter/material.dart";

class Cart extends StatefulWidget{
  const Cart({super.key});

  @override State<Cart> createState() => CartState();
}

class CartState extends State<Cart>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}