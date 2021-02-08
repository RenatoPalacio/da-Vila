import 'dart:convert';
import 'package:compradordodia/models/endereco.dart';
import 'package:compradordodia/widgets/inputcustomizado.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:validadores/Validador.dart';
import '../models/usuarios.dart';
import 'package:http/http.dart'as http;

class CadastraEndereco extends StatefulWidget {
  @override
  Endereco endereco = Endereco();
  CadastraEndereco(this.endereco);
  _CadastraEnderecoState createState() => _CadastraEnderecoState();
}

class _CadastraEnderecoState extends State<CadastraEndereco> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _cepController = TextEditingController();
  TextEditingController _logradouroController = TextEditingController();
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _complementoController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();
  TextEditingController _ufController = TextEditingController();

  String qualErro;
  String _idUsuario;
  String _nomeRecuperado;
  final _formEnderecoKey = GlobalKey<FormState>();
  Usuario usuario = Usuario();
  Endereco endereco = Endereco();
  String _cepRecuperado;
  String _logradouroRecuperado;
  String _numeroRecuperado;
  String _complementoRecuperado;
  String _cidadeRecuperado;
  String _ufRecuperado;
  String _textoBotao = "Cadastrar";
  bool _enderecoAtivo = true;
  String _idEndereco;

  //CADASTRA O ENDEREÇO NO FIREBASE
  _cadastraEndereco(Endereco endereco) async {
    Firestore db = Firestore.instance;
    db.collection("usuarios")
        .document(_idUsuario)
        .updateData({
      "enderecoEntrega" : endereco.nome,
    });
    db.collection("usuarios")
        .document(_idUsuario)
        .collection("enderecos")
        .document()
        .setData(endereco.toMap());
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ler_carrinho", arguments: _idUsuario );
  }

  //ATUALIZA O USUÁRIO NO FIREBASE
  _atualizarEndereco(Endereco endereco) async {
    Firestore db = Firestore.instance;
    db.collection("usuarios")
        .document(_idUsuario)
        .collection("enderecos")
        .document(_idEndereco)
        .updateData(endereco.toMap());
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushNamed(context, "/ler_carrinho", arguments: _idUsuario );
  }

  //RECUPERA ENDEREÇO USUÁRIO
  void _recuperaEndereco() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario = _usuario.uid;
    Endereco _endereco = widget.endereco;
    if(_endereco != null){
      _idEndereco = _endereco.idEndereco;
      setState(() {
        _textoBotao = "Atualizar";
        _nomeRecuperado = _endereco.nome;
        _cepRecuperado = _endereco.cep;
        _logradouroRecuperado = _endereco.logradouro;
        _numeroRecuperado = _endereco.numero;
        _complementoRecuperado = _endereco.complemento;
        _cidadeRecuperado = _endereco.cidade;
        _ufRecuperado = _endereco.uf;
        _enderecoAtivo = _endereco.ativo;
      });
    }
    endereco.ativo = _enderecoAtivo;
    endereco.latitude = _endereco.latitude;
    endereco.longitude = _endereco.longitude;
  }

  //RECUPERA ENDEREÇO PELO CEP
  void _recuperaEndCEP(String cepdigitado) async {
    Map<String, dynamic> _retornoEndereco;
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
        _nomeRecuperado = _nomeController.text;
        _cepRecuperado = _cepController.text;
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
      endereco.latitude =  item.position.latitude;
      endereco.longitude =  item.position.longitude;
    }
    //Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude)
  }

  _ativarEndereco() async {
    Firestore db = Firestore.instance;
    Map<String, dynamic> _ativo = {
      "ativo": _enderecoAtivo
    };
    await db.collection("usuarios")
        .document(_idUsuario)
        .collection("enderecos")
        .document(_idEndereco)
        .updateData(_ativo);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaEndereco();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        title: Text("Endereço de entrega")
      ),
        body: Builder(
          builder: (context) => SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Form(
                    key: _formEnderecoKey,
                    child: Column(
                      children: <Widget>[
                        _textoBotao == "Atualizar"
                            ? Padding(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: SwitchListTile(
                                title: Text("Endereço ativo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                value: _enderecoAtivo,
                                onChanged: (bool valor){
                                  setState(() {
                                    _enderecoAtivo = valor;
                                  });
                                  _ativarEndereco();
                                },
                              ),
                              )
                            : Container(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10, top: 10),
                          child: InputCustomizado(
                            hint: "Título (casa, escritório, namorad@, etc)",
                            controller: _nomeController = new TextEditingController(text: _nomeRecuperado ),
                            onSaved: (nome){
                              endereco.nome = nome;
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
                            hint: "CEP - ex: 01010000",
                            controller: _cepController = new TextEditingController(text: _cepRecuperado),
                            type: TextInputType.number,
                            onSaved: (cep){
                              endereco.cep = cep;
                            },
                            onChanged: (cepdigitado){
                              if(cepdigitado.length == 8){
                                _recuperaEndCEP(cepdigitado);
                              }
                            },
                            maxLines: null,
                            validator: (valor){
                              return Validador()
                                  .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                  .maxLength(8, msg: "O CEP deve ter 8 digitos")
                                  .minLength(8, msg: "O CEP deve ter 8 digitos")
                                  .valido(valor);
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: InputCustomizado(
                            hint: "Endereço",
                            onSaved: (logradouro){
                              endereco.logradouro = logradouro;
                            },
                            controller: _logradouroController = new TextEditingController(text: _logradouroRecuperado),
                            validator: (valor){
                              return Validador()
                                  .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                  .valido(valor);
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child:InputCustomizado(
                            type: TextInputType.number,
                            hint: "Número",
                            controller: _numeroController = new TextEditingController(text: _numeroRecuperado),
                            onSaved: (numero){
                              endereco.numero = numero;
                            },
                            onChanged: (_){
                              _numeroRecuperado = _numeroController.text;
                              if(_logradouroRecuperado != null && _cidadeRecuperado != null){
                                _recuperaLatLong();
                              }
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
                            hint: "Complemento",
                            controller: _complementoController = new TextEditingController(text: _complementoRecuperado),
                            onSaved: (complemento){
                              endereco.complemento = complemento;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: InputCustomizado(
                            hint: "Cidade",
                            controller: _cidadeController = new TextEditingController(text: _cidadeRecuperado),
                            onSaved: (cidade){
                              endereco.cidade = _cidadeController.text;
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
                            hint: "Estado",
                            controller: _ufController = new TextEditingController(text: _ufRecuperado),
                            onSaved: (estado){
                              endereco.uf = _ufController.text;
                            },
                            validator: (valor){
                              return Validador()
                                  .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                  .valido(valor);
                            },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: RaisedButton(
                                        child: Text(
                                          _textoBotao,
                                          style: TextStyle(color: Colors.white, fontSize: 20),
                                        ),
                                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                        color: Colors.amber,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(32)),
                                        onPressed: (){
                                          if( _formEnderecoKey.currentState.validate() ){
                                            _formEnderecoKey.currentState.save();
                                            if (_textoBotao == "Cadastrar"){
                                              _cadastraEndereco(endereco);
                                            } else {
                                              _atualizarEndereco(endereco);
                                            }
                                          }
                                        }
                                    )
                                )
                              ],
                            )
                        ),
                      ],
                    )
                )
            ),
          ),
        )
      //bottomNavigationBar: Container(),
    );
  }
}

