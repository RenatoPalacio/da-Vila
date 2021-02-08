import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/lista_seusprodutos.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class addProduto extends StatefulWidget {
  @override
  bool _cadastro;
  Produto _produto;
  String _idUsuario;
  String _idLoja;
  String _nomeLoja;
  String _url;
  bool _lojaAtiva;
  addProduto(this._cadastro, this._produto, this._idUsuario, this._idLoja, this._nomeLoja, this._url, this._lojaAtiva);
  _addProdutoState createState() => _addProdutoState();
}

class _addProdutoState extends State<addProduto> {

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _precoController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ",",
      thousandSeparator: ".",
      initialValue: 0.0,
      precision: 2
  );

  var _prazoController = TextEditingController();
  bool habilitado = true;
  String lojaID;
  bool lojaAtiva;
  String nomeLoja;
  String usuario;
  String url;
  String _idUsuario;
  String _idLoja;
  String _nomeLoja;
  String _nomeRecuperado;
  String _descricaoRecuperado;
  double _precoRecuperado;
  String _prazoRecuperado;
  String _tituloAppbar = "Cadastrar produto";
  String _textoBotao = "Cadastrar";
  bool _cadastrar;
  String _produtoId;
  File _imagemSelecionada;
  File _foto;
  String _urlFotoPerfil;
  String _fotoPerfil;
  String _urlRecuperado = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
  BuildContext _dialogoContext;

  //MOSTRA PROGRESSO DO CADASTRO
  _mostraProgresso(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text("Salvando produto"),
              ],
            ),
          );
        }
    );
  }

  //SELECIONA FOTO
  Future _recuperaImagem(bool daCamera) async {
    if(daCamera){
      _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
    } else{
      _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    if (_imagemSelecionada != null){
      setState(() {
        _foto = _imagemSelecionada;
      });
    }
  }

  //VALIDA OS CAMPOS DIGITADOS
  _validaCampos() async {
    Produto produto = Produto();
    produto.nomeProduto = _nomeController.text;
    produto.descricaoProduto = _descricaoController.text;
    produto.urlFotoProduto = "";
    produto.precoProduto = _precoController.numberValue;
    produto.prazo = _prazoController.text;
    produto.existe = true;
    produto.disponivel = true;
    String msgErro = "";
    if (produto.nomeProduto.isEmpty) {
      msgErro = "Digite o nome do produto";
    } else if (produto.descricaoProduto.isEmpty) {
      msgErro = "Digite a descrição do produto";
    }else if(produto.precoProduto == 0.0){
      msgErro = "Digite o preço do produto";
    } else {
      _mostraProgresso(context);
      if(_cadastrar){
        return await _criarProduto(produto);
      } else{
        return await _updateProduto();
      }
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(msgErro),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK")),
            ],
          );
        });
  }

  _criarProduto(Produto produto) async {
    Firestore db = Firestore.instance;
    db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja)
        .collection("produtos").add(produto.toMap()).then((dados){
          _produtoId = dados.documentID;
          Map<String, dynamic> _id = {
            "id" : _produtoId
          };
          db.collection("lojas")
          .document(_idUsuario)
          .collection("lojasusuario")
          .document(_idLoja)
          .collection("produtos").document(_produtoId).updateData(_id);
          if(_imagemSelecionada != null) {
            _uploadImagem();
          } else {
            Navigator.pop(_dialogoContext);
            Navigator.popAndPushNamed(context, "/lista_suaslojas");
          }
    });
    //_produtoId = ref.documentID;
  }

  //UPLOAD FOTO DO PERFIL
  Future _uploadImagem() async {
    Firestore db = Firestore.instance;
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    _fotoPerfil = _produtoId + ".jpg";
    StorageReference arquivo = pastaRaiz
        .child("fotos_lojas")
        .child(_idUsuario)
        .child(_nomeLoja)
        .child(_fotoPerfil);
    StorageUploadTask task = await arquivo.putFile(_imagemSelecionada);
    final snapshot = await task.onComplete;
    //_recuperaURL(snapshot);
    Map<String, dynamic> urlfotoperfil;
    _urlFotoPerfil = await snapshot.ref.getDownloadURL().then((urlrecuperada){
      urlfotoperfil = {
        "urlfotoperfil": urlrecuperada
      };
      db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idLoja).collection("produtos").document(_produtoId).updateData(urlfotoperfil);
      Navigator.pop(_dialogoContext);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Produtosloja(lojaID, nomeLoja, usuario, url, lojaAtiva)));
    });
    task.events.listen((StorageTaskEvent storageEvent){
      switch(storageEvent.type){
        case StorageTaskEventType.progress :
          return Center(
            child: CircularProgressIndicator(),
          );
        case StorageTaskEventType.failure :
          return AlertDialog(
            title: Text("Não foi possível carregar a imagem. Tente novamente."),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK")),
            ],
          );
        case StorageTaskEventType.pause :
        case StorageTaskEventType.resume :
        case StorageTaskEventType.success:
      }
      return storageEvent.type;
    });
  }

  _updateProduto() async {
    Firestore db = Firestore.instance;
    Map<String, dynamic> _updateProduto = {
      "nome" : _nomeController.text,
      "descricao" : _descricaoController.text,
      "preco" : _precoController.numberValue,
      "disponivel" : habilitado,
      "prazo" : _prazoController.text
    };
    await db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idLoja).collection("produtos").document(_produtoId).updateData(_updateProduto);
    if(_imagemSelecionada != null) {
      _uploadImagem();
    } else {
      Navigator.pop(_dialogoContext);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Produtosloja(lojaID, nomeLoja, usuario, url, lojaAtiva)));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _idUsuario = widget._idUsuario;
    _idLoja = widget._idLoja;
    _cadastrar = widget._cadastro;
    _nomeLoja = widget._nomeLoja;
    lojaID = _idLoja;
    nomeLoja = _nomeLoja;
    usuario = _idUsuario;
    url = widget._url;
    lojaAtiva = widget._lojaAtiva;
    Produto _recuperaProduto = widget._produto;
    _produtoId = _recuperaProduto.idProduto;
    _nomeRecuperado = _recuperaProduto.nomeProduto;
    _descricaoRecuperado = _recuperaProduto.descricaoProduto;
    _precoRecuperado = _recuperaProduto.precoProduto;
    if(_precoRecuperado == null){
      _precoRecuperado = 0.0;
    }

    _urlRecuperado = _recuperaProduto.urlFotoProduto;
    _prazoRecuperado = _recuperaProduto.prazo;
    habilitado = _recuperaProduto.disponivel;
    if(_urlRecuperado == null){
      _urlRecuperado = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
    }
    if(_cadastrar == false){
      _textoBotao = "Atualizar";
      _tituloAppbar = "Atualizar produto";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Produtosloja(lojaID, nomeLoja, usuario, url, lojaAtiva)));
                }),
          title: Text(_tituloAppbar),
        ),
        body: Builder(builder: (context) => Container(
            decoration: BoxDecoration(color: Colors.amberAccent),
            padding: EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(bottom: 2),),
                    GestureDetector(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: _foto == null
                            ? Image.network(_urlRecuperado)
                            : Image.file(_foto),
                      ),
                      onTap: () {
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
                    Column(
                      children: <Widget>[
                        _cadastrar == false
                            ? Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 10),
                          child: CheckboxListTile(
                            title: Text("Produto ativo/disponível?"),
                            value: habilitado,
                            selected: false,
                            onChanged: (bool valor){
                              setState(() {
                                habilitado = valor;
                              });;
                            },
                          ),
                        )
                            : Column()
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 10),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                hintText: "Nome do produto",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            style: TextStyle(fontSize: 15),
                            controller: _nomeController = new TextEditingController(text: _nomeRecuperado),
                            onChanged: (text){
                              _nomeRecuperado = text;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                hintText: "Descrição do produto",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            style: TextStyle(fontSize: 15),
                            controller: _descricaoController= new TextEditingController(text: _descricaoRecuperado),
                            onChanged: (text){
                              _descricaoRecuperado = text;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                hintText: "Preço",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            style: TextStyle(fontSize: 15),
                            controller: _precoController = new MoneyMaskedTextController(
                                leftSymbol: 'R\$ ',
                                decimalSeparator: ",",
                                thousandSeparator: ".",
                                initialValue: _precoRecuperado,
                                precision: 2
                            ),
                            //onChanged: (text){
                              //_precoRecuperado = text as double;
                            //},
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                hintText: "Prazo de entrega em dias",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            style: TextStyle(fontSize: 15),
                            controller: _prazoController = new TextEditingController(text: _prazoRecuperado),
                            onChanged: (text){
                              _prazoRecuperado = text;
                            },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: BotaoCustomizado(
                              textoBotao: _textoBotao,
                              onPressed: ()  {
                                _dialogoContext = context;
                                _validaCampos();
                              },
                            )
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )),
        )
    );
  }
}
