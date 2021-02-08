class Usuario {
  String _nome;
  String _email;
  String _senha;
  String _urlFotoPerfil;
  String _telefone;
  String _zap;
  String _cpf;
  String _cep;
  String _endereco;
  String _numero;
  String _complemento;
  double _latitude;
  double _longitude;
  String _bairro;
  String _cidade;
  String _uf;
  bool _ativo;
  String _nomeEnd;

  Map<String, dynamic> toMap(){
    Map<String, dynamic> mapUser = {
      "nome" : this.nome,
      "email" : this.email,
      "telefone" : this.telefone,
      "zap" : this.zap,
      "cpf" : this.cpf,
      "urlfotoperfil" : this.urlFotoPerfil,
      "enderecoEntrega" : "Principal",
    };
    return mapUser;
  }

  Map<String, dynamic> toMapEnd(){
    Map<String, dynamic> mapEnd = {
      "nome" : "Principal",
      "ativo" : true,
      "cep" : this.cep,
      "endereco" : this.endereco,
      "numero" : this.numero,
      "complemento" : this.complemento,
      "bairro" : this.bairro,
      "latitude" : this.latitude,
      "longitude" : this.longitude,
      "cidade" : this.cidade,
      "uf" : this.uf,
    };
    return mapEnd;
  }

  Usuario();

  String get uf => _uf;

  set uf(String value) {
    _uf = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get bairro => _bairro;

  set bairro(String value) {
    _bairro = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get complemento => _complemento;

  set complemento(String value) {
    _complemento = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get endereco => _endereco;

  set endereco(String value) {
    _endereco = value;
  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  String get cpf => _cpf;

  set cpf(String value) {
    _cpf = value;
  }

  String get zap => _zap;

  set zap(String value) {
    _zap = value;
  }

  String get telefone => _telefone;

  set telefone(String value) {
    _telefone = value;
  }

  String get urlFotoPerfil => _urlFotoPerfil;

  set urlFotoPerfil(String value) {
    _urlFotoPerfil = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get nomeEnd => _nomeEnd;

  set nomeEnd(String value) {
    _nomeEnd = value;
  }

  bool get ativo => _ativo;

  set ativo(bool value) {
    _ativo = value;
  }
}