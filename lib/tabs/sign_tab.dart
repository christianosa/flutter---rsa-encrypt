import 'dart:ui';

import 'package:encrypt/utils/dependency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignTab extends StatefulWidget {
  @override
  _SignTabState createState() => _SignTabState();
}

class _SignTabState extends State<SignTab> {
  TextEditingController _inputController = TextEditingController();
  TextEditingController _resultController = TextEditingController();

  /// The Future that will show the Pem String
  Future<String> futureText;
  /// Text Editing Controller to retrieve the text to sign
  TextEditingController _controller = TextEditingController();
  String plainTextPk;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<String>(
            future: _read("PrivateKey"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                              width: 300.0,
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "Text to Sign",
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blueAccent, width: 2.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.cyan, width: 2.0),
                                  ),
                                ),
                              ),
                          ),
                        ),
                        RaisedButton(
                          child: Icon(
                            Icons.playlist_add_check,
                          ),
                          color: Colors.lightBlueAccent,
                          onPressed: () {
                            setState(() {
                              plainTextPk = DependencyProvider.of(context).getRsaKeyHelper().removePemHeaderAndFooter(snapshot.data);
                              futureText = Future.value(
                                  DependencyProvider.of(context)
                                      .getRsaKeyHelper()
                                      .signText(
                                      _controller.text,
                                      plainTextPk));
                            });
                          },
                        )
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Signed Text using PrivateKey :", style:
                        TextStyle(fontSize: 17.0)),
                      )
                    )
                    ,
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.all(8),
                          child: FutureBuilder(
                              future: futureText,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return SingleChildScrollView(
                                    // the inkwell is used to register the taps
                                    // in order to be able to copy the text
                                    child: Text(snapshot.data, style: TextStyle(fontSize: 17.0),),
                                  );
                                } else {
                                  return Center(
                                    child: Text("Your signed text will appears here."),
                                  );
                                }
                              }),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

    Future<String> _read(String key) async {
      final _storage = FlutterSecureStorage();
      String keyValue = await _storage.read(key: key);
      return keyValue;
    }
}

class _Item {
  _Item(this.key, this.value);

  final String key;
  final String value;
}
