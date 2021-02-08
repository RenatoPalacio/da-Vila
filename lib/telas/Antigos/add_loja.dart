import 'package:compradordodia/models/categorias.dart';
import 'package:compradordodia/models/loja.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'dart:convert';

class addLoja extends StatefulWidget {
  @override
  Loja atualizaLoja = Loja();
  bool cadastrar;
  addLoja(this.cadastrar, {this.atualizaLoja});
  _addLojaState createState() => _addLojaState();
}

class _addLojaState extends State<addLoja> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  TextEditingController _cepController = TextEditingController();
  TextEditingController _logradouroController = TextEditingController();
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _complementoController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();
  TextEditingController _ufController = TextEditingController();

  String qualErro;
  File _imagemSelecionada;
  File _foto;
  String _urlFotoPerfil;
  String _fotoPerfil;
  String _idUsuario;
  String _idLoja;
  String _nomeLoja;
  String _urlRecuperado = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
  String _nomeRecuperado;
  String _descricaoRecuperado;
  String _cepRecuperado;
  String _logradouroRecuperado;
  String _numeroRecuperado;
  String _complementoRecuperado;
  String _cidadeRecuperado;
  String _ufRecuperado;
  String _idRecuperado;
  String _tituloAppbar = "Cadastrar loja";
  String _textoBotao = "Cadastrar";
  bool _cadastrar;
  List<DropdownMenuItem<String>> _listaCategorias = List();
  String _categoria0;
  String _categoria1;
  String _categoria2;
  BuildContext _dialogoContext;

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
    Loja loja = Loja();
    loja.nome = _nomeController.text;
    loja.descricao = _descricaoController.text;
    loja.urlFotoPerfil = "";
    loja.cep = _cepController.text;
    loja.endereco = _logradouroController.text;
    loja.numero = _numeroController.text;
    loja.complemento = _complementoController.text;
    loja.cidade = _cidadeController.text;
    loja.uf = _ufController.text;
    loja.lojaexistente = true;
    loja.lojaativa = false;
    loja.categoria1 = _categoria0;
    loja.categoria2 = _categoria1;
    loja.categoria3 = _categoria2;
    String msgErro = "";
    if (loja.nome.isEmpty) {
      msgErro = "Digite o nome da sua loja";
    } else if (loja.descricao.isEmpty) {
      msgErro = "Digite a descrição da sua loja";
    }else {
      _mostraProgresso(_dialogoContext);
      if(_cadastrar){
        return await _criarLoja(loja);
      } else{
        return await _updateLoja();
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

  //CADASTRA A LOJA NO FIREBASE
  _criarLoja(Loja loja) async {
    _nomeLoja = loja.nome;
    //CRIA AUTENTICAÇÃO DO USUÁRIO
    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario =  _usuario.uid;
    loja.adm = _idUsuario;
    Firestore db = Firestore.instance;
    _idLoja = _idUsuario + "_" + _nomeLoja;
    Map<String, dynamic> _dataAtualizacao = {
      "data" : new DateTime.now(),
    };
    db.collection("lojas").document(_idUsuario).setData(_dataAtualizacao);
    db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idLoja).setData(loja.toMap());
    Map<String, dynamic> idloja = {
      "idLoja": _idLoja,
      "Ativo" : true,
      "Existe" : true
    };
    db.collection("usuarios").document(_idUsuario).collection("lojas").document().setData(idloja);
    if(_imagemSelecionada != null) {
      _uploadImagem();
    } else {
      Navigator.pop(_dialogoContext);
      Navigator.pop(context);
    }
  }

  //UPLOAD FOTO DO PERFIL
  Future _uploadImagem() async {
    Firestore db = Firestore.instance;
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    _fotoPerfil = _idLoja + ".jpg";
    StorageReference arquivo = pastaRaiz
        .child("fotos_lojas")
        .child(_idUsuario)
        .child(_fotoPerfil);
    StorageUploadTask task = await arquivo.putFile(_imagemSelecionada);
    final snapshot = await task.onComplete;
    Map<String, dynamic> urlfotoperfil;
    _urlFotoPerfil = await snapshot.ref.getDownloadURL().then((urlrecuperada){
      print("urlrecuperada $urlrecuperada");
      urlfotoperfil = {
        "urlfotoperfil": urlrecuperada
      };
      db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idLoja).updateData(urlfotoperfil);
      if(!_cadastrar){
        _alterarFotoLojaPedidos(urlrecuperada);
      }
      Navigator.pop(_dialogoContext);
      Navigator.pop(context);
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

  //ALTERA FOTO DA LOJA NAS ENCOMENDAS
  _alterarFotoLojaPedidos(urlnova){
    Firestore db = Firestore.instance;
    List _pedidos = List();
    List _compradores = List();
    print(_nomeRecuperado);
    db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja)
        .collection("pedidos").getDocuments().then((docs){
          for (DocumentSnapshot item in docs.documents){
            String docid = item.documentID;
            String inicio = docid.substring(0, docid.indexOf("_")+1);
            String fim = docid.substring(docid.indexOf("_")+1);
            String _idpedido;
            _idpedido = inicio + _nomeRecuperado.toString();
            _pedidos.add(_idpedido);
            _compradores.add(fim);
          }
          int cont = 0;
          for(String iddoc in _compradores){
            Map<String, dynamic> _mapa = {
              "url" : urlnova
            };
            db.collection("usuarios").document(iddoc).collection("pedidos").document(_pedidos[cont]).updateData(_mapa);
            cont = cont + 1;
          }
    });
  }

  //RECUPERA URL
  Future _recuperaURL(StorageTaskSnapshot snapshot) async {
    _urlFotoPerfil = await snapshot.ref.getDownloadURL().toString();
    print("url: $_urlFotoPerfil");
  }

  //LIMPA CAMPOS LOGIN E SENHA
  _limpaDados(){
    _nomeController.clear();
    _descricaoController.clear();
    setState(() {
    });
  }

  //RECUPERA ENDEREÇO PELO CEP
  void _recuperaEndereco() async {
    Map<String, dynamic> _retornoEndereco;
    String _cepDigitado = _cepController.text;
    String _url = "https://viacep.com.br/ws/" + _cepDigitado + "/json/";
    http.Response resposta = await http.get(_url);
    _retornoEndereco = json.decode(resposta.body);
    if(_retornoEndereco["erro"] == true){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("CEP inválido. Digite novamente."),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      setState(() {
                        return _cepController.clear();
                      });
                      Navigator.pop(context);
                    },
                    child: Text("OK")),
              ],
            );
          });
    }else{
      setState(() {
        _cepRecuperado = _cepController.text;
        _logradouroRecuperado = _retornoEndereco["logradouro"];
        _cidadeRecuperado = _retornoEndereco["localidade"];
        _ufRecuperado = _retornoEndereco["uf"];
      });
    }
  }

  //ALTERA DADOS LOJA
  _updateLoja() async {
    print("Update: $_idRecuperado");
    Firestore db = Firestore.instance;
    Map<String, dynamic> _updateLoja = {
      "nome" : _nomeController.text,
      "descricao" : _descricaoController.text,
      "cep" : _cepController.text,
      "endereco" : _logradouroController.text,
      "numero" : _numeroController.text,
      "complemento" : _complementoController.text,
      "cidade" : _cidadeController.text,
      "uf" : _ufController.text,
      "categoria1" :_categoria0,
      "categoria2" :_categoria1,
      "categoria3" :_categoria2,
    };
    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario =  _usuario.uid;
    _idLoja = _idRecuperado;
    await db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idRecuperado).updateData(_updateLoja);
    if(_imagemSelecionada != null) {
      _uploadImagem();
    } else {
      Navigator.pop(_dialogoContext);
      Navigator.pop(context);
    }
  }

  //CARREGA DROPDOWN CATEGORIA
  _carregaListaCategorias(){
    _listaCategorias = Categorias.getCategorias();
  }

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
              Text("Salvando loja"),
            ],
          ),
        );
      }
    );
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    Loja _recuperaLoja = widget.atualizaLoja;
    _idRecuperado = _recuperaLoja.id;
    _urlRecuperado = _recuperaLoja.urlFotoPerfil;
    _nomeRecuperado = _recuperaLoja.nome;
    _descricaoRecuperado = _recuperaLoja.descricao;
    _cepRecuperado = _recuperaLoja.cep;
    _logradouroRecuperado = _recuperaLoja.endereco;
    _numeroRecuperado = _recuperaLoja.numero;
    _complementoRecuperado = _recuperaLoja.complemento;
    _cidadeRecuperado = _recuperaLoja.cidade;
    _ufRecuperado = _recuperaLoja.uf;
    _categoria0 = _recuperaLoja.categoria1;
    _categoria1 = _recuperaLoja.categoria2;
    _categoria2 = _recuperaLoja.categoria3;
    if(_urlRecuperado == null){
       _urlRecuperado = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
    }
    _cadastrar = widget.cadastrar;
    if(_cadastrar == false){
      _textoBotao = "Atualizar";
      _tituloAppbar = "Atualizar loja";
    }
    _carregaListaCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.popAndPushNamed(context, "/lista_suaslojas");
            }),*/
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
                                hintText: "Nome da loja",
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
                                hintText: "Descrição da loja",
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
                          padding: EdgeInsets.only(bottom: 0),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                hintText: "CEP - ex: 01010000",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            style: TextStyle(fontSize: 15),
                            controller: _cepController= new TextEditingController(text: _cepRecuperado),
                            maxLength: 8,
                            onChanged: (text){
                              if(text.length == 8){
                                _recuperaEndereco();
                              }
                            },
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              hintText: "Endereço",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32))),
                          style: TextStyle(fontSize: 15),
                          controller: _logradouroController = new TextEditingController(text: _logradouroRecuperado),
                          readOnly: true,
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              hintText: "Número",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32))),
                          style: TextStyle(fontSize: 15),
                          controller: _numeroController = new TextEditingController(text: _numeroRecuperado),
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              hintText: "Complemento",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32))),
                          style: TextStyle(fontSize: 15),
                          controller: _complementoController = new TextEditingController(text: _complementoRecuperado),
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              hintText: "Cidade",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32))),
                          style: TextStyle(fontSize: 15),
                          controller: _cidadeController = new TextEditingController(text: _cidadeRecuperado),
                          readOnly: true,
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              hintText: "UF",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32))),
                          style: TextStyle(fontSize: 15),
                          controller: _ufController = new TextEditingController(text: _ufRecuperado),
                          readOnly: true,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            "Indique até 3 categorias para sua loja:",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Container(
                          width: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                child: DropdownButtonHideUnderline(
                                    child: Center(
                                      child: DropdownButton(
                                          iconEnabledColor: Colors.black,
                                          value: _categoria0,
                                          items: _listaCategorias,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.black,
                                          ),
                                          onChanged: (categoria){
                                            setState(() {
                                              _categoria0 = categoria;
                                            });
                                          }),
                                    )
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                child: DropdownButtonHideUnderline(
                                    child: Center(
                                      child: DropdownButton(
                                          iconEnabledColor: Colors.black,
                                          value: _categoria1,
                                          items: _listaCategorias,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                              color: Colors.black,
                                          ),
                                          onChanged: (categoria){
                                            setState(() {
                                              _categoria1 = categoria;
                                            });
                                          }),
                                    )
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                child: DropdownButtonHideUnderline(
                                    child: Center(
                                      child: DropdownButton(
                                          iconEnabledColor: Colors.black,
                                          value: _categoria2,
                                          items: _listaCategorias,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                              color: Colors.black,
                                          ),
                                          onChanged: (categoria){
                                            setState(() {
                                              _categoria2 = categoria;
                                            });
                                          }),
                                    )
                                ),
                              ),
                            ],
                          )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: BotaoCustomizado(
                              textoBotao: _textoBotao,
                              onPressed: ()  {
                                _dialogoContext = context;
                                _validaCampos();
                              },
                            ),
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
