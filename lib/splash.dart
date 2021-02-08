import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'Home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  String idUsuario;

  _checaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if(usuarioLogado != null){
      idUsuario = usuarioLogado.uid;
      /*
      Firestore db = Firestore.instance;
      QuerySnapshot _limpacarrinho = await db.collection("usuarios").document(idUsuario).collection("carrinho").getDocuments();
      for(DocumentSnapshot item in _limpacarrinho.documents){
        String idItem = item.documentID;
        db.collection("usuarios").document(idUsuario).collection("carrinho").document(idItem).delete();
      }
      */
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checaUsuarioLogado();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Timer(
        Duration(seconds: 5), (){
          if(idUsuario != null){
            Navigator.pushReplacementNamed(
                context, "/home",
                arguments: idUsuario
            );
          } else {
            Navigator.pushReplacementNamed(
                context, "/login",
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //color: Color(0xFFFFCC00),
        color: Colors.amber,
        padding: EdgeInsets.all(60),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("images/icone_casa.jpg"),
              Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Da Vila",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
              )
            ],
          )
        ),
      ),
    );
  }
}
