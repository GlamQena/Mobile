import"package:flutter/material.dart";

class Wishlist extends StatefulWidget{
  const Wishlist({super.key});

  @override State<Wishlist> createState() => WishlistState();
}

class WishlistState extends State<Wishlist>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("Wishlist", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}