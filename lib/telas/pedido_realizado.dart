import 'dart:async';

import 'package:compradordodia/models/pedido.dart';
import 'package:compradordodia/models/produto.dart';
import 'package:compradordodia/telas/pagina_produto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';

class Pedidorealizado extends StatefulWidget {
  String _idUsuario;
  Pedidorealizado(this._idUsuario);
  @override
  _PedidorealizadoState createState() => _PedidorealizadoState();
}

class _PedidorealizadoState extends State<Pedidorealizado> {

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Timer(
        Duration(seconds: 3), (){
      String idUsuario = widget._idUsuario;
      Navigator.pushNamedAndRemoveUntil(
        context, "/home", (Route<dynamic> route) => false,
        arguments: idUsuario,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        color: Color.fromRGBO(27, 175, 80, 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.asset("images/cheque_verde.jpg",),
                  Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "Pedido realizado com sucesso!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      )
                  )
                ],
              ),

            ],
          ),

        ),
      ),
    );
  }
}
