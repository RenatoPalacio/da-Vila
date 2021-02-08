class Produto{

  String tipoProduto;
  String idProduto;
  String idLoja;
  String idUsuario;
  String urlFotoProduto;
  String nomeProduto;
  String descricaoProduto;
  double precoProduto;
  String prazo;
  int quantidade;
  String observacao;
  String idProdutonoCarrinho;
  bool disponivel;
  bool existe;
  bool retirada;
  bool fazentrega;
  double valorminimo;

  Produto();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "id" : this.idProduto,
      "nome" : this.nomeProduto,
      "descricao" : this.descricaoProduto,
      //"urlfotoperfil" : this.urlFotoProduto,
      "preco" : this.precoProduto,
      "disponivel" : this.disponivel,
      "existe" : true,
      "prazo" : this.prazo,
      "idLoja": this.idLoja,
      "adm" : this.idUsuario,
      "retirada" : this.retirada,
      "fazentrega" : this.fazentrega,
      "valorminimo" : this.valorminimo,
    };
    return map;
  }
}