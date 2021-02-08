import 'package:compradordodia/models/dadosdelivery.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:compradordodia/models/pedido.dart';
import 'package:compradordodia/telas/troca_mensagens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:date_format/date_format.dart';

class DetalhesDelivery extends StatefulWidget {
  DadosDelivery _dadosDelivery;
  DetalhesDelivery(this._dadosDelivery);
  @override
  _DetalhesDeliveryState createState() => _DetalhesDeliveryState();
}

class _DetalhesDeliveryState extends State<DetalhesDelivery> {
  String _idDelivery;
  DateTime _dataAgendada;
  DateTime _horaAgendada;
  String _urlFotoPerfil;
  String _nome;
  String _telefone;
  
  _dadosDelivery() async {
    print("id: $_idDelivery");
    Firestore db = Firestore.instance;
    DocumentSnapshot _docDelivery = await db
        .collection("usuarioDelivery")
        .document(_idDelivery).get();
    setState(() {
      _urlFotoPerfil = _docDelivery["urlfotperfil"];
      _nome = _docDelivery["nome"];
      _telefone = _docDelivery["telefone"];
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    _idDelivery = widget._dadosDelivery.idDelivery;
    _dataAgendada = widget._dadosDelivery.dia;
    _horaAgendada = widget._dadosDelivery.hora;
    _dadosDelivery();
  }
  
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*1;
    return Scaffold(
      appBar: AppBar(title: Text("Detalhes de $_nome"),),
      body: SafeArea(
        child: Container(
          width: c_width,
          child: Column(

          ),
        ),
      ),
    );
  }
}
