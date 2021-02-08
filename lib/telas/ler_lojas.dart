
import 'dart:math';
import 'package:compradordodia/models/categorias.dart';
import 'package:compradordodia/models/mostracarrinho.dart';
import 'package:compradordodia/telas/ler_produtos.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Listalojas extends StatefulWidget {
  @override
  _ListalojasState createState() => _ListalojasState();
}

class _ListalojasState extends State<Listalojas> {

  bool _lendolojas;
  String _idUsuario;
  List lojas = List();
  List ids = List();
  List<DropdownMenuItem<String>> _listaCategorias = List();
  String _filtroCategoria;
  double _scoreLoja;
  int _lojausuario = 0;
  bool _dousuario = false;
  double _distancia = 30.0;
  String _ordenar;
  int _modoEntrega;
  List<String> _formaPagamento = [];
  double _latitudeUser;
  double _longitudeUser;
  int _indice = 0;
  Map<String, dynamic> _mapaFavoritos;
  List<String> _listaIdFavoritas = [];

  Future<List> _lerlojas() async {
    _lendolojas = true;
    Firestore db = Firestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario = _usuario.uid;
    //Verifica Lat e Long do Usuario
    Future<QuerySnapshot> query = db.collection("usuarios")
        .document(_idUsuario)
        .collection("enderecos")
        .where("nome", isEqualTo: "Principal").getDocuments().then((_dados){
      for (DocumentSnapshot dados in _dados.documents) {
        _latitudeUser = dados["latitude"];
        _longitudeUser = dados["longitude"];
      }});

    //Ler lojas
    QuerySnapshot _docsUsuario = await db.collection("lojas").getDocuments();
    for (DocumentSnapshot itemDoc in _docsUsuario.documents){
      if(itemDoc.documentID == _idUsuario){
        _dousuario = true;
      } else {_dousuario = false;};
      String _idDocumento = itemDoc.documentID;
      QuerySnapshot _docsLojasUsuario = await db.collection("lojas").document(_idDocumento).collection("lojasusuario").getDocuments();
      for (DocumentSnapshot itemLoja in _docsLojasUsuario.documents){
        bool _existe = itemLoja["existe"];
        bool _ativa = itemLoja["ativo"];

        bool _entrega =  itemLoja["fazentrega"];
        if(_entrega == null){_entrega = true;};
        bool _retirada =  itemLoja["retirada"];
        if(_retirada == null){_retirada = true;};

        Map<String, dynamic> pagtos = itemLoja["mapPagto"];
        if(pagtos == null){

          pagtos = {"FormaPagto6": "Dinheiro", "FormaPagto7": "Master Débito", "FormaPagto4": "PayPal",
          "FormaPagto10": "Mercado Pago", "FormaPagto5": "Master Crédito", "FormaPagto8": "VR/TR", "FormaPagto9": "Hipercard",
          "FormaPagto2": "Elo", "FormaPagto3": "Visa Crédito", "FormaPagto0": "Transferência", "FormaPagto1": "Visa Débito"};

        //pagtos = {"FormaPagto0": "Transferência", "FormaPagto6": "Dinheiro"};
        };

        if (_existe && _ativa){
          String idloja = itemLoja.documentID;
          var dados = itemLoja.data;

          if(_filtroCategoria != null ){
            String _categoria1 = itemLoja["categoria1"];
            String _categoria2 = itemLoja["categoria2"];
            String _categoria3 = itemLoja["categoria3"];
            if(_categoria1 != _filtroCategoria && _categoria2 != _filtroCategoria && _categoria3 != _filtroCategoria ){
              continue;
            }
          }

          if(_modoEntrega == 0 && !_entrega){
            continue;
          } else if (_modoEntrega == 1 && !_retirada){
            continue;
          }

          double _latitudeLoja = itemLoja["latitude"];
          double _longitudeLoja = itemLoja["longitude"];
          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 - c((_latitudeLoja - _latitudeUser) * p)/2 +
              c(_latitudeUser * p) * c(_latitudeLoja * p) *
                  (1 - c((_longitudeLoja - _longitudeUser) * p))/2;
          double distancia = 12742 * asin(sqrt(a));
          if(distancia > _distancia){
            continue;
          }

          bool contem = false;
          for(String item in _formaPagamento){
            contem = pagtos.containsValue(item);
            if (contem){
              break;
            }
          }
          if(!contem){
            continue;
          }

          dados.putIfAbsent("dosUsuario", () => _dousuario.toString());
          dados.putIfAbsent("distancialoja", () => distancia);

          //dados["distancia"] = distancia;
          dados["id"] = idloja;

          if(dados["score"] == null || dados["score"] == 0) {
            dados.putIfAbsent("scorefinal", () => 0.0);
          } else {
            dados.putIfAbsent("scorefinal", () => dados["score"]/dados["totalQualificacoes"]);
          }
          lojas.add(dados);
        }
      }
    }

    //
    int indice = 0;
    for(Map item in lojas){
      String _lojafavorita = item["id"];
      bool contem = _listaIdFavoritas.contains(_lojafavorita);
      if(contem){
        item.putIfAbsent("favorito", () => 1);
      } else {
        item.putIfAbsent("favorito", () => 2);
      }
      lojas.remove(item);
      lojas.insert(indice, item);
      indice = indice + 1;
    }

    if (_ordenar == null){
      _ordenar = "dosUsuario";
    }
    if (_ordenar != "distancialoja" && _ordenar != "favorito"){
      lojas.sort((b,a) => a[_ordenar].compareTo(b[_ordenar]));
    }  else{
      lojas.sort((a,b) => a[_ordenar].compareTo(b[_ordenar]));
    }
    setState(() {
      _lendolojas = false;
    });
  }

  _produtosLoja(indice){
    String idAdm = lojas[indice]["adm"];
    String nomeLoja = lojas[indice]["nome"];
    String urlFotoLoja = lojas[indice]["urlfotoperfil"];
    double minimo = lojas[indice]["valorminimo"];
    String bairro = lojas[indice]["bairro"];
    double latitude = lojas[indice]["latitude"];
    double longitude = lojas[indice]["longitude"];
    bool retirada = lojas[indice]["retirada"];
    bool entrega = lojas[indice]["fazentrega"];
    double entregadistancia = lojas[indice]["distancia"];
    double distancialoja = lojas[indice]["distancialoja"];
    double entregapreco = lojas[indice]["precokmdelivery"];
    String descricao = lojas[indice]["descricao"];
    bool _ativaFone = lojas[indice]["ativaFone"];
    _ativaFone == null ? _ativaFone = false : null;
    bool _ativaMail = lojas[indice]["ativaMail"];
    _ativaMail == null ? _ativaMail = false : null;
    bool _ativaZap = lojas[indice]["ativaZap"];
    _ativaZap == null ? _ativaZap = false : null;
    String idUsuarioDono = _idUsuario;

    Map<String, dynamic> mapPagto = lojas[indice]["mapPagto"];
    String idLoja = lojas[indice]["id"];

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Listaprodutos(urlFotoLoja, idAdm, idLoja, nomeLoja, idUsuarioDono, minimo, bairro, latitude, longitude,
            _idUsuario, mapPagto, retirada, entrega, entregadistancia, entregapreco, distancialoja, descricao, _ativaFone, _ativaMail, _ativaZap)));
  }

  //CARREGA DROPDOWN CATEGORIA
  _carregaListaCategorias(){
    _listaCategorias = Categorias.getCategorias();
  }

  _defineFiltros(){
    Navigator.pushNamed(context, "/filtros", arguments: _idUsuario);
  }

  _recuperarFiltros() async {
    final filtros =  await SharedPreferences.getInstance();
    _distancia = filtros.getDouble("distancia");
    _distancia == null ? _distancia = 30.0 : null;

    _formaPagamento = filtros.getStringList("formapagamento");
    if(_formaPagamento == null || _formaPagamento.isEmpty){
      _formaPagamento = ["Dinheiro", "Master Débito",  "PayPal",
        "Mercado Pago", "Master Crédito", "VR/TR", "Hipercard",
        "Elo", "Visa Crédito",  "Transferência",  "Visa Débito"];
    }

    _modoEntrega = filtros.getInt("entrega");
    _modoEntrega == null ? _modoEntrega = 2 : null;

    _ordenar = filtros.getString("ordenar");
    _ordenar == null ? _ordenar = "dosUsuario" : null;
  }

  _verificarFavorito() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario = _usuario.uid;
    Firestore db = Firestore.instance;
    print("idusuario: $_idUsuario");
    DocumentSnapshot documentSnapshot = await db.collection("usuarios").document(_idUsuario).get();
    _mapaFavoritos = documentSnapshot["favoritos"];
    if (_mapaFavoritos == null){
      _mapaFavoritos = {};
    }
    if(_mapaFavoritos != null || _mapaFavoritos.isNotEmpty){
      for(String item in _mapaFavoritos.values){
        _listaIdFavoritas.add(item);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarFiltros();
    _lerlojas();
    _carregaListaCategorias();
    _verificarFavorito();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ! _lendolojas
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 3, 0, 0),
                    child: DropdownButton(
                        iconEnabledColor: Colors.black,
                        items: _listaCategorias,
                        value: _filtroCategoria,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                        onChanged: (categoria){
                          setState(() {
                            _filtroCategoria = categoria;
                          });
                          ids.clear();
                          lojas.clear();
                          _lerlojas();
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      child: Icon(
                        Icons.filter_list,
                        color: Colors.deepOrange,
                        size: 30,
                      ),
                      onTap: _defineFiltros,
                    ),
                  )
                ],
              )
              : Container(),
              Expanded(
                  child:
                  lojas.length > 0
                      ? ListView.builder(
                      itemCount: lojas.length,
                      itemBuilder: (context, indice){
                        String _urlFotoLoja = lojas[indice]["urlfotoperfil"];
                        String _nomeLoja = lojas[indice]["nome"];
                        if(_nomeLoja.length > 20){
                          _nomeLoja = _nomeLoja.substring(0,19) + "...";
                        }
                        int _score = lojas[indice]["score"];
                        int _qtd = lojas[indice]["totalQualificacoes"];
                        if (_score == null) {
                          _score = 0;
                          _qtd = 0;
                        }
                        if (_score > 0){
                          _scoreLoja = _score/_qtd;
                        }else {_scoreLoja = 0;}
                        bool _dousuario = false;
                        if (_idUsuario == lojas[indice]["adm"]){
                          _dousuario = true;
                        }
                        bool _fav = false;
                        lojas[indice]["favorito"] != null
                            ? lojas[indice]["favorito"]  == 1 ? _fav = true : null
                            : null;

                        return GestureDetector(
                            onTap: (){
                              _produtosLoja(indice);
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                              child: Card(
                                color: Colors.transparent,
                                elevation: 0,
                                borderOnForeground: false,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child:CircleAvatar(
                                              maxRadius: 30,
                                              backgroundColor: Colors.amberAccent,
                                              backgroundImage: _urlFotoLoja != null
                                                  ? NetworkImage(_urlFotoLoja)
                                                  : null),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  _nomeLoja,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18),
                                                  textAlign: TextAlign.start,
                                                ),
                                                _dousuario
                                                    ? Text(
                                                  "Sua Loja",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                )
                                                    : Container()
                                              ],
                                            )
                                        ),
                                      ],
                                    ),

                                    _scoreLoja > 0
                                        ? Row(
                                      children: [
                                        _fav
                                            ? Padding(padding: EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.favorite,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                        )
                                            : Container(),
                                        Padding(
                                            padding: EdgeInsets.only(left: 16, right: 8),
                                            child: Column(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.red,
                                                ),
                                                Text(
                                                  _scoreLoja.toString().substring(0,3),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.red
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ],
                                            )
                                        )
                                      ],
                                    )

                                        : _fav
                                        ? Padding(padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.favorite,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    )
                                        : Container(),
                                  ],
                                ),
                              ),
                            )
                        );
                      }
                  )
                      : _lendolojas
                      ? Container()
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Text(
                          "Nenhum resultado para pesquisa.",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      )
                  )
              )
            ],
          ),),
    );
  }
}

