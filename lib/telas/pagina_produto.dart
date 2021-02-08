import 'package:compradordodia/models/carrinho.dart';
import 'package:compradordodia/models/mostracarrinho.dart';
import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/ler_carrinho_novo.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Paginaproduto extends StatefulWidget {
  @override
  Produto _produtoDetalhe = Produto();
  bool _inclui;
  Paginaproduto(this._produtoDetalhe, this._inclui);
  _PaginaprodutoState createState() => _PaginaprodutoState();
}

class _PaginaprodutoState extends State<Paginaproduto> {

  TextEditingController _obsController = TextEditingController();
  Produto _detalhesProduto = Produto();
  String _urlFotoPerfil;
  String _nomeProduto;
  String _descricao;
  double _precoProduto;
  String _prazo;
  String _dia = "dias";
  String _idLoja;
  String _admLoja;
  String _idProduto;
  bool _fazentrega;
  bool _retirada;
  MoneyFormatterOutput _preco;
  int _qdtControle = 0;
  Carrinho carrinho = Carrinho();
  String _obsRecuperada = "";
  bool _incluir = true;
  bool _lendoproduto = true;
  String idUsuario;
  double _valorminimo;

  _converteReal(precoProduto){
    if(_qdtControle > 0){
      precoProduto = precoProduto * _qdtControle;
    }
     _preco = FlutterMoneyFormatter(
        amount: precoProduto,
        settings: MoneyFormatterSettings(
            symbol: "R\$",
            decimalSeparator: ",",
            thousandSeparator: ".",
            fractionDigits: 2
        )
    ).output;
  }

  _incluiUnidade(){
    _qdtControle = _qdtControle + 1;
    setState(() {
      _qdtControle;
      _converteReal(_precoProduto);
    });
  }

  _excluiUnidade(){
    if (_qdtControle > 0) {
      _qdtControle = _qdtControle - 1;
      setState(() {
        _qdtControle;
        _converteReal(_precoProduto);
      });
    }
  }

  _incluirCarrinho() async {

    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();

    carrinho.Loja = _idLoja;
    carrinho.idProduto = _idProduto;
    carrinho.quantidade = _qdtControle;
    carrinho.valor = _precoProduto;
    carrinho.obs = _obsController.text;
    carrinho.admLoja = _admLoja;
    carrinho.urlFotoProduto = _urlFotoPerfil;
    carrinho.nomeProduto = _nomeProduto;
    carrinho.retirada = _retirada;
    carrinho.fazentrega = _fazentrega;
    carrinho.valorminimo = _valorminimo;

    String _idUsuario = _usuario.uid;
    Firestore db = Firestore.instance;
    String _idCarrinho = _idLoja + "_" + _idProduto;
    String _idExistente;
    DocumentSnapshot _doc;

    //checa se já tem carrinho de outra loja
    QuerySnapshot _query = await db.collection("usuarios")
        .document(_idUsuario)
        .collection("carrinho")
        .getDocuments();

    if(_query.documents.isNotEmpty){
      _doc = _query.documents.last;
      _idExistente = _doc["idLoja"];
    } else {
      _idExistente = _idLoja;
    }

    if(_idExistente != _idLoja){
      _apagarCarrinho(_idUsuario, _query, _idCarrinho);
    } else {
      db.collection("usuarios")
          .document(_idUsuario)
          .collection("carrinho")
          .document(_idCarrinho).setData(carrinho.toMap());
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Lercarrinho(_idUsuario)));
    }
  }

  _apagarCarrinho(String _idUsuario, QuerySnapshot query, String _idCarrinho){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: Text("Revisar compra"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Você já tem produtos de outra loja no carrinho. Quer substituí-los?",
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            "Não",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text(
                            "Sim",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Firestore db = Firestore.instance;
                            for(DocumentSnapshot _doc in query.documents){
                              db.collection("usuarios")
                                  .document(_idUsuario)
                                  .collection("carrinho")
                                  .document(_doc.documentID)
                                  .delete();
                            }
                            db.collection("usuarios")
                                .document(_idUsuario)
                                .collection("carrinho")
                                .document(_idCarrinho).setData(carrinho.toMap());
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Lercarrinho(_idUsuario)));
                          },
                        ),
                      ],
                    ),
                  )
                ],
              )
          );
        }
    );
  }

  _atualizarCarrinho() async {

    Map<String, dynamic> mapa = {
      "quantidade" : _qdtControle,
      "observacao" : _obsController.text
    };
    String _idProdutonoCarrinho = _detalhesProduto.idProdutonoCarrinho;
    Firestore db = Firestore.instance;
    db.collection("usuarios")
        .document(idUsuario)
        .collection("carrinho")
        .document(_idProdutonoCarrinho)
        .updateData(mapa);
    Navigator.pop(context);
  }

  _carregaUsuario() async {
    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    idUsuario = _usuario.uid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _detalhesProduto = widget._produtoDetalhe;
    _urlFotoPerfil = _detalhesProduto.urlFotoProduto;
    _nomeProduto = _detalhesProduto.nomeProduto;
    _descricao = _detalhesProduto.descricaoProduto;
    _precoProduto = _detalhesProduto.precoProduto.toDouble();
    _prazo = _detalhesProduto.prazo;
    _idLoja = _detalhesProduto.idLoja;
    _admLoja = _detalhesProduto.idUsuario;
    _idProduto = _detalhesProduto.idProduto;
    _obsRecuperada = _detalhesProduto.observacao;
    _retirada = _detalhesProduto.retirada;
    _fazentrega = _detalhesProduto.fazentrega;
    _valorminimo = _detalhesProduto.valorminimo;

    if(_prazo == "1"){
      _dia = "dia";
    }
    int qtdCarrinho = _detalhesProduto.quantidade;
    if(qtdCarrinho > 0){
      _qdtControle = qtdCarrinho;
    }
    _incluir = widget._inclui;
    _converteReal(_precoProduto);
    _carregaUsuario();
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do produto"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(0),
              child: Center(
                child: Image.network(
                  _urlFotoPerfil,
                  scale: 2,
                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      )
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Container(
                width: c_width,
                child: Text(
                  _nomeProduto,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Container(
                width: c_width,
                child: Wrap(
                  children: <Widget>[
                    Text(
                      _descricao,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Prazo de entrega: $_prazo $_dia corridos",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Preço: ${_preco.symbolOnLeft}",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              child: Card(
                                child: Icon(Icons.exposure_neg_1, size: 30,) ,
                              ),
                              onTap: _excluiUnidade,
                            ),
                            Card(
                              child: Container(
                                width: 40,
                                child: Center(
                                  child: Text(
                                    _qdtControle.toString(),
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Card(
                                child: Icon(Icons.exposure_plus_1, size: 30),
                              ),
                              onTap: _incluiUnidade,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                hintText: "Alguma observação?",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            style: TextStyle(fontSize: 15),
                            controller: _obsController = new TextEditingController(text: _obsRecuperada),
                            onChanged: (text){_obsRecuperada = text;}
                          )
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: _qdtControle > 0
                            ? BotaoCustomizado(
                                textoBotao: "Incluir",
                                onPressed: _incluir
                                  ? (){_incluirCarrinho();}
                                  : (){_atualizarCarrinho();} ,)
                            : null
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Mostracarrinho()
    );
  }
}
