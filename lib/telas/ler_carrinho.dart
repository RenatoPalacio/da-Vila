import 'package:compradordodia/models/delivery.dart';
import 'package:compradordodia/models/menu_enderecos.dart';
import 'package:compradordodia/models/pedido.dart';
import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/pagina_produto.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class Lercarrinho extends StatefulWidget {
  @override
  String _idUsuario;
  Lercarrinho(this._idUsuario);
  _LercarrinhoState createState() => _LercarrinhoState();
}

class _LercarrinhoState extends State<Lercarrinho> {
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
  List<DropdownMenuItem<String>> _listaEnderecos = List();
  String _enderecoEntrega;
  Delivery _delivery = Delivery();
  String _idDonoLoja;
  String _idDocumentoLoja;
  String _idDocumentoReg;
  DateTime _dataagora = DateTime.now();
  double _valor;
  int _qtd;
  String idLoja;
  String _nome;
  String _enderecoComprador;
  double _latitudeComprador;
  double _longitudeComprador;
  String _idUsuarioComprador;
  String _nomeVendedor;
  String _idLojaDelivery;
  List<Map> _listadelivery = List();
  int _contador = 0;
  String _textoMudaForma;
  List<Map> _deliveryincorreto = [];
  String _mudouDelivery = "";
  bool _mudaendereco = false;

  _escolhaMenuItem(itemEscolhido){
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
    String _idProduto = produtos[_indice].documentID;
    db = Firestore.instance;
    db.collection("usuarios")
        .document(_idUsuario)
        .collection("carrinho")
        .document(_idProduto).delete();
    db.collection("usuarios")
        .document(_idUsuario)
        .collection("carrinho")
        .getDocuments()
        .then((dados) => dados.documents.length > 0  ? null : Navigator.pop(context) );
  }

  _editarProdutoCarrinho() async {
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

  _checarValorMinimo() async {
    double _valorminimo;
    String _idLoja;
    String _admLoja;
    double _valorPedido = 0;
    int _qtd_lojas = 1;
    List<String> _lojassemmin = List();
    QuerySnapshot _itensCarrinho = await db
        .collection("usuarios")
        .document(_idUsuario)
        .collection("carrinho").getDocuments();
    for(DocumentSnapshot item in _itensCarrinho.documents){
      if(_idLoja != null && _idLoja != item["idLoja"] && _valorPedido < _valorminimo){
        String _nomeLoja = _idLoja.substring(_idLoja.indexOf("_")+1);
        _lojassemmin.add(_nomeLoja);
        _valorPedido = 0;
      } else if (_idLoja != item["idLoja"]){
        _valorPedido = 0;
        _qtd_lojas = _qtd_lojas + 1;
      }
      _admLoja = item["admLoja"];
      _idLoja = item["idLoja"];
      DocumentSnapshot _doc = await db.collection("lojas").document(_admLoja).collection("lojasusuario").document(_idLoja).get();
      _valorminimo = _doc["valorminimo"];
      if (_valorminimo > 0){
        double _total = item["valor"] * item["quantidade"];
        _valorPedido = _valorPedido + _total;
      }
    }
    if(_valorPedido < _valorminimo){
      String _nomeLoja = _idLoja.substring(_idLoja.indexOf("_")+1);
      _lojassemmin.add(_nomeLoja);
    }

    //_lojassemmin.clear();
   int _tamanho = _lojassemmin.length;
    if(_tamanho > 0){
      String _texto;
      if (_qtd_lojas == 1){
        _texto = "Você não atingiu o valor mínimo da loja.";
      }
      else if (_tamanho == 1){
        _texto = "Você não atingiu o valor mínimo da seguinte loja:";
      } else {
        _texto = "Você não atingiu o valor mínimo das seguintes lojas:";
      }
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Revisar compra"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _texto,
                  style: TextStyle(
                    fontSize: 18
                  ),
                ),
                Container(
                  width: 400,
                  height: 100,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _tamanho,
                    itemBuilder: (BuildContext context, int indice){
                      return ListTile(
                          title: Text(
                            _lojassemmin[indice],
                            style: TextStyle(
                              fontSize: 17
                            ),
                          )
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          "OK",
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
                    ],
                  ),
                )
              ],
            )
          );
        }
      );
    } else {
      _fazerPedido();
    };
  }

  Future<String> _checarEntrega(DocumentSnapshot item) async {
    String _idAdmLoja = item["admLoja"];
    String _idLoja = item["idLoja"];
    DocumentSnapshot documento = await db.collection("lojas")
        .document(_idAdmLoja)
        .collection("lojasusuario")
        .document(_idLoja).get();
    String _nomeloja = documento["nome"];
    bool _fazentrega = documento["fazentrega"];
    bool _retirada = documento["retirada"];

    if(_enderecoEntrega == "retirada" && ! _retirada || _enderecoEntrega != "retirada" && ! _fazentrega){
      return _nomeloja;
    }
  }

  _cancelarEncomendas() async {
    db = Firestore.instance;
    for(Map item in _deliveryincorreto){
      String _idProduto = item["id"];
      db.collection("usuarios")
          .document(_idUsuario)
          .collection("carrinho")
          .document(_idProduto).delete();
    }
    Navigator.pop(context);
    _deliveryincorreto.clear();
    db.collection("usuarios")
        .document(_idUsuario)
        .collection("carrinho")
        .getDocuments()
        .then((dados) => dados.documents.length > 0  ? null : Navigator.pop(context));
  }

  _fazerPedido() async {
    List _lojasIncompativeis = List();
    _checarEnderecoEntrega();
    Pedido pedido = Pedido();
    String _comparaLoja = "null";
    Firestore db = Firestore.instance;
    DocumentSnapshot item = await db.collection("usuarios").document(_idUsuario).get();
    _nome = item["nome"];
    String _urlperfil = item["urlfotoperfil"];

    QuerySnapshot _itensCarrinho = await db
        .collection("usuarios")
        .document(_idUsuario)
        .collection("carrinho").getDocuments();
    String _idDocumento = DateTime.now().toString().replaceAll(" ", "").replaceAll("-", "").replaceAll(":", "").replaceAll(".", "");
    for(DocumentSnapshot item in _itensCarrinho.documents){

      String _idAdmLoja = item["admLoja"];
      String _idLoja = item["idLoja"];
      DocumentSnapshot documento = await db.collection("lojas")
          .document(_idAdmLoja)
          .collection("lojasusuario")
          .document(_idLoja).get();
      String _nomeloja = documento["nome"];
      bool _fazentrega = documento["fazentrega"];
      bool _retirada = documento["retirada"];

      if(_enderecoEntrega == "retirada" && ! _retirada || _enderecoEntrega != "retirada" && ! _fazentrega){
        _lojasIncompativeis.add(_nomeloja);
        continue;
      }

/*
      idLoja = item["idLoja"];

      //FINALIZOUO PEDIDO DA LOJA E VERIFICA  NÃO É A  PRIMEIRA CHECAGEM
      if (idLoja != _comparaLoja && _comparaLoja != "null"){
        //CRIA DELIVERY
        _idLojaDelivery = _comparaLoja;
        _gerarDelivery();
      }

      //_endereceoEntrega = item["enderecoEntrega"];
      pedido.idProduto = item["idProduto"];
      pedido.quantidade = item["quantidade"];
      double valor = item["valor"];
      pedido.valorPedido = valor * pedido.quantidade;
      pedido.obsProduto = item["observacao"];
      pedido.idComprador = _idUsuario;
      pedido.nomeComprador = _nome;
      pedido.urlFotoPerfilComprador = _urlperfil;
      pedido.idPedido = "";
      pedido.statusPedido = "Realizado";
      pedido.obsPedido = "";
      pedido.url = item["url"];
      pedido.nomeProduto = item["nome"];
      Map<String, dynamic> _produto = pedido.toMap();
      String _idNomeLoja = idLoja.substring(idLoja.indexOf("_") + 1);
      _valor = pedido.valorPedido;
      _qtd = pedido.quantidade;

      _idDocumentoReg = _idDocumento + "_" + _idNomeLoja;

      db.collection("usuarios")
          .document(_idUsuario)
          .collection("pedidos")
          .document(_idDocumentoReg)
          .collection("produtos")
          .add(_produto);

      DocumentSnapshot snapshot = await db
          .collection("lojas")
          .document(item["admLoja"])
          .collection("lojasusuario")
          .document(idLoja).get();
      var dadosLoja = snapshot.data;

      //lÊ DAODOS DA LOJA
      db
          .collection("lojas")
          .document(item["admLoja"])
          .collection("lojasusuario")
          .document(idLoja).updateData({"tempedido" : true});

      //ATUALIZA QUANTIDADE DE PEDIDOS NOVOS DA LOJA - SOMENTE 1 INDEPENDETE DA QUANITADE DE PRODUTOS DO PEDIDO
      if(idLoja != _comparaLoja){
        int _qtdPedidos = dadosLoja["pedidosnovos"];
        _qtdPedidos = _qtdPedidos + 1;
        db
            .collection("lojas")
            .document(item["admLoja"])
            .collection("lojasusuario")
            .document(idLoja).updateData({"pedidosnovos" : _qtdPedidos});
      }

      _comparaLoja = idLoja;

      //LÊ DADOS DO PEDIDO QUE ACABOU DE CRIAR
      DocumentSnapshot conferevalor = await  db.collection("usuarios")
          .document(_idUsuario)
          .collection("pedidos")
          .document(_idDocumentoReg).get();
      var dadosValor = conferevalor.data;
      //INCRMENTA VALOR E QUANTIDADE CASO O PEDIDO PARA A LOJA TENHA MAIS DE UM PRODUTO
      if(dadosValor != null ){
        _valor = _valor + dadosValor["valor"];
        _qtd = _qtd + dadosValor["quantidade"];
      }

      String _url = dadosLoja["urlfotoperfil"];
      db.collection("usuarios")
          .document(_idUsuario)
          .collection("pedidos")
          .document(_idDocumentoReg)
          .setData(
          {
            "url" : _url,
            "idLoja" : idLoja,
            "statusPedido" : "Realizado",
            "entregue" : false,
            "data" : DateTime.now(),
            "valor" : _valor,
            "quantidade" : _qtd,
            "tempedido" : true,
            "entrega" : _enderecoEntrega,
            "pagamento" : ""
          });

       _idDonoLoja = item["admLoja"];
       _idDocumentoLoja = _idDocumento + "_" + _idUsuario;
      db.collection("lojas")
          .document(_idDonoLoja)
          .collection("lojasusuario")
          .document(idLoja)
          .collection("pedidos")
          .document(_idDocumentoLoja)
          .collection("produtos").add(_produto);

      db.collection("lojas")
          .document(_idDonoLoja)
          .collection("lojasusuario")
          .document(idLoja)
          .collection("pedidos")
          .document(_idDocumentoLoja)
          .setData({
        "dataPedido" : _dataagora,
        "valorPedido" : _valor,
        "quantidadePedido" : _qtd,
        "statusPedido" : "Realizado",
        "compradorPedido": _produto["Comprador"],
        "nomeComprador" : _produto["NomeComprador"],
        "urlComprador" : _produto["urlPerfilComprador"],
      });
      db.collection("usuarios").document(_idUsuario).collection("carrinho").document(item.documentID).delete();
      */
    }
    /*
    //CRIA O DELIVERY DO ÚLTIMO REGISTRO
    _idLojaDelivery = idLoja;

    _gerarDelivery();

    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Encomenda realizada"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aguarde a loja aceitar a encomenda. Acompanhe o status na aba Encomendas",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      String idUsuario = widget._idUsuario;
                      Navigator.pushNamedAndRemoveUntil(
                        context, "/home", (Route<dynamic> route) => false,
                        arguments: idUsuario,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
    */
  }

  _checarEnderecoEntrega() async {
    if (_enderecoEntrega != "") {
      QuerySnapshot _enderecos = await db.collection("usuarios").document(_idUsuario).collection("enderecos").getDocuments();
      for (DocumentSnapshot item in _enderecos.documents) {
        String _entrega = item["nome"];
        if (_enderecoEntrega.toString().trim() == _entrega.toString().trim()) {
          _enderecoComprador = item["endereco"] + ", " + item["numero"] + " " + item["complemento"];
          _latitudeComprador = item["latitude"];
          _longitudeComprador = item["longitude"];
          _idUsuarioComprador = _idUsuario;
        }
      }
    }
  }

  _gerarDelivery() async {
    //GERADELIVERY
    _delivery.idPedido = _idDocumentoReg;
    _delivery.valorPedido = _valor;
    _delivery.quantidade = _qtd;
    _delivery.idUsuarioComprador = _idUsuarioComprador;
    DocumentSnapshot nomeVendedor = await db.collection("usuarios").document(_idDonoLoja).get();
    _nomeVendedor = nomeVendedor["nome"];
    _delivery.nomeVendedor = _nomeVendedor;
    _delivery.enderecoComprador = _enderecoComprador;
    _delivery.latitudeComprador = _latitudeComprador;
    _delivery.longitudeComprador = _longitudeComprador;
    _delivery.idUsuarioVendedor = _idDonoLoja;
    _delivery.idLoja = _idLojaDelivery;
    _delivery.nomeLoja = _idLojaDelivery.substring(_idLojaDelivery.indexOf("_")+1);
    _delivery.nomeComprador = _nome;
    _delivery.dataPedido = _dataagora;
    _listadelivery.add(_delivery.toMap());

    DocumentSnapshot _docLoja = await db.collection("lojas").document(_idDonoLoja).collection("lojasusuario").document(_idLojaDelivery).get().then((dados){
      Delivery delivery = Delivery();
      delivery.enderecoLoja = dados["endereco"] + ", " + dados["numero"] + " " + dados["complemento"];
      delivery.latitudeLoja = dados["latitude"];
      delivery.longitudeLoja = dados["longitude"];
      delivery.nomeVendedor = _listadelivery[_contador]["nome_vendedor"];
      delivery.idUsuarioComprador = _listadelivery[_contador]["idComprador"];
      delivery.enderecoComprador = _listadelivery[_contador]["endereco_comprador"];
      delivery.latitudeComprador = _listadelivery[_contador]["latitude_comprador"];
      delivery.longitudeComprador = _listadelivery[_contador]["longitude_comprador"];
      delivery.idUsuarioVendedor = _listadelivery[_contador]["idVendedor"];
      delivery.idLoja = _listadelivery[_contador]["idLoja"];
      delivery.idPedido = _listadelivery[_contador]["idPedido"];
      delivery.nomeLoja = _listadelivery[_contador]["loja"];;
      delivery.nomeComprador = _listadelivery[_contador]["nome_comprador"];
      delivery.dataPedido = _listadelivery[_contador]["datapedido"];
      delivery.valorPedido = _listadelivery[_contador]["valor_pedido"];
      delivery.quantidade = _listadelivery[_contador]["quantidade_itens"];

      String _idPedidos = _idDocumentoLoja + "_" + delivery.nomeLoja;
      db.collection("pedidos").document(_idPedidos).setData(delivery.toMap());
      //db.collection("pedidos").add(delivery.toMap());

      _contador = _contador + 1;
    });

    }

  //CARREGA DROPDOWN ENDEREÇOS
  _carregaListaEnderecos(BuildContext context) async {
    DocumentSnapshot _snapshot = await db
        .collection("usuarios")
        .document(_idUsuario).get();
    if (_snapshot["enderecoEntrega"].toString().length > 0){
      _enderecoEntrega = _snapshot["enderecoEntrega"];
    }
    _listaEnderecos = await Enderecos.getEnderecos(_idUsuario, context);
    setState(() {
      _listaEnderecos;
      _enderecoEntrega;
    });
  }

  //CADASTRAR NOVO ENDEREÇOS
  _cadastrarEndereo(){
    Navigator.pushNamed(context, "/novo_endereco");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _idUsuario = widget._idUsuario;
    _carregaListaEnderecos(context);
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*0.25;
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
                          onTap: (){
                            //_indice = indice;
                            //_editarProdutoCarrinho();
                          },
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 16, 0, 10),
                              child: Column(
                                children: <Widget>[
                                  Card(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    borderOnForeground: false,
                                    child: Row(
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
                                  ),
                                  Column(
                                    //mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      indice == _tamanhoLista - 1
                                          ? _valorTotalFormatado != null
                                          ? Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end ,
                                            children: <Widget>[
                                              Padding(
                                                  padding: EdgeInsets.only(top: 32, right: 16),
                                                  child: Text(
                                                    "TOTAL: " + _valorTotalFormatado.symbolOnLeft.toString(),
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  )),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                  padding:EdgeInsets.fromLTRB(10, 32, 0, 10),
                                                  child: BotaoCustomizado(
                                                      textoBotao: "Encomendar",
                                                      onPressed: (){
                                                        if(_enderecoEntrega != null){
                                                          //_fazerPedido();
                                                           _checarValorMinimo();
                                                          //_checarModeloEntrega();

                                                        } else{
                                                          showDialog(
                                                              context: context,
                                                              builder: (context){
                                                                return AlertDialog(
                                                                  title: Text("Você não indicou um endereço paras entrega."),
                                                                  content: Text("Você vai retirar os produtos?"),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                        onPressed: (){Navigator.pop(context);},
                                                                        child: Text("Não", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange))),
                                                                    FlatButton(
                                                                        onPressed: (){_fazerPedido();},
                                                                        child: Text("Sim", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange))),
                                                                  ],
                                                                );
                                                              }
                                                          );
                                                        }
                                                      }
                                                  )
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(10, 32, 0, 10),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Continuar comprando:",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    )
                                                  ],
                                                ) ,
                                              ),
                                             Padding(
                                                 padding: EdgeInsets.fromLTRB(10, 8, 10, 10),
                                                 child:  Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: <Widget>[
                                                     RaisedButton(
                                                         child: Text("Na loja"),
                                                         color: Colors.orange,
                                                         onPressed: (){Navigator.pop(context);}
                                                     ),
                                                     RaisedButton(
                                                         child: Text("Outra loja"),
                                                         color: Colors.orange,
                                                         onPressed: (){
                                                           Navigator.pushReplacementNamed(context, "/home", arguments: _idUsuario);
                                                         }
                                                     ),
                                                   ],
                                                 ),)
                                            ],
                                          )
                                        ],
                                      )
                                          : Text(
                                        "TOTAL: ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),)
                                          : Container()
                                    ],
                                  ),
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
              padding: EdgeInsets.all(0),
              child: Column(
                //mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  DropdownButtonFormField(
                      items: _listaEnderecos,
                      value: _enderecoEntrega,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      onChanged: (endereco){
                        if(endereco == "novo"){
                          _cadastrarEndereo();
                        } else {
                          Firestore db = Firestore.instance;
                          db.collection("usuarios")
                              .document(_idUsuario)
                              .updateData({
                            "enderecoEntrega" : endereco,
                          });
                        }
                        setState(() {
                          _enderecoEntrega = endereco;
                        });
                      }),
                  stream,
                ],
              ),
            )),
      ),
    );
  }
}


