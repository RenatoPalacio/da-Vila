class Delivery {

  String _nomeLoja;
  String _enderecoLoja;
  double _latitudeLoja;
  double _longitudeLoja;
  String _nomeVendedor;
  String _nomeComprador;
  String _enderecoComprador;
  double _latitudeComprador;
  double _longitudeComprador;
  DateTime _dataPedido;
  String _idUsuarioVendedor;
  String _idUsuarioComprador;
  String _idLoja;
  String _idPedido;
  String _status;
  DateTime _dataEntrega;
  double _valorPedido;
  int _quantidade;

  Delivery();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "loja": this.nomeLoja,
      "enderecço_loja": this.enderecoLoja,
      "latitude_loja": this.latitudeLoja,
      "longitude_loja": this.longitudeLoja,
      "nome_vendedor": this.nomeVendedor,
      "nome_comprador": this.nomeComprador,
      "endereco_comprador": this.enderecoComprador,
      "latitude_comprador": this.latitudeComprador,
      "longitude_comprador": this.longitudeComprador,
      "datapedido": this.dataPedido,
      "idVendedor": this.idUsuarioVendedor,
      "idComprador": this.idUsuarioComprador,
      "idLoja": this.idLoja,
      "idPedido": this.idPedido,
      "status" : this.status,
      "data_entrega" : this.dataEntrega,
      "valor_pedido" : this.valorPedido,
      "quantidade_itens" : this.quantidade,
    };
    return map;
  }

  String get nomeLoja => _nomeLoja;

  set nomeLoja(String value) {
    _nomeLoja = value;
  }


  String get enderecoLoja => _enderecoLoja;

  set enderecoLoja(String value) {
    _enderecoLoja = value;
  }

  double get latitudeLoja => _latitudeLoja;

  set latitudeLoja(double value) {
    _latitudeLoja = value;
  }

  double get longitudeLoja => _longitudeLoja;

  set longitudeLoja(double value) {
    _longitudeLoja = value;
  }

  String get nomeVendedor => _nomeVendedor;

  set nomeVendedor(String value) {
    _nomeVendedor = value;
  }

  String get nomeComprador => _nomeComprador;

  set nomeComprador(String value) {
    _nomeComprador = value;
  }

  String get enderecoComprador => _enderecoComprador;

  set enderecoComprador(String value) {
    _enderecoComprador = value;
  }

  double get latitudeComprador => _latitudeComprador;

  set latitudeComprador(double value) {
    _latitudeComprador = value;
  }

  double get longitudeComprador => _longitudeComprador;

  set longitudeComprador(double value) {
    _longitudeComprador = value;
  }

  DateTime get dataPedido => _dataPedido;

  set dataPedido(DateTime value) {
    _dataPedido = value;
  }

  String get idUsuarioVendedor => _idUsuarioVendedor;

  set idUsuarioVendedor(String value) {
    _idUsuarioVendedor = value;
  }

  String get idUsuarioComprador => _idUsuarioComprador;

  set idUsuarioComprador(String value) {
    _idUsuarioComprador = value;
  }

  String get idLoja => _idLoja;

  set idLoja(String value) {
    _idLoja = value;
  }

  String get idPedido => _idPedido;

  set idPedido(String value) {
    _idPedido = value;
  }

  DateTime get dataEntrega => _dataEntrega;

  set dataEntrega(DateTime value) {
    _dataEntrega = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  int get quantidade => _quantidade;

  set quantidade(int value) {
    _quantidade = value;
  }

  double get valorPedido => _valorPedido;

  set valorPedido(double value) {
    _valorPedido = value;
  }
}
