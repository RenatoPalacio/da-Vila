// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lerlojasMobx.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$lerlojasMobx on _lerlojasMobx, Store {
  final _$lendolojasAtom = Atom(name: '_lerlojasMobx.lendolojas');

  @override
  bool get lendolojas {
    _$lendolojasAtom.reportRead();
    return super.lendolojas;
  }

  @override
  set lendolojas(bool value) {
    _$lendolojasAtom.reportWrite(value, super.lendolojas, () {
      super.lendolojas = value;
    });
  }

  final _$lojasAtom = Atom(name: '_lerlojasMobx.lojas');

  @override
  List<dynamic> get lojas {
    _$lojasAtom.reportRead();
    return super.lojas;
  }

  @override
  set lojas(List<dynamic> value) {
    _$lojasAtom.reportWrite(value, super.lojas, () {
      super.lojas = value;
    });
  }

  final _$idsAtom = Atom(name: '_lerlojasMobx.ids');

  @override
  List<dynamic> get ids {
    _$idsAtom.reportRead();
    return super.ids;
  }

  @override
  set ids(List<dynamic> value) {
    _$idsAtom.reportWrite(value, super.ids, () {
      super.ids = value;
    });
  }

  final _$loadStuffAsyncAction = AsyncAction('_lerlojasMobx.loadStuff');

  @override
  Future<void> loadStuff() {
    return _$loadStuffAsyncAction.run(() => super.loadStuff());
  }

  @override
  String toString() {
    return '''
lendolojas: ${lendolojas},
lojas: ${lojas},
ids: ${ids}
    ''';
  }
}
