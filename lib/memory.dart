import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:hive/hive.dart';

Future<String> getCode() async {
  String code = '1234567';
  final appDocumentDirectory =
      await pathProvider.getApplicationDocumentsDirectory();

  Hive..init(appDocumentDirectory.path);
  final setting = await Hive.openBox('setting');
  code = setting.get('code') ?? '1234567';

  if (code.trim().length < 7) {
    code = '1234567';
  }

  return code;
}
