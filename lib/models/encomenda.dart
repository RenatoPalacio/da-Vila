class Encomenda {
  String idUsuario;
  String idDocumentoPedido;
  String urlLoja;
  String nomeLoja;
  String dataPedido;
  double valorPedido;
  int quantidadeProdutos;
  String statusPedido;
  String entrega;

  Encomenda();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "DocPedido": this.idDocumentoPedido,
      "URL": this.urlLoja,
      "Nome": this.nomeLoja,
      "Data": this.dataPedido,
      "Valor": this.valorPedido,
      "Quantidade": this.quantidadeProdutos,
      "Status" : this.statusPedido,
      "Entrega" : this.entrega,
    };
    return map;
  }

}