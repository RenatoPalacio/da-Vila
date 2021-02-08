
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:compradordodia/widgets/botaocustomizado.dart';

class Filtros extends StatefulWidget {
  String _idUsuario;
  Filtros(this._idUsuario);
  @override
  _FiltrosState createState() => _FiltrosState();
}

class _FiltrosState extends State<Filtros> {

  double _distancia = 30.0;
  String _ordenar;
  Color corOrdenar1 = Colors.white;
  Color corOrdenar2 = Colors.white;
  Color corOrdenar3 = Colors.white;
  Color corOrdenar4 = Colors.white;
  List<String> _formaPagamento = [];
  List<String> opcoesPagto = [
    'Dinheiro', 'Visa Crédito', 'Visa Débito',
    'Master Crédito', 'Master Débito', 'Elo',
    'Hipercard', 'Mercado Pago', 'PayPal',
    'Transferência',  'VR/TR',
  ];
  int _modoEntrega;
  List<String> modosEntrega = ["Entrega", "Para retirar", "Todas opções"];
  String idUsuario;


  _salvarFiltros() async {
    final filtros =  await SharedPreferences.getInstance();
    await filtros.setDouble("distancia", _distancia);
    await filtros.setStringList("formapagamento", _formaPagamento);
    await filtros.setInt("entrega", _modoEntrega);
    await filtros.setString("ordenar", _ordenar);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/home", arguments: idUsuario);
  }

  _recuperarFiltros() async {
    final filtros =  await SharedPreferences.getInstance();
    setState(() {
      _distancia = filtros.getDouble("distancia");
      _distancia == null ? _distancia = 30.0 : null;
      _formaPagamento = filtros.getStringList("formapagamento");
      _modoEntrega = filtros.getInt("entrega");
      _ordenar = filtros.getString("ordenar");
      switch(_ordenar){
        case "dosUsuario" : corOrdenar1 = Colors.amberAccent;
        break;
        case "favoritos" : corOrdenar2 = Colors.amberAccent;
        break;
        case "distancia" : corOrdenar3 = Colors.amberAccent;
        break;
        case "scorefinal" : corOrdenar4 = Colors.amberAccent;
      }
    });
  }

  _removerFiltros() async {
    final filtros =  await SharedPreferences.getInstance();
    await filtros.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarFiltros();
    idUsuario = widget._idUsuario;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filtros"),
      ),
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 32, left: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Ordenar por:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 32, left: 24, right: 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                              onTap: (){
                                _ordenar = "dosUsuario";
                                setState(() {
                                  corOrdenar1 = Colors.amberAccent;
                                  corOrdenar2 = Colors.white;
                                  corOrdenar3 = Colors.white;
                                  corOrdenar4 = Colors.white;
                                });
                              },
                              child: Card(
                                  color: corOrdenar1,
                                  elevation: 3.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 24),
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.format_list_numbered,
                                          size: 32,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text("Padrão",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold
                                              ),)
                                        )
                                      ],
                                    ),
                                  )
                              )
                          ),
                          GestureDetector(
                              onTap: (){
                                _ordenar = "favorito";
                                setState(() {
                                  corOrdenar1 = Colors.white;
                                  corOrdenar2 = Colors.amberAccent;
                                  corOrdenar3 = Colors.white;
                                  corOrdenar4 = Colors.white;
                                });
                              },
                              child: Card(
                                  color: corOrdenar2,
                                  elevation: 3.0,
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.favorite,
                                          size: 32,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text("Favoritos",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold
                                              ),)
                                        )
                                      ],
                                    ),
                                  )
                              )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 32, left: 24, right: 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                              onTap: (){
                                _ordenar = "distancialoja";
                                setState(() {
                                  corOrdenar1 = Colors.white;
                                  corOrdenar2 = Colors.white;
                                  corOrdenar3 = Colors.amberAccent;
                                  corOrdenar4 = Colors.white;
                                });
                              },
                              child: Card(
                                  color: corOrdenar3,
                                  elevation: 3.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.directions_run,
                                          size: 32,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text("Distância",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold
                                              ),)
                                        )
                                      ],
                                    ),
                                  )
                              )
                          ),
                          GestureDetector(
                              onTap: (){
                                _ordenar = "scorefinal";
                                setState(() {
                                  corOrdenar1 = Colors.white;
                                  corOrdenar2 = Colors.white;
                                  corOrdenar3 = Colors.white;
                                  corOrdenar4 = Colors.amberAccent;
                                });
                              },
                              child: Card(
                                  color: corOrdenar4,
                                  elevation: 3.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.star,
                                          size: 32,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text("Avaliação",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold
                                              ),)
                                        )
                                      ],
                                    ),
                                  )
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: Padding(
                    padding: EdgeInsets.only(top: 8, left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Text(
                            "Distância: $_distancia Km",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                          child: Slider(
                              activeColor: Colors.black,
                              inactiveColor: Colors.grey,
                              value: _distancia,
                              min: 1,
                              max: 30,
                              divisions: 29,
                              label: _distancia.toString(),
                              onChanged: (double escolhaUsuario){
                                setState(() {
                                  _distancia = escolhaUsuario;
                                });
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 32, left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  "Modo de entrega:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),),
                              Padding(
                                padding: EdgeInsets.only(top: 16, left: 0),
                                child: ChipsChoice<int>.single(
                                  clipBehavior: Clip.antiAlias,
                                  value: _modoEntrega,
                                  onChanged: (val) => setState(() => _modoEntrega = val),
                                  choiceItems: C2Choice.listFrom<int, String>(
                                    source: modosEntrega,
                                    value: (i, v) => i,
                                    label: (i, v) => v,
                                  ),
                                  wrapped: true,
                                  textDirection: TextDirection.ltr,
                                  choiceStyle: C2ChoiceStyle(
                                    borderRadius: BorderRadius.circular(10),
                                    labelStyle: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black
                                    ),
                                    showCheckmark: false,
                                  ),
                                  choiceActiveStyle: C2ChoiceStyle(
                                    borderRadius: BorderRadius.circular(10),
                                    labelStyle: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                    showCheckmark: false,
                                    borderColor: Colors.amber,
                                    color: Colors.amber,
                                    brightness: Brightness.dark,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 32, left: 16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: Text(
                                      "Formas de pagamento:",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 16, left: 0),
                                    child: ChipsChoice<String>.multiple(
                                      clipBehavior: Clip.antiAlias,
                                      value: _formaPagamento,
                                      onChanged: (val) => setState(() => _formaPagamento = val),
                                      choiceItems: C2Choice.listFrom<String, String>(
                                        source: opcoesPagto,
                                        value: (i, v) => v,
                                        label: (i, v) => v,
                                      ),
                                      wrapped: true,
                                      textDirection: TextDirection.ltr,
                                      choiceStyle: C2ChoiceStyle(
                                        borderRadius: BorderRadius.circular(10),
                                        labelStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black
                                        ),
                                        showCheckmark: false,
                                      ),
                                      choiceActiveStyle: C2ChoiceStyle(
                                        borderRadius: BorderRadius.circular(10),
                                          labelStyle: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold
                                          ),
                                          showCheckmark: false,
                                          borderColor: Colors.amber,
                                          color: Colors.amber,
                                          brightness: Brightness.dark,
                                      ),
                                    ),
                                  )
                                ]
                            )
                        )
                      ],
                    )
                ),
              ),
            ],
          )
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                child: BotaoCustomizado(
                  textoBotao: "Ver resultados",
                  onPressed: _salvarFiltros,
                )
            )
          ],
        ),
      ),
    );
  }
}



