import 'dart:math';
import 'package:compradordodia/telas/troca_mensagens.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/pagina_produto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'ler_carrinho_novo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class Listaprodutos extends StatefulWidget {
  @override
  String _idUsuario;
  String _urlFotoLoja;
  String _idAdm;
  String _idLoja;
  String _nomeLoja;
  double _pedidominino;
  String bairro;
  double _latitude;
  double _longitude;
  String _idUsuarioComprador;
  bool _retirada;
  bool _entrega;
  double _entregaDistancia;
  double _entregaPreco;
  double _distancialoja;
  String _descricao;
  bool _ativaFone;
  bool _ativaZap;
  bool _ativaMail;


  Map<String, dynamic> _mapaPagto;
  Listaprodutos(this._urlFotoLoja, this._idAdm, this._idLoja, this._nomeLoja, this._idUsuario, this._pedidominino, this.bairro, this._latitude,
      this._longitude, this._idUsuarioComprador, this._mapaPagto, this._retirada, this._entrega, this._entregaDistancia, this._entregaPreco,
      this._distancialoja, this._descricao, this._ativaFone, this._ativaMail, this._ativaZap);
  _ListaprodutosState createState() => _ListaprodutosState();
}

class _ListaprodutosState extends State<Listaprodutos> {

  String _urlLoja;
  String _idUsuario;
  String _idLoja;
  String _nomeLoja;
  bool _produtoDisponivel;
  List produtos = List();
  bool _lendoprodutos = true;
  double _pedidominimo;
  String _idUsuarioLogado;
  MoneyFormatterOutput _pedidomin;
  MoneyFormatterOutput _precoDelivery;
  String _bairro;
  double _latitudeLoja;
  double _longitudeLoja;
  double _latitudeUser;
  double _longitudeUser;
  double distancia;
  String _idUsuarioComprador;
  bool _lendoDistancia = false;
  String distanciaAjustada;
  Map<String, dynamic> _mapaPagto;
  //List<String> _formaPagto = [];
  String _formaPagto = "Formas de pagamento: ";
  bool _retirada;
  bool _entrega;
  double _entregaDistancia;
  double _entregaPreco;
  String _msgFormaEntrega = "";
  double _precofinal;
  String _descricao;
  double _tambottom = 60.0;
  String _telefone;
  String _zap;
  String _email;
  bool _ativaFone;
  bool _ativaMail;
  bool _ativaZap;
  bool _favorito = false;
  bool _favorigem;
  Map<String, dynamic> _mapaFavoritos;
  List<String> _listaIdFavoritas = [];
  String _urlFotoPerfil;
  String _nome;

  _formaEntrega(){
    if(_entregaPreco != null && distancia != null){
       _precofinal = _entregaPreco * distancia;
    } else { _precofinal = 0.0;};

    _precoDelivery = FlutterMoneyFormatter(
        amount: _precofinal,
        settings: MoneyFormatterSettings(
            symbol: "R\$",
            decimalSeparator: ",",
            thousandSeparator: ".",
            fractionDigits: 2
        )
    ).output;
    String dist;
    if(_entregaDistancia != null){
      dist = _entregaDistancia.toStringAsPrecision(3);
    } else {dist = "0.0";}

    if(_retirada && _entrega && _precofinal > 0){
      _msgFormaEntrega = "Retirada e entrega (raio: $dist" + "Km - Preço da entrega: ${_precoDelivery.symbolOnLeft.toString()})";
    } else if (_retirada && _entrega && _precofinal == 0){
      _msgFormaEntrega = "Retirada e entrega (raio: $dist" + "Km - sem custo de entrega)";
    } else if (_retirada && !_entrega){
      _msgFormaEntrega = "Somente retirada";
    } else if(!_retirada && _entrega && _precofinal > 0){
      _msgFormaEntrega = "Somente entrega (raio: $dist" + "Km - Preço: ${_precoDelivery.symbolOnLeft.toString()})";
    } else if(!_retirada && _entrega && _precofinal==0) {
      _msgFormaEntrega = "Somente entrega (raio: $dist" + "Km - sem custo)";
    } else {
      _msgFormaEntrega = "Entrega: Combninar com o vendedor";
    }
  }

  _lerProdutos() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("lojas")
        .document(_idUsuario)
        .collection("lojasusuario")
        .document(_idLoja)
        .collection("produtos").getDocuments();
    for (DocumentSnapshot item in querySnapshot.documents){
      String _idDocumento = item.documentID;
      var dados = item.data;
      bool _produtoExiste = dados["existe"];
      if(_produtoExiste) {
        produtos.add(dados);
      }
    }

    setState(() {
      _lendoprodutos = false;
      return produtos;
    });
  }

  _paginaProduto(indice){
    _produtoDisponivel = produtos[indice]["disponivel"];
    if (_produtoDisponivel){
      Produto produtoescolhido = Produto();
      produtoescolhido.idProduto = produtos[indice]["id"];
      produtoescolhido.urlFotoProduto = produtos[indice]["urlfotoperfil"];
      produtoescolhido.nomeProduto = produtos[indice]["nome"];
      produtoescolhido.descricaoProduto = produtos[indice]["descricao"];
      produtoescolhido.precoProduto = produtos[indice]["preco"].toDouble();
      produtoescolhido.prazo = produtos[indice]["prazo"];
      produtoescolhido.idUsuario = _idUsuario;
      produtoescolhido.idLoja = _idLoja;
      produtoescolhido.quantidade = 0;
      produtoescolhido.retirada = _retirada;
      produtoescolhido.fazentrega = _entrega;
      produtoescolhido.valorminimo = _pedidominimo;
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Paginaproduto(produtoescolhido, true)));
    }
  }

  _lerDistancia(){
    Firestore db = Firestore.instance;
    Future<QuerySnapshot> query = db.collection("usuarios")
        .document(_idUsuarioComprador)
        .collection("enderecos")
        .where("nome", isEqualTo: "Principal").getDocuments().then((_dados){
      for (DocumentSnapshot dados in _dados.documents) {
        _latitudeUser = dados["latitude"];
        _longitudeUser = dados["longitude"];
        var p = 0.017453292519943295;
        var c = cos;
        var a = 0.5 - c((_latitudeLoja - _latitudeUser) * p)/2 +
            c(_latitudeUser * p) * c(_latitudeLoja * p) *
                (1 - c((_longitudeLoja - _longitudeUser) * p))/2;
        distancia = 12742 * asin(sqrt(a));
        setState(() {
          _lendoDistancia = false;
          distanciaAjustada = distancia.toStringAsPrecision(3);
        });
      }});
  }

  _lerFormasPagto(Map map){
    int indice = 1;
    String operador = ", ";
    for(String item in map.values) {
      //_formaPagto.insert(indice, item);
      if (indice == map.length){operador = ". ";}
      _formaPagto = _formaPagto + item.toString() + operador;
      indice = indice + 1;
    }
  }

  _verCarrinho() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Lercarrinho(_idUsuarioComprador)));
  }

  _checareMailFoneZap() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot documento = await db.collection("usuarios").document(_idUsuario).get();
    _telefone = documento["telefone"];
    _zap = documento["zap"];
    _email = documento["email"];
  }

  _enviareMail() async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: _email,
        queryParameters: {
          'subject': 'Dúvida sobre produtos'
        }
    );
    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      throw 'Não conseguiu acessar ${_emailLaunchUri.toString()}';
    }
  }

  _enviarZap() async {
    _telefone = "+55 " + _telefone;
    final link = WhatsAppUnilink(
      phoneNumber: _telefone,
      text: "Olá, tenho uma dúvida",
    );
    print(_telefone);
    // Convert the WhatsAppUnilink instance to a string.
    // Use either Dart's string interpolation or the toString() method.
    // The "launch" method is part of "url_launcher".
    await launch('$link');
  }

  _verificarFavorito() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot documentSnapshot = await db.collection("usuarios").document(_idUsuarioComprador).get();
    _mapaFavoritos = documentSnapshot["favoritos"];
    _mapaFavoritos == null ? _mapaFavoritos = {} : null;
    if(_mapaFavoritos.isNotEmpty){
      setState(() {
        _favorito = _mapaFavoritos.containsValue(_idLoja);
      });
    }
    _favorigem = _favorito;
  }

  _alterarFavorito() async {
    Firestore db = Firestore.instance;
    if(_favorito){
      _mapaFavoritos.removeWhere((key, value) => value == _idLoja);
      _favorito = false;
    } else {
      int indice = 0;
      for(String item in _mapaFavoritos.values){
        _listaIdFavoritas.add(item);
      }
      _listaIdFavoritas.add(_idLoja);
      for(String item in _listaIdFavoritas){
        print(item);
        String qualfavorito = "favorito" + indice.toString();
        _mapaFavoritos.putIfAbsent(qualfavorito, () => item);
        indice = indice + 1;
      }
      _favorito = true;
    }
    setState(() {
      _favorito;
    });
    await db.collection("usuarios")
        .document(_idUsuarioComprador)
        .updateData({"favoritos": _mapaFavoritos});
  }

  _checaUsuarioComprador() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot _doc = await db
        .collection("usuarios")
        .document(_idUsuarioComprador).get();
    _urlFotoPerfil = _doc["urlfotoperfil"];
    _nome = _doc["nome"];
  }

  _trocaMsg() {
    String _idLojaAlterado = _idLoja.substring(_idLoja.indexOf("_")+1)+"_";
    print(_idLojaAlterado);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => trocaMensagem(_urlLoja, _nomeLoja, _idUsuario, _idUsuarioComprador, _idLoja, _idLojaAlterado, _idUsuarioComprador)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _urlLoja = widget._urlFotoLoja;
    _idUsuario = widget._idAdm;
    _idLoja = widget._idLoja;
    _nomeLoja = widget._nomeLoja;
    _idUsuarioLogado = widget._idUsuario;
    _pedidominimo = widget._pedidominino;
    _bairro = widget.bairro;
    _latitudeLoja = widget._latitude;
    _longitudeLoja = widget._longitude;
    _idUsuarioComprador = widget._idUsuarioComprador;
    _retirada = widget._retirada;
    _entrega = widget._entrega;
    _descricao = widget._descricao;
    _ativaFone = widget._ativaFone;
    _ativaMail = widget._ativaMail;
    _ativaZap = widget._ativaZap;

    //APAGAR DEPOS
    if(_retirada == null){_retirada = false;}
    if(_entrega == null){_entrega = false;}

    _entregaDistancia = widget._entregaDistancia;
    _entregaPreco = widget._entregaPreco;
    distancia = widget._distancialoja;
    distanciaAjustada = distancia.toStringAsPrecision(3);

    if(_pedidominimo > 0){
       _pedidomin = FlutterMoneyFormatter(
          amount: _pedidominimo,
          settings: MoneyFormatterSettings(
              symbol: "R\$",
              decimalSeparator: ",",
              thousandSeparator: ".",
              fractionDigits: 2
          )
      ).output;
    }
    _mapaPagto = widget._mapaPagto;
    if(_mapaPagto != null){
      _lerFormasPagto(_mapaPagto);
    }
    //_lerDistancia();
    _checaUsuarioComprador();
    _checareMailFoneZap();
    _lerProdutos();
    _formaEntrega();
    _verificarFavorito();
  }

  _menuBottom(){
    return Container(
      color: Colors.white,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _trocaMsg,
                  child: Icon(
                    Icons.chat,
                    size: 30,
                    color: Colors.amber,
                  ),
                ),
                _telefone != null && _ativaFone
                    ? GestureDetector(
                onTap: (){final phoneCall = FlutterPhoneState.startPhoneCall(_telefone);},
                child: Icon(
                Icons.phone,
                size: 30,
                color: Colors.amber,),
                )
                    : Container(width: 0,),
                _email  != null && _ativaMail
                    ? GestureDetector(
                  onTap: _enviareMail,
                  child: Icon(
                    Icons.email,
                    size: 30,
                    color: Colors.amber,
                  ),
                )
                    : Container(width: 0,),
                _zap != null && _ativaZap
                    ? GestureDetector(
                  onTap: _enviarZap,
                  child: Image.asset(
                      "images/whatsapp.jpg",
                    width: 35,
                    height: 35,
                  )
                )
                    : Container(width: 0,),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*0.5;
    double c_width_topo = MediaQuery.of(context).size.width*0.9;
    Firestore db = Firestore.instance;
    var temcarrinho =  StreamBuilder(
      stream: db.collection("usuarios").document(_idUsuarioComprador).collection("carrinho").snapshots(),
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
            QuerySnapshot querySnapshot = snapshot.data;
            if(querySnapshot.documents.length == 0){
              return _menuBottom();
            }

            return SizedBox(
                height: 100,
                child: Container(
                  height: 40,
                  color: Colors.orange,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Card(
                          elevation: 0,
                          color: Colors.orange,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Icon(Icons.shopping_basket),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Text(
                                  "Cesta de compras",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: _verCarrinho,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 0),
                        child: _menuBottom(),
                      )
                    ],
                  )

                )
            );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
            if(_favorito != _favorigem){
              Navigator.pop(context);
              Navigator.pushNamed(context, "/home", arguments: _idUsuarioComprador);
            }
          },
          child: Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Image(
          image: NetworkImage(_urlLoja),
          fit: BoxFit.cover,

        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _nomeLoja,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: _alterarFavorito,
                                child: _favorito ? Icon(Icons.favorite, size: 40, color: Colors.amber,) : Icon(Icons.favorite_border, size: 40, color: Colors.amber,),
                              )
                          )
                        ],
                      ),

                      Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Container(
                            width: c_width_topo,
                            child: Text(
                              _descricao,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          )
                      ),
                      _lendoDistancia
                          ? Column(children: <Widget>[
                        Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),)],)
                          : Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          _bairro + " - " + distanciaAjustada + " Km",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Container(
                            width: c_width_topo,
                            child: Text(
                              _msgFormaEntrega,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          )
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Container(
                          width: c_width_topo,
                          child: Text(
                            _formaPagto,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        )
                      ),
                      _pedidominimo > 0
                      ? Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Pedido mínimo: ${_pedidomin.symbolOnLeft.toString()}",
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black
                          ),
                        ),
                      )
                          : Container()
                    ],
                  )
              ),
              Container(
                  child: _lendoprodutos
                      ? Column(children: <Widget>[
                    Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),)
                  ],)
                      : Container(height: 0,)
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: produtos.length,
                      itemBuilder: (context, indice){
                        String nomeProduto = produtos[indice]["nome"];
                        var precoProduto = produtos[indice]["preco"].toDouble();
                        MoneyFormatterOutput _preco = FlutterMoneyFormatter(
                            amount: precoProduto,
                            settings: MoneyFormatterSettings(
                                symbol: "R\$",
                                decimalSeparator: ",",
                                thousandSeparator: ".",
                                fractionDigits: 2
                            )
                        ).output;
                        String urlFotoProduto = produtos[indice]["urlfotoperfil"];
                        bool disponivel = produtos[indice]["disponivel"];
                        return GestureDetector(
                            onTap: (){
                              _paginaProduto(indice);
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                              child: Card(
                                color: Colors.transparent,
                                elevation: 0,
                                borderOnForeground: false,
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
                                              nomeProduto,
                                              softWrap: true,
                                              style: TextStyle(
                                                  fontSize: 15),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8, left: 8),
                                          child: Text(
                                            _preco.symbolOnLeft.toString(),
                                            style: TextStyle(
                                                fontSize: 14),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                        disponivel == false
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
                                              child: urlFotoProduto != null
                                                  ? Image.network(
                                                urlFotoProduto, loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
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
                            )
                        );
                      }
                  )
              )
            ],
          ), ),
        bottomNavigationBar: temcarrinho
    );
  }
}
