import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import 'models/usuarios.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Config extends StatefulWidget {
  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  String qualErro;
  File _imagemSelecionada;
  File _foto;
  String _urlFotoPerfil;
  String _fotoPerfil;
  String _idUsuario;
  String _nomeRecuperado;
  String _emailRecuperado;
  String _urlRecuperada = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
  bool _subindoImagem = false;

  //SELECIONA FOTO
  Future _recuperaImagem(bool daCamera) async {
    if(daCamera){
      _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
    } else{
      _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    print(_imagemSelecionada);
    if (_imagemSelecionada != null){
      setState(() {
        _foto = _imagemSelecionada;
      });
    }
  }

  //VALIDA OS CAMPOS DIGITADOS
  _validaCampos() async {
    Usuario usuario = Usuario();
    usuario.nome = _nomeController.text;
    usuario.email = _loginController.text.trim();
    usuario.urlFotoPerfil = _urlRecuperada;
    String msgErro = "";
    if (usuario.nome.isEmpty) {
      msgErro = "Digite seu nome";
    } else if (usuario.email.isEmpty) {
      msgErro = "Forneça um e-mail válido";
    }  else {
      return await _atualizarUsuario(usuario);
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

  //ATUALIZA O USUÁRIO NO FIREBASE
  _atualizarUsuario(Usuario usuario) async {
    String msgErro = "";
    String funcao;
    String flatB1 = "";
    String flatB2 = "";
    Firestore db = Firestore.instance;
    db.collection("usuarios")
        .document(_idUsuario)
        .updateData(usuario.toMap()).then((firebaseuser){
      if(_imagemSelecionada != null) {
        _uploadImagem();
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_)=>false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_)=>false);
      }
    }).catchError((erro) {
      print("Erro ao criar usuário ${erro.code}");
      qualErro = erro.code;
      switch (qualErro) {
        case "ERROR_INVALID_EMAIL":
          msgErro = "e-mail incorreto. Digite novamente.";
          flatB1 = "";
          flatB2 = "OK";
          funcao = "digitarnovamente";
      };
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
                    child: Text(flatB1)),
                FlatButton(
                    onPressed: () {
                      if (funcao == "recuperasenha") {
                        Navigator.pop(context);
                      } else if (funcao == "digitarnovamente") {
                        _limpaDados();
                        Navigator.pop(context);
                      }
                      else {
                        _senhaController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: Text(flatB2)),
              ],
            );
          });
    });
  }
  //UPLOAD FOTO DO PERFIL
  Future _uploadImagem() async {
    _subindoImagem = true;
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    _fotoPerfil = _idUsuario.toString() + ".jpg";
    StorageReference arquivo = pastaRaiz
        .child("fotos_perfil")
        .child(_fotoPerfil);
    StorageUploadTask task = await arquivo.putFile(_imagemSelecionada);
    final snapshot = await task.onComplete;
    //_recuperaURL(snapshot);
    Map<String, dynamic> urlfotoperfil;
    _urlFotoPerfil = await snapshot.ref.getDownloadURL().then((urlrecuperada){
      urlfotoperfil = {
        "urlfotoperfil": urlrecuperada
      };
    });
    Firestore db = await Firestore.instance;
    db.collection("usuarios").document(_idUsuario).updateData(urlfotoperfil);
    task.events.listen((StorageTaskEvent storageEvent){
      switch(storageEvent.type){
        case StorageTaskEventType.progress : return Center(
          child: CircularProgressIndicator(),
        );
        case StorageTaskEventType.failure : return AlertDialog(
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
    });
  }

  //RECUPERA URL
  Future _recuperaURL(StorageTaskSnapshot snapshot) async {
    _urlFotoPerfil = await snapshot.ref.getDownloadURL().toString();
  }

  //LIMPA CAMPOS LOGIN E SENHA
  _limpaDados(){
    _loginController.clear();
    _senhaController.clear();
    setState(() {
    });
  }

  //RECUPERA DADOS USUÁRIO
  void _recuperaUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario = _usuario.uid;
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios")
        .document(_idUsuario)
        .get().then((dados){
      //var dados = snapshot.data;
      setState(() {

        if(dados["urlfotoperfil"] != null){
          _urlRecuperada = dados["urlfotoperfil"];
        }
        _nomeRecuperado = dados["nome"];
        _emailRecuperado = dados["email"];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      _recuperaUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações do usuário")
      ),
        body: Builder(
          builder: (context) => Container(
              decoration: BoxDecoration(color: Colors.amberAccent),
              padding: EdgeInsets.all(16),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16),
                        child: _subindoImagem
                            ? CircularProgressIndicator()
                            : Container()
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10),),
                      GestureDetector(
                        child: CircleAvatar(
                          backgroundColor: Colors.amber,
                          radius: 100,
                          backgroundImage:
                          _foto == null
                              ? NetworkImage(_urlRecuperada)
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
                                  hintText: "Nome",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                              style: TextStyle(fontSize: 20),
                              controller: _nomeController = new TextEditingController(text: _nomeRecuperado),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: TextField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "E-mail",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32))),
                                style: TextStyle(fontSize: 20),
                                controller: _loginController = new TextEditingController(text: _emailRecuperado),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: RaisedButton(
                                  child: Text(
                                    "Atualizar",
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  color: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                  onPressed: ()  {
                                    _validaCampos();
                                  })
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
        )
      //bottomNavigationBar: Container(),
    );
  }
}

