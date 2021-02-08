
import 'package:compradordodia/mobX/dadosMobx.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:compradordodia/models/pedido.dart';
import 'package:compradordodia/telas/troca_mensagens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class LerDetalhesPedidoMobx extends StatelessWidget {

  LerDetalhesPedidoMobx(this._url, this._comprador, this._data, this. _status, this._idUsuario, this._idLoja, this._idPedido);

  String _comprador;
  String _idUsuario;
  String _idLoja;
  String _idPedido;
  String _url;
  String _data;
  String _status;
  String _idPedidoDelivery;
  List _listaProdutos = List();
  String dropdownValue;
  String _idComprador;
  String idPedidoUsuario;
  double _precoTotalPedido = 0;
  int _tamanhoLista;
  MoneyFormatterOutput _valorTotalFormatado;
  double _valorTotal = 0.0;
  CalendarController _controleCalendario = CalendarController();
  bool _deliveryAgendado = false;
  String _idDelivery;
  DateTime _dia;
  DateTime _hora;
  DateTime _dataEntregue;
  String _nomeEntregador;
  String _urlFotoEntregador;
  String _telefoneEntregador;
  String _coletivoDelivery;
  bool _temEntregador = false;
  bool _primeiravez = true;
  bool _lendodelivery = true;
  bool _foientregue = false;
  bool qualificado;
  bool habilitado =false;
  int score = 0;
  int scoreanterior = 0;
  List<IconData> estrela1 = [Icons.star_border,Icons.star, Icons.star,Icons.star,Icons.star,Icons.star,];
  List<IconData> estrela2 = [Icons.star_border,Icons.star_border, Icons.star,Icons.star,Icons.star,Icons.star,];
  List<IconData> estrela3 = [Icons.star_border,Icons.star_border, Icons.star_border,Icons.star,Icons.star,Icons.star,];
  List<IconData> estrela4 = [Icons.star_border,Icons.star_border, Icons.star_border,Icons.star_border,Icons.star,Icons.star,];
  List<IconData> estrela5 = [Icons.star_border,Icons.star_border, Icons.star_border,Icons.star_border,Icons.star_border,Icons.star,];
  BuildContext context;
  final dadosmobx = dadosMobx();
  bool _lendo;

  mudaStatus(){
    Firestore db = Firestore.instance;
    if (_status == "Realizado" && dropdownValue != "Realizado"){
      db
          .collection("lojas")
          .document(_idUsuario)
          .collection("lojasusuario")
          .document(_idLoja).get().then((dados){
        int _pedidosnovos = dados["pedidosnovos"];
        _pedidosnovos = _pedidosnovos - 1;
        db.collection("lojas")
            .document(_idUsuario)
            .collection("lojasusuario")
            .document(_idLoja).updateData({"pedidosnovos" : _pedidosnovos});
      });
    }

    db
        .collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja)
        .collection("pedidos")
        .document(_idPedido).updateData({"statusPedido" : dropdownValue});

    db
        .collection("usuarios")
        .document(_idComprador)
        .collection("pedidos")
        .document(idPedidoUsuario)
        .updateData({"statusPedido" : dropdownValue});
  }

  _calculaValorTotal(){
    _valorTotalFormatado = FlutterMoneyFormatter(
        amount: _valorTotal,
        settings: MoneyFormatterSettings(
            symbol: "R\$",
            decimalSeparator: ",",
            thousandSeparator: ".",
            fractionDigits: 2
        )
    ).output;
  }

  _conversarCom(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => trocaMensagem(_url, _comprador, _idUsuario, _idComprador, _idLoja, _idPedido, _idUsuario)));
  }

  _conversarComDelivery(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => trocaMensagem(_urlFotoEntregador, _nomeEntregador, _idUsuario, _idDelivery, _idLoja, _idPedido, _idUsuario)));
  }

  _chamaDelivery(BuildContext context){
    if (score == 0){
      Navigator.pushNamed(context, "/agenda_delivery", arguments: _idPedidoDelivery);
    } else {
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Não é possível alterar data de um produto que já foi entregue."),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber
                        ),
                      )
                  ),
                ],
              ),
            );
          }
      );
    }
  }

  _limpaDelivery(BuildContext context){
    String _texto;
    String _textoBotao1 = "Não";
    String _textoBotao2 = "Sim";
    if(score > 0){
      _texto = "Você não pode cancelar o delivery de um pedido que já foi entregue.";
      _textoBotao1 = "";
      _textoBotao2 = "OK";
    } else {
      _texto = "Cancelar Agendamento Delivery?";
    }

    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(_texto),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: (){Navigator.pop(context);},
                    child: Text(
                      _textoBotao1,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber
                      ),
                    )
                ),
                FlatButton(
                    onPressed: (){
                      if (_textoBotao2 == "Sim"){
                        _removeDelivery();
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      _textoBotao2,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber
                      ),
                    )
                ),
              ],
            ),
          );
        }
    );
  }

  _removeDelivery() async {
    Firestore db = Firestore.instance;
    db.collection("pedidos").document(_idPedidoDelivery).updateData({
      "idDelivery" : null,
      "dataDeliveryAgendada" : null,
    });

    _primeiravez = true;
    dadosmobx.deliveryAgendado(false);
  }

  _deliveryFavorito(){
    print("chama Favorito");
  }

 _dadosDelivery() async {

    Firestore db = Firestore.instance;
    DocumentSnapshot _docDelivery = await db
        .collection("usuarioDelivery")
        .document(_idDelivery).get();

    if(_primeiravez){
        _urlFotoEntregador = _docDelivery["urlfotoperfil"];
        _nomeEntregador = _docDelivery["nome"];
        _telefoneEntregador = _docDelivery["telefone"];
        _primeiravez = false;
        dadosmobx.lendoDelivery(false);
        dadosmobx.temEntregador(true);
    }

  }

  _scorePedido(){
    Firestore db = Firestore.instance;

    db.collection("pedidos").document(_idPedidoDelivery).updateData({
      "score" : score,
      "qualificado" : true
    });

    db.collection("usuarioDelivery").document(_idDelivery).get().then((dados){
      int scoreTotal = dados["score"];
      int totalQuali = dados["totalQualificacoes"];
      if (scoreTotal == null){
        scoreTotal = 0;
      }
      if(totalQuali == null){
        totalQuali = 0;
      }
      scoreTotal = scoreTotal + score - scoreanterior;
      if(qualificado == false){
        totalQuali = totalQuali + 1;
        qualificado = true;
      }
      db.collection("usuarioDelivery").document(_idDelivery).updateData({
        "score" : scoreTotal,
        "totalQualificacoes" : totalQuali
      });
    });

  }

  _lerScore() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot _doc = await db
        .collection("pedidos")
        .document(_idPedidoDelivery)
        .get();
    qualificado = _doc["qualificado"];
    if(qualificado == null){
      qualificado = false;
    }
    score = _doc["score"];
    if(score == null){
      score = 0;
    }
  }

  _lerEstadoInicial() async {
    // TODO: implement initState
    dadosmobx.deliveryAgendado(false);
    dropdownValue = _status;
    _idComprador = _idPedido.substring(_idPedido.indexOf("_") + 1);
    String _nPedido = _idPedido.substring(0, _idPedido.indexOf("_"));
    String _nLoja = _idLoja.substring(_idLoja.indexOf("_") + 1);
    idPedidoUsuario = _nPedido + "_" + _nLoja;
    _idPedidoDelivery = _idPedido + "_" + _nLoja;
    dadosmobx.lendoDelivery(true);
    dadosmobx.temEntregador(false);

    _lerScore();
  }

  @override
  Widget build(BuildContext context) {

    _lerEstadoInicial();

    Firestore db = Firestore.instance;
    double c_width = MediaQuery.of(context).size.width*1;
    double card_width = MediaQuery.of(context).size.width*0.25;
    double obs_width = MediaQuery.of(context).size.width*0.85;


    var delivery = StreamBuilder(
        stream: db.collection("pedidos").document(_idPedidoDelivery).snapshots(),
        builder: (context, snapshot){
          switch (snapshot.connectionState){
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
              DocumentSnapshot _dados = snapshot.data;
              if(_dados["entregue"] != null){
                _foientregue = _dados["entregue"];
                if (_foientregue){
                  _dataEntregue = _dados["data_entrega"].toDate();
                }
              }

              if(_dados["dataDeliveryAgendada"] != null ){
                dadosmobx.deliveryAgendado(true);
                _dia = _dados["dataDeliveryAgendada"].toDate();
                _hora = _dados["horaDeliveryAgendada"].toDate();
              }
              if(_dados["idDelivery"] != null){
                _idDelivery = _dados["idDelivery"];
                _dadosDelivery();
              } else {
                dadosmobx.lendoDelivery(false);
                print(dadosmobx.lendodelivery.value);
              }
              return Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: dadosmobx.lendodelivery.value
                      ? Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),)])
                      : Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Chamar delivery",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Column(
                          children: <Widget>[
                            dadosmobx.deliveryagendado
                                ? Card(
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            dadosmobx.tementregador
                                                ? CircleAvatar(
                                                maxRadius: 45,
                                                backgroundColor: Colors.amberAccent,
                                                backgroundImage: _urlFotoEntregador != null
                                                    ? NetworkImage(_urlFotoEntregador)
                                                    : null)
                                                : Icon(
                                              Icons.directions_bike,
                                              size: 50,
                                              color: Colors.amber,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(left: 16),
                                                  child: dadosmobx.tementregador
                                                      ? Text(
                                                    _nomeEntregador,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green
                                                    ),
                                                  )
                                                      : Text(
                                                    "Aguardando confirmação",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.deepOrange
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 16, top: 16),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        formatDate(_dia, [dd, "/", mm, "/", yyyy]).toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black
                                                        ),
                                                      ),
                                                      Text(
                                                        " - ",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black
                                                        ),
                                                      ),
                                                      Text(
                                                        _hora.hour.toString() + ":" + _hora.minute.toString().padLeft(2, '0'),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        dadosmobx.tementregador
                                            ? Padding(
                                          padding: EdgeInsets.only(top: 24),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: (){
                                                  final phoneCall = FlutterPhoneState.startPhoneCall(_telefoneEntregador);
                                                },
                                                child: Icon(
                                                  Icons.phone,
                                                  size: 30,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: _conversarComDelivery,
                                                child: Icon(
                                                  Icons.chat,
                                                  size: 30,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){_chamaDelivery(context);},
                                                child: Icon(
                                                  Icons.schedule,
                                                  size: 30,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){_limpaDelivery(context);},
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 30,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                            : Padding(
                                            padding: EdgeInsets.only(top: 24),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: (){_chamaDelivery(context);},
                                                  child: Icon(
                                                    Icons.schedule,
                                                    size: 30,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 48),
                                                  child: GestureDetector(
                                                    onTap: (){_limpaDelivery(context);},
                                                    child: Icon(
                                                      Icons.delete,
                                                      size: 30,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                        ),
                                        _foientregue
                                            ? Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 8, top: 32,),
                                              child: Text(
                                                "Entregador indica que o produto foi entregue em ${formatDate(_dataEntregue, [dd, "/", mm, "/", yyyy]).toString().toString()}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 0, top: 24),
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    "Quantas estrelas ${_nomeEntregador} merece:",
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                            Padding(
                                              padding: EdgeInsets.only(left: 0, top: 16),
                                              child: Row(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: (){
                                                      scoreanterior = score;
                                                      //setState(() {
                                                        score = 1;
                                                      //});
                                                      _scorePedido();
                                                    },
                                                    child: Icon(
                                                      estrela1[score],
                                                      color: Colors.amber,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      scoreanterior = score;
                                                      //setState(() {
                                                        score = 2;
                                                      //});
                                                      _scorePedido();
                                                    },
                                                    child: Icon(
                                                      estrela2[score],
                                                      color: Colors.amber,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      scoreanterior = score;
                                                      //setState(() {
                                                        score = 3;
                                                      //});
                                                      _scorePedido();
                                                    },
                                                    child: Icon(
                                                      estrela3[score],
                                                      color: Colors.amber,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      scoreanterior = score;
                                                      //setState(() {
                                                        score = 4;
                                                      //});
                                                      _scorePedido();
                                                    },
                                                    child: Icon(
                                                      estrela4[score],
                                                      color: Colors.amber,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      scoreanterior = score;
                                                      //setState(() {
                                                        score = 5;
                                                      //});

                                                      _scorePedido();
                                                    },
                                                    child: Icon(
                                                      estrela5[score],
                                                      color: Colors.amber,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                            : Container()
                                      ],
                                    )
                                )
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                GestureDetector(
                                  child: Icon(
                                    Icons.directions_bike,
                                    size: 50,
                                    color: Colors.amber,
                                  ),
                                  onTap: (){
                                    _chamaDelivery(context);
                                  },
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.favorite,
                                    size: 50,
                                    color: Colors.amber,
                                  ),
                                  onTap: _deliveryFavorito,
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )
              );
          }
        });

    var stream = StreamBuilder(
        stream: db
            .collection("lojas")
            .document(_idUsuario)
            .collection("lojasusuario")
            .document(_idLoja)
            .collection("pedidos")
            .document(_idPedido)
            .collection("produtos").snapshots(),
        builder: (context, snapshot){
          switch (snapshot.connectionState){
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
              _valorTotal = 0;
              _listaProdutos.clear();
              QuerySnapshot querySnapshot = snapshot.data;
              for (DocumentSnapshot _dadosProduto in querySnapshot.documents) {
                Pedido pedido = Pedido();
                pedido.url = _dadosProduto["URL"];
                pedido.nomeProduto = _dadosProduto["Nome"];
                pedido.quantidade = _dadosProduto["Quantidade"];
                pedido.valorPedido = _dadosProduto["Valor"];
                pedido.obsProduto = _dadosProduto["ObsProduto"];
                _precoTotalPedido = _precoTotalPedido + pedido.valorPedido;
                Map<String, dynamic> _produto = pedido.toMap();
                _listaProdutos.add(_produto);
              }
              return Expanded(
                child: ListView.builder(
                    itemCount: _listaProdutos.length,
                    itemBuilder: (context, indice){
                      _tamanhoLista = _listaProdutos.length;
                      String _urlFotoProduto = _listaProdutos[indice]["URL"];
                      String _nomeProduto = _listaProdutos[indice]["Nome"];
                      String _obs = _listaProdutos[indice]["ObsProduto"];
                      int _quantidade = _listaProdutos[indice]["Quantidade"];
                      double _valor = _listaProdutos[indice]["Valor"];
                      _valorTotal = _valorTotal + _valor;
                      _calculaValorTotal();
                      MoneyFormatterOutput _preco = FlutterMoneyFormatter(
                          amount: _valor,
                          settings: MoneyFormatterSettings(
                              symbol: "R\$",
                              decimalSeparator: ",",
                              thousandSeparator: ".",
                              fractionDigits: 2
                          )
                      ).output;
                      return Container(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(
                              children: <Widget>[
                                Card(
                                    child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Padding(
                                                    padding: EdgeInsets.all(2),
                                                    child: SizedBox(
                                                        width: 72,
                                                        height: 48,
                                                        child: _urlFotoProduto != null
                                                            ? Image.network(
                                                          _urlFotoProduto, loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                                          if (loadingProgress == null) return child;
                                                          return Center(
                                                              child: Padding(
                                                                padding: EdgeInsets.all(4),
                                                                child: CircularProgressIndicator(),
                                                              )
                                                          );
                                                        },
                                                        )
                                                            : Container()
                                                    )
                                                ),
                                                Container(
                                                  width: card_width,
                                                  child: Wrap(
                                                    children: <Widget>[
                                                      Text(
                                                        _nomeProduto,
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                        textAlign: TextAlign.start,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  _quantidade.toString(),
                                                  style: TextStyle(
                                                      fontSize: 16),
                                                  textAlign: TextAlign.start,
                                                ),
                                                Text(
                                                  _preco.symbolOnLeft.toString(),
                                                  style: TextStyle(
                                                      fontSize: 16),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ],
                                            ),
                                            _obs.length > 0
                                                ? Container(
                                              width: obs_width,
                                              child:  Wrap(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      "Observação: $_obs",
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                                : Container()
                                          ],
                                        )
                                    )
                                ),
                                Container(
                                  width: obs_width,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      indice == _tamanhoLista - 1
                                          ? _valorTotalFormatado != null
                                          ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Padding(
                                              padding: EdgeInsets.only(top: 32, right: 0),
                                              child: Text(
                                                "TOTAL: " + _valorTotalFormatado.symbolOnLeft.toString(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              )
                                          ),
                                          delivery,
                                        ],
                                      )
                                          : Text(
                                        "TOTAL: ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )
                                          : Container()
                                    ],
                                  ),
                                ),

                              ],
                            )
                        ),
                      );
                    }),
              );
          }
        }
    );


    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido de $_comprador"),
      ),
      body: SafeArea(
          child: Container(
              width: c_width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: _conversarCom,
                          child: SizedBox(
                            width: 186,
                            height: 130,
                            child: _url != null
                                ? Image.network(
                              _url, loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: CircularProgressIndicator(),
                                  )
                              );
                            },
                            )
                                : Image.asset("images/semfoto.png"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 8, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _comprador,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
                                child: Text(
                                  "Data pedido: $_data",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),),
                              ),
                              DropdownButton<String>(
                                value: dropdownValue,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17
                                ),
                                underline: Container(
                                  height: 2,
                                  color: Colors.black,
                                ),
                                onChanged: (String newValue) {
                                  if (newValue != "Realizado"){
                                    //setState(() {
                                      dropdownValue = newValue;
                                    //});
                                    mudaStatus();
                                    _status = newValue;
                                  }
                                },
                                items: <String>['Realizado', 'Em preparação', 'Enviado', 'Entregue', 'Cancelado']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  stream,
                ],
              )
          )),
    );
  }
}
