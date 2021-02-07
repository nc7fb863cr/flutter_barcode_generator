import 'package:flutter/material.dart';
import 'splash.dart';
import 'widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Barcode',
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: Future.delayed(Duration(seconds: 1)).then((value) => true),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data) {
                return BarcodeScreen(
                  context: context,
                );
              }
            } else {
              return SplashScreen();
            }
            return SplashScreen();
          },
        ));
  }
}
