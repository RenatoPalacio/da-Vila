import 'package:compradordodia/models/mostracarrinho.dart';
import 'package:compradordodia/telas/encomendas.dart';
import 'package:compradordodia/telas/ler_carrinho_novo.dart';
import 'package:compradordodia/telas/ler_lojas.dart';
import 'package:compradordodia/telas/historico.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compradordodia/telas/lista_mensagens.dart';

class Home extends StatefulWidget {
  String idUsuario;
  Home(this.idUsuario);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String idUsuario;
  List<String> itensMenu = [
    "Minhas lojas", "Minhas mensagens",  "Editar perfil", "Quero fazer entregas", "Fazer denúncia", "Suas denúncias" , "Sair"
  ];
  Firestore db = Firestore.instance;
  bool _cesta = false;
  double _tamanhoBottomBar;
  String _nomeUsuario;

  _escolhaMenuItem(itemEscolhido){
    switch(itemEscolhido){
      case "Editar perfil" :
        _configura();
        break;
      case "Sair" :
        _logout();
        break;
      case "Minhas lojas" :
        _grupo();
        break;
      case "Quero fazer entregas" :
        _entregador();
        break;
      case  "Fazer denúncia" :
        _fazerdenuncia();
        break;
      case  "Suas denúncias" :
        _suadenuncia();
        break;
      case  "Minhas mensagens" :
        __listaMsgs();
        break;
    }
  }

  __listaMsgs(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => listaMsgs(_nomeUsuario, idUsuario, documento: "enviadas",)));
  }

  _configura(){
    Navigator.pushNamed(context, "/cadastro", arguments: false);
  }

  _logout() async {
    QuerySnapshot _limpacarrinho = await db.collection("usuarios").document(idUsuario).collection("carrinho").getDocuments();
    for(DocumentSnapshot item in _limpacarrinho.documents){
      String idItem = item.documentID;
      db.collection("usuarios").document(idUsuario).collection("carrinho").document(idItem).delete();
    }
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  _grupo(){
    Navigator.pushNamed(context, "/lista_suaslojas");
  }

  _entregador(){
    Navigator.pushNamed(context, "/novo_delivery");
  }

  _fazerdenuncia(){
    Navigator.pushNamed(context, "/denuncia");
  }

  _suadenuncia(){
    Navigator.pushNamed(context, "/suadenuncia");
  }

  _verCarrinho() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Lercarrinho(idUsuario)));
  }

  _checarNomeUsuario() async {
    DocumentSnapshot doc = await db.collection("usuarios").document(idUsuario).get();
    _nomeUsuario = doc["nome"];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    idUsuario = widget.idUsuario;
    _tabController = TabController(
        length: 3,
        vsync: this);
    _temCarrinho();
    _checarNomeUsuario();
  }

   _temCarrinho() async {
    QuerySnapshot querySnapshot = await db.collection("usuarios").document(idUsuario).collection("carrinho").getDocuments();
    if(querySnapshot.documents.length != 0){
      setState(() {
        _tamanhoBottomBar = 40.0;
        _cesta = true;
      });
    } else {
      _tamanhoBottomBar = 0.0;
      _cesta = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Da Vila"),
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: <Widget> [
            Tab(text: "Lojas"),
            Tab(text: "Encomendas"),
            Tab(text: "Histórico"),
          ]
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context){
                return itensMenu.map((String item){
                  return PopupMenuItem<String>(
                      value: item,
                      child: Text(item)
                  );
                }).toList();
              }
              )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Listalojas(),
          Encomendas(idUsuario),
          Historico(idUsuario),
        ],
      ),
      bottomNavigationBar: Mostracarrinho()
    );
  }
}
