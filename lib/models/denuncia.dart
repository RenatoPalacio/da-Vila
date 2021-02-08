class Denuncia{
  String _descricao;
  String _url1;
  String _url2;
  String _data;
  String _ticket;

  Denuncia();


  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get url1 => _url1;

  set url1(String value) {
    _url1 = value;
  }

  String get url2 => _url2;

  set url2(String value) {
    _url2 = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get ticket => _ticket;

  set ticket(String value) {
    _ticket = value;
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "descricao" : this.descricao,
      "URL1" : this.url1,
      "URL2" : this.url2,
      "data" : this.data,
      "ticket" : this.ticket,
    };
    return map;
  }
}