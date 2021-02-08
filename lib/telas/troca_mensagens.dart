import 'dart:async';
import 'package:compradordodia/models/mensagem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class trocaMensagem extends StatefulWidget {
  String _url;
  String _nome;
  String _idVendedor;
  String _idComprador;
  String _idLoja;
  String _idPedido;
  String _idUsuario;
  trocaMensagem(this._url, this._nome, this._idVendedor, this._idComprador, this._idLoja, this._idPedido, this._idUsuario);
  @override
  _trocaMensagemState createState() => _trocaMensagemState();
}

class _trocaMensagemState extends State<trocaMensagem> {
  String _url;
  String _nome;
  String _idVendedor;
  String _idComprador;
  String _idLoja;
  String _idPedido;
  String _idRemetente;
  String _idConversa;
  String _idRegistro;
  File _imagemSelecionada;
  bool _subindoImagem = false;
  String _dataAanterior = "";
  String data = "";
  String _nomeComprador;
  String _urlComprador;

  TextEditingController _controllerMensagem = TextEditingController();
  final _controleMsgs = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollMensagens = ScrollController();

  Firestore db = Firestore.instance;

  Stream<QuerySnapshot> _trocaMensagens(){
    final stream = db
        .collection("mensagens")
        .document(_idVendedor)
        .collection(_idLoja)
        .document(_idComprador)
        .collection(_idRemetente)
        .orderBy("data", descending: false)
        .snapshots();
    stream.listen((dados){
      _controleMsgs.add(dados);
      Timer(Duration(milliseconds: 500), (){
        _scrollMensagens.jumpTo(_scrollMensagens.position.maxScrollExtent);
      });
    });
  }

  _checaUsuario() async {
    DocumentSnapshot _doc = await db.collection("usuarios").document(_idComprador).get();
    _nomeComprador = _doc["nome"];
    _urlComprador = _doc["urlfotoperfil"];
  }

  _enviarMensagem(){
    String textoMensagem = _controllerMensagem.text;
    if( textoMensagem.isNotEmpty ){
      Mensagem mensagem = Mensagem();
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.idRemetente = _idRemetente;
      mensagem.tipo = "texto";
      mensagem.data = Timestamp.now();
      data = "";
      _salvarMensagem(_idRemetente, mensagem);
      if(_idRemetente == _idComprador){
        _salvarMensagem(_idVendedor, mensagem);
        _salvarEnviadas(_idRemetente, mensagem, _url, _nome);
      } else
        {
          _atualizaUltimaMsg(mensagem);
          _salvarMensagem(_idComprador, mensagem);
        }
      }
    }

  _atualizaUltimaMsg(Mensagem msg) async {
    db.collection("mensagens").document(_idComprador).collection("enviadas").document(_idLoja).updateData(
        {
          "mensagem" : msg.tipo == "imagem" ? "imagem" : msg.mensagem,
        });
  }

    _salvarEnviadas(String _remetente, Mensagem msg, String url, String nome) async {
      db.collection("mensagens").document(_remetente).collection("enviadas").document(_idLoja).setData({
        "url_foto" : url,
        "nome" : nome,
        "data" : msg.data,
        "mensagem" : msg.tipo == "imagem" ? "imagem" : msg.mensagem,
        "idVendedor" : _idVendedor,
        "idComprador" : _idComprador,
        "idLoja" : _idLoja,
      });
  }

  _salvarMensagem(String _remetente, Mensagem msg) async {
    _idRegistro = Timestamp.now().toString();
    db.collection("mensagens")
        .document(_idVendedor)
        .collection(_idLoja)
        .document(_idComprador).setData({
      "url_foto" : _urlComprador,
      "nome" : _nomeComprador,
      "data" : msg.data,
      "mensagem" : msg.tipo == "imagem" ? "imagem" : msg.mensagem,
      "idVendedor" : _idVendedor,
      "idComprador" : _idComprador,
      "idLoja" : _idLoja,
    });

    db.collection("mensagens")
        .document(_idVendedor)
        .collection(_idLoja)
        .document(_idComprador)
        .collection(_remetente).add(msg.toMap());
    _controllerMensagem.clear();
  }

  Future _recuperaImagem(bool daCamera) async {
    if(daCamera){
      _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
    } else{
      _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    _salvaImagem();
  }

  _salvaImagem() async {
    _subindoImagem = true;
    String nomeImagem = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idRemetente)
        .child(nomeImagem + ".jpg");
    StorageUploadTask task = arquivo.putFile(_imagemSelecionada);
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot){
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {

    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idRemetente = _idRemetente;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    //mensagem.data = Timestamp.now().toString();
    mensagem.data = Timestamp.now();


    _salvarMensagem(_idRemetente, mensagem);
    if(_idRemetente == _idComprador){
      _salvarMensagem(_idVendedor, mensagem);
    } else
    {_salvarMensagem(_idComprador, mensagem);}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _idRemetente = widget._idUsuario;
    _url = widget._url;
    _nome = widget._nome;
    _idVendedor = widget._idVendedor;
    _idComprador = widget._idComprador;
    _idLoja = widget._idLoja;
    _idPedido = widget._idPedido;
    String p1 = _idPedido.substring(0,_idPedido.indexOf("_"));
    String p2 = _idComprador;
    String p3 = _idVendedor;
    _idConversa = p1 + "_" + p2 + "_" + p3;
    _checaUsuario();
    _trocaMensagens();
  }
  @override
  Widget build(BuildContext context) {

    var stream = StreamBuilder(
      stream: _controleMsgs.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:

            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return  Text("Erro ao carregar os dados!");
            } else {
              return Expanded(
                  child: ListView.builder(
                    controller: _scrollMensagens,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      _dataAanterior = data;
                      List<DocumentSnapshot> mensagens = querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[indice];
                      Timestamp _timestamp = item["data"];
                      DateTime dataconversa = _timestamp.toDate();
                      data = dataconversa.day.toString() + "/" + dataconversa.month.toString() + "/" + dataconversa.year.toString();
                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor =Color(0xFFFFD54F);
                      if ( _idRemetente != item["idRemetente"] ) {
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }
                      return Column(
                        children: [
                          data == _dataAanterior
                              ? Container()
                              :
                          Padding(
                              padding: EdgeInsets.only(top: 4, bottom: 4),
                              child: Center(
                                child: Card(
                                  child: Padding(padding: EdgeInsets.all(8), child: Text(data),),
                                ),
                              )
                          ),
                          Align(
                            alignment: alinhamento,
                            child: Padding(
                              padding: EdgeInsets.all(6),
                              child: Container(
                                width: larguraContainer,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: cor,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                                child: item["tipo"] == "texto"
                                    ? Text(item["mensagem"],style: TextStyle(fontSize: 18),)
                                    : Image.network(item["urlImagem"]),
                              ),
                            ),
                          )
                        ],
                      );
                    }),
              );
            }
            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 23,
                backgroundColor: Colors.amberAccent,
                backgroundImage: _url != null
                    ? NetworkImage(_url)
                    : AssetImage("images/semfoto.png")),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(_nome),
            )
          ],
        ),
      ),
      body: Builder(
        builder: (context) => SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Color(0xFFFFEF3E0),
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                stream,
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: TextField(
                            controller: _controllerMensagem,
                            autofocus: true,
                            keyboardType: TextInputType.text,
                            style: TextStyle(fontSize: 15),
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                              hintText: "Digite uma mensagem...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32)
                              ),
                              prefixIcon: IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () {
                                  final snackbar = SnackBar(
                                    backgroundColor: Colors.white,
                                    duration: Duration(seconds: 20),
                                    content: Row(
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(left: 16, right: 32),
                                            child: GestureDetector(
                                                onTap: (){
                                                  Scaffold.of(context).hideCurrentSnackBar();
                                                  _recuperaImagem(false);
                                                },
                                                child: Image.asset(
                                                  "images/icone_arquivo.png",
                                                  height: 25,
                                                )
                                            )
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            Scaffold.of(context).hideCurrentSnackBar();
                                            _recuperaImagem(true);
                                          },
                                          child: Image.asset(
                                            "images/icone_camera.png",
                                            height: 25,),
                                        )
                                      ],
                                    ),
                                  );
                                  Scaffold.of(context).showSnackBar(snackbar);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.send, color: Colors.white,),
                        mini: true,
                        onPressed: _enviarMensagem,
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
      ),
      )
    );
  }
}
