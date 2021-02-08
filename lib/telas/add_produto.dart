import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/lista_seusprodutos.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:compradordodia/widgets/inputcustomizado.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:validadores/validadores.dart';

class addProduto extends StatefulWidget {
  @override
  bool _cadastro;
  Produto _produto;
  String _idUsuario;
  String _idLoja;
  String _nomeLoja;
  String _url;
  bool _lojaAtiva;
  double _distancia;
  addProduto(this._cadastro, this._produto, this._idUsuario, this._idLoja, this._nomeLoja, this._url, this._lojaAtiva, this._distancia);
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
  String _tituloAppbar = "Cadastrar oferta";
  String _textoBotao = "Cadastrar";
  bool _cadastrar;
  String _produtoId;
  File _imagemSelecionada;
  File _foto;
  String _urlFotoPerfil;
  String _fotoPerfil;
  String _urlRecuperado = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
  BuildContext _dialogoContext;
  final _formProdutoKey = GlobalKey<FormState>();
  double _espacamento = 16;
  Produto saveproduto;
  double _distancia;

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
      _mostraProgresso(context);
      if(_cadastrar){
        saveproduto.disponivel = true;
        return await _criarProduto(saveproduto);
      } else{
        saveproduto.disponivel = habilitado;
        saveproduto.idProduto = _produtoId;
        saveproduto.idLoja = _idLoja;
        saveproduto.idUsuario = _idUsuario;
        return await _updateProduto(saveproduto);
      }
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
              builder: (context) => Produtosloja(lojaID, nomeLoja, usuario, url, lojaAtiva, _distancia)));
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

  _updateProduto(Produto produto) async {

    Firestore db = Firestore.instance;
    await db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja)
        .collection("produtos")
        .document(_produtoId).updateData(produto.toMap());
    if(_imagemSelecionada != null) {
      _uploadImagem();
    } else {
      Navigator.pop(_dialogoContext);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Produtosloja(lojaID, nomeLoja, usuario, url, lojaAtiva, _distancia)));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveproduto = Produto();
    _distancia = widget._distancia;
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
      _tituloAppbar = "Atualizar oferta";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amberAccent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Produtosloja(lojaID, nomeLoja, usuario, url, lojaAtiva, _distancia)));
                }),
          title: Text(_tituloAppbar),
        ),
        body: Builder(builder: (context) => SingleChildScrollView(
          child: Container(
            //height: ,
            decoration: BoxDecoration(color: Colors.amberAccent),
            padding: EdgeInsets.all(16),
            child: Form(
                key: _formProdutoKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FormField(
                        initialValue: _foto,
                        validator: (imagem){
                          if(_foto == null && _cadastrar){
                            return "Selecione uma foto do produto/oferta";
                          }
                          return null;
                        },
                        builder: (state){
                          return Column(
                            children: <Widget>[
                              Container(
                                child: Center(
                                  child: GestureDetector(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.amber,
                                      radius: 75,
                                      backgroundImage:
                                      _foto == null
                                          ? NetworkImage(_urlRecuperado)
                                          : FileImage(_foto),
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
                                ),
                              ),
                              state.hasError
                                  ? Container(child: Text("[${state.errorText}]",style: TextStyle(color: Colors.red, fontSize: 14),),)
                                  : Container(),
                            ],
                          );
                          return Container();
                        },
                    ),
                    Column(
                      children: <Widget>[
                        _cadastrar == false
                            ? Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 10),
                          child: CheckboxListTile(
                            title: Text("Oferta ativa/disponível?"),
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
                    Padding(
                      padding: EdgeInsets.only(bottom: _espacamento, top: _espacamento),
                      child: InputCustomizado(
                        hint: "Nome",
                        initialValue: _nomeRecuperado,
                        onSaved: (nome){
                          saveproduto.nomeProduto = nome;
                        },
                        maxLines: null,
                        validator: (valor){
                          return Validador()
                              .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                              .valido(valor);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: _espacamento),
                      child: InputCustomizado(
                        hint: "Descrição do produto (200 caracteres)",
                        initialValue: _descricaoRecuperado,
                        onSaved: (descricao){
                          saveproduto.descricaoProduto = descricao;
                        },
                        maxLines: null,
                        validator: (valor){
                          return Validador()
                              .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                              .maxLength(200, msg: "Máximo de 200 caracteres")
                              .valido(valor);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: _espacamento),
                      child: InputCustomizado(
                        hint: "Preço unitário",
                        controller: _precoController = new MoneyMaskedTextController(
                            leftSymbol: 'R\$ ',
                            decimalSeparator: ",",
                            thousandSeparator: ".",
                            initialValue: _precoRecuperado,
                            precision: 2
                        ),
                        type: TextInputType.number,
                        onSaved: (preco){
                          saveproduto.precoProduto = _precoController.numberValue;
                        },
                        maxLines: null,
                        validator: (valor){
                          valor = valor.substring(3,4);
                          return Validador()
                              .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                              .minVal(1, msg: "Valor deve ser maior que 0")
                              .valido(valor);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: _espacamento),
                      child: InputCustomizado(
                        hint: "Prazo de entrega em dias corridos",
                        type: TextInputType.number,
                        initialValue: _prazoRecuperado,
                        onSaved: (prazo){
                          saveproduto.prazo = prazo;
                        },
                        maxLines: null,
                        validator: (valor){
                          return Validador()
                              .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                              .minVal(1, msg: "prazo deve ser maior que 0")
                              .valido(valor);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                              child: BotaoCustomizado(
                                textoBotao: _textoBotao,
                                onPressed: ()  {
                                  if( _formProdutoKey.currentState.validate() ){
                                    _formProdutoKey.currentState.save();
                                    _dialogoContext = context;
                                    _validaCampos();
                                  }
                                },
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
        )
    );
  }
}
