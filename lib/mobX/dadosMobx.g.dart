// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dadosMobx.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$dadosMobx on _dadosMobx, Store {
  final _$deliveryagendadoAtom = Atom(name: '_dadosMobx.deliveryagendado');

  @override
  bool get deliveryagendado {
    _$deliveryagendadoAtom.reportRead();
    return super.deliveryagendado;
  }

  @override
  set deliveryagendado(bool value) {
    _$deliveryagendadoAtom.reportWrite(value, super.deliveryagendado, () {
      super.deliveryagendado = value;
    });
  }

  final _$tementregadorAtom = Atom(name: '_dadosMobx.tementregador');

  @override
  bool get tementregador {
    _$tementregadorAtom.reportRead();
    return super.tementregador;
  }

  @override
  set tementregador(bool value) {
    _$tementregadorAtom.reportWrite(value, super.tementregador, () {
      super.tementregador = value;
    });
  }

  final _$lendodeliveryAtom = Atom(name: '_dadosMobx.lendodelivery');

  @override
  ObservableFuture<bool> get lendodelivery {
    _$lendodeliveryAtom.reportRead();
    return super.lendodelivery;
  }

  @override
  set lendodelivery(ObservableFuture<bool> value) {
    _$lendodeliveryAtom.reportWrite(value, super.lendodelivery, () {
      super.lendodelivery = value;
    });
  }

  final _$_dadosMobxActionController = ActionController(name: '_dadosMobx');

  @override
  void deliveryAgendado(dynamic valor) {
    final _$actionInfo = _$_dadosMobxActionController.startAction(
        name: '_dadosMobx.deliveryAgendado');
    try {
      return super.deliveryAgendado(valor);
    } finally {
      _$_dadosMobxActionController.endAction(_$actionInfo);
    }
  }

  @override
  void temEntregador(dynamic tem) {
    final _$actionInfo = _$_dadosMobxActionController.startAction(
        name: '_dadosMobx.temEntregador');
    try {
      return super.temEntregador(tem);
    } finally {
      _$_dadosMobxActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic lendoDelivery(dynamic lendo) {
    final _$actionInfo = _$_dadosMobxActionController.startAction(
        name: '_dadosMobx.lendoDelivery');
    try {
      return super.lendoDelivery(lendo);
    } finally {
      _$_dadosMobxActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
deliveryagendado: ${deliveryagendado},
tementregador: ${tementregador},
lendodelivery: ${lendodelivery}
    ''';
  }
}
