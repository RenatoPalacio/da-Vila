import 'package:flutter/material.dart';

class Categorias {

  static List<DropdownMenuItem<String>> getCategorias(){

    List<DropdownMenuItem<String>> itensDropCategorias = [];

    //Categorias
    itensDropCategorias.add(
        DropdownMenuItem(child: Text(
            "Categoria", style: TextStyle(
          color: Color(0xFFFF6F00)
        ),
        ), value: null,)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Doces"), value: "doces",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Confeitaria"), value: "confeitaria",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Padaria"), value: "padaria",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Salgados"), value: "salgados",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Tortas"), value: "tortas",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Bolos"), value: "bolos",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Macramês"), value: "macrames",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Artesanatos"), value: "artesanatos",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Pet"), value: "pet",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Serviços"), value: "serviços",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Aulas"), value: "aulas",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Congelados"), value: "congelados",)
    );

    return itensDropCategorias;

  }

}