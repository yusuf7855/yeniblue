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
  var stateD = "Durum: ";

  BluetoothConnection? connection;

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
    var ekranBilgisi = MediaQuery.of(context);
    final double ekranYuksekligi = ekranBilgisi.size.height;
    final double ekranGenisligi = ekranBilgisi.size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "YUSUF",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stateD,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),



                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          enableBluetooth();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          padding: EdgeInsets.all(16),
                          minimumSize: Size(constraints.maxWidth, 0),
                        ),
                        child: const Text(
                          "BLUETOOTH AÇ",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _navigateToBluetoothPage(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          padding: EdgeInsets.all(16),
                          minimumSize: Size(constraints.maxWidth, 0),
                        ),
                        child: const Text(
                          "BLUETOOTH CİHAZLARINI LİSTELE",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          sendBluetoothData(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          padding: EdgeInsets.all(16),
                          minimumSize: Size(constraints.maxWidth, 0),
                        ),
                        child: const Text(
                          "OTA MODU",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToBluetoothPage(BuildContext context) async {
    BluetoothDevice? selectedDevice = await Navigator.push( // BluetoothPage'e yönlendirme yapılıyor ve seçilen cihaz döndürülüyor
      context,
      MaterialPageRoute(builder: (context) => BluetoothPage()),
    );
    if (selectedDevice != null) {  // Seçilen bir cihaz varsa, cihaza bağlanılıyor
      _connectToDevice(selectedDevice);
    }
  }

  void _disconnectFromDevice() {
    if (connection != null) {
      connection!.finish();
      connection = null;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      stateD = 'Durum: BAĞLANILIYOR...';
    });

    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        this.connection = connection;
        stateD = 'Durum: ${device.name} - Cihazına Bağlantı Kuruldu';
      });
      connection!.input!.listen((Uint8List data) {
        setState(() {
          print('Gelen veri: ${ascii.decode(data)}');
        });
        connection!.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          connection!.finish(); // Closing connection
          // Bağlantı kapatıldığında durum güncelleniyor
          setState(() {
            stateD = 'Durum: BAĞLANTI KESİLDİ';
          });
        }
      }).onDone(() {
        // Veri akışı tamamlandığında durum güncelleniyor
        setState(() {
          stateD = 'Durum: BAĞLANTI KESİLDİ';
        });
      });
      // Bağlantı hatası durumunda durum güncelleniyor
    } catch (exception) {
      setState(() {
        stateD = 'Bağlanamıyor';
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
        title: const Text('BLUETOOTH CİHAZLARI'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(height: 16),
              ..._devices.map((device) => ListTile(
                title: Text(device.name ?? ''),
                onTap: () {
                  Navigator.pop(context, device);
                },
              )),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Geri'),
              ),
            ),
          ),
        ],
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



void sendBluetoothData(BuildContext context) async {
  BluetoothDevice? selectedDevice = await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) {
      return BluetoothPage();
    }),
  );

  BluetoothConnection? connection;
  try {
    if (selectedDevice != null) {
      connection = await BluetoothConnection.toAddress(selectedDevice.address);
      print('Bağlantı kuruldu: ${selectedDevice.name}');

      Uint8List dataToSend = Uint8List.fromList([0x01]);
      connection.output.add(dataToSend);

      connection.input!.listen((Uint8List data) {
        print('Gelen veri: ${ascii.decode(data)}');
        connection!.output.add(data);
      }).onDone(() {
        print('Bağlantı kesildi');
      });

      print('Veri gönderildi: 0x01');
    }
  } catch (error) {
    print('Bağlantı hatası: $error');
  } finally {
    if (connection != null) {
      connection.finish();
    }
  }
}
