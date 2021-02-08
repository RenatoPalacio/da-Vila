import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class autenticaeMail {
  String email;
  String senha;
  dynamic qualErro = "";

  autenticaeMail(this.email, this.senha);

   Future logarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((firebaseUser) {
      print("Usuário logado ${firebaseUser.user.email}");
    }).catchError((erro) {
      qualErro = erro.code;
      //print(qualErro);
      //_trataErroLogar();
    });
  }

  /*_trataErroLogar(){
    print(qualErro);
     switch (qualErro){
       case "ERROR_USER_NOT_FOUND":

     }
  }*/

   Future criarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .createUserWithEmailAndPassword(email: email, password: senha)
        .then((firebaseUser) {
          print("Usuário cadastrado ${firebaseUser.user.email}");
    }).catchError((erro) {
      //print("Erro ao criar usuário ${erro.toString()}");
    });
  }
}
