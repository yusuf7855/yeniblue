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
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
              child: ElevatedButton(
                onPressed: () {
                  enableBluetooth();
                },
                child: const Text("BLUETOOTH AÇ"),
              ),
            ),
            Padding(
              padding:EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
              child: ElevatedButton(
                onPressed: () {
                  sendBluetoothData(context);
                },
                child: const Text("Veriyi Yolla"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
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

  void _navigateToBluetoothPage(BuildContext context) async {
    BluetoothDevice? selectedDevice = await Navigator.push( // BluetoothPage'e yönlendirme yapılıyor ve seçilen cihaz döndürülüyor
      context,
      MaterialPageRoute(builder: (context) => BluetoothPage()),
    );
    if (selectedDevice != null) {  // Seçilen bir cihaz varsa, cihaza bağlanılıyor
      _connectToDevice(selectedDevice);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Bluetooth cihaza bağlanılıyor
      connection = await BluetoothConnection.toAddress(device.address);
      // Bağlantı başarılı olduğunda durum güncelleniyor
      setState(() {
        stateD = 'Durum: BAĞLANTI BAŞARILI';
      });
// Gelen veriler dinleniyor
      connection!.input!.listen((Uint8List data) {
        setState(() {
          print('Gelen veri: ${ascii.decode(data)}');
        });
// Gelen veri tekrar gönderiliyor
        connection!.output.add(data); // Sending data
// Gelen veride '!' karakteri varsa bağlantı kapatılıyor
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
      // Eşleştirilmiş Bluetooth cihazları alınıyor
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();

      // Cihaz listesi güncelleniyor
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
              // Seçilen cihaz geri döndürülüyor
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
    // Bluetooth'u etkinleştirmek için kullanıcıdan izin isteniyor
    await flutterBluetoothSerial.requestEnable();
  }
}

void disableBluetooth() async {
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;

  bool? isEnabled = await flutterBluetoothSerial.isEnabled;

  if (isEnabled != null && isEnabled) {
    // Bluetooth'u devre dışı bırakmak için kullanıcıdan izin isteniyor
    await flutterBluetoothSerial.requestDisable();
  }
}

void sendBluetoothData(BuildContext context) async {
  BluetoothConnection? connection; // Bluetooth bağlantısı için değişken tanımlanıyor

  BluetoothDevice? selectedDevice = await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) {
      return BluetoothPage();
    }),
  );

  // BluetoothPage'inden seçilen cihaz alınıyor

  if (selectedDevice != null) {
    try {
      connection = await BluetoothConnection.toAddress(selectedDevice.address);
      // Seçilen cihazın adresine bağlantı yapılıyor
      print('Bağlantı kuruldu: ${selectedDevice.name}');

      Uint8List dataToSend = Uint8List.fromList([0x01]);
      connection.output.add(dataToSend); // Veri gönderiliyor
      // 0x01 değerini veri olarak gönderir

      connection.input!.listen((Uint8List data) {
        print('Gelen veri: ${ascii.decode(data)}');
        connection!.output.add(data); // Veri gönderiliyor
        // Gelen veriyi ekrana yazdırır ve tekrar gönderir
      }).onDone(() {
        print('Bağlantı kesildi');
        // Veri alımı tamamlandığında bağlantı kesildiğini belirtir
      });

      print('Veri gönderildi: 0x01');
      // Veri başarıyla gönderildiğini belirtir
    } catch (error) {
      print('Bağlantı hatası: $error');
      // Bağlantı hatası durumunda hata mesajı yazdırılır
    }
  }
}

