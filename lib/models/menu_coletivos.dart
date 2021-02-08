import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Coletivos {

  static Future<List<DropdownMenuItem<String>>> getColetivos(BuildContext context) async {

    List<DropdownMenuItem<String>> itensDropEnderecos = [];
    itensDropEnderecos.add(
        DropdownMenuItem(child: Text(
          "Faz parte de algum coletivo de entregas:", style: TextStyle(
            color: Color(0xFFFF6F00)
        ),
        ), value: null,)
    );

    Firestore db = Firestore.instance;
    QuerySnapshot _coletivos = await db.collection("coletivos")
        .getDocuments();
    for(DocumentSnapshot item in _coletivos.documents){
      if(item["ativo"] == false){
        continue;
      }
      String _idColetivo = item.documentID;
      String _nomeColetivo = item["nome"];
      itensDropEnderecos.add(
          DropdownMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_nomeColetivo),
                  ],
                ),
              ],
            ),
            value: _nomeColetivo,)
      );
    }
    itensDropEnderecos.add(
        DropdownMenuItem(child: Text("Novo coletivo"), value: "novo",)
    );
    return itensDropEnderecos;
  }
}