import 'dart:io';

import 'package:flutter/foundation.dart';

class ErrorsModel extends ChangeNotifier {

  final StringBuffer _errors = StringBuffer();

  String get errors => _errors.toString();
  bool get hasSome => _errors.isNotEmpty;

  void write(String msg) {
    stderr.write(msg);
    _errors.write(msg);
    notifyListeners();
  }
}