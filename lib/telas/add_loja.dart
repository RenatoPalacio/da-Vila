import 'package:chips_choice/chips_choice.dart';
import 'package:compradordodia/models/categorias.dart';
import 'package:compradordodia/models/loja.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:compradordodia/widgets/inputcustomizado.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'dart:convert';
import 'package:validadores/validadores.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

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
  var _precoKm = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ",",
      thousandSeparator: ".",
      initialValue: 0.0,
      precision: 2
  );

  var _valorminimoController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ",",
      thousandSeparator: ".",
      precision: 2
  );

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
  double _valorminimoRecuperado;
  String _cepRecuperado;
  String _logradouroRecuperado;
  String _numeroRecuperado;
  String _complementoRecuperado;
  String _bairroRecuperado;
  String _cidadeRecuperado;
  String _ufRecuperado;
  String _idRecuperado;
  double _precokmRecuperado;
  String _tituloAppbar = "Cadastrar loja";
  String _textoBotao = "Cadastrar";
  String _bairro;
  bool _cadastrar;
  List<DropdownMenuItem<String>> _listaCategorias = List();
  String _categoria0;
  String _categoria1;
  String _categoria2;
  BuildContext _dialogoContext;
  final _formLojaKey = GlobalKey<FormState>();
  double _espacamento = 10;
  Loja saveloja;
  double _latitude;
  double _longitude;
  bool _tempedido;
  int _qtdPedido;
  int _pedidosNovos;
  bool _temvalormin = false;
  double valor = 3.0;
  bool _fazentrega = true;
  List<String> _formaPagamento = [];
  List<String> opcoesPagto = [
    'Dinheiro', 'Visa Crédito', 'Visa Débito',
    'Master Crédito', 'Master Débito', 'Elo',
    'Hipercard', 'Mercado Pago', 'PayPal',
    'Transferência',  'VR/TR',
  ];
  Map<String, dynamic> _mapaPagto = Map();
  bool _retirada;
  bool _ativaFone;
  bool _ativaMail;
  bool _ativaZap;
  String _prefixPreco = "Preço Km: ";

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
    _cadastroFormasPagto();
    _mostraProgresso(context);
    if(_cadastrar){
      return await _criarLoja(saveloja);
    } else{
      return await _updateLoja(saveloja);
    }
  }

  //CADASTRAR FORMAS DE PAGAMENTO
  _cadastroFormasPagto(){
    int indice = 0;
    if(_formaPagamento.length == 0){
      _formaPagamento = opcoesPagto;
    }
    for(String item in _formaPagamento){
      String FormaPagto = "FormaPagto" + indice.toString();
      _mapaPagto.putIfAbsent(FormaPagto, () => item);
      indice = indice + 1;
    }
    saveloja.mapPagto = _mapaPagto;
  }

  //LER FORMAS DE PAGAMENTO
  _lerFormasPagto(Map map){
    int indice = 0;
    for(String item in map.values) {
      _formaPagamento.insert(indice, item);
      indice = indice + 1;
    }
  }

  //CADASTRA A LOJA NO FIREBASE
  _criarLoja(Loja loja) async {
    _nomeLoja = loja.nome;
    //CRIA AUTENTICAÇÃO DO USUÁRIO
    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario =  _usuario.uid;
    loja.adm = _idUsuario;
    loja.distancia = valor;
    loja.bairro = _bairro;
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
  }

  //LIMPA CAMPOS LOGIN E SENHA
  _limpaDados(){
    _nomeController.clear();
    _descricaoController.clear();
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
      _bairro = _retornoEndereco["bairro"];
      print(_bairro);
      _bairroRecuperado = _bairro;
      setState(() {
        _cepRecuperado = _cepController.text;
        _logradouroRecuperado = _retornoEndereco["logradouro"];
        _cidadeRecuperado = _retornoEndereco["localidade"];
        _ufRecuperado = _retornoEndereco["uf"];
        _numeroRecuperado = null;
      });
    }
  }

  //ALTERA DADOS LOJA
  _updateLoja(Loja loja) async {
    Firestore db = Firestore.instance;
    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario =  _usuario.uid;
    _idLoja = _idRecuperado;
    loja.adm = _idUsuario;
    loja.distancia = valor;
    loja.bairro = _bairroRecuperado;
    await db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idRecuperado).updateData(loja.toMap());
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

  //RECUPERA LATITUDE E LONGITUDE
  _recuperaLatLong() async {
    String _endereco = _logradouroRecuperado + "," + _numeroRecuperado.toString() + " " + _cidadeRecuperado;
    List<Placemark> placemarks = await Geolocator().placemarkFromAddress(_endereco);
    if(placemarks != null && placemarks.length > 0){
      Placemark item = placemarks[0];
      saveloja.latitude =  item.position.latitude;
      saveloja.longitude =  item.position.longitude;
    }
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveloja = Loja();
    Loja _recuperaLoja = widget.atualizaLoja;
    _idRecuperado = _recuperaLoja.id;
    _urlRecuperado = _recuperaLoja.urlFotoPerfil;
    _nomeRecuperado = _recuperaLoja.nome;
    _descricaoRecuperado = _recuperaLoja.descricao;
    _valorminimoRecuperado = _recuperaLoja.valorminimo;
    if(_valorminimoRecuperado == null){
      _temvalormin = false;
    }  else if (_valorminimoRecuperado > 0){
      _temvalormin = true;
    }
    _cepRecuperado = _recuperaLoja.cep;
    _logradouroRecuperado = _recuperaLoja.endereco;
    _numeroRecuperado = _recuperaLoja.numero;
    _complementoRecuperado = _recuperaLoja.complemento;
    _bairroRecuperado = _recuperaLoja.bairro;
    _cidadeRecuperado = _recuperaLoja.cidade;
    _ufRecuperado = _recuperaLoja.uf;
    _categoria0 = _recuperaLoja.categoria1;
    _categoria1 = _recuperaLoja.categoria2;
    _categoria2 = _recuperaLoja.categoria3;
    _latitude = _recuperaLoja.latitude;
    _longitude = _recuperaLoja.longitude;
    _qtdPedido = _recuperaLoja.qtdpedidos;
    _tempedido = _recuperaLoja.tempedido;
    _pedidosNovos = _recuperaLoja.pedidosnovos;
    saveloja.latitude = _latitude;
    saveloja.longitude = _longitude;
    saveloja.pedidosnovos = _pedidosNovos;
    saveloja.tempedido = _tempedido;
    saveloja.qtdpedidos = _qtdPedido;
    valor = _recuperaLoja.distancia;
    _fazentrega = _recuperaLoja.entrega;

    _precokmRecuperado = _recuperaLoja.precokmdelivery;
    _retirada = _recuperaLoja.retirada;

    _ativaFone = _recuperaLoja.ativaFone;
    _ativaFone == null ? _ativaFone = false : null;
    _ativaMail = _recuperaLoja.ativaMail;
    _ativaMail == null ? _ativaMail = false : null;
    _ativaZap = _recuperaLoja.ativaZap;
    _ativaZap == null ? _ativaZap = false : null;

    if(valor == null){
      valor = 3.0;
    }

    if (_fazentrega == null){
      _fazentrega = false;
    }
    if(_urlRecuperado == null){
       _urlRecuperado = "https://firebasestorage.googleapis.com/v0/b/comprador-do-dia.appspot.com/o/fotos_perfil%2Fincluir_foto_laranja.png?alt=media&token=313c6369-ad40-4d1e-b501-7220bd834984";
    }
    if(_retirada == null){_retirada = false;}

    _cadastrar = widget.cadastrar;
    if(_cadastrar == false){
      _textoBotao = "Atualizar";
      _tituloAppbar = "Atualizar loja";
    }
    if(_recuperaLoja.mapPagto != null){
      _lerFormasPagto(_recuperaLoja.mapPagto);
    }

    if(_precokmRecuperado == null){_precokmRecuperado = 0.0;}

    _carregaListaCategorias();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppbar),
      ),
      body: Builder(builder: (context) =>
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(color: Colors.amberAccent),
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _formLojaKey,
                  child: Column(
                    children: <Widget>[
                      FormField<File>(
                        initialValue: _foto,
                        validator: (imagem){
                          if(_foto == null && _cadastrar){
                            return "Selecione uma imagem para sua loja";
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
                      Padding(
                        padding: EdgeInsets.only(bottom: _espacamento, top: _espacamento),
                        child: InputCustomizado(
                          hint: "Nome da loja",
                          initialValue: _nomeRecuperado,
                          onSaved: (titulo){
                            saveloja.nome = titulo;
                          },
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
                          hint: "Descrição da loja (100 caracteres)",
                          initialValue: _descricaoRecuperado,
                          onSaved: (descricao){
                            saveloja.descricao = descricao;
                          },
                          maxLines: null,
                          validator: (valor){
                            return Validador()
                                .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .maxLength(100, msg: "Máximo de 100 caracteres")
                                .valido(valor);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: SwitchListTile(
                          title: Text("Loja tem valor mínimo de compra"),
                          value: _temvalormin,
                          onChanged: (bool valor){
                            setState(() {
                              _temvalormin = valor;
                            });
                            //_ativarLoja();
                          },
                        ),
                      ),
                      _temvalormin
                          ?  Padding(
                        padding: EdgeInsets.only(bottom: _espacamento),
                        child: InputCustomizado(
                          hint: "Informe o valor mínimo de venda, caso tenha",
                          controller: _valorminimoController = new MoneyMaskedTextController(
                              leftSymbol: 'R\$ ',
                              decimalSeparator: ",",
                              thousandSeparator: ".",
                              initialValue: _valorminimoRecuperado,
                              precision: 2
                          ),
                          type: TextInputType.number,
                          onSaved: (minimo){
                            saveloja.valorminimo = _valorminimoController.numberValue;
                          },
                          onChanged: (preco){
                            _valorminimoRecuperado = _valorminimoController.numberValue;
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
                      )
                      : Container(),
                      Padding(
                        padding: EdgeInsets.only(bottom: _espacamento),
                        child: InputCustomizado(
                          hint: "CEP - ex: 01010000",
                          initialValue: _cepRecuperado,
                          type: TextInputType.number,
                          onSaved: (cep){
                            saveloja.cep = cep;
                          },
                          onChanged: (cepdigitado){
                            if(cepdigitado.length == 8){
                              _recuperaEndereco(cepdigitado);
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
                        padding: EdgeInsets.only(bottom: _espacamento),
                        child: InputCustomizado(
                          hint: "Endereço",
                          onSaved: (endereco){
                            saveloja.endereco = endereco;
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
                        padding: EdgeInsets.only(bottom: _espacamento),
                        child:InputCustomizado(
                          type: TextInputType.number,
                          hint: "Número",
                          controller: _numeroController = new TextEditingController(text: _numeroRecuperado),
                          onSaved: (numero){
                            saveloja.numero = numero;
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
                        padding: EdgeInsets.only(bottom: _espacamento),
                        child: InputCustomizado(
                          hint: "Complemento",
                          initialValue: _complementoRecuperado,
                          onSaved: (complemento){
                            saveloja.complemento = complemento;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: _espacamento),
                        child: InputCustomizado(
                          hint: "Cidade",
                          controller: _cidadeController = new TextEditingController(text: _cidadeRecuperado),
                          onSaved: (cidade){
                            saveloja.cidade = _cidadeController.text;
                          },
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
                          hint: "Estado",
                          controller: _ufController = new TextEditingController(text: _ufRecuperado),
                          onSaved: (estado){
                            saveloja.uf = _ufController.text;
                          },
                          validator: (valor){
                            return Validador()
                                .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16, left: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                "Indique até 3 categorias para sua loja:",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(child: Padding(
                                  padding: EdgeInsets.fromLTRB(4, 8, 0, 0),
                                  child: DropdownButtonFormField(
                                    iconEnabledColor: Colors.black,
                                    value: _categoria0,
                                    items: _listaCategorias,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    onChanged: (categoria){
                                      setState(() {
                                        _categoria0 = categoria;
                                      });
                                    },
                                    onSaved: (estado){
                                      saveloja.categoria1 = _categoria0;
                                    },
                                  ),
                                ),),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: DropdownButtonFormField(
                                      iconEnabledColor: Colors.black,
                                      value: _categoria1,
                                      items: _listaCategorias,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      onChanged: (categoria){
                                        setState(() {
                                          _categoria1 = categoria;
                                        });
                                      },
                                      onSaved: (estado){
                                        saveloja.categoria2 = _categoria1;
                                      },
                                    ),
                                  ),),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                    child: DropdownButtonFormField(
                                      iconEnabledColor: Colors.black,
                                      value: _categoria2,
                                      items: _listaCategorias,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      onChanged: (categoria){
                                        setState(() {
                                          _categoria2 = categoria;
                                        });
                                      },
                                      onSaved: (estado){
                                        saveloja.categoria3 = _categoria2;
                                      },
                                    ),
                                  ),),
                              ],
                            ),
                          ],
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Formas de entrega:",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8,),
                              child: SwitchListTile(
                                title: Text("Se você permite retirada, habilite esta opção."),
                                value: _retirada,
                                onChanged: (bool retirada){
                                  saveloja.retirada = retirada;
                                  setState(() {
                                    _retirada = retirada;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 2),
                              child: SwitchListTile(
                                title: Text("Se você faz entrega, habilite esta opção."),
                                value: _fazentrega,
                                onChanged: (bool entrega){
                                  saveloja.entrega = entrega;
                                  if (entrega){
                                    valor = 3.0;
                                  } else {valor = 0.0;}
                                  setState(() {
                                    _fazentrega = entrega;
                                  });
                                  //_ativarLoja();
                                },
                              ),
                            ),
                            _fazentrega
                                ? Padding(
                                padding: EdgeInsets.only(top: 8, left: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                        "Distância de entrega: $valor Km",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8, left: 0),
                                      child: Slider(
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.grey,
                                          value: valor,
                                          min: 1,
                                          max: 5,
                                          divisions: 40,
                                          label: valor.toString(),
                                          onChanged: (double escolhaUsuario){
                                            setState(() {
                                              valor = escolhaUsuario;
                                            });
                                          }),
                                    ),
                                    InputCustomizado(
                                      hint: "Preço por Km",
                                      controller: _precoKm = new MoneyMaskedTextController(
                                          leftSymbol: 'R\$ ',
                                          decimalSeparator: ",",
                                          thousandSeparator: ".",
                                          initialValue: _precokmRecuperado,
                                          precision: 2
                                      ),
                                      type: TextInputType.number,
                                      prefixText: _prefixPreco,
                                      onSaved: (preco){
                                        saveloja.precokmdelivery = _precokmRecuperado;
                                      },
                                      onChanged: (preco){
                                        if(preco.length > 0){
                                          setState(() {
                                            _prefixPreco = "";
                                            _precokmRecuperado = _precoKm.numberValue;
                                          });
                                        }
                                      },
                                      maxLines: null,
                                      validator: (valor){
                                        valor = valor.substring(3,4);
                                        return Validador()
                                            .valido(valor);
                                      },
                                    ),
                                  ],
                                )
                            )
                                : Container(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 24, left: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  "Formas de pagamento aceitas:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            ChipsChoice<String>.multiple(
                              clipBehavior: Clip.antiAlias,
                              value: _formaPagamento,
                              onChanged: (val) => setState(() => _formaPagamento = val),
                              choiceItems: C2Choice.listFrom<String, String>(
                                source: opcoesPagto,
                                value: (i, v) => v,
                                label: (i, v) => v,
                              ),
                              wrapped: true,
                              textDirection: TextDirection.ltr,
                              choiceStyle: C2ChoiceStyle(
                                borderRadius: BorderRadius.circular(10),
                                labelStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black
                                ),
                                showCheckmark: false,
                              ),
                              choiceActiveStyle: C2ChoiceStyle(
                                borderRadius: BorderRadius.circular(10),
                                labelStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                                showCheckmark: false,
                                borderColor: Colors.amber,
                                color: Colors.amber,
                                brightness: Brightness.dark,
                              ),
                            ),
                          ],
                        )
                      ),
                  Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Habilite as formas que o comprador pode interagir com você:",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8,),
                              child: SwitchListTile(
                                title: Text("Celular:"),
                                secondary: Icon(Icons.phone),
                                value: _ativaFone,
                                onChanged: (bool fone){
                                  saveloja.ativaFone = fone;
                                  setState(() {
                                    _ativaFone = fone;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8,),
                              child: SwitchListTile(
                                title: Text("e-mail:"),
                                secondary: Icon(Icons.mail),
                                value: _ativaMail,
                                onChanged: (bool mail){
                                  saveloja.ativaMail = mail;
                                  setState(() {
                                    _ativaMail = mail;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8,),
                              child: SwitchListTile(
                                title: Text("WhatsApp:"),
                                secondary: Image.asset(
                                    "images/whatsapp.jpg",
                                  width: 30,
                                  height: 30,
                                ),
                                value: _ativaZap,
                                onChanged: (bool zap){
                                  saveloja.ativaZap = zap;
                                  setState(() {
                                    _ativaZap = zap;
                                  });
                                },
                              ),
                            ),

                          ]
                      )),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                                child: BotaoCustomizado(
                                  textoBotao: _textoBotao,
                                  onPressed: ()  {
                                    if( _formLojaKey.currentState.validate() ){
                                      _formLojaKey.currentState.save();
                                      _dialogoContext = context;
                                      saveloja.ativaFone = _ativaFone;
                                      saveloja.ativaMail = _ativaMail;
                                      saveloja.ativaZap = _ativaZap;
                                      saveloja.entrega = _fazentrega;
                                      saveloja.retirada = _retirada;
                                      _validaCampos();
                                      //_cadastroFormasPagto();
                                    }
                                    },
                                )
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),
      )
    );
  }
}
