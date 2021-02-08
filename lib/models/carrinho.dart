class Carrinho{

  String Loja;
  String idProduto;
  int quantidade;
  double valor;
  String obs;
  String admLoja;
  String urlFotoProduto;
  String nomeProduto;
  String endereco;
  bool fazentrega;
  bool retirada;
  double valorminimo;

  Carrinho();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "idLoja" : this.Loja,
      "idProduto" : this.idProduto,
      "quantidade" : this.quantidade,
      "valor" : this.valor,
      "observacao" : this.obs,
      "admLoja" : this.admLoja,
      "url" : this.urlFotoProduto,
      "nome" : this.nomeProduto,
      "fazentrega" : this.fazentrega,
      "retirada" : this.retirada,
      "valorminimo" : this.valorminimo,
    };
    return map;
  }
}