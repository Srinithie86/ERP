import 'dart:typed_data';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothDevice {
  final String name;
  final String address;

  BluetoothDevice({required this.name, required this.address});
}

class PrinterService {
  Future<List<BluetoothDevice>> getPrinters() async {
    final List<BluetoothInfo> results = await PrintBluetoothThermal.pairedBluetooths;
    return results
        .map((device) => BluetoothDevice(
              name: device.name,
              address: device.macAdress,
            ))
        .toList();
  }

  Future<bool> connect(BluetoothDevice device) async {
    return await PrintBluetoothThermal.connect(
      macPrinterAddress: device.address,
    );
  }

  Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  Future<bool> get isConnected async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<void> printBytes(Uint8List bytes) async {
    bool connected = await PrintBluetoothThermal.connectionStatus;
    if (connected) {
      // CRITICAL FIX: Convert Uint8List to regular List<int> 
      // to avoid ClassCastException in the plugin's native code.
      await PrintBluetoothThermal.writeBytes(bytes.toList());
    }
  }
}
