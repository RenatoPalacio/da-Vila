class Entregador {
  String idUsuario;
  String nome;
  String telefone;
  String urlFotoPerfil;
  bool ativo;
  bool entregando;
  String coletivo;

  Entregador();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "nome" : this.nome,
      "telefone" : this.telefone,
      "urlfotoperfil" : this.urlFotoPerfil,
      "ativo" : this.ativo,
      "entregando" : this.entregando,
      "coletivo" : this.coletivo
    };
    return map;
  }

}