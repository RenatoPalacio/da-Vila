import 'package:compradordodia/telas/add_loja.dart';
import 'package:compradordodia/telas/adicionar_filtros.dart';
import 'package:compradordodia/telas/agendar_delivery.dart';
import 'package:compradordodia/telas/cadastra_delivery.dart';
import 'package:compradordodia/telas/cadastrar_endereco.dart';
import 'package:compradordodia/telas/detalhes_delivery.dart';
import 'package:compradordodia/telas/fazer_denuncia.dart';
import 'package:compradordodia/telas/ler_carrinho_novo.dart';
import 'package:compradordodia/telas/lista_mensagens.dart';
import 'package:compradordodia/telas/lista_suaslojas.dart';
import 'package:compradordodia/telas/lista_seusprodutos.dart';
import 'package:compradordodia/telas/suas_denuncias.dart';
import 'package:compradordodia/telas/ver_denuncia.dart';
import 'package:flutter/material.dart';

import 'cadastro.dart';
import 'Home.dart';
import 'config.dart';
import 'login.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;

    switch( settings.name ){
      case "/" :
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/login" :
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/cadastro" :
        return MaterialPageRoute(
            builder: (_) => Cadastro(args)
        );
      case "/configuracao" :
        return MaterialPageRoute(
            builder: (_) => Config()
        );
      case "/home" :
        return MaterialPageRoute(
            builder: (_) => Home(args)
        );
      case "/lista_suaslojas" :
        return MaterialPageRoute(
            builder: (_) => Listasuaslojas(),
        );
      case "/ler_carrinho" :
        return MaterialPageRoute(
          builder: (_) => Lercarrinho(args),
        );
      case "/adiciona_loja" :
        return MaterialPageRoute(
            builder: (_) => addLoja(true),
            maintainState: false
        );
      case "/novo_endereco" :
        return MaterialPageRoute(
            builder: (_) => CadastraEndereco(args),
        );
      case "/novo_delivery" :
        return MaterialPageRoute(
          builder: (_) => CadastraDelivery(),
        );
      case "/agenda_delivery" :
        return MaterialPageRoute(
          builder: (_) => AgendarDelivery(args),
        );
      case "/detalhes_delivery" :
        return MaterialPageRoute(
          builder: (_) => DetalhesDelivery(args),
        );
      case "/filtros" :
        return MaterialPageRoute(
          builder: (_) => Filtros(args),
        );
      case "/denuncia" :
        return MaterialPageRoute(
          builder: (_) => fazerDenuncia(),
        );
      case "/suadenuncia" :
        return MaterialPageRoute(
          builder: (_) => suasDenuncias(),
        );
      case "/verdenuncia" :
        return MaterialPageRoute(
          builder: (_) => verDenuncia(args),
        );
      case "/listamsgs" :
        return MaterialPageRoute(
          builder: (_) => listaMsgs(args, args),
        );
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
        builder: (_){
          return Scaffold(
            appBar: AppBar(title: Text("Tela não encontrada!"),),
            body: Center(
              child: Text("Tela não encontrada!"),
            ),
          );
        }
    );
  }

}