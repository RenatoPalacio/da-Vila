import 'package:mobx/mobx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part "lerlojasMobx.g.dart";

class lerlojasMobx = _lerlojasMobx with _$lerlojasMobx;

abstract class _lerlojasMobx with Store {

  @observable
  bool lendolojas = true;

  @observable
  List lojas = List();

  @observable
  List ids = List();

  @action
  Future<void> loadStuff() async {// Isso notifica os observadores
    lojas = await _lerlojas();
    await asyncWhen((_) => lojas.length > 0);
    lendolojas = false; //Isso também notifica os observadores
  }

  Future<List>_lerlojas() async {
    List _lojas = List();
    String _idUsuario;
    bool _dousuario = false;
    String _filtroCategoria;
    int _lojausuario = 0;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser _usuario = await auth.currentUser();
    _idUsuario = _usuario.uid;
    Firestore db = Firestore.instance;
    QuerySnapshot _docsUsuario = await db.collection("lojas").getDocuments();
    for (DocumentSnapshot itemDoc in _docsUsuario.documents){
      if(itemDoc.documentID == _idUsuario){
        _dousuario = true;
      } else {_dousuario = false;};
      String _idDocumento = itemDoc.documentID;
      QuerySnapshot _docsLojasUsuario = await db.collection("lojas").document(_idDocumento).collection("lojasusuario").getDocuments();
      for (DocumentSnapshot itemLoja in _docsLojasUsuario.documents){
        bool _existe = itemLoja["existe"];
        bool _ativa = itemLoja["ativo"];
        if (_existe && _ativa){
          String idloja = itemLoja.documentID;
          var dados = itemLoja.data;
          if(_filtroCategoria != null ){
            String _categoria1 = itemLoja["categoria1"];
            String _categoria2 = itemLoja["categoria2"];
            String _categoria3 = itemLoja["categoria3"];
            if(_categoria1 != _filtroCategoria && _categoria2 != _filtroCategoria && _categoria3 != _filtroCategoria ){
              continue;
            }
          }
          if (_dousuario){
            _lojas.insert(_lojausuario, dados);
            ids.insert(_lojausuario,idloja);
            _lojausuario = _lojausuario + 1;
          } else {
            _lojas.add(dados);
            ids.add(idloja);
          }
        }
      }
    }
    return _lojas;
  }

}

