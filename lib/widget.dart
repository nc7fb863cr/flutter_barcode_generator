import 'package:barcode_generator/memory.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode/barcode.dart';
import 'package:hive/hive.dart';

//ignore:must_be_immutable
class BarcodeScreen extends StatefulWidget {
  BuildContext context;

  BarcodeScreen({this.context});

  @override
  _BarcodeScreenState createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController();

  AnimationController rotationController;
  AnimationController scaleAnimationController;

  Animation rotationAnimation;
  Animation scaleAnimation;

  String code = '1234567';

  double scale = 1;
  double ratio = 0.3;

  @override
  void initState() {
    super.initState();

    // rotation animation
    rotationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    rotationAnimation =
        Tween<double>(begin: 0.0, end: 0.25).animate(CurvedAnimation(
      parent: rotationController,
      curve: Curves.fastOutSlowIn,
    ));

    // scale animation
    scaleAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.6).animate(CurvedAnimation(
      parent: rotationController,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void dispose() {
    rotationController.dispose();
    scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.9;
    double height = MediaQuery.of(context).size.width * 0.9 * ratio;

    Future<bool> configureCode() async {
      String inputText = controller.text.trim();

      if (inputText.length == 7) {
        setState(() {
          code = inputText.toUpperCase();
        });

        var box = await Hive.openBox('setting');
        box.put('code', inputText);
        return true;
      } else if (inputText.length > 7) {
        setState(() {
          code = inputText.toUpperCase().substring(0, 6);
        });

        var box = await Hive.openBox('setting');
        box.put('code', inputText);
        return true;
      } else {
        return false;
      }
    }

    void animateBarcode() {
      if (rotationController.value == 0) {
        rotationController.forward();
        scaleAnimationController.forward().then((value) {
          setState(() {
            scale = scaleAnimation.value;
          });
        });
      } else {
        rotationController.animateBack(0);
        scaleAnimationController.animateBack(scale).then((value) {
          setState(() {
            scale = scaleAnimation.value;
          });
        });
      }
    }

    void inputPanel() {
      showDialog(
        context: context,
        child: AlertDialog(
          title: Text('條碼設定'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            maxLength: 7,
            maxLengthEnforced: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                hintText: '請輸入電子發票條碼(7碼)',
                labelText: '設定條碼',
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.blue, width: 3)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey, width: 1))),
          ),
          actions: [
            FlatButton(
                disabledTextColor: Colors.grey,
                onPressed: () {
                  if (controller.text.trim().length != 7) {
                    _key.currentState.showSnackBar(SnackBar(
                      content: Text(
                        "條碼輸入錯誤",
                      ),
                      duration: Duration(seconds: 2),
                    ));
                  } else {
                    configureCode().then((value) {
                      _key.currentState.showSnackBar(SnackBar(
                        content: Text(
                          "條碼設定成功",
                        ),
                        duration: Duration(seconds: 2),
                      ));
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: Text(
                  '確定',
                  style: TextStyle(color: Colors.blue),
                )),
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '取消',
                  style: TextStyle(color: Colors.red),
                ))
          ],
        ),
      );
    }

    return Scaffold(
      key: _key,
      floatingActionButton: FloatingActionButton(
          onPressed: inputPanel, child: Icon(Icons.settings)),
      body: SafeArea(
          child: Container(
              child: Center(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Center(
                        child: GestureDetector(
                          onTap: animateBarcode,
                          child: FutureBuilder(
                            future: getCode(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                return _barcodeComponent(
                                    width, height, snapshot.data);
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ),
                      ))))),
    );
  }

  Widget _barcodeComponent(double width, double height, String code) {
    return ScaleTransition(
        scale: scaleAnimation,
        child: RotationTransition(
          turns: rotationAnimation,
          child: Container(
            width: width,
            height: height + 50,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '電子發票載具條碼',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  BarcodeWidget(
                    barcode: Barcode.code39(),
                    data: '/$code',
                    width: width,
                    height: height,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
