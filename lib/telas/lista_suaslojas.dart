import 'package:compradordodia/models/loja.dart';
import 'package:compradordodia/telas/add_loja.dart';
import 'package:compradordodia/telas/ler_pedidos_loja.dart';
import 'package:compradordodia/telas/lista_mensagens.dart';
import 'package:compradordodia/telas/lista_seusprodutos.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable_list_view/flutter_slidable_list_view.dart';

class Listasuaslojas extends StatefulWidget {
  @override
  _ListasuaslojasState createState() => _ListasuaslojasState();
}

class _ListasuaslojasState extends State<Listasuaslojas> {

  String _idUsuario;
  List<Loja> _lojasrecuperadas = List();
  List<Loja> _listadelojas;
  List<Loja> lojas = List();
  List<String> idDocumentos = List();
  Loja atualizaLoja = Loja();
  bool _lendolojas = true;
  String _nomeUsuario = "";
  int _qtdpedidos = 0;
  List<IconData> icones = [null, Icons.filter_1, Icons.filter_2, Icons.filter_3,
    Icons.filter_4, Icons.filter_5, Icons.filter_6, Icons.filter_7,
    Icons.filter_8, Icons.filter_9, Icons.filter_9_plus, Icons.format_list_numbered];
  String _nomeLoja;
  String _idLoja;
  bool _tempedido;
  String _urlLoja;

  _adicionaGrupo(){
    atualizaLoja = Loja();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => addLoja(true, atualizaLoja: atualizaLoja,)));
  }

  Future<List<Loja>> _lerlojas() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario = _usuario.uid;
    Firestore db = Firestore.instance;
    DocumentSnapshot _doc = await db
        .collection("usuarios")
        .document(_idUsuario).get();
    setState(() {
      _nomeUsuario = _doc["nome"];
    });
  }

  _apagar(indice) async {
    String _idLoja = idDocumentos[indice];
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
                        _removerLoja(_idLoja);
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

  _removerLoja(_idLoja) async {
    Firestore db = Firestore.instance;
    Map<String, dynamic> _existe = {
      "existe": false
    };
    await db.collection("lojas").document(_idUsuario).collection("lojasusuario").document(_idLoja).updateData(_existe);
  }
  
  _atualizaObjeto(indice){
    atualizaLoja.id = lojas[indice].id;
    atualizaLoja.urlFotoPerfil = lojas[indice].urlFotoPerfil;
    atualizaLoja.nome = lojas[indice].nome;
    atualizaLoja.descricao = lojas[indice].descricao;
    atualizaLoja.cep = lojas[indice].cep;
    atualizaLoja.endereco = lojas[indice].endereco;
    atualizaLoja.numero = lojas[indice].numero;
    atualizaLoja.complemento = lojas[indice].complemento;
    atualizaLoja.bairro = lojas[indice].bairro;
    atualizaLoja.cidade = lojas[indice].cidade;
    atualizaLoja.uf = lojas[indice].uf;
    atualizaLoja.categoria1 = lojas[indice].categoria1;
    atualizaLoja.categoria2 = lojas[indice].categoria2;
    atualizaLoja.categoria3 = lojas[indice].categoria3;
    atualizaLoja.longitude = lojas[indice].longitude;
    atualizaLoja.latitude = lojas[indice].latitude;
    atualizaLoja.pedidosnovos = lojas[indice].pedidosnovos;
    atualizaLoja.qtdpedidos = lojas[indice].qtdpedidos;
    atualizaLoja.tempedido = lojas[indice].tempedido;
    atualizaLoja.valorminimo = lojas[indice].valorminimo;
    atualizaLoja.distancia = lojas[indice].distancia;
    atualizaLoja.mapPagto = lojas[indice].mapPagto;
    atualizaLoja.precokmdelivery = lojas[indice].precokmdelivery;
    atualizaLoja.retirada = lojas[indice].retirada;
    atualizaLoja.entrega = lojas[indice].entrega;
    atualizaLoja.ativaFone = lojas[indice].ativaFone;
    atualizaLoja.ativaMail = lojas[indice].ativaMail;
    atualizaLoja.ativaZap = lojas[indice].ativaZap;
  }

  _configurar(indice){
    _atualizaObjeto(indice);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => addLoja(false, atualizaLoja: atualizaLoja,)));
  }

  _produtosLoja(loja, indice){
    _atualizaObjeto(indice);
    String lojaID = loja.id;
    String nomeLoja = loja.nome;
    String usuario = _idUsuario;
    String url = loja.urlFotoPerfil;
    bool lojaativa = loja.lojaativa;
    double distancia = loja.distancia;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Produtosloja(lojaID, nomeLoja, usuario, url, lojaativa, distancia, loja: atualizaLoja)));
  }

  _detalhePedido(){
    Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => LerProdutoPedido(_nomeLoja, _idUsuario, _idLoja)));
  }

  __listaMsgs(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => listaMsgs(_nomeLoja, _idUsuario)));
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerlojas();
  }

  @override
  Widget build(BuildContext context) {
    Firestore db = Firestore.instance;

    var stream = StreamBuilder(
        stream:  db.collection("lojas").document(_idUsuario).collection("lojasusuario").snapshots(),
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
                    lojas.clear();
                    idDocumentos.clear();
                    QuerySnapshot querySnapshot = snapshot.data;
                    for (DocumentSnapshot item in querySnapshot.documents){
                      var dados = item.data;
                      String _idLoja = item.documentID;
                      Loja loja = Loja();
                      bool _lojaExiste = dados["existe"];
                      if(_lojaExiste){
                        loja.id = _idLoja;
                        String _nomelojaabrevidado = dados["nome"];
                        if (_nomelojaabrevidado.length > 20){
                          loja.nome = _nomelojaabrevidado.substring(0,17) + "...";
                        } else {
                          loja.nome = dados["nome"];
                        }

                        loja.descricao = dados["descricao"];
                        loja.urlFotoPerfil = dados["urlfotoperfil"];
                        loja.cep = dados["cep"];
                        loja.endereco  = dados["endereco"];
                        loja.numero = dados["numero"];
                        loja.complemento = dados["complemento"];
                        loja.bairro = dados["bairro"];
                        loja.cidade = dados["cidade"];
                        loja.uf = dados["uf"];
                        loja.lojaativa = dados["ativo"];
                        loja.qtdpedidos = dados["pedidosnovos"];
                        loja.tempedido = dados["tempedido"];
                        loja.categoria1 = dados["categoria1"];
                        loja.categoria2 = dados["categoria2"];
                        loja.categoria3 = dados["categoria3"];
                        loja.latitude  = dados["latitude"];
                        loja.longitude  = dados["longitude"];
                        loja.tempedido = dados["tempedido"];
                        loja.valorminimo = dados["valorminimo"];
                        loja.qtdpedidos = dados["qtdpedidos"];
                        loja.pedidosnovos = dados["pedidosnovos"];
                        loja.distancia = dados["distancia"];
                        loja.mapPagto = dados["mapPagto"];
                        loja.precokmdelivery = dados["precokmdelivery"];
                        loja.retirada = dados["retirada"];
                        loja.entrega = dados["fazentrega"];
                        loja.ativaFone = dados["ativaFone"];
                        loja.ativaMail = dados["ativaMail"];
                        loja.ativaZap = dados["ativaZap"];

                        lojas.add(loja);
                        idDocumentos.add(loja.id );
                      }
                    }
                    return Expanded(
                      child: SlideListView(
                        padding: EdgeInsets.all(16),
                        itemBuilder: (bc , indice){
                          Loja loja = lojas[indice];
                          int icone = loja.pedidosnovos;
                          bool _tempedido = loja.tempedido;
                          if(icone == 0 && _tempedido){
                            icone = 11;
                          }
                          return GestureDetector(
                              onTap: (){
                                _produtosLoja(loja, indice);
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  borderOnForeground: false,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                  maxRadius: 30,
                                                  backgroundColor: Colors.amberAccent,
                                                  backgroundImage: loja.urlFotoPerfil != null
                                                      ? NetworkImage(loja.urlFotoPerfil)
                                                      : null),
                                              Padding(padding:
                                              EdgeInsets.only(left: 24),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      loja.nome,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    ! loja.lojaativa
                                                        ? Text(
                                                      "Inativa",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.red,
                                                          fontSize: 16),
                                                      textAlign: TextAlign.start,
                                                    )
                                                        : Container(),
                                                  ],
                                                )
                                              )
                                            ],
                                          )
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                              onTap: (){
                                                _idLoja = loja.id;
                                                _nomeLoja = loja.nome;
                                                _urlLoja = loja.urlFotoPerfil;
                                                __listaMsgs();
                                              },
                                              child: Icon(Icons.chat_outlined)
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 16),
                                            child: GestureDetector(
                                                onTap: (){
                                                  _idLoja = loja.id;
                                                  _nomeLoja = loja.nome;
                                                  _detalhePedido();
                                                },
                                                child: Icon(icones[icone])
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              )
                          );
                        },
                        dataList: lojas,
                        actionWidgetDelegate: ActionWidgetDelegate(2, (actionIndex, listIndex) {
                          if (actionIndex == 0) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[Icon(Icons.delete), Text('apagar')],
                            );
                          } else {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                listIndex > 5 ? Icon(Icons.edit) : Icon(Icons.edit),
                                Text('configurar')
                              ],
                            );
                          }
                        }, (int indexInList, int index, BaseSlideItem item) {
                          if (index == 0) {
                            item.close();
                            _apagar(indexInList);
                          } else {
                            item.close();
                            _configurar(indexInList);
                          }
                        }, [Colors.redAccent, Colors.blueAccent]),
                      ),
                    );
          }
        }
        );
    int _tamanhoNome = _nomeUsuario.length;
    if (_tamanhoNome > 20){
      _tamanhoNome = 20;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Lojas de ${_nomeUsuario.substring(0,_tamanhoNome)}")
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          onPressed: _adicionaGrupo
      ),
      body: SafeArea(
          child: Container(
              child: Column(
                children: <Widget>[
                  stream,
                ],
              )
          ))
    );
  }
}
