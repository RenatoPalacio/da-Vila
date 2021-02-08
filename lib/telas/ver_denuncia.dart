import 'dart:io';
import 'package:compradordodia/models/denuncia.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:compradordodia/widgets/inputcustomizado.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:validadores/Validador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class verDenuncia extends StatefulWidget {
  Denuncia denuncia = Denuncia();
  verDenuncia(this.denuncia);
  @override
  _verDenunciaState createState() => _verDenunciaState();
}

class _verDenunciaState extends State<verDenuncia> {

  Denuncia denuncia = Denuncia();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    denuncia = widget.denuncia;
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*1;
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes de denúncia"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: c_width,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ticket #" + denuncia.ticket,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  "Data da denúncia: " + denuncia.data,
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  denuncia.descricao,
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 24),
                child:
                  denuncia.url1 != null
                    ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Text(
                  "Anexos: ",
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16, left: 16),
                            child: SizedBox(
                              height: 270,
                              width: 120,
                              child: Image.network(
                                denuncia.url1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16, right: 16),
                            child:
                              denuncia.url2 != null
                                  ? SizedBox(
                                height: 270,
                                width: 120,
                                child: Image.network(
                                  denuncia.url2,
                                ),
                              )
                                  : null
                          ),
                        ],
                      )
                    ],
                  )
                      : null
              ),
            ],
          ),
        ),
      ),
    );
  }
}
