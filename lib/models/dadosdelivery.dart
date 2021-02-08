class DadosDelivery {
  String _idDelivery;
  DateTime _dia;
  DateTime _hora;

  DadosDelivery();

  DateTime get hora => _hora;

  set hora(DateTime value) {
    _hora = value;
  }

  DateTime get dia => _dia;

  set dia(DateTime value) {
    _dia = value;
  }

  String get idDelivery => _idDelivery;

  set idDelivery(String value) {
    _idDelivery = value;
  }
}