import 'package:compradordodia/models/mostracarrinho.dart';
import 'package:compradordodia/models/pedido.dart';
import 'package:compradordodia/telas/troca_mensagens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class Lerpedido extends StatefulWidget {
  String _idUsuario;
  String _idDocPedido;
  Lerpedido(this._idUsuario, this._idDocPedido);
  @override
  _LerpedidoState createState() => _LerpedidoState();
}

class _LerpedidoState extends State<Lerpedido> {
  String _idUsuario;
  String _idDocumentoPedido;
  bool _lendolojas = true;
  double _precoTotalPedido = 0;
  List _produtos = List();
  int _tamanhoLista;
  MoneyFormatterOutput _valorTotalFormatado;
  double _valorTotal = 0.0;
  bool habilitado;
  String _status;
  String _idLoja;
  String _url;
  String _nomeloja;
  String _idVendedor;
  bool qualificado;
  int score = 0;
  int scoreanterior = 0;
  List<IconData> estrela1 = [Icons.star_border,Icons.star, Icons.star,Icons.star,Icons.star,Icons.star,];
  List<IconData> estrela2 = [Icons.star_border,Icons.star_border, Icons.star,Icons.star,Icons.star,Icons.star,];
  List<IconData> estrela3 = [Icons.star_border,Icons.star_border, Icons.star_border,Icons.star,Icons.star,Icons.star,];
  List<IconData> estrela4 = [Icons.star_border,Icons.star_border, Icons.star_border,Icons.star_border,Icons.star,Icons.star,];
  List<IconData> estrela5 = [Icons.star_border,Icons.star_border, Icons.star_border,Icons.star_border,Icons.star_border,Icons.star,];

  _lerPedido() async {
    Firestore db = Firestore.instance;

    DocumentSnapshot _doc = await db
        .collection("usuarios")
        .document(_idUsuario)
        .collection("pedidos")
        .document(_idDocumentoPedido).get();
    habilitado = _doc["entregue"];
    _status = _doc["statusPedido"];
    _idLoja = _doc["idLoja"];
    _url = _doc["url"];
    _nomeloja = _idLoja.substring(_idLoja.indexOf("_") + 1);
    _idVendedor = _idLoja.substring(0, _idLoja.indexOf("_"));
    qualificado = _doc["qualificado"];
    if(qualificado == null){
      qualificado = false;
    }
    score = _doc["score"];
    if(score == null){
      score = 0;
    }
    QuerySnapshot _docsProdutosPedido = await db
        .collection("usuarios")
        .document(_idUsuario)
        .collection("pedidos")
        .document(_idDocumentoPedido)
        .collection("produtos").getDocuments();

    for(DocumentSnapshot itemPedido in _docsProdutosPedido.documents){
      Pedido pedido = Pedido();
      pedido.url = itemPedido["URL"];
      pedido.nomeProduto = itemPedido["Nome"];
      pedido.quantidade = itemPedido["Quantidade"];
      pedido.valorPedido = itemPedido["Valor"];
      pedido.obsProduto = itemPedido["ObsProduto"];
      _precoTotalPedido = _precoTotalPedido + pedido.valorPedido;
      Map<String, dynamic> _produto = pedido.toMap();
      _produtos.add(_produto);
    }
    setState(() {
      _lendolojas = false;
      return _produtos;
    });
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

  _entregue() async {
    Firestore db = Firestore.instance;
    Map<String, dynamic> _entregue = {
      "entregue" : habilitado,
      "score" : score
    };
    db
        .collection("usuarios")
        .document(_idUsuario)
        .collection("pedidos")
        .document(_idDocumentoPedido).updateData(_entregue);
  }

  _scorePedido(){
    Firestore db = Firestore.instance;

    db.collection("usuarios").document(_idUsuario).collection("pedidos").document(_idDocumentoPedido).updateData({
      "score" : score,
      "qualificado" : true
    });

    db.collection("lojas").document(_idVendedor).collection("lojasusuario").document(_idLoja).get().then((dados){
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
      db.collection("lojas").document(_idVendedor).collection("lojasusuario").document(_idLoja).updateData({
        "score" : scoreTotal,
        "totalQualificacoes" : totalQuali
      });
    });
  }

  _conversarCom(){
    String _idLojaAlterado = _idLoja.substring(_idLoja.indexOf("_")+1)+"_";
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => trocaMensagem(_url, _nomeloja, _idVendedor, _idUsuario, _idLoja, _idLojaAlterado, _idUsuario)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _idUsuario = widget._idUsuario;
    _idDocumentoPedido = widget._idDocPedido;
    _lerPedido();
  }
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*0.25;
    double obs_width = MediaQuery.of(context).size.width*0.85;
    _valorTotal = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do pedido"),
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                  child: _lendolojas
                      ? Column(children: <Widget>[
                    Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),)
                  ],)
                      : Container(height: 0,)
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: _produtos.length,
                      itemBuilder: (context, indice){
                        _tamanhoLista = _produtos.length;
                        String _urlFotoProduto = _produtos[indice]["URL"];
                        String _nomeProduto = _produtos[indice]["Nome"];
                        String _obs = _produtos[indice]["ObsProduto"];
                        int _quantidade = _produtos[indice]["Quantidade"];
                        double _valor = _produtos[indice]["Valor"];
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
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                                                width: c_width,
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
                                            GestureDetector(
                                                onTap: _conversarCom,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(0, 27, 16, 0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.chat,
                                                        color: Colors.orange,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 8),
                                                        child: Text(
                                                          "Converse com o vendedor",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.orange,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),)
                                                    ],
                                                  ),
                                                )
                                            ),
                                            _status == "Entregue"
                                            ? Padding(
                                              padding: EdgeInsets.only(bottom: 8, top: 32,),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  CheckboxListTile(
                                                      title: Text("Produto entregue?"),
                                                      value: habilitado,
                                                      selected: false,
                                                      onChanged: (bool valor){
                                                        setState(() {
                                                          habilitado = valor;
                                                        });
                                                        _entregue();
                                                      }),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 0, top: 32),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          "Avalie seu pedido:",
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
                                                            setState(() {
                                                              score = 1;
                                                            });
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
                                                            setState(() {
                                                              score = 2;
                                                            });
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
                                                            setState(() {
                                                              score = 3;
                                                            });
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
                                                            setState(() {
                                                              score = 4;
                                                            });
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
                                                            setState(() {
                                                              score = 5;
                                                            });
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
                                            )
                                                : Container()
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
                      }
                  )
              )
            ],
          )
      ),
      bottomNavigationBar: Mostracarrinho(),
    );
  }
}
