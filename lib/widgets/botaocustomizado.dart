import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {

  final String textoBotao;
  final Color corTextoBotao;
  final VoidCallback onPressed;

  BotaoCustomizado({
    @required this.textoBotao,
    this.corTextoBotao = Colors.white,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Text(
          this.textoBotao,
          style: TextStyle(
              color: this.corTextoBotao,
              fontSize: 20),
        ),
        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
        color: Colors.amber,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        onPressed: this.onPressed,
    );
  }
}
