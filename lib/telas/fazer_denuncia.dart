import 'dart:io';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:compradordodia/widgets/inputcustomizado.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:validadores/Validador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';


class fazerDenuncia extends StatefulWidget {
  @override
  _fazerDenunciaState createState() => _fazerDenunciaState();
}


class _fazerDenunciaState extends State<fazerDenuncia> {

  TextEditingController _denunciaController = TextEditingController();
  final _formDenuncia = GlobalKey<FormState>();
  String _denuncia;
  File _screen;
  File _foto1;
  File _foto2;
  BuildContext _dialogoContext;
  String _idUsuario;
  String _idDocumentoDenuncia;
  String _idData;
  String _URL1;
  String _URL2;

  //SELECIONA FOTO
  Future _recuperaImagem() async {
    _screen = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _foto1 == null ? _foto1 = _screen : _foto2 = _screen;
    });
  }

  _checaUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuario = usuarioLogado.uid;
  }

  _mostraProgresso(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text("Salvando denúncia"),
              ],
            ),
          );
        }
    );
  }

  _salvaDenuncia() async {
    _mostraProgresso(context);
    StorageUploadTask codfoto1;
    StorageUploadTask codfoto2;
    _idDocumentoDenuncia = DateTime.now().toString().replaceAll(" ", "").replaceAll("-", "").replaceAll(":", "").replaceAll(".", "");
    _idData = DateTime.now().day.toString() + "/" + DateTime.now().month.toString() + "/" + DateTime.now().year.toString();

    Firestore db = Firestore.instance;
    db.collection("administração").document("denuncias").collection(_idUsuario).document(_idDocumentoDenuncia).setData(
        {
          "ticket" : _idDocumentoDenuncia,
          "descricao" : _denuncia,
          "data" : _idData,
        });

    db.collection("usuarios").document(_idUsuario).collection("denuncias").document(_idDocumentoDenuncia).setData(
        {
          "ticket" : _idDocumentoDenuncia,
          "descricao" : _denuncia,
          "data" : _idData,
        });

    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo1 = pastaRaiz
        .child("denuncias")
        .child(_idUsuario)
        .child(_idDocumentoDenuncia)
        .child("screen1");
    StorageReference arquivo2 = pastaRaiz
        .child("denuncias")
        .child(_idUsuario)
        .child(_idDocumentoDenuncia)
        .child("screen2");
    if(_foto1 != null){
       codfoto1 = await arquivo1.putFile(_foto1);
       final snapshot1 = await codfoto1.onComplete;
       await snapshot1.ref.getDownloadURL().then((urlrecuperada1) => _URL1 = urlrecuperada1);
    }
    if(_foto2 != null){
      codfoto2 = await arquivo2.putFile(_foto2);
      final snapshot2 = await codfoto2.onComplete;
      await snapshot2.ref.getDownloadURL().then((urlrecuperada2) => _URL2 = urlrecuperada2);
    }
    db.collection("administração").document("denuncias").collection(_idUsuario).document(_idDocumentoDenuncia).updateData(
        {
          "URL1" : _URL1,
          "URL2" : _URL2,
        });

    db.collection("usuarios").document(_idUsuario).collection("denuncias").document(_idDocumentoDenuncia).updateData(
        {
          "URL1" : _URL1,
          "URL2" : _URL2,
        });

    Navigator.pop(_dialogoContext);
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checaUsuario();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fazer Denúncia"),
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  "Caso tenha se sentido ofendido por alguma mensagem trocada ou não concorde com a evolução/conclusão de "
                      "alguma negociação realizadas neste aplicativo, por favor relate abaixo o ocorrido. "
                      "Você também pode anexar um print da tela.",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black
                  ),
                ),
                Form(
                  key: _formDenuncia,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: InputCustomizado(
                          hint: "Escreva sua denúncia detalhando o ocorrido e informando qual usuário/loja você gostaria de denunciar",
                          controller: _denunciaController,
                          maxLines: 10,
                          onSaved: (denuncia){
                            _denuncia = denuncia;
                          },
                          validator: (valor){
                            return Validador()
                                .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                                .valido(valor);
                          },
                        ),
                      ),
                      _foto1 == null
                          ? GestureDetector(
                        onTap: _recuperaImagem,
                        child: Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_to_home_screen_outlined,
                                size: 32,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  "Incluir print da tela",
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                          : Row(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 16, left: 16),
                                  child: SizedBox(
                                    height: 270,
                                    width: 120,
                                    child: Image.file(
                                      _foto1,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _foto2 == null ?_foto1 = null : _foto1 = _foto2; _foto2 = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16, left: 0),
                                    child: Icon(
                                      Icons.clear,
                                      size: 32,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _foto2 == null
                                ? Padding(
                              padding: EdgeInsets.only(top: 16, left: 24),
                              child: GestureDetector(
                                  onTap: _recuperaImagem,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_to_home_screen_outlined,
                                        size: 32,
                                      ),
                                    ],
                                  )
                              ),
                            )
                                : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 16, left: 16),
                                  child: SizedBox(
                                    height: 270,
                                    width: 120,
                                    child: Image.file(
                                      _foto2,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _foto2 = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16, left: 0),
                                    child: Icon(
                                      Icons.clear,
                                      size: 32,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                                child: BotaoCustomizado(
                                  textoBotao: "Enviar denúncia",
                                  onPressed: ()  {
                                    if( _formDenuncia.currentState.validate() ){
                                      _formDenuncia.currentState.save();
                                      _dialogoContext = context;
                                      _salvaDenuncia();
                                    }
                                  },
                                )
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                )
              ],
            ),
          )
      ),
    );
  }
}
