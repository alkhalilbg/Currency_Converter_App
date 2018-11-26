import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';


void main() {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      home: CurrencyConverter(),
    ));
  }


class CurrencyConverter extends StatefulWidget {
  @override
  _StateCurrencyConverter createState() => _StateCurrencyConverter();
}

class _StateCurrencyConverter extends State<CurrencyConverter> {
  List<String> currencyList;
  String convertFromCurrency = 'JPY';
  String convertToCurrency = 'INR';
  String converted;
  final fromTextController = TextEditingController();

  currencyFromChanged(String val) {
    setState(() {
      convertFromCurrency = val;
    });
  }

  currencyToChanged(String val) {
    setState(() {
      convertToCurrency = val;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currencyLoad();
  }

  Future<String> currencyLoad() async {
    String uri = 'https://api.exchangeratesapi.io/latest';
    var response = await http
        .get(Uri.encodeFull(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    Map currencyMap = responseBody['rates'];
    currencyList = currencyMap.keys.toList();
    setState(() {});
    print(currencyList);
    return 'results';
  }

  Future<String> convert() async {
    String uri =
        'http://api.openrates.io/latest?base=$convertFromCurrency&symbols=$convertToCurrency';
    var response = await http
        .get(Uri.encodeFull(uri), headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body);
    //converted = responseBody['rates'][convertToCurrency].toString();
    setState(() {
      converted = (double.parse(fromTextController.text) *
              (responseBody['rates'][convertToCurrency]))
          .toString();
    });
    print((double.parse(fromTextController.text) *
            (responseBody['rates'][convertToCurrency]))
        .toString());
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp
    ]);
    return Scaffold(
            appBar: AppBar(
              title: Text('Currency Convertor'),
              backgroundColor: Colors.green,
            ),
            body: currencyList == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Material(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        //height: 300,
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          elevation: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ListTile(
                                  title: TextField(
                                    controller: fromTextController,
                                    keyboardType: TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0))),
                                  ),
                                  trailing: dropDownBuilder(convertFromCurrency)),
//                        IconButton(
//                            icon: Icon(Icons.beenhere),
//                            onPressed: convert,
//                        ),
                              ListTile(
                                  title: Chip(
                                    label: converted != null
                                        ? Text(
                                            converted,
                                            style: Theme.of(context)
                                                .textTheme
                                                .display1,
                                          )
                                        : Text(''),
                                  ),
                                  trailing: dropDownBuilder(convertToCurrency)),
                              ButtonTheme( minWidth: 300, height: 50,
                                  child: RaisedButton(child: const Text('Convert'), color: Colors.green[400], onPressed: convert)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
  }

  Widget dropDownBuilder(String currencyFromOrTo) {
    return DropdownButton<String>(
      value: currencyFromOrTo,
      items: currencyList.map((String val) {
        return DropdownMenuItem(
          value: val,
          child: Row(
            children: <Widget>[
              Text(val),
            ],
          ),
        );
      }).toList(),
      onChanged: (String val) {
        if (currencyFromOrTo == convertFromCurrency) {
          currencyFromChanged(val);
        } else {
          currencyToChanged(val);
        }
      },
    );
  }
}
