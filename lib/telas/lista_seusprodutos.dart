import 'package:compradordodia/models/loja.dart';
import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/add_loja.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable_list_view/flutter_slidable_list_view.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

import 'add_produto.dart';

class Produtosloja extends StatefulWidget {
  @override
  String _nomeLoja;
  String _idLoja;
  String _idUsuario;
  String _url;
  bool _lojaAtiva;
  String idLojaUsuario;
  double _distancia;
  Loja loja = Loja();
  Produtosloja(this._idLoja, this._nomeLoja, this._idUsuario, this._url, this._lojaAtiva, this._distancia, {this.loja});
  _ProdutoslojaState createState() => _ProdutoslojaState();
}

class _ProdutoslojaState extends State<Produtosloja> {

  String _nomeLoja;
  String _idUsuario;
  String _idLoja;
  String _urlLoja;
  List<Produto> produtos = List();
  List<String> idDocumentos = List();
  Produto atualizaProduto = Produto();
  bool _produtoDisponivel;
  bool _lojaAtiva;
  MoneyFormatterOutput _preco;
  bool _lendoprodutos = true;
  double _distancia;
  bool _tempedido;

  Future<List<Produto>>_lerProdutos() async {
    _idUsuario = widget._idUsuario;
    _idLoja = widget._idLoja;
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja)
        .collection("produtos").getDocuments();
    for (DocumentSnapshot item in querySnapshot.documents){
      var dados = item.data;
      String _idDocumento = item.documentID;
      _produtoDisponivel = dados["disponivel"];
      bool _produtoExiste = dados["existe"];
      if(_produtoExiste) {
              Produto produto = Produto();
              produto.idProduto = item.documentID;
              produto.nomeProduto = dados["nome"];
              produto.descricaoProduto = dados["descricao"];
              produto.urlFotoProduto = dados["urlfotoperfil"];
              produto.precoProduto = dados["preco"].toDouble();
              produto.disponivel = dados["disponivel"];
              produto.prazo = dados["prazo"];
              produtos.add(produto);
              idDocumentos.add(_idDocumento);
      }
    }
    setState(() {
      _lendoprodutos = false;
      return produtos;
    });
  }

  _addProduto(){
    String idloja = widget._idLoja;
    String idusuario = widget._idUsuario;
    String url = _urlLoja;
    bool lojaativa = _lojaAtiva;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => addProduto(true, atualizaProduto, idusuario, idloja, _nomeLoja, url, lojaativa, _distancia)));
  }

  _paginaProduto(){
    print("oi");
  }

  _apagar(indice) async {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Apagar produto?"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: (){Navigator.pop(context);},
                    child: Text(
                      "Não",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber
                      ),
                    )
                ),
                FlatButton(
                    onPressed: (){
                      _removerProduto(indice);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Sim",
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

  _removerProduto(indice) async {
    Firestore db = Firestore.instance;
    String _idProduto = idDocumentos[indice];
    Map<String, dynamic> _existe = {
      "existe": false
    };
    await db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja)
        .collection("produtos")
        .document(_idProduto).updateData(_existe);
  }

  _ativarLoja() async {
    Firestore db = Firestore.instance;
    String _idLojaUsuario = widget.idLojaUsuario;;
    Map<String, dynamic> _ativo = {
      "ativo": _lojaAtiva
    };
    await db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idLoja).updateData(_ativo);
  }

  _configurar(indice){
    String idloja = widget._idLoja;
    String idusuario = widget._idUsuario;
    String url = _urlLoja;
    bool lojaativa = _lojaAtiva;
    atualizaProduto.idProduto = produtos[indice].idProduto;
    atualizaProduto.urlFotoProduto = produtos[indice].urlFotoProduto;
    atualizaProduto.nomeProduto = produtos[indice].nomeProduto;
    atualizaProduto.descricaoProduto = produtos[indice].descricaoProduto;
    atualizaProduto.precoProduto = produtos[indice].precoProduto.toDouble();
    atualizaProduto.disponivel = produtos[indice].disponivel;
    atualizaProduto.prazo = produtos[indice].prazo;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => addProduto(false, atualizaProduto, idusuario, idloja, _nomeLoja, url, lojaativa, _distancia)));
  }

  _converteReal(precoproduto) {
    _preco = FlutterMoneyFormatter(
        amount: precoproduto,
        settings: MoneyFormatterSettings(
            symbol: "R\$",
            decimalSeparator: ",",
            thousandSeparator: ".",
            fractionDigits: 2
        )
    ).output;
  }

  _configurarLoja() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot documento = await db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja).get();

    Loja loja = Loja();
    loja.urlFotoPerfil = documento["urlfotoperfil"];
    loja.nome = documento["nome"];
    loja.descricao = documento["descricao"];
    loja.valorminimo = documento["valorminimo"];
    loja.cep = documento["cep"];
    loja.endereco = documento["endereco"];
    loja.numero = documento["numero"];
    loja.complemento = documento["complemento"];
    loja.bairro = documento["bairro"];
    loja.cidade = documento["cidade"];
    loja.uf = documento["uf"];
    loja.categoria1 = documento["categoria1"];
    loja.categoria2 = documento["categoria2"];
    loja.categoria3 = documento["categoria3"];
    loja.retirada = documento["retirada"];
    loja.entrega = documento["fazentrega"];
    loja.distancia = documento["distancia"];
    loja.precokmdelivery = documento["precokmdelivery"];
    loja.mapPagto = documento["mapPagto"];
    loja.ativaZap = documento["ativaZap"];
    loja.ativaFone = documento["ativaFone"];
    loja.ativaMail = documento["ativaMail"];
    loja.adm = documento["adm"];
    loja.latitude = documento["latitude"];
    loja.longitude = documento["longitude"];
    loja.lojaativa = documento["ativo"];
    loja.lojaexistente = documento["existe"];
    loja.pedidosnovos = documento["pedidosnovos"];
    loja.qtdpedidos = documento["qtdpedidos"];
    loja.tempedido = documento["tempedido"];
    loja.id = _idLoja;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => addLoja(false, atualizaLoja: loja,)));
  }

  _apagarLoja() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot documento = await db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja).get();
    _tempedido = documento["tempedido"];
    String _texto;
    String _textoBotao1 = "Não";
    String _textoBotao2 = "Sim";
    if(_tempedido) {
      _texto = "Você não pode apagar uma loja que tem pedidos.";
      _textoBotao1 = "";
      _textoBotao2 = "OK";
    } else {
      _texto = "Apagar loja?";
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
                        _removerLoja();
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

  _removerLoja() async {
    Firestore db = Firestore.instance;;
    Map<String, dynamic> _existe = {
      "existe": false
    };
    await db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idLoja).updateData(_existe);
    Navigator.pop(context);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nomeLoja = widget._nomeLoja;
    _urlLoja = widget._url;
    _lojaAtiva = widget._lojaAtiva;
    _distancia = widget._distancia;
    //_lerProdutos();
  }

  @override
  Widget build(BuildContext context) {
    _idUsuario = widget._idUsuario;
    _idLoja = widget._idLoja;
    double c_width = MediaQuery.of(context).size.width*0.5;
    Firestore db = Firestore.instance;
    var lerProdutos = StreamBuilder(
        stream: db.collection("lojas")
            .document(_idUsuario)
            .collection("lojasusuario")
            .document(_idLoja)
            .collection("produtos").snapshots(),
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
              produtos.clear();
              QuerySnapshot querySnapshot = snapshot.data;
              for (DocumentSnapshot item in querySnapshot.documents){
                var dados = item.data;
                String _idDocumento = item.documentID;
                _produtoDisponivel = dados["disponivel"];
                bool _produtoExiste = dados["existe"];
                if(_produtoExiste) {
                  Produto produto = Produto();
                  produto.idProduto = item.documentID;
                  produto.nomeProduto = dados["nome"];
                  produto.descricaoProduto = dados["descricao"];
                  produto.urlFotoProduto = dados["urlfotoperfil"];
                  produto.precoProduto = dados["preco"].toDouble();
                  produto.disponivel = dados["disponivel"];
                  produto.prazo = dados["prazo"];
                  produtos.add(produto);
                  idDocumentos.add(_idDocumento);
                }
              }
              return Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: SlideListView(
                          padding: EdgeInsets.all(16),
                          itemBuilder: (bc , indice){
                            Produto produto = produtos[indice];
                            double precoproduto = produto.precoProduto.toDouble();
                            _converteReal(precoproduto);
                            return GestureDetector(
                                onTap: _paginaProduto,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Container(
                                              width: c_width,
                                              child: Text(
                                                produto.nomeProduto,
                                                softWrap: true,
                                                style: TextStyle(
                                                    fontSize: 16),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8, left: 8),
                                            child: Text(
                                              _preco.symbolOnLeft.toString(),
                                              style: TextStyle(
                                                  fontSize: 16),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8, left: 16),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: (){_configurar(indice);},
                                                  child: Icon(Icons.edit),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 32),
                                                  child: GestureDetector(
                                                    onTap: (){_apagar(indice);},
                                                    child: Icon(Icons.delete),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          produto.disponivel == false
                                              ? Padding(
                                            padding: EdgeInsets.only(left: 8, top: 8),
                                            child: Text(
                                                "Oferta indisponível",
                                                style: TextStyle(
                                                    color: Colors.red
                                                )
                                            ),
                                          )
                                              : Text("")
                                        ],
                                      ),
                                      Card(
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: SizedBox(
                                                width: 120,
                                                height: 80,
                                                child: produto.urlFotoProduto != null
                                                    ? Image.network(
                                                  produto.urlFotoProduto,
                                                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
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
                                      )
                                    ],
                                  ),
                                )
                            );
                          },
                          dataList: produtos,
                          actionWidgetDelegate: ActionWidgetDelegate(2, (actionIndex, listIndex) {

                            if (actionIndex == 0) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[Icon(Icons.delete), Text('apagar')],
                              );
                            }  else  {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[Icon(Icons.edit), Text('configurar')],
                              );
                            }
                          }, (int indexInList, int index, BaseSlideItem item) {
                            if (index == 0) {
                              item.remove();
                              _apagar(indexInList);
                            }  else {
                              item.close();
                              _configurar(indexInList);
                            }
                          }, [Colors.redAccent,  Colors.blueAccent]),
                        ),
                      ),
                    ],
                  )
              );
          }
        }
    );


    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Image(
            image: NetworkImage(_urlLoja),
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            onPressed: _addProduto
        ),
        body: SafeArea(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Text(
                          _nomeLoja,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: GestureDetector(
                            onTap: _configurarLoja,
                            child: Icon(Icons.edit),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: GestureDetector(
                            onTap: _apagarLoja,
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: Text("Loja ativa"),
                    value: _lojaAtiva,
                    onChanged: (bool valor){
                      setState(() {
                        _lojaAtiva = valor;
                      });
                      _ativarLoja();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8, left: 16, bottom: 8),
                    child: Text(
                      "Raio de entrega: $_distancia Km",
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),
                  ),
                  lerProdutos,
                ],
              ),
            ))
    );
  }
}
