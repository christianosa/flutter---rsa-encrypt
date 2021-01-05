import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:encrypt/utils/dependency_provider.dart';


class KeysTab extends StatefulWidget {
  @override
  _KeysTabState createState() => _KeysTabState();
}

class _KeysTabState extends State<KeysTab> {

  /// The Future that will show the Pem String
  Future<String> futureText;

  /// Future to hold the reference to the KeyPair generated with PointyCastle
  /// in order to extract the [crypto.PrivateKey] and [crypto.PublicKey]
  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      futureKeyPair;

  /// The current [crypto.AsymmetricKeyPair]
  crypto.AsymmetricKeyPair keyPair;

  /// With the helper [RsaKeyHelper] this method generates a
  /// new [crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>
  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() {
    var keyHelper = DependencyProvider.of(context).getRsaKeyHelper();
    return keyHelper.computeRSAKeyPair(keyHelper.getSecureRandom());
  }

  final _storage = FlutterSecureStorage();
  List<_Item> _items = [];

  @override
  void initState() {
    super.initState();

    _readAll();
  }

  @override
  Widget build(BuildContext context) => Container(
          child: Stack(children: <Widget>[
        (_items.length == 0)
            ? Container(
                height: 50,
                alignment: Alignment.centerRight,
                child: IconButton(
                    key: Key('add_random'),
                    onPressed: () {
                      setState(() {
                        _addNewItem();
                      });
                    },
                    icon: Icon(Icons.add)))
            :
              ListView.builder(
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  leading: (_items[index].key == "PublicKey")
                      ? Icon(Icons.vpn_key_outlined)
                      : Icon(Icons.vpn_key_sharp),
                  trailing: (_items[index].key == "PublicKey")
                      ? Icon(Icons.delete_outline_outlined)
                      : null,
                  onTap: () {
                    showAlertDialog(context);
                    //_removeAll();
                  },
                  onLongPress: () {

                    //DIALOG///////////////////////////////////////
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              contentPadding: EdgeInsets.only(left: 25, right: 25),
                              title: Center(child: Text("Dados")),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                              content: Container(
                                  height: 440,
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          height: 320,
                                          //width: 300,
                                          child:  SingleChildScrollView (
                                            child: InkWell(
                                                onTap: () {
                                                  // Copies the data to the keyboard
                                                  Clipboard.setData(
                                                      new ClipboardData(text: _items[index].value));
                                                },
                                                child: Text('${_items[index].value}')),
                                          ),
                                        ),

                                            Row(
                                              children: <Widget>[
                                                  FlatButton(
                                                      child: Icon(Icons.ios_share, color: (_items[index].key != "PublicKey")
                                                          ? Colors.grey
                                                          : Theme.of(context).primaryColor),
                                                      onPressed: () {} ,
                                                      shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5.0)
                                                            ),
                                                  )
                                              ],
                                            )
                                      ],
                                    ),
                                  )
                              );

                        });
                    //DIALOG///////////////////////////////////////


                  },
                  title: Text(
                    _items[index].key,
                    key: Key('title_row_$index'),
                  ),
                ),
              ),
            FutureBuilder<
                    crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>(
                future: futureKeyPair,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // if we are waiting for a future to be completed, show a progress indicator
                    return Center(child: CircularProgressIndicator());
                  } else
                    return Container();
                }),
      ])
  );

  String _randomValue() {
    final rand = Random();
    final codeUnits = List.generate(20, (index) {
      return rand.nextInt(26) + 65;
    });
    return String.fromCharCodes(codeUnits);
  }

  Future<Null> _readAll() async {
    final all = await _storage.readAll();
    setState(() {
      return _items =
          all.keys.map((key) => _Item(key, all[key])).toList(growable: false);
    });
  }


  void _addNewItem() async {
    final String key = _randomValue();
    final String value = _randomValue();

    // If there are any pemString being shown, then show an empty message
    futureText = Future.value("");
    // Generate a new keypair
    futureKeyPair = getKeyPair().then((key) {
      String private = DependencyProvider.of(context)
          .getRsaKeyHelper()
          .encodePrivateKeyToPemPKCS1(key.privateKey);
      String public = DependencyProvider.of(context)
          .getRsaKeyHelper()
          .encodePublicKeyToPemPKCS1(key.publicKey);

      _storage.write(key: "PrivateKey", value: private);
      _storage.write(key: "PublicKey", value: public);

      _readAll();
    });
  }

  void _removeItem(String key) async {
    await _storage.delete(key: key);
    await _storage.deleteAll();
    _readAll();
  }

  void _removeAll() async {
    await _storage.deleteAll();
    _readAll();
  }


  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed:  () {
        _removeAll();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialogs
    AlertDialog alert = AlertDialog(
      title: Text("Alerta"),
      content: Text("Do you want to confirm the exclusion of selected key pair?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}

class _Item {
  _Item(this.key, this.value);

  final String key;
  final String value;
}
