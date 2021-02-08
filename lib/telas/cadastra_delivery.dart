import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compradordodia/models/entregador.dart';
import 'package:compradordodia/models/menu_coletivos.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:compradordodia/widgets/inputcustomizado.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:validadores/Validador.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class CadastraDelivery extends StatefulWidget {
  @override
  _CadastraDeliveryState createState() => _CadastraDeliveryState();
}

class _CadastraDeliveryState extends State<CadastraDelivery> {

  final _formDeliveryKey = GlobalKey<FormState>();
  File _imagemSelecionada;
  File _foto;
  String _fotoPerfil;
  String _urlRecuperada = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil"
      "%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
  String _nomeRecuperado;
  Entregador entregador = Entregador();
  String _telRecuperado;
  BuildContext _dialogoContext;
  String _idUsuario;
  //String _urlRecuperada;
  TextEditingController _nomeController = TextEditingController();
  List<DropdownMenuItem<String>> _listaColetivos = List();
  String _coletivo;
  TextEditingController _nomeColetivoController = TextEditingController();
  Firestore db = Firestore.instance;

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

  _validaCampos() async {
    _mostraProgresso(context);
    _criarContatoEntrega(entregador);
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
                Text("Salvando contato"),
              ],
            ),
          );
        }
    );
  }

  //CADASTRA O CONTATO NO FIREBASE
  _criarContatoEntrega(Entregador _entregador) async {
    //CRIA AUTENTICAÇÃO DO USUÁRIO
    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario =  _usuario.uid;
    Firestore db = Firestore.instance;
    db.collection("usuarioDelivery").document(_idUsuario).setData(_entregador.toMap());
    db.collection("coletivos").add({
      "nome" : _nomeColetivoController.text,
      "ativo" : false,
    });
    if(_imagemSelecionada != null) {
      //_uploadImagem();
    } else {
      Navigator.pop(_dialogoContext);
      Navigator.pop(context);
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
        _urlRecuperada = dados["urlfotoperfil"];
        _nomeRecuperado = dados["nome"];
      });
    });
  }

  //CARREGA DROPDOWN ENDEREÇOS
  _carregaListaColetivos(BuildContext context) async {
    _listaColetivos = await Coletivos.getColetivos(context);
    setState(() {
      _listaColetivos;
    });
  }

  //CADASTRA COLETIVO
  _cadastrarColetivo(){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Digite o nome do seu Coletivo:"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                autofocus: true,
                controller: _nomeColetivoController,
                keyboardType: TextInputType.text,
              ),
              Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                        },
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange
                        ),
                      )
                  ),
                  FlatButton(
                      onPressed: (){
                        _salvarColetivo();
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange
                        ),
                      )
                  ),
                ],
              )
            ],
          )
        );
      }
    );
  }
/*
  _salvarColetivo() async {
    db.collection("coletivos").add({
      "nome" : _nomeColetivoController.text,
      "ativo" : true,
    }).then((nome){
      _carregaListaColetivos(context);
      setState(() {
        _coletivo = _nomeColetivoController.text;

      });
      Navigator.pop(context);
    });
  }
*/

  _salvarColetivo(){
    String _nomeColetivo = _nomeColetivoController.text;
    _listaColetivos.add(
        DropdownMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_nomeColetivo),
                ],
              ),
            ],
          ),
          value: _nomeColetivo,)
    );
    setState(() {
      _coletivo = _nomeColetivo;
    });
    Navigator.pop(context);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaUsuario();
    _carregaListaColetivos(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar delivery"),
      ),
      body: Builder(
          builder: (context) => SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  Text(
                    "Se você gostaria de fazer as entregas dos pedidos "
                        "gerados neste aplicativo, por favor preencha os campos "
                        "abaixo que em breve entraremos em contato com você.",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.pink
                    ),
                  ),
                  Form(
                      key: _formDeliveryKey,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: FormField<File>(
                              initialValue: _foto,
                              validator: (imagem){
                                if(_urlRecuperada == null){
                                  return "Selecione uma foto";
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
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10, top: 10),
                            child: InputCustomizado(
                              hint: "Seu nome",
                              controller: _nomeController = new TextEditingController(text: _nomeRecuperado),
                              onSaved: (nome){
                                print(nome);
                                entregador.nome = nome;
                              },
                              validator: (valor){
                                return Validador()
                                    .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                    .valido(valor);
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: InputCustomizado(
                              hint: "Telefone para contato",
                              autofocus: true,
                              initialValue: _telRecuperado,
                              type: TextInputType.phone,
                              inputFormatters: [MaskedInputFormater("(##) #####-####")],
                              onSaved: (telefone){
                                entregador.telefone = telefone;
                              },
                              maxLines: null,
                              validator: (valor){
                                return Validador()
                                    .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                    .valido(valor);
                              },
                            ),
                          ),
                          DropdownButtonFormField(
                              items: _listaColetivos,
                              value: _coletivo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              onChanged: (coletivo){
                                if(coletivo == "novo"){
                                  _cadastrarColetivo();
                                } else {
                                  setState(() {
                                    _coletivo = coletivo;
                                  });
                                }
                              }),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                    child: BotaoCustomizado(
                                      textoBotao: "Cadastrar",
                                      onPressed: ()  {
                                        if( _formDeliveryKey.currentState.validate() ){
                                          _formDeliveryKey.currentState.save();
                                          _dialogoContext = context;
                                          entregador.urlFotoPerfil = _urlRecuperada;
                                          entregador.ativo = false;
                                          entregador.entregando = false;
                                          entregador.coletivo = _coletivo;
                                          _validaCampos();
                                        }
                                      },
                                    )
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                  )
                ],
              ),
            ),
          )),
    );
  }
}
