
class Loja {
  String _id;
  String _idDocumento;
  String _nome;
  String _adm;
  String _descricao;
  String _urlFotoPerfil;
  String _cep;
  String _endereco;
  String _uf;
  String _cidade;
  String _numero;
  String _complemento;
  bool _lojaativa = true;
  bool _lojaexistente = true;
  int _qtdpedidos = 0;
  int _pedidosnovos = 0;
  bool _tempedido = false;
  String _categoria1;
  String _categoria2;
  String _categoria3;
  double _latitude;
  double _longitude;
  double _valorminimo = 0.0;
  double _distancia = 0.0;
  String _bairro;
  Map<String, dynamic> _mapPagto;
  double _precokmdelivery = 0.0;
  bool _retirada;
  bool _entrega;
  bool _ativaFone;
  bool _ativaMail;
  bool _ativaZap;

  Loja();

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get idDocumento => _idDocumento;

  set idDocumento(String value) {
    _idDocumento = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get adm => _adm;

  set adm(String value) {
    _adm = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get urlFotoPerfil => _urlFotoPerfil;

  set urlFotoPerfil(String value) {
    _urlFotoPerfil = value;
  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  String get endereco => _endereco;

  set endereco(String value) {
    _endereco = value;
  }

  String get uf => _uf;

  set uf(String value) {
    _uf = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get complemento => _complemento;

  set complemento(String value) {
    _complemento = value;
  }

  bool get lojaativa => _lojaativa;

  set lojaativa(bool value) {
    _lojaativa = value;
  }

  bool get lojaexistente => _lojaexistente;

  set lojaexistente(bool value) {
    _lojaexistente = value;
  }

  int get pedidosnovos => _pedidosnovos;

  set pedidosnovos(int value) {
    _pedidosnovos = value;
  }

  int get qtdpedidos => _qtdpedidos;

  set qtdpedidos(int value) {
    _qtdpedidos = value;
  }

  bool get tempedido => _tempedido;

  set tempedido(bool value) {
    _tempedido = value;
  }

  String get categoria1 => _categoria1;

  set categoria1(String value) {
    _categoria1 = value;
  }

  String get categoria2 => _categoria2;

  set categoria2(String value) {
    _categoria2 = value;
  }

  String get categoria3 => _categoria3;

  set categoria3(String value) {
    _categoria3 = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }


  double get valorminimo => _valorminimo;

  set valorminimo(double value) {
    _valorminimo = value;
  }


  double get distancia => _distancia;

  set distancia(double value) {
    _distancia = value;
  }


  String get bairro => _bairro;

  set bairro(String value) {
    _bairro = value;
  }

  Map<String, dynamic> get mapPagto => _mapPagto;

  set mapPagto(Map<String, dynamic> value) {
    _mapPagto = value;
  }


  double get precokmdelivery => _precokmdelivery;

  set precokmdelivery(double value) {
    _precokmdelivery = value;
  }

  bool get entrega => _entrega;

  set entrega(bool value) {
    _entrega = value;
  }


  bool get ativaFone => _ativaFone;

  set ativaFone(bool value) {
    _ativaFone = value;
  }

  bool get retirada => _retirada;

  set retirada(bool value) {
    _retirada = value;
  }

  bool get ativaMail => _ativaMail;

  set ativaMail(bool value) {
    _ativaMail = value;
  }

  bool get ativaZap => _ativaZap;

  set ativaZap(bool value) {
    _ativaZap = value;
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "id" : this.id,
      "nome" : this.nome,
      "adm" : this.adm,
      "descricao" : this.descricao,
      //"urlfotoperfil" : this.urlFotoPerfil,
      "cep" : this.cep,
      "endereco" : this.endereco,
      "uf" : this.uf,
      "cidade" : this.cidade,
      "numero" : this.numero,
      "complemento" : this.complemento,
      "ativo" : this.lojaativa,
      "existe" : this.lojaexistente,
      "qtdpedidos" : this.qtdpedidos,
      "pedidosnovos" : this.pedidosnovos,
      "tempedido" : this.tempedido,
      "categoria1" : this.categoria1,
      "categoria2" : this.categoria2,
      "categoria3" : this.categoria3,
      "latitude" : this.latitude,
      "longitude" : this.longitude,
      "valorminimo" : this.valorminimo,
      "distancia" : this.distancia,
      "bairro" : this.bairro,
      "mapPagto" : this.mapPagto,
      "precokmdelivery" : this.precokmdelivery,
      "retirada" : this.retirada,
      "fazentrega" : this.entrega,
      "ativaFone" : this.ativaFone,
      "ativaMail" : this.ativaMail,
      "ativaZap" : this.ativaZap,
    };
    return map;
  }


}