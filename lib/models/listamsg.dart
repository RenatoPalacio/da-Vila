import 'package:cloud_firestore/cloud_firestore.dart';

class listaMsg {

  String mensagem;
  String url;
  String nome;
  String idUsuario;
  Timestamp data;
  String idLoja;
  String idComprador;
  String idVendedor;

  listaMsg();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "mensagem": this.mensagem,
      "url_foto": this.url,
      "nome" : this.nome,
      "data" : this.data,
      "idUsuario" : this.idUsuario,
      "idLoja" : this.idLoja,
      "idComprador" : this.idComprador,
      "idVendedor" : this.idVendedor,
    };
    return map;
  }
}