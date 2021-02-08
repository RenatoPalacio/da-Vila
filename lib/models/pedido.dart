class Pedido {

  //String idLoja;
  String idProduto;
  int quantidade;
  double valorPedido;
  String obsProduto;
  String idComprador;
  String nomeComprador;
  String urlFotoPerfilComprador;
  String idPedido;
  String statusPedido;
  String obsPedido;
  String url;
  String nomeProduto;
  double latitude;
  double longitude;
  String endereco;
  String delivery;

  Pedido();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "Produto": this.idProduto,
      "Quantidade": this.quantidade,
      "Valor": this.valorPedido,
      "ObsProduto": this.obsProduto,
      "Comprador": this.idComprador,
      "NomeComprador" : this.nomeComprador,
      "urlPerfilComprador" : this.urlFotoPerfilComprador,
      "Pedido": this.idPedido,
      "Status": this.statusPedido,
      "ObsPedido": this.obsPedido,
      "URL" : this.url,
      "Nome" : this.nomeProduto,
      "latitude" : this.latitude,
      "longitude" : this.longitude,
      "endereco" : this.endereco,
      "delivery" : this.delivery,
    };
    return map;
  }
}