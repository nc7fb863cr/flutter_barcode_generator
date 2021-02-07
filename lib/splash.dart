import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double ratio = 0.4;
    double width = MediaQuery.of(context).size.width * ratio;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Barcode',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Image(
                    image: AssetImage('assets/icon.png'),
                    width: width,
                    height: width,
                  ),
                ],
              ),
            ),
            Positioned(
              child: Text(
                'Copyright @ 2020 NAN Studio All rights reserved',
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withOpacity(0.4)),
              ),
              bottom: 15,
            )
          ],
        ),
      ),
    );
  }
}
