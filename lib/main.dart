import 'package:encrypt/tabs/keys_tab.dart';
import 'package:encrypt/tabs/sign_tab.dart';
import 'package:encrypt/utils/dependency_provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
      DependencyProvider(child: MyApp(),)
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.vpn_key),
                  text: 'RSA Keys',
                ),
                Tab(
                  icon: Icon(Icons.message_outlined),
                  text: 'Sign Message',
                ),
              ],
            ),
            title: Text('RSA Generator'),
          ),
          body: TabBarView(
            children: [
              KeysTab(),
              SignTab(),
              //DataTransferPageStarter(),
            ],
          ),
        ),
      ),
    );
  }
}

