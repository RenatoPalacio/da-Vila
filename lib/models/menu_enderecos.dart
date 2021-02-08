import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'endereco.dart';

class Enderecos {

  static Future<List<DropdownMenuItem<String>>> getEnderecos(String _idUsuario, BuildContext context) async {

    final _tam = MediaQuery.of(context).size;

    List<DropdownMenuItem<String>> itensDropEnderecos = [];
    itensDropEnderecos.add(
        DropdownMenuItem(child: Text(
          "Endereço para entrega:", style: TextStyle(
            color: Color(0xFFFF6F00)
        ),
        ), value: null,)
    );

    Firestore db = Firestore.instance;
    QuerySnapshot _enderecos = await db.collection("usuarios")
        .document(_idUsuario)
        .collection("enderecos")
        .getDocuments();
    for(DocumentSnapshot item in _enderecos.documents){
      if(item["ativo"] == false){
        continue;
      }
      String _idEndereco = item.documentID;
      String _titulo = item["nome"];
      String _endereco = item["endereco"] + ", " + item["numero"];
      print(_endereco);
      itensDropEnderecos.add(
          DropdownMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 0, top: 0, left: 8),
                          child: Text(_titulo),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 0, top: 0, left: 8),
                          child: Text(_endereco, style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal) ,),
                        ),
                      ],
                    ),
                  )
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 64),
                      child: IconButton(
                          icon: Icon(
                              Icons.settings,
                              size: 17,
                              color: Colors.black),
                          onPressed: (){
                            Endereco _endereco = Endereco();
                            _endereco.nome = item["nome"];
                            _endereco.cep = item["cep"];
                            _endereco.logradouro = item["endereco"];
                            _endereco.numero = item["numero"];
                            _endereco.complemento = item["complemento"];
                            _endereco.uf = item["uf"];
                            _endereco.cidade = item["cidade"];
                            _endereco.ativo = item["ativo"];
                            _endereco.idEndereco = _idEndereco;
                            _endereco.latitude = item["latitude"];
                            _endereco.longitude = item["longitude"];

                            Navigator.pushNamed(context, "/novo_endereco", arguments: _endereco);
                          }),
                    ),
                    IconButton(
                        icon: Icon(
                            Icons.clear,
                            size: 19,
                            color: Colors.black),
                        onPressed: (){
                          showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text("Apagar endereço?"),
                                  actions: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        FlatButton(
                                            onPressed: (){
                                              Firestore db = Firestore.instance;
                                              db.collection("usuarios")
                                                  .document(_idUsuario)
                                                  .collection("enderecos")
                                                  .document(_idEndereco).delete();
                                              db.collection("usuarios")
                                                  .document(_idUsuario).updateData({
                                                "enderecoEntrega" : "",
                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              //Navigator.pop(context);
                                              Navigator.pushNamed(context, "/ler_carrinho", arguments: _idUsuario );
                                              //itensDropEnderecos.remove(_titulo);
                                            },
                                            child: Text("Sim", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),)),
                                        FlatButton(
                                          onPressed: (){Navigator.pop(context);},
                                          child: Text("Não", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),),)
                                      ],
                                    )
                                  ],
                                );
                              }
                          );
                        })
                  ],
                )
              ],
            ),
            value: _titulo,)
      );
    }
    itensDropEnderecos.add(
        DropdownMenuItem(child: Padding(padding: EdgeInsets.only(left: 16), child: Text("Retirada"),), value: "retirada",),
    );
    itensDropEnderecos.add(
      DropdownMenuItem(
        child: Text("Novo endereço"), value: "novo",),
    );
    return itensDropEnderecos;
  }
}