import 'package:compradordodia/models/usuarios.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:compradordodia/cadastro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class CustomWebView extends StatefulWidget {
  final String selectedUrl;

  CustomWebView({this.selectedUrl});

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains("#access_token")) {
        succeed(url);
      }

      if (url.contains(
          "https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied")) {
        denied();
      }
    });
  }

  denied() {
    Navigator.pop(context);
  }

  succeed(String url) {
    var params = url.split("access_token=");
    print("Params: $params");
    var endparam = params[1].split("&");

    Navigator.pop(context, endparam[0]);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        url: widget.selectedUrl,
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(66, 103, 178, 1),
          title: new Text("Facebook login"),
        ));
  }
}

class _LoginState extends State<Login> {
  TextEditingController _loginController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();
  String qualErro;
  bool _senhaobscura = true;
  IconData _icone = Icons.remove_red_eye;
  String your_client_id = "881709949035531";
  String your_redirect_url = "https://comprador-do-dia.firebaseapp.com/__/auth/handler";
  String _nomeusuarioFB;
  String _emailFB;
  String _fotourlFB;
  String _foneFB;
  String _uidFB;
  bool _criandousuario = false;

  Future<String> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    FirebaseAuth auth = FirebaseAuth.instance;

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final  authResult = await auth.signInWithCredential(credential);
    final user = authResult.user;

    _nomeusuarioFB = user.displayName;
    _emailFB = user.email;
    _fotourlFB = user.photoUrl;
    _foneFB = user.phoneNumber;
    _uidFB = user.uid;
    _regristraUsuarioFB();
  }

  loginWithFacebook() async{
    setState(() {
      _criandousuario = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    String result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomWebView(
              selectedUrl:
              'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,',
            ),
            maintainState: true),

    );
    if (result != null) {
      try {
        final facebookAuthCred = FacebookAuthProvider.getCredential(accessToken: result);
        final user = await auth.signInWithCredential(facebookAuthCred);

        _nomeusuarioFB = user.user.displayName;
        _emailFB = user.user.email;
        _fotourlFB = user.user.photoUrl;
        _foneFB = user.user.phoneNumber;
        _uidFB = user.user.uid;

        _regristraUsuarioFB();

      } catch (e) {}
    }
  }

  _regristraUsuarioFB() async {
    Firestore db = Firestore.instance;
    Usuario usuario = Usuario();
    usuario.nome = _nomeusuarioFB;
    usuario.email = _emailFB;
    usuario.telefone = _foneFB;
    usuario.urlFotoPerfil = _fotourlFB;
    DocumentSnapshot doc = await db.collection("usuarios").document(_uidFB).get();
    if (doc.data == null){
      db.collection("usuarios").document(_uidFB).setData(usuario.toMap());
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Cadastro(false, obrigatorio: true,))
      );
    } else {
      _checaUsuarioLogado();
    }
  }

  _validaCampos(){
    String email = _loginController.text;
    String senha = _senhaController.text;
    String msgErro = "";
    if (email.isEmpty){
      msgErro = "Forneça um e-mail válido";
    } else if (senha.isEmpty) {
      msgErro = "Digite uma senha de no mínimo 6 caracteres";
    } else {
      return _autenticaUsuario();
    }
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(msgErro),
            actions: <Widget>[
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("OK")),
            ],
          );
        }
    );
  }

  _autenticaUsuario() {
    String email = _loginController.text.trim();
    String senha = _senhaController.text;
    String msgErro = "";
    String funcao;
    String flatB1 = "";
    String flatB2 = "";

    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((firebaseUser) {
          if(!firebaseUser.user.isEmailVerified){
            firebaseUser.user.sendEmailVerification();
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: Text("Verificação de e-mail"),
                    content: Text("Um e-mail de verifição foi enviado para $email."),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("OK")),
                    ],
                  );
                }
            );
          }
      //Navigator.pushReplacementNamed(context, "/home");
      _checaUsuarioLogado();
    }).catchError((erro) {
      qualErro = erro.code;
      switch(qualErro){
        case "ERROR_USER_NOT_FOUND" :
          msgErro = "Usuário não encontrado. Deseja cadastrar?";
          funcao = "criarusuario";
          flatB1 = "Não";
          flatB2 = "Sim";
          break;
        case "ERROR_INVALID_EMAIL" :
          msgErro = "e-mail incorreto. Digite novamente.";
          flatB1 = "";
          flatB2 = "OK";
          funcao = "digitarnovamente";
          break;
        case "ERROR_WRONG_PASSWORD" :
          msgErro = "Senha incorreta. Digite novamente.";
          flatB1 = "";
          flatB2 = "OK";
          funcao = "";
      };
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text(msgErro),
              actions: <Widget>[
                FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text(flatB1)),
                FlatButton(
                    onPressed: (){
                      if(funcao == "criarusuario"){
                        //Navigator.pushReplacementNamed(context, "/cadastro", );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Cadastro(true, email: email,)));
                      } else if(funcao == "digitarnovamente"){
                       _limpaDados();
                       Navigator.pop(context);
                      } else {
                        _senhaController.clear();;
                        Navigator.pop(context);
                      }
                    },
                    child: Text(flatB2)),
              ],
            );
          }
      );
    });
  }

  _limpaDados(){
    _loginController.clear();
    _senhaController.clear();
    setState(() {
    });
  }

  _checaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if(usuarioLogado != null){
      String idUsuario = usuarioLogado.uid;
      Firestore db = Firestore.instance;
      QuerySnapshot _limpacarrinho = await db.collection("usuarios").document(idUsuario).collection("carrinho").getDocuments();
      for(DocumentSnapshot item in _limpacarrinho.documents){
        String idItem = item.documentID;
        db.collection("usuarios").document(idUsuario).collection("carrinho").document(idItem).delete();
      }
      Navigator.pushReplacementNamed(
        context, "/home",
        arguments: idUsuario
      );
    }
  }

  Future<void> resetPassword(String email) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: email);
    Navigator.pop(context);
    _avisoemailenviado(email);
  }

  _avisoemailenviado(String email){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: Text("Recuperar e-mail"),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "e-mail de recuperação de senha enviao para:",
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        email,
                        style: TextStyle(
                            fontSize: 16
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                              onPressed: (){Navigator.pop(context);},
                              child: Text(
                                "OK",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          );
        }
    );
  }

  _recuperarSenha(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Confirme seu e-mail:"),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                    ),
                    style: TextStyle(fontSize: 20),
                    controller: _loginController,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                            onPressed: (){Navigator.pop(context);},
                            child: Text(
                              "Cancelar",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber
                              ),
                            )
                        ),
                        FlatButton(
                            onPressed: (){
                              //_checaremail(_loginController.text);
                              resetPassword(_loginController.text);
                            },
                            child: Text(
                              "Ok",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber
                              ),
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checaUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Colors.amberAccent),
          padding: EdgeInsets.all(16),
          child: _criandousuario
              ? Column(children: <Widget>[
            Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),)
          ],)
              : Center(child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                    style: TextStyle(fontSize: 20),
                    controller: _loginController,
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    suffixIcon: GestureDetector(
                      onTap: (){
                        if (_senhaobscura){
                          setState(() {
                            _senhaobscura = false;
                            _icone = Icons.not_interested;
                          });
                        } else {
                          setState(() {
                            _senhaobscura = true;
                            _icone = Icons.remove_red_eye;
                          });
                        }
                      },
                      child: Icon(
                        _icone,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  obscureText: _senhaobscura,
                  controller: _senhaController,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 8, left: 16),
                    child: GestureDetector(
                      child: Text(
                        "Esqueceu sua senha?",
                        style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onTap: _recuperarSenha,
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: RaisedButton(
                        child: Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        color: Colors.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        onPressed: () {
                          _validaCampos();
                        })),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: GestureDetector(
                        child: Text(
                          "Cadastrar-se",
                          style: TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, "/cadastro", arguments: true);
                        },
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: GestureDetector(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      color: Colors.indigo,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              "images/f-1.jpg",
                              scale: 2.5,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "Login com o Facebook",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: loginWithFacebook,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      color: Colors.indigoAccent,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              "images/g-1.jpg",
                              scale: 2.5,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "Login com o Google",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: signInWithGoogle,
                  ),
                ),
              ],
            ),
          ))

      ),
    );
  }
}
