import 'package:compradordodia/telas/troca_mensagens.dart';
import 'package:compradordodia/models/listamsg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class listaMsgs extends StatefulWidget {
  String _nomeLoja;
  String _idUsuario;
  String documento;
  
  listaMsgs(this._nomeLoja, this._idUsuario, {this.documento});
  @override
  _listaMsgsState createState() => _listaMsgsState();
}

class _listaMsgsState extends State<listaMsgs> {

  String _nomeLoja;
  String _idLoja;
  String _colecao;
  String _idUsuario;
  bool _lendomsgs = true;
  List _msgs = [];
  String _idUsuarioComprador;
  String _urlfotoperfil;
  String _nome;
  String _documento;
  String _idVendedor;

  _lerMsgs() async {
    Firestore db = Firestore.instance;
    QuerySnapshot snapshot = await db.collection("mensagens").document(_idUsuario).collection(_documento).orderBy("data", descending: true).getDocuments();
    for (DocumentSnapshot documentSnapshot in snapshot.documents){
      listaMsg listademsgs = listaMsg();
      listademsgs.url = documentSnapshot["url_foto"];
      listademsgs.nome = documentSnapshot["nome"];
      listademsgs.data = documentSnapshot["data"];
      listademsgs.mensagem = documentSnapshot["mensagem"];
      listademsgs.idVendedor = documentSnapshot["idVendedor"];
      listademsgs.idComprador = documentSnapshot["idComprador"];
      listademsgs.idLoja = documentSnapshot["idLoja"];

      Map<String, dynamic> _listademensagens = listademsgs.toMap();
      _msgs.add(_listademensagens);
    }
    setState(() {
      _lendomsgs = false;
      _msgs;
    });
  }

  trocaMsg() {
    String _idLojaAlterado = _idLoja.substring(_idLoja.indexOf("_")+1)+"_";
    print(_idVendedor);
    print(_idUsuarioComprador);
    print(_idLoja);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => trocaMensagem(_urlfotoperfil, _nome, _idVendedor, _idUsuarioComprador, _idLoja, _idLojaAlterado, _idUsuario)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nomeLoja = widget._nomeLoja;
    _idUsuario = widget._idUsuario;
    _documento = widget.documento;
    _documento == null ? _documento = _idUsuario + "_" + _nomeLoja : null;
    _lerMsgs();
  }

  @override
  Widget build(BuildContext context) {
    Firestore db = Firestore.instance;
    var mensagens = StreamBuilder(
        stream: db.collection("mensagens").document(_idUsuario).collection(_documento).orderBy("data", descending: true).snapshots(),
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
              _msgs.clear();
              QuerySnapshot querySnapshot = snapshot.data;
              for (DocumentSnapshot documentSnapshot in querySnapshot.documents){
                listaMsg listademsgs = listaMsg();
                listademsgs.url = documentSnapshot["url_foto"];
                listademsgs.nome = documentSnapshot["nome"];
                listademsgs.data = documentSnapshot["data"];
                listademsgs.mensagem = documentSnapshot["mensagem"];
                listademsgs.idVendedor = documentSnapshot["idVendedor"];
                listademsgs.idComprador = documentSnapshot["idComprador"];
                listademsgs.idLoja = documentSnapshot["idLoja"];
                Map<String, dynamic> _listademensagens = listademsgs.toMap();
                _msgs.add(_listademensagens);}
          }
          if(_msgs.length == 0){
            return Center(child: Padding(padding: EdgeInsets.only(top: 64), child: Text("Você não possui encomendas\n"
                "no momento.",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),),));
          }
          return Expanded(
            child: ListView.builder(
              itemCount: _msgs.length,
              itemBuilder: (context, indice){
                listaMsg listademsgs = listaMsg();
                String _ultMsg;
                listademsgs.url = _msgs[indice]["url_foto"];
                listademsgs.nome = _msgs[indice]["nome"];
                listademsgs.mensagem = _msgs[indice]["mensagem"];
                listademsgs.idUsuario = _msgs[indice]["idUsuario"];
                listademsgs.idLoja = _msgs[indice]["idLoja"];
                _ultMsg = listademsgs.mensagem;
                if(_ultMsg.length > 20){
                  _ultMsg = listademsgs.mensagem.substring(0,20) + "...";
                }
                listademsgs.data = _msgs[indice]["data"];
                DateTime data = listademsgs.data.toDate();
                String dataajustada = data.day.toString() + "/" + data.month.toString() + "/" + data.year.toString();
                listademsgs.idVendedor = _msgs[indice]["idVendedor"];
                listademsgs.idComprador = _msgs[indice]["idComprador"];
                listademsgs.idLoja = _msgs[indice]["idLoja"];
                return GestureDetector(
                  onTap: (){
                    _idUsuarioComprador = listademsgs.idComprador;
                    _idVendedor = listademsgs.idVendedor;
                    _urlfotoperfil = listademsgs.url;
                    _nome = listademsgs.nome;
                    _idLoja = listademsgs.idLoja;

                    trocaMsg();
                  },
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    borderOnForeground: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: CircleAvatar(
                                  maxRadius: 30,
                                  backgroundColor: Colors.amberAccent,
                                  backgroundImage: listademsgs.url != null
                                      ? NetworkImage(listademsgs.url)
                                      : null),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    listademsgs.nome,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      _ultMsg,
                                      style: TextStyle(
                                          fontSize: 17
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Text(dataajustada)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensagens da $_nomeLoja"),
      ),
      body: SafeArea(
          child: mensagens
      ),
    );
  }
}
