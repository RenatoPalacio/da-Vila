import 'package:compradordodia/models/encomenda.dart';
import 'package:compradordodia/models/mostracarrinho.dart';
import 'package:compradordodia/telas/ler_pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';

class Historico extends StatefulWidget {
  String _idUsuario;
  Historico(this._idUsuario);
  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  String _idUsuario;
  List _encomendas = List();
  bool _semEncomendas = true;

  _detalhePedido(indice){
    String idUsuario;
    String idDocPedido;
    String idDocLoja;
    idUsuario = _encomendas[indice]["idUsuario"];
    idDocPedido = _encomendas[indice]["DocPedido"];
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Lerpedido(idUsuario, idDocPedido)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _idUsuario = widget._idUsuario;
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*1;
    Firestore db = Firestore.instance;

    var stream = StreamBuilder(
        stream: db
            .collection("usuarios")
            .document(_idUsuario)
            .collection("pedidos").snapshots(),
        builder: (context, snapshot){
          switch (snapshot.connectionState) {
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
              Color _cor = Colors.red;;
              _encomendas.clear();
              QuerySnapshot querySnapshot = snapshot.data;
              for (DocumentSnapshot documentSnapshot in querySnapshot.documents){
                bool _entregue = documentSnapshot["entregue"];
                if(! _entregue){
                  continue;
                }
                Encomenda encomenda = Encomenda();
                String _idNomeLoja = documentSnapshot.documentID.substring(documentSnapshot.documentID.indexOf("_") + 1);
                var _dataPedido = documentSnapshot["data"];
                _dataPedido = formatDate(_dataPedido.toDate(), [dd, "/", mm, "/", yyyy]).toString();
                encomenda.idUsuario = _idUsuario;
                encomenda.idDocumentoPedido = documentSnapshot.documentID;
                encomenda.urlLoja = documentSnapshot["url"];
                encomenda.nomeLoja = _idNomeLoja;
                encomenda.dataPedido = _dataPedido;
                encomenda.valorPedido = documentSnapshot["valor"];
                encomenda.quantidadeProdutos = documentSnapshot["quantidade"];
                encomenda.statusPedido = documentSnapshot["statusPedido"];
                Map<String, dynamic> _encomenda = encomenda.toMap();
                _encomendas.add(_encomenda);
              }
              if(_encomendas.length == 0){
                return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 64),
                      child: Text(
                        "Você ainda não tem um\n"
                            "histórico de encomendas.",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),
                      ),
                    )
                );
              }
              return Expanded(
                  child: ListView.builder(
                      itemCount: _encomendas.length,
                      itemBuilder: (context, indice){
                        String _urlFotoLoja = _encomendas[indice]["URL"];
                        String _nomeLoja = _encomendas[indice]["Nome"];
                        if(_nomeLoja.length > 25){
                          _nomeLoja = _nomeLoja.substring(0,24) + "...";
                        }
                        int _qtd = _encomendas[indice]["Quantidade"];
                        double _valor = _encomendas[indice]["Valor"];
                        String _status = _encomendas[indice]["Status"];
                        _cor = Colors.green;

                        MoneyFormatterOutput _preco = FlutterMoneyFormatter(
                            amount: _valor,
                            settings: MoneyFormatterSettings(
                                symbol: "R\$",
                                decimalSeparator: ",",
                                thousandSeparator: ".",
                                fractionDigits: 2
                            )
                        ).output;
                        String _data = _encomendas[indice]["Data"];
                        return GestureDetector(
                            onTap: (){
                              _detalhePedido(indice);
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Card(
                                  child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Container(
                                        width: c_width,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(right: 0),
                                                  child: Text(
                                                    _status,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: _cor
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                CircleAvatar(
                                                    maxRadius: 20,
                                                    backgroundColor: Colors.amberAccent,
                                                    backgroundImage: _urlFotoLoja != null
                                                        ? NetworkImage(_urlFotoLoja)
                                                        : null),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 16),
                                                  child: Text(
                                                    _nomeLoja,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),

                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 16),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    "Data do pedido: " + _data.toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 15),
                                                    textAlign: TextAlign.start,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 16),
                                              child: Row(
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                                                      child: Text(
                                                        "Itens: " + _qtd.toString(),
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 15),
                                                        textAlign: TextAlign.start,
                                                      )
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                                                      child: Text(
                                                        "Preço: " + _preco.symbolOnLeft.toString(),
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 15),
                                                        textAlign: TextAlign.start,
                                                      )
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                  )
                              ),
                            )
                        );
                      }
                  )
              );
          }
        }
    );

    return Scaffold(
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              stream,
            ],
          )
      ),
    );
  }
}


