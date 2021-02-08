
import 'package:compradordodia/telas/ler_carrinho_novo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mostracarrinho extends StatefulWidget {
  @override
  _MostracarrinhoState createState() => _MostracarrinhoState();
}

class _MostracarrinhoState extends State<Mostracarrinho> {
  String _idUsuario;
  _verCarrinho() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Lercarrinho(_idUsuario)));
  }

  _checausuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuario = usuarioLogado.uid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Firestore db = Firestore.instance;
    bool _cesta;
    double _tamanhoBottomBar;
    return StreamBuilder(
        initialData: _checausuario(),
        stream: db.collection("usuarios").document(_idUsuario).collection("carrinho").snapshots(),
        builder: (context, snapshot){
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data;
              if(querySnapshot.documents.length != 0){
                _tamanhoBottomBar = 40.0;
                _cesta = true;
              } else {
                _tamanhoBottomBar = 0.0;
                _cesta = false;
              }
              return SizedBox(
                  height: _tamanhoBottomBar,
                  child:
                  _cesta
                      ? Container(
                    color: Colors.orange,
                    child: GestureDetector(
                      child: Card(
                        elevation: 0,
                        color: Colors.orange,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Icon(Icons.shopping_basket),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(
                                "Cesta de compras",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: _verCarrinho,
                    ),
                  )
                      : null
              );
          }
        });
  }
}
