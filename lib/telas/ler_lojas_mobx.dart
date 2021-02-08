import 'package:compradordodia/mobX/lerlojasMobx.dart';
import 'package:compradordodia/models/categorias.dart';
import 'package:compradordodia/telas/ler_produtos.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compradordodia/mobX/dadosMobx.dart';

class ListaLojasMobx extends StatelessWidget {

  bool _lendolojas;
  String _idUsuario;
  List lojas = List();
  List ids = List();
  List<DropdownMenuItem<String>> _listaCategorias = List();
  String _filtroCategoria;
  double _scoreLoja;
  int _lojausuario = 0;
  bool _dousuario = false;
  BuildContext context;
  final dadosmobx = dadosMobx();
  final lerlojasmobx = lerlojasMobx();



  _produtosLoja(indice){
    String idAdm = lojas[indice]["adm"];
    String nomeLoja = lojas[indice]["nome"];
    String idLoja = ids[indice];
    String urlFotoLoja = lojas[indice]["urlfotoperfil"];
    double minimo = lojas[indice]["valorminimo"];
    String bairro = lojas[indice]["bairro"];
    double latitude = lojas[indice]["latitude"];
    double longitude = lojas[indice]["longitude"];
    Map<String, dynamic> mapPagto = lojas[indice]["mapPagto"];
    String idUsuarioDono = _idUsuario;
    /*
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Listaprodutos(urlFotoLoja, idAdm, idLoja, nomeLoja, idUsuarioDono, minimo, bairro, latitude, longitude, _idUsuario, mapPagto )));
  */
  }


  //CARREGA DROPDOWN CATEGORIA
  _carregaListaCategorias(){
    _listaCategorias = Categorias.getCategorias();
  }

  _defineFiltros(){
    Navigator.pushNamed(context, "/filtros");
  }


  @override
  Widget build(BuildContext context)  {
    lerlojasmobx.loadStuff();
    _carregaListaCategorias();
    return Scaffold(
        body: SafeArea(
          child:
          lerlojasmobx.lendolojas
              ? Column(children: <Widget>[Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),), Text("Carregando ${lerlojasmobx.lendolojas}")],)
              : Column(
            children: <Widget>[
              Row(
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

                          _filtroCategoria = categoria;

                          ids.clear();
                          lojas.clear();
                          //_lerlojas();
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      child: Icon(
                        Icons.filter_list,
                        color: Colors.deepOrange,
                      ),
                      onTap: _defineFiltros,
                    ),
                  )
                ],
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: lerlojasmobx.lojas.length,
                      itemBuilder: (context, indice){
                        String _urlFotoLoja = lerlojasmobx.lojas[indice]["urlfotoperfil"];
                        String _nomeLoja = lerlojasmobx.lojas[indice]["nome"];
                        if(_nomeLoja.length > 20){
                          _nomeLoja = _nomeLoja.substring(0,19) + "...";
                        }
                        int _score = lerlojasmobx.lojas[indice]["score"];
                        int _qtd = lerlojasmobx.lojas[indice]["totalQualificacoes"];
                        if (_score == null) {
                          _score = 0;
                          _qtd = 0;
                        }
                        if (_score > 0){
                          _scoreLoja = _score/_qtd;
                        }else {_scoreLoja = 0;}
                        bool _dousuario = false;
                        if (_idUsuario == lerlojasmobx.lojas[indice]["adm"]){
                          _dousuario = true;
                        }

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
                                        ? Padding(
                                        padding: EdgeInsets.only(right: 8),
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
                                        : Container(),
                                  ],
                                ),
                              ),
                            )
                        );
                      }
                  )
              )
            ],
          )
        )
    );
  }
}


