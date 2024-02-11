import 'dart:io';
import 'package:collection/collection.dart';

class Network {
  static Future<List<String>> getNetworkInterfaces() async {
    // Get a list of network interfaces
    List<NetworkInterface> interfaces = await NetworkInterface.list();
    List<String> interfaceNames = interfaces.map((interface) => interface.name).toList();
    return interfaceNames;
  }

  static Future<String?> getWlanInterface() async {
    final List<String> allNames = await getNetworkInterfaces();
    return allNames.firstWhereOrNull((name) => name.startsWith("wl"));
  }
}