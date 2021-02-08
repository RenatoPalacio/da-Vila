import 'package:compradordodia/telas/ler_detalhes_pedido.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

import 'ler_detalhes_encomenda_mobx.dart';

class LerProdutoPedido extends StatefulWidget {
  String _nomeLoja;
  String _idUsuario;
  String _idLoja;
  LerProdutoPedido(this._nomeLoja, this._idUsuario, this._idLoja);
  @override
  _LerProdutoPedidoState createState() => _LerProdutoPedidoState();
}

class _LerProdutoPedidoState extends State<LerProdutoPedido> {
  String _nomeLoja;
  String _idUsuario;
  String _idLoja;
  String idPedidoEscolhido;
  String urlEscolhido;
  String nomeEscolhido;
  String compradorEscolhido;
  String dataEscolhido;
  String statusEscolhido;
  List _pedidosLoja = List();

  _detalhePedido(){
    Firestore db = Firestore.instance;
    db.collection("usuarios").document(compradorEscolhido).get().then((dados){
      String url = dados["urlfotoperfil"];
      String nome = dados["nome"];
      if (url != urlEscolhido){
        db
            .collection("lojas")
            .document(_idUsuario)
            .collection("lojasusuario")
            .document(_idLoja)
            .collection("pedidos")
            .document(idPedidoEscolhido).updateData({"urlComprador" : url});
      }
      if (nome != nomeEscolhido){
        db
            .collection("lojas")
            .document(_idUsuario)
            .collection("lojasusuario")
            .document(_idLoja)
            .collection("pedidos")
            .document(idPedidoEscolhido).updateData({"nomeComprador" : nome});
      }
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LerDetalhesPedido(url, nome, dataEscolhido, statusEscolhido,_idUsuario, _idLoja, idPedidoEscolhido)));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nomeLoja = widget._nomeLoja;
    int _tamanhoNome = _nomeLoja.length;
    if (_tamanhoNome > 20){
      _tamanhoNome = 20;
    }
    _nomeLoja = _nomeLoja.substring(0,_tamanhoNome);
    _idUsuario = widget._idUsuario;
    _idLoja = widget._idLoja;
  }

  @override
  Widget build(BuildContext context) {
    Firestore db = Firestore.instance;
    double c_width = MediaQuery.of(context).size.width*1;

   var stream = StreamBuilder(
     stream: db
         .collection("lojas")
         .document(_idUsuario)
         .collection("lojasusuario")
         .document(_idLoja)
         .collection("pedidos").snapshots(),
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
         Color _cor = Colors.red;;
         _pedidosLoja.clear();
         QuerySnapshot querySnapshot = snapshot.data;
         for (DocumentSnapshot _pedido in querySnapshot.documents){
           String _idPedido = _pedido.documentID;
           var dadosPedido = _pedido.data;
           String _idComprador = dadosPedido["compradorPedido"];
           String _nomeComprador = dadosPedido["nomeComprador"];
           var _dataPedido = dadosPedido["dataPedido"];
           _dataPedido = formatDate(_dataPedido.toDate(), [dd, "/", mm, "/", yyyy]).toString();
           int _quantidadeItens = dadosPedido["quantidadePedido"];
           String _statusPedido = dadosPedido["statusPedido"];
           String _salvaStatus;
           switch(_statusPedido){
           //'Realizado', 'Recebido', 'Em preparação', 'Entregue', 'Cancelado'
             case "Realizado" : _salvaStatus = "1 - Realizado";
             break;
             case "Em preparação" : _salvaStatus = "2 - Em preparação";
             break;
             case "Enviado" : _salvaStatus = "3 - Enviado";
             break;
             case "Entregue" : _salvaStatus = "4 - Entregue";
             break;
             case "Cancelado" : _salvaStatus = "5 - Cancelado";
           }
           double _valorPedido = dadosPedido["valorPedido"];
           MoneyFormatterOutput _preco = FlutterMoneyFormatter(
               amount: _valorPedido,
               settings: MoneyFormatterSettings(
                   symbol: "R\$",
                   decimalSeparator: ",",
                   thousandSeparator: ".",
                   fractionDigits: 2
               )
           ).output;
           Map<String, dynamic> pedido = {
             "Comprador" : _nomeComprador,
             "idComprador" : _idComprador,
             "Data" : _dataPedido,
             "Quantidade" : _quantidadeItens,
             "Valor" : _preco.symbolOnLeft,
             "Status" : _salvaStatus,
             "idPedido" : _idPedido
           };
           _pedidosLoja.add(pedido);
         }
         _pedidosLoja.sort((m1, m2) {
           var r = m1["Status"].compareTo(m2["Status"]);
           if (r != 0) return r;
           return m1["Status"].compareTo(m2["Status"]);
         });
         return Expanded(
             child: ListView.builder(
               itemCount: _pedidosLoja.length,
               itemBuilder: (bc, indice){
                 String comprador = _pedidosLoja[indice]["Comprador"];
                 String data = _pedidosLoja[indice]["Data"].toString();
                 String qtd = _pedidosLoja[indice]["Quantidade"].toString();
                 String valor = _pedidosLoja[indice]["Valor"].toString();
                 String status = _pedidosLoja[indice]["Status"];
                 print(status);
                 status = status.substring(4);
                 switch (status){
                   case "Realizado" : _cor = Colors.red;
                   break;
                   case "Em preparação" : _cor = Colors.blue;
                   break;
                   case "Enviado" : _cor = Colors.amber;
                   break;
                   case "Entregue" : _cor = Colors.green;
                   break;
                   case "Cancelado" : _cor = Colors.black26;
                 }
                 return GestureDetector(
                   onTap: (){
                     idPedidoEscolhido = _pedidosLoja[indice]["idPedido"];
                     urlEscolhido = _pedidosLoja[indice]["urlComprador"];
                     nomeEscolhido = _pedidosLoja[indice]["nomeComprador"];
                     compradorEscolhido = _pedidosLoja[indice]["idComprador"];
                     dataEscolhido = _pedidosLoja[indice]["Data"];
                     statusEscolhido = _pedidosLoja[indice]["Status"];
                     statusEscolhido = statusEscolhido.substring(4);
                     _detalhePedido();
                   },
                   child: Padding(
                     padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                     child: Card(
                         child: Padding(
                           padding: EdgeInsets.all(16),
                           child: Container(
                             width: c_width,
                             child: Column(
                               mainAxisSize: MainAxisSize.max,
                               children: <Widget>[
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: <Widget>[
                                     Text(
                                       data,
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 17,
                                       ),
                                     ),
                                     Text(
                                       status,
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: 17,
                                         color: _cor
                                       ),
                                     ),
                                   ],
                                 ),
                                 Padding(
                                   padding: EdgeInsets.only(top: 16),
                                   child: Row(
                                     children: <Widget>[
                                       Text(
                                         "Comprador(a): $comprador",
                                         style: TextStyle(
                                           fontWeight: FontWeight.bold,
                                           fontSize: 16,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 Padding(
                                   padding: EdgeInsets.only(top: 16),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: <Widget>[
                                       Text(
                                         "Quantidade: $qtd",
                                         style: TextStyle(
                                           fontWeight: FontWeight.normal,
                                           fontSize: 15,
                                         ),
                                       ),
                                       Text(
                                         "Preço: $valor",
                                         style: TextStyle(
                                           fontWeight: FontWeight.normal,
                                           fontSize: 15,
                                         ),
                                       ),
                                     ],
                                   ),
                                 )
                               ],
                             ),
                           ),
                         )
                     ),
                   ),
                 );
               },
             )
         );
       }
     },
   );

    return Scaffold(
      appBar: AppBar(
        title: Text("Encomendas de $_nomeLoja"),
      ),
      body: SafeArea(
          child: Container(
              child: Column(
                children: <Widget>[
                  stream,
                ],
              )
          )),
    );
  }
}

