
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compradordodia/models/denuncia.dart';

class suasDenuncias extends StatefulWidget {
  @override
  _suasDenunciasState createState() => _suasDenunciasState();
}

class _suasDenunciasState extends State<suasDenuncias> {

  String _idUsuario;
  List _denuncias = List();
  bool _lendodenuncias =  true;

  _checaUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    setState(() {
      _idUsuario = usuarioLogado.uid;
      _lendodenuncias = false;
    });
  }

  _verDenuncia(Denuncia denuncia){
    Navigator.pushNamed(context, "/verdenuncia", arguments: denuncia);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checaUsuario();
  }

  @override
  Widget build(BuildContext context) {

    Firestore db = Firestore.instance;

    var streamDenuncia = StreamBuilder(
      stream:  db.collection("usuarios").document(_idUsuario).collection("denuncias").snapshots(),
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
        _denuncias.clear();
      QuerySnapshot querySnapshot = snapshot.data;
      for (DocumentSnapshot documentSnapshot in querySnapshot.documents){
        Denuncia denuncia = Denuncia();
        denuncia.data = documentSnapshot["data"];
        denuncia.descricao = documentSnapshot["descricao"];
        denuncia.url1 = documentSnapshot["URL1"];
        denuncia.url2 = documentSnapshot["URL2"];
        denuncia.ticket = documentSnapshot["ticket"];
        Map<String, dynamic> _denuncia = denuncia.toMap();
        _denuncias.add(_denuncia);
      }
        if(_denuncias.length == 0){
          return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 64),
                child: Text(
                  "Você não possui denúncias\n"
                      "no momento.",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
              )
          );
        }
        return Expanded(
          child: ListView.builder(
              itemCount: _denuncias.length,
              itemBuilder: (context, indice){
                Denuncia denuncia = Denuncia();
                denuncia.ticket = _denuncias[indice]["ticket"];
                denuncia.data = _denuncias[indice]["data"];
                denuncia.descricao = _denuncias[indice]["descricao"];
                denuncia.url1 = _denuncias[indice]["URL1"];
                denuncia.url2 = _denuncias[indice]["URL2"];
                String descricao = denuncia.descricao;
                if (descricao.length > 40){
                  descricao = descricao.substring(0,36) + "...";
                }
                return GestureDetector(
                  onTap: (){
                    _verDenuncia(denuncia);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16, left: 16),
                            child: Text(
                              "Ticket #" + denuncia.ticket,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16, left: 32),
                            child: Text(
                              denuncia.data,
                              style: TextStyle(
                                  fontSize: 18
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8, left: 32, bottom: 16),
                            child: Text(
                              descricao,
                              style: TextStyle(
                                  fontSize: 18
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                );
              }),
        );
    }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Suas denúncias"),
      ),
      body: SafeArea(
          child:
          _lendodenuncias
              ? Column(children: <Widget>[
            Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),)
          ],)
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              streamDenuncia,
            ],
          )

      ),
    );
  }
}
