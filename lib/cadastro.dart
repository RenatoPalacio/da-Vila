import 'dart:convert';
import 'package:validadores/validadores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'models/usuarios.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Cadastro extends StatefulWidget {
  @override
  String email;
  bool cadastro;
  bool obrigatorio;
  Cadastro(this.cadastro, {this.email, this.obrigatorio});
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  TextEditingController _senhaConfirmaController = TextEditingController();
  TextEditingController _telefoneController = TextEditingController();
  TextEditingController _zapController = TextEditingController();
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _CEPController = TextEditingController();
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
  bool _subindoImagem = false;
  bool _senhaobscura = true;
  IconData _icone = Icons.remove_red_eye;
  String _urlRecuperada;
  String _nomeRecuperado;
  String _emailRecuperado;
  String _telefoneRecuperado;
  String _zapRecuperado;
  String _cpfRecuperado;
  String _bairro;
  String _cepRecuperado;
  String _logradouroRecuperado;
  String _cidadeRecuperado;
  String _ufRecuperado;
  String _numeroRecuperado;
  String _complementoRecuperado;
  double _latitude;
  double _longitude;
  final _formCadastroKey = GlobalKey<FormState>();
  bool _lendoRecuperaDados = false;
  bool _cadastro;
  String _idDocEnderecoPref;
  String _botao = "Cadastrar";
  bool _obrigatorio = false;

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
    usuario.senha = _senhaController.text;
    usuario.telefone = _telefoneController.text;
    usuario.zap = _zapController.text;
    usuario.cpf = _cpfController.text;
    usuario.cep = _CEPController.text;
    usuario.endereco = _logradouroRecuperado;
    usuario.numero = _numeroController.text;
    usuario.complemento = _complementoController.text;
    usuario.bairro = _bairro;
    usuario.cidade = _cidadeRecuperado;
    usuario.uf = _ufRecuperado;
    usuario.latitude = _latitude;
    usuario.longitude = _longitude;

    String senhaconfirma = _senhaConfirmaController.text;
    usuario.urlFotoPerfil = "";
    if(senhaconfirma != usuario.senha && _cadastro){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("As senhas fornecidas devem ser iguais."),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK")),
              ],
            );
          });
    }else if (_cadastro){
      return await _criarUsuario(usuario);
    } else {
      return await _atualizarCadastro(usuario);
    }
  }

  //CADASTRA O USUÁRIO NO FIREBASE
  _criarUsuario(Usuario usuario) async {
    String msgErro = "";
    String funcao;
    String flatB1 = "";
    String flatB2 = "";
    _subindoImagem = true;
    //CRIA AUTENTICAÇÃO DO USUÁRIO
    FirebaseAuth auth = await FirebaseAuth.instance;
    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      firebaseUser.user.sendEmailVerification();
      //CRIA DOCUMENTO DO USUÁRIO
      _idUsuario =  firebaseUser.user.uid;
      Firestore db = Firestore.instance;
        db.collection("usuarios").document(_idUsuario).setData(usuario.toMap());
        db.collection("usuarios").document(_idUsuario).collection("enderecos").document().setData(usuario.toMapEnd());
      if(_imagemSelecionada != null) {
        _uploadImagem();
        //Navigator.pushNamedAndRemoveUntil(context, "/home", (_)=>false);
      } else {
        //Navigator.pushNamedAndRemoveUntil(context, "/home", (_)=>false);
      }
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Verificação de e-mail"),
              content: Text("Um e-mail de verifição foi enviado para ${usuario.email}."),
              actions: <Widget>[
                FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("OK")),
              ],
            );
          }
      );
    })
      //trata os erros
    .catchError((erro) {
      qualErro = erro.code;
      switch (qualErro) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
          msgErro = "e-mail já cadastrado. Recuperar senha?";
          flatB1 = "Não";
          flatB2 = "Sim";
          funcao = "recuperasenha";
          break;
        case "ERROR_INVALID_EMAIL":
          msgErro = "e-mail incorreto. Digite novamente.";
          flatB1 = "";
          flatB2 = "OK";
          funcao = "digitarnovamente";
          break;
        case "ERROR_WEAK_PASSWORD":
          msgErro = "Senha inválida, digite novamente. Deve ter no mínimo 6 caracteres";
          flatB1 = "";
          flatB2 = "OK";
          funcao = "";
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

  _atualizarCadastro(Usuario usuario) async {
    Firestore db = Firestore.instance;
    db.collection("usuarios").document(_idUsuario).updateData(usuario.toMap());
    db.collection("usuarios").document(_idUsuario).collection("enderecos").document(_idDocEnderecoPref).updateData(usuario.toMapEnd());
    if(_imagemSelecionada != null) {
      _uploadImagem();
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_)=>false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "/home", (_)=>false);
    }
  }

  //UPLOAD FOTO DO PERFIL
  Future _uploadImagem() async {
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

  //RECUPERA ENDEREÇO PELO CEP
  void _recuperaEndereco(String cepdigitado) async {
    Map<String, dynamic> _retornoEndereco;
    //String _cepDigitado = _cepController.text;
    String _cepDigitado = cepdigitado;
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
                      Navigator.pop(context);
                    },
                    child: Text("OK")),
              ],
            );
          });
    }else{
      _bairro = _retornoEndereco["bairro"];
      setState(() {
        _cepRecuperado = _CEPController.text;
        _logradouroRecuperado = _retornoEndereco["logradouro"];
        _cidadeRecuperado = _retornoEndereco["localidade"];
        _ufRecuperado = _retornoEndereco["uf"];
        _numeroRecuperado = null;
      });
    }
  }

  //RECUPERA LATITUDE E LONGITUDE
  _recuperaLatLong() async {
    String _endereco = _logradouroRecuperado + "," + _numeroRecuperado.toString() + " " + _cidadeRecuperado;
    List<Placemark> placemarks = await Geolocator().placemarkFromAddress(_endereco);
    if(placemarks != null && placemarks.length > 0){
      Placemark item = placemarks[0];
      _latitude =  item.position.latitude;
      _longitude =  item.position.longitude;
    }
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
        _telefoneRecuperado = dados["telefone"];
        _zapRecuperado = dados["zap"];
        _cpfRecuperado = dados["cpf"];
      });

      Future<QuerySnapshot> query = db.collection("usuarios")
          .document(_idUsuario)
          .collection("enderecos")
          .where("nome", isEqualTo: "Principal").getDocuments().then((_dados){
        for (DocumentSnapshot dados in _dados.documents){
          setState(() {
            _idDocEnderecoPref = dados.documentID;
            _cepRecuperado = dados["cep"];
            _logradouroRecuperado = dados["endereco"];
            _numeroRecuperado = dados["numero"];
            _complementoRecuperado = dados["complemento"];
            _cidadeRecuperado = dados["cidade"];
            _ufRecuperado = dados["uf"];
            //_lendoRecuperaDados = false;

          });
        }
        if(_idDocEnderecoPref == null){
          Usuario usuario = Usuario();
          _idDocEnderecoPref = db.collection("usuarios").document(_idUsuario).collection("enderecos").document().documentID;
          db.collection("usuarios").document(_idUsuario).collection("enderecos").document(_idDocEnderecoPref).setData(usuario.toMapEnd());
        }
        /*
        else {
          _idDocEnderecoPref = dados.documentID;
        }
        */
        setState(() {
          _lendoRecuperaDados = false;
        });
      }
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cadastro = widget.cadastro;
    widget.obrigatorio == null ? _obrigatorio = false : _obrigatorio = widget.obrigatorio;
    if(!_cadastro){
      setState(() {
        _lendoRecuperaDados = true;
        _botao = "Atualizar";
      });
      _recuperaUsuario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
        automaticallyImplyLeading: false,
        leading: _obrigatorio
            ? Container()
            : GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Builder(
        builder: (context) => Container(
            decoration: BoxDecoration(color: Colors.amberAccent),
            padding: EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: _lendoRecuperaDados
                    ? Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(backgroundColor: Colors.white,),)])
                    : Column(
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
                        _urlRecuperada == null
                            ? _foto != null
                            ? FileImage(_foto)
                            : AssetImage("images/semfoto.png")
                            : _foto == null
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
                    Form(
                        key: _formCadastroKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only( top: 10),
                              child: TextFormField(
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
                                validator: (valor){
                                  return Validador()
                                      .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                                      .valido(valor,clearNoNumber: false);
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "E-mail",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32))),
                                style: TextStyle(fontSize: 20),
                                validator: (valor){
                                  return Validador()
                                      .add(Validar.EMAIL,  msg: 'e-mail Inválido')
                                      .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                                      .valido(valor,clearNoNumber: false);
                                },
                                controller:
                                widget.email != null
                                    ? _loginController = new TextEditingController(text: widget.email)
                                    : _loginController = new TextEditingController(text: _emailRecuperado),
                              ),
                            ),
                            _cadastro
                                ? Column(
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "Senha",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32)),
                                    suffixIcon: GestureDetector(
                                      onTap: (){
                                        if (_senhaobscura){
                                          setState(() {
                                            _senhaobscura = false;
                                            _icone = Icons.not_interested;
                                          });
                                        } else {
                                          setState(() {
                                            _senhaobscura = true;
                                            _icone = Icons.remove_red_eye;
                                          });
                                        }
                                      },
                                      child: Icon(
                                        _icone,
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  obscureText: _senhaobscura,
                                  controller: _senhaController,
                                  validator: (valor){
                                    return Validador()
                                        .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                                        .minLength(6, msg: 'A senha deve ter no mínimo 6 caracteres')
                                        .valido(valor,clearNoNumber: false);
                                  },
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "Confirmar senha",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32)),
                                    suffixIcon: GestureDetector(
                                      onTap: (){
                                        if (_senhaobscura){
                                          setState(() {
                                            _senhaobscura = false;
                                            _icone = Icons.not_interested;
                                          });
                                        } else {
                                          setState(() {
                                            _senhaobscura = true;
                                            _icone = Icons.remove_red_eye;
                                          });
                                        }
                                      },
                                      child: Icon(
                                        _icone,
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  obscureText: _senhaobscura,
                                  controller: _senhaConfirmaController,
                                  validator: (valor){
                                    return Validador()
                                        .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                                        .minLength(6, msg: 'A senha deve ter no mínimo 6 caracteres')
                                        .valido(valor,clearNoNumber: false);
                                  },
                                ),
                              ],
                            )
                                : Container(),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                controller: _telefoneController = new TextEditingController(text: _telefoneRecuperado),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "Telefone de contato",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32))),
                                inputFormatters: [MaskedInputFormater("(##) #####-####")],
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                validator: (valor){
                                  return Validador()
                                      .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                                      .minLength(9, msg: 'O telefone deve ter no mínimo 9 caracteres com o DDD')
                                      .valido(valor,clearNoNumber: false);
                                },
                                onChanged: (telefone){_telefoneRecuperado = _telefoneController.text;},
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "WhatsApp",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32))),
                                style: TextStyle(fontSize: 20),
                                controller: _zapController = new TextEditingController(text: _zapRecuperado),
                                inputFormatters: [MaskedInputFormater("(##) #####-####")],
                                onChanged: (zap){_zapRecuperado = _zapController.text;},
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only( top: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                autofocus: false,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "CPF",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32))),
                                validator: (valor){
                                  return Validador()
                                      .add(Validar.CPF, msg: 'CPF Inválido')
                                      .minLength(11)
                                      .maxLength(11)
                                      .valido(valor,clearNoNumber: true);
                                },
                                inputFormatters: [MaskedInputFormater("###.###.###-##")],
                                style: TextStyle(fontSize: 20),
                                controller: _cpfController = new TextEditingController(text: _cpfRecuperado),
                                onChanged: (cpf){_cpfRecuperado = _cpfController.text;},
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only( top: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                autofocus: false,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    hintText: "CEP - ex: 01010000",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32))),
                                style: TextStyle(fontSize: 20),
                                controller: _CEPController = new TextEditingController(text: _cepRecuperado),
                                validator: (valor){
                                  return Validador()
                                      .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                                      .minLength(8, msg: 'O CEP deve ter 8 números')
                                      .maxLength(8, msg: 'O CEP deve ter 8 números')
                                      .valido(valor,clearNoNumber: false);
                                },
                                onChanged: (cepdigitado){
                                  if(cepdigitado.length == 8){
                                    _recuperaEndereco(cepdigitado);
                                  }
                                },
                              ),
                            ),
                            TextFormField(
                              enabled: false,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  hintText: "Endereço",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                              style: TextStyle(fontSize: 20),
                              controller: _logradouroController = new TextEditingController(text: _logradouroRecuperado),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  hintText: "Número",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                              style: TextStyle(fontSize: 20),
                              controller: _numeroController = new TextEditingController(text: _numeroRecuperado),
                              validator: (valor){
                                return Validador()
                                    .add(Validar.OBRIGATORIO, msg: 'Campo obrigatório')
                                    .valido(valor,clearNoNumber: false);
                              },
                              onChanged: (_){
                                _numeroRecuperado = _numeroController.text;
                                if(_logradouroRecuperado != null && _cidadeRecuperado != null){
                                  _recuperaLatLong();
                                }
                              },
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  hintText: "Complemento",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                              style: TextStyle(fontSize: 20),
                              controller: _complementoController = new TextEditingController(text: _complementoRecuperado),
                            ),
                            TextFormField(
                              enabled: false,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  hintText: "Cidade",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                              style: TextStyle(fontSize: 20),
                              controller: _cidadeController = new TextEditingController(text: _cidadeRecuperado),
                            ),
                            TextFormField(
                              enabled: false,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  hintText: "UF",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32))),
                              style: TextStyle(fontSize: 20),
                              controller: _ufController = new TextEditingController(text: _ufRecuperado),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: RaisedButton(
                                    child: Text(
                                      "Cadastrar",
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    color: Colors.amber,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32)),
                                    onPressed: ()  {
                                      if( _formCadastroKey.currentState.validate() ){
                                        _validaCampos();
                                      }
                                    })
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            )),
      )
      //bottomNavigationBar: Container(),
    );
    ;
  }
}
