import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem {

  String mensagem;
  String urlImagem;
  String idRemetente;
  String tipo;
  Timestamp data;

  Mensagem();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "mensagem": this.mensagem,
      "urlImagem": this.urlImagem,
      "idRemetente" : this.idRemetente,
      "tipo": this.tipo,
      "data" : this.data,
    };
    return map;
  }
}