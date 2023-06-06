import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.deepPurple),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      home: Anasayfa(),
    );
  }
}

class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  bool kontrol = false;
  var stateD = "aszz";

  @override
  void initState() {
    degistir();
    super.initState();
  }

  void degistir() {
    setState(() {
      stateD;
    });
  }


  @override
  Widget build(BuildContext context) {
    var ekranBilgisi =MediaQuery.of(context);
    final double ekranYuksekligi = ekranBilgisi.size.height;
    final double ekranGenisligi = ekranBilgisi.size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("YUSUF"),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: stateD,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                disableBluetooth();
              },
              child: const Text("BLUETOOTH KAPAT"),

            ),


            ElevatedButton(
              onPressed: () {
                enableBluetooth();
              }, child: const Text("BLUETOOTH AÇ"),

            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.3),
              child: Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToBluetoothPage(context);
                  },
                  child: Text("BLUETOOTH CİHAZLARINI LİSTELE"),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _navigateToBluetoothPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BluetoothPage()),
    ).then((selectedDevice) {
      if (selectedDevice != null) {
        _connectToDevice(selectedDevice);
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        stateD=('BAĞLANTI BAŞARILI');
      });


      connection.input?.listen((Uint8List data) {
        setState(() {
          print('Gelen veri: ${ascii.decode(data)}');
        });

        connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          setState(() {
            stateD=('BAĞLANTI KESİLDİ');
          });

        }
      }).onDone(() {
        setState(() {
          stateD=('BAĞLANTI KESİLDİ');
        });

      });
    } catch (exception) {
      setState(() {
        stateD=('Bağlanamıyor');
      });

    }
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> _devices = [];
  var stateD;

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();
  }

  Future<void> _getBluetoothDevices() async {
    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLUETOOTH CİHAZLARINI LİSTELE'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_devices[index].name ?? ""),
            onTap: () {
              Navigator.pop(context, _devices[index]);
            },
          );
        },
      ),
    );
  }
}
void enableBluetooth() async {
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;

  bool? isEnabled = await flutterBluetoothSerial.isEnabled;

  if (isEnabled != null && !isEnabled) {
    await flutterBluetoothSerial.requestEnable();
  }
}

void disableBluetooth() async {
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;

  bool? isEnabled = await flutterBluetoothSerial.isEnabled;

  if (isEnabled != null && isEnabled) {
    await flutterBluetoothSerial.requestDisable();
  }
} 