import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/pagina_produto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';


class Mensagens extends StatefulWidget {
  String _idUsuario;
  Mensagens(this._idUsuario);
  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  String _idUsuario;
  Firestore db = Firestore.instance;
  int _indice;
  int _tamanhoLista;
  MoneyFormatterOutput _valorTotalFormatado;
  double _valorTotal = 0.0;
  DocumentSnapshot _produtosCarrinho;
  List _idProdutoCarrinho = List();
  List<String> itensMenu = [
    "Remover", "Editar",
  ];
  List<DocumentSnapshot> produtos;

  _escolhaMenuItem(itemEscolhido){
    print("escolhido: $itemEscolhido");
    switch(itemEscolhido){
      case "Remover" :
        _removerProdutoCarrinho();
        break;
      case "Editar" :
        _editarProdutoCarrinho();
        break;
    }
  }

  _removerProdutoCarrinho(){
    print("Carrinho remover produto _idProduto");
    String _idProduto = produtos[_indice].documentID;
    db = Firestore.instance;
    db.collection("usuarios")
        .document(_idUsuario)
        .collection("carrinho")
        .document(_idProduto).delete();
  }

  _editarProdutoCarrinho() async {
    print("Carrinho editar produto");
    Produto produto = Produto();
    produto.idUsuario = _idUsuario;
    produto.idLoja = produtos[_indice]["idLoja"];
    produto.idProduto = produtos[_indice]["idProduto"];
    produto.quantidade = produtos[_indice]["quantidade"];
    produto.precoProduto = produtos[_indice]["valor"];
    produto.observacao = produtos[_indice]["observacao"];
    produto.nomeProduto = produtos[_indice]["nome"];
    produto.urlFotoProduto = produtos[_indice]["url"];
    produto.idProdutonoCarrinho = produtos[_indice].documentID;
    String _adm = produtos[_indice]["admLoja"];
    Firestore db = Firestore.instance;
    db.collection("lojas")
        .document(_adm)
        .collection("lojasusuario")
        .document(produto.idLoja)
        .collection("produtos").document(produto.idProduto).get().then((dados){
      produto.descricaoProduto = dados["descricao"];
      produto.prazo = dados["prazo"];
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Paginaproduto(produto, false)));

    });
  }

  _lerProduto(){
    print("Produto infos");
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

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _idUsuario = widget._idUsuario;
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*0.25;
    print(_idUsuario);
    var stream = StreamBuilder(
      stream: db
          .collection("usuarios")
          .document(_idUsuario)
          .collection("carrinho")
          .snapshots(),
      builder: (context, snapshot) {
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
            _valorTotal = 0;
            QuerySnapshot querySnapshot = snapshot.data;
            print(querySnapshot.documents.length,);
            if (snapshot.hasError) {
              return Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      _tamanhoLista = querySnapshot.documents.length;
                      produtos = querySnapshot.documents;
                      DocumentSnapshot _produtosCarrinho = produtos[indice];
                      String _urlFotoProduto = _produtosCarrinho["url"];
                      String _nomeProduto = _produtosCarrinho["nome"];
                      int _quantidade = _produtosCarrinho["quantidade"];
                      double _valor = _produtosCarrinho["valor"];
                      _valor = _valor * _quantidade;
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
                      return  GestureDetector(
                          onTap: _lerProduto,
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 16, 0, 10),
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
                                                      padding: EdgeInsets.all(16),
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
                                      Container(
                                          width: 40,
                                          child: PopupMenuButton<String>(
                                              onSelected: _escolhaMenuItem,
                                              itemBuilder: (context){
                                                _indice = indice;
                                                return itensMenu.map((String item){
                                                  return PopupMenuItem<String>(
                                                      value: item,
                                                      child: Text(item)
                                                  );
                                                }).toList();
                                              }
                                          )
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      indice == _tamanhoLista - 1
                                          ? _valorTotalFormatado != null
                                          ? Padding(
                                          padding: EdgeInsets.only(top: 32, right: 16),
                                          child: Text(
                                            "TOTAL: " + _valorTotalFormatado.symbolOnLeft.toString(),
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ))
                                          : Text(
                                        "TOTAL: ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),) : Container()
                                    ],
                                  )
                                ],
                              )
                          )
                      );
                    }),
              );
            }
            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Seu carrinho"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  stream,
                ],
              ),
            )),
      ),
    );
  }
}
