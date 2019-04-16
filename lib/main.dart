import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const requestUrl = 'https://api.hgbrasil.com/finance/quotations?key=0c37a5d3';

Future main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey,
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber)))),
  ));
}

Future<Map> getData() async {
  var response = await http.get(requestUrl);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final bitcoinController = TextEditingController();

  var _dollarActualValue = 0.0;
  var _bitcoinActualValue = 0.0;
  var _bitcoinDollarActualValue = 0.0;

  void _realChange(String text) {
    var real = double.parse(text);
    if (real > 0) {
      dollarController.text = (real / _dollarActualValue).toStringAsFixed(2);
      bitcoinController.text = (real / _bitcoinActualValue).toStringAsFixed(8);
    }
  }

  void _dollarChange(String text) {
    var dollar = double.parse(text);
    if (dollar > 0) {
      realController.text = (_dollarActualValue * dollar).toStringAsFixed(2);
      bitcoinController.text =
          (dollar / _bitcoinDollarActualValue).toStringAsFixed(8);
    }
  }

  void _bitcoinChange(String text) {
    var bitcoin = double.parse(text);
    if (bitcoin > -0.1) {
      realController.text = (_bitcoinActualValue * bitcoin).toStringAsFixed(2);
      dollarController.text =
          (bitcoin * _bitcoinDollarActualValue).toStringAsFixed(2);
    } else {
      realController.text = "0.00";
      dollarController.text = "0.00";
      bitcoinController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text("Conversor"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Carregando Dados...",
                style: TextStyle(color: Colors.amber, fontSize: 25.0),
                textAlign: TextAlign.center,
              ));
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  "Erro ao carregar dados :(",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ));
              } else {
                _dollarActualValue =
                    snapshot.data['results']['currencies']['USD']['buy'];
                _bitcoinActualValue =
                    snapshot.data['results']['bitcoin']['xdex']['last'];
                _bitcoinDollarActualValue = snapshot.data['results']['bitcoin']
                    ['blockchain_info']['buy'];

                return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Dólar:    \$ ${_dollarActualValue.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.amber, fontSize: 20.0),
                        ),
                        Text(
                          'Bitcoin: \$ ${_bitcoinDollarActualValue.toStringAsFixed(2)} | R\$ ${_bitcoinActualValue.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.amber, fontSize: 20.0),
                        ),
                        Divider(),
                        // Icon(Icons.monetization_on,
                        //     color: Colors.amber, size: 100.0)
                        buildTextField(
                            "Real", "R\$   ", realController, _realChange),
                        Divider(),
                        buildTextField(
                            "Dólar", "U\$   ", dollarController, _dollarChange),
                        Divider(),
                        buildTextField(
                            "Bitcoin", "BTC ", bitcoinController, _bitcoinChange)
                      ],
                    ),
                    padding: EdgeInsets.all(10.0));
              }
          }
        },
      ),
    );
  }
}

TextField buildTextField(String labelText, String prefix,
    TextEditingController controller, Function onChangedFunction,
    {String suffixText}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix,
        suffixText: suffixText != null ? suffixText : ''),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: onChangedFunction,
    keyboardType: TextInputType.number,
  );
}
