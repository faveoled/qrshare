import 'package:qrshare/Network.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  test('Get network interface names', () async {
    List<String> interfaceNames = await Network.getNetworkInterfaces();
    print(interfaceNames);
    expect(interfaceNames, isNotEmpty);
  });

  test('Get wlan interface name', () async {
    String? interface = await Network.getWlanInterface();
    print(interface);
    expect(interface, "wlo1");
  });
}
