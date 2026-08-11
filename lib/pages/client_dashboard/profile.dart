import"package:flutter/material.dart";

class Profile extends StatefulWidget{
  const Profile({super.key});

  @override State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile>{

  @override Widget build(BuildContext context){
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Text("Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
    );
  }
}