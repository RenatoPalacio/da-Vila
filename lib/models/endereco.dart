class Endereco {
  String _nome;
  String _cep;
  String _logradouro;
  String _uf;
  String _cidade;
  String _numero;
  String _complemento;
  double _latitude;
  double _longitude;
  String _idEndereco;
  bool _ativo;

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "nome" : this.nome,
      "cep" : this.cep,
      "endereco" : this.logradouro,
      "uf" : this.uf,
      "cidade" : this.cidade,
      "numero" : this.numero,
      "complemento" : this.complemento,
      "ativo" : this._ativo,
      "latitude" : this.latitude,
      "longitude" : this.longitude,
    };
    return map;
  }

  Endereco();

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get complemento => _complemento;

  set complemento(String value) {
    _complemento = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get uf => _uf;

  set uf(String value) {
    _uf = value;
  }

  String get logradouro => _logradouro;

  set logradouro(String value) {
    _logradouro = value;
  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get idEndereco => _idEndereco;

  set idEndereco(String value) {
    _idEndereco = value;
  }

  bool get ativo => _ativo;

  set ativo(bool value) {
    _ativo = value;
  }
}