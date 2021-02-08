import 'package:mobx/mobx.dart';

part "dadosMobx.g.dart";

class dadosMobx = _dadosMobx with _$dadosMobx;

abstract class _dadosMobx with Store {

  @observable
  bool deliveryagendado = false;
  @observable
  bool tementregador = false;
  @observable
  //bool lendodelivery;
  ObservableFuture<bool> lendodelivery;


  @action
  void deliveryAgendado(valor){
    deliveryagendado = valor;
  }

  @action
  void temEntregador(tem)  {
    tementregador =  tem;
  }

  @action
  lendoDelivery(lendo)  {
    lendodelivery.value;
  }

}