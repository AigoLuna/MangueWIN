//port 'package:flutter_blue/flutter_blue.dart';
//port 'dart:convert';
//port 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
//
//
//ass BluetoothController {
//final FlutterBlue flutterBlue = FlutterBlue.instance;
//BluetoothDevice? device;
//BluetoothCharacteristic? characteristic;
//
//void startScan() {
//  flutterBlue.scan().listen((scanResult) {
//    if (scanResult.device.name == "ESP32_Car_Data") {
//      connectToDevice(scanResult.device);
//    }
//  });
//}
//
//Future<void> connectToDevice(BluetoothDevice device) async {
//  this.device = device;
//  await device.connect();
//  discoverServices();
//}
//
//Future<void> discoverServices() async {
//  var services = await device!.discoverServices();
//  for (var service in services) {
//    if (service.uuid.toString() == '91bad492-b950-4226-aa2b-4ede9fa42f59') {
//      characteristic = service.characteristics.firstWhere((c) =>
//        c.uuid.toString() == 'cba1d466-344c-4be3-ab3f-189f80dd7518');
//      enableNotifications();
//      break;
//    }
//  }
//}
//
//Future<void> enableNotifications() async {
//  await characteristic!.setNotifyValue(true);
//  characteristic!.value.listen((value) {
//    utf8.decode(value);
//    
//  });
//}
//
//