import"package:flutter/material.dart";

class ProductDetails extends StatefulWidget{
  const ProductDetails({super.key});

  @override State<ProductDetails> createState() => ProductDetailsState();
}

class ProductDetailsState extends State<ProductDetails>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("ProductDetails", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}