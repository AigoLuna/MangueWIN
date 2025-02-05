import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mangueweb/cubit/live_cubit.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:mangueweb/screens/home_screen.dart';
import 'package:mangueweb/screens/live_screen.dart';
import 'package:mangueweb/screens/settings.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:embedded_serialport/embedded_serialport.dart';(incompativel com windows)

int spotIndex = 0;

late SerialPort port;
late bool isOpen;
late SerialPortConfig config;
List<int> buffer = [];
bool leituraAtiva = true;

int acc_x = 0;
int acc_y = 0;
int acc_z = 0;
int dps_x = 0;
int dps_y = 0;
int dps_z = 0;
int rpm = 0;
int speed = 0;
int temperature = 0;
int flags = 0;
int soc = 0;
int cvt = 0;
int sat = 0;
double roundedValue = 0.0;

int value1 = 0,
    value2 = 0,
    value3 = 0,
    value4 = 0,
    value5 = 0,
    value6 = 0,
    value7 = 0,
    value8 = 0,
    value9 = 0,
    value10 = 0;
int value11 = 0,
    value12 = 0,
    value13 = 0,
    value14 = 0,
    value15 = 0,
    value16 = 0,
    value17 = 0,
    value18 = 0,
    value19 = 0,
    value20 = 0;
int value21 = 0,
    value22 = 0,
    value23 = 0,
    value24 = 0,
    value25 = 0,
    value26 = 0,
    value27 = 0,
    value28 = 0,
    value29 = 0,
    value30 = 0;
int value31 = 0,
    value32 = 0,
    value33 = 0,
    value34 = 0,
    value35 = 0,
    value36 = 0,
    value37 = 0,
    value38 = 0,
    value39 = 0,
    value40 = 0;
int value41 = 0,
    value42 = 0,
    value43 = 0,
    value44 = 0,
    value45 = 0,
    value46 = 0,
    value47 = 0;

void processPacket(List<int> packet) {
  debugPrint('Processing packet: $packet');

  double convertBytesToDouble(
      int b0, int b1, int b2, int b3, int b4, int b5, int b6, int b7) {
    final byteData = ByteData(8);
    byteData.setInt8(0, b0);
    byteData.setInt8(1, b1);
    byteData.setInt8(2, b2);
    byteData.setInt8(3, b3);
    byteData.setInt8(4, b4);
    byteData.setInt8(5, b5);
    byteData.setInt8(6, b6);
    byteData.setInt8(7, b7);

    return byteData.getFloat64(0, Endian.little);
  }

  double bytesToFloat(int value22, int value23, int value24, int value25,
      {Endian endian = Endian.little}) {
    ByteData byteData = ByteData(4);

    if (endian == Endian.little) {
      byteData.setUint8(0, value22);
      byteData.setUint8(1, value23);
      byteData.setUint8(2, value24);
      byteData.setUint8(3, value25);
    }

    return byteData.getFloat32(0, endian);
  }

  acc_x = (value3 << 8) | value2;
  acc_y = (value5 << 8) | value4;
  acc_z = (value7 << 8) | value6;
  dps_x = (value9 << 8) | value8;
  dps_y = (value11 << 8) | value10;
  dps_z = (value13 << 8) | value12;
  rpm = (value15 << 8) | value14;
  speed = (value17 << 8) | value16;
  double latitude = convertBytesToDouble(packet[25], packet[26], packet[27],
      packet[28], packet[29], packet[30], packet[31], packet[32]);

  double longitude = convertBytesToDouble(packet[33], packet[34], packet[35],
      packet[36], packet[37], packet[38], packet[39], packet[40]);
  int timestamp =
      (value42) | (value43 << 8) | (value44 << 16) | (value45 << 24);
  double valueLittleEndian =
      bytesToFloat(value22, value23, value24, value25, endian: Endian.little);
  roundedValue = (valueLittleEndian * 10000).roundToDouble() / 10000;

  temperature = value18;
  flags = value19;
  soc = value20;
  cvt = value21;
  sat = value46;

  debugPrint('acc_x: $acc_x');
  debugPrint('acc_y: $acc_y');
  debugPrint('acc_z: $acc_z');
  debugPrint('dps_x: $dps_x');
  debugPrint('dps_y: $dps_y');
  debugPrint('dps_z: $dps_z');
  debugPrint('rpm: $rpm');
  debugPrint('speed: $speed');
  debugPrint('temperature: $temperature');
  debugPrint('flags: $flags');
  debugPrint('soc: $soc');
  debugPrint('cvt: $cvt');
  debugPrint('volt: $roundedValue');
  debugPrint('latitude: $latitude');
  debugPrint('longitude: $longitude');
  debugPrint('timestamp: $timestamp');
  debugPrint('sat: $sat');
}

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({Key? key}) : super(key: key);

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 11,
  );

  void readData() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        final data = await port.read(port.bytesAvailable);

        if (data.isNotEmpty) {
          setState(() {
            debugPrint("Valor de cvt: $cvt");
          });

          String receivedData = String.fromCharCodes(data);
          buffer.addAll(data);

          if (buffer.length >= 50) {
            for (int i = 0; i < 50; i++) {
              if (i < buffer.length) {
                switch (i) {
                  case 0:
                    value1 = buffer[i];
                    break;
                  case 1:
                    value2 = buffer[i];
                    break;
                  case 2:
                    value3 = buffer[i];
                    break;
                  case 3:
                    value4 = buffer[i];
                    break;
                  case 4:
                    value5 = buffer[i];
                    break;
                  case 5:
                    value6 = buffer[i];
                    break;
                  case 6:
                    value7 = buffer[i];
                    break;
                  case 7:
                    value8 = buffer[i];
                    break;
                  case 8:
                    value9 = buffer[i];
                    break;
                  case 9:
                    value10 = buffer[i];
                    break;
                  case 10:
                    value11 = buffer[i];
                    break;
                  case 11:
                    value12 = buffer[i];
                    break;
                  case 12:
                    value13 = buffer[i];
                    break;
                  case 13:
                    value14 = buffer[i];
                    break;
                  case 14:
                    value15 = buffer[i];
                    break;
                  case 15:
                    value16 = buffer[i];
                    break;
                  case 16:
                    value17 = buffer[i];
                    break;
                  case 17:
                    value18 = buffer[i];
                    break;
                  case 18:
                    value19 = buffer[i];
                    break;
                  case 19:
                    value20 = buffer[i];
                    break;
                  case 20:
                    value21 = buffer[i];
                    break;
                  case 21:
                    value22 = buffer[i];
                    break;
                  case 22:
                    value23 = buffer[i];
                    break;
                  case 23:
                    value24 = buffer[i];
                    break;
                  case 24:
                    value25 = buffer[i];
                    break;
                  case 25:
                    value26 = buffer[i];
                    break;
                  case 26:
                    value27 = buffer[i];
                    break;
                  case 27:
                    value28 = buffer[i];
                    break;
                  case 28:
                    value29 = buffer[i];
                    break;
                  case 30:
                    value31 = buffer[i];
                    break;
                  case 31:
                    value32 = buffer[i];
                    break;
                  case 32:
                    value33 = buffer[i];
                    break;
                  case 33:
                    value34 = buffer[i];
                    break;
                  case 34:
                    value35 = buffer[i];
                    break;
                  case 35:
                    value36 = buffer[i];
                    break;
                  case 36:
                    value37 = buffer[i];
                    break;
                  case 37:
                    value38 = buffer[i];
                    break;
                  case 38:
                    value39 = buffer[i];
                    break;
                  case 39:
                    value40 = buffer[i];
                    break;
                  case 40:
                    value41 = buffer[i];
                    break;
                  case 41:
                    value42 = buffer[i];
                    break;
                  case 42:
                    value43 = buffer[i];
                    break;
                  case 43:
                    value44 = buffer[i];
                    break;
                  case 44:
                    value45 = buffer[i];
                    break;
                  case 45:
                    value46 = buffer[i];
                    break;
                  case 46:
                    value47 = buffer[i];
                    break;
                  case 47:

                  // Continue similarly for all other indices
                  default:
                    break;
                }
              }
            }
            processPacket(buffer.sublist(0, 50));
            buffer.removeRange(0, 50);
          }
        } else {
          buffer.clear();
        }
      } catch (e) {
        debugPrint('Erro ao ler dados: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    List<String> availablePorts = SerialPort.availablePorts;
    debugPrint('Available ports: $availablePorts');

    String targetPort = 'COM6';
    if (availablePorts.contains(targetPort)) {
      debugPrint('Found port: $targetPort');
      port = SerialPort(targetPort);
      isOpen = port.openReadWrite();

      if (isOpen) {
        debugPrint('Port $targetPort opened successfully.');
        config = SerialPortConfig();
        config.baudRate = 115200;
        port.config = config;

        readData();
      } else {
        debugPrint('Failed to open port $targetPort.');
      }
    } else {
      debugPrint('Port $targetPort not available.');
    }
  }

  // ignore: unused_field
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveCubit, LiveState>(
      builder: (context, state) {
        if (state is DataState) {
          List<FlSpot> speedSpots = [];
          List<FlSpot> rpmSpots = [];
          List<FlSpot> temperatureMotorSpots = [];
          List<FlSpot> temperatureCVTSpots = [];
          List<FlSpot> socSpots = [];
          List<FlSpot> voltageSpots = [];
          List<FlSpot> curentSpots = [];
          List<LatLng> gpsSpots = [];
          List<FlSpot> accxSpots = [];
          List<FlSpot> accySpots = [];
          List<FlSpot> acczSpots = [];
          List<FlSpot> rollSpots = [];
          List<FlSpot> pitchSpots = [];

          for (var element in state.packets) {
            speedSpots.add(FlSpot(element.time, element.speed));
            rpmSpots.add(FlSpot(element.time, element.rpm));
            temperatureMotorSpots
                .add(FlSpot(element.time, element.temperatureMotor));
            temperatureCVTSpots
                .add(FlSpot(element.time, element.temperatureCVT));
            socSpots.add(FlSpot(element.time, element.soc));
            voltageSpots.add(FlSpot(element.time, element.voltage));
            curentSpots.add(FlSpot(element.time, element.current));
            gpsSpots.add(LatLng(element.latitude, element.longitude));
            accxSpots.add(FlSpot(element.time, element.accx));
            accySpots.add(FlSpot(element.time, element.accy));
            acczSpots.add(FlSpot(element.time, element.accz));
            rollSpots.add(FlSpot(element.time, element.roll));
            pitchSpots.add(FlSpot(element.time, element.pitch));
          }

          _controller.future.then((controller) {
            controller.animateCamera(CameraUpdate.newLatLng(gpsSpots.last));
          });

          return Material(
            color: const Color.fromRGBO(251, 251, 251, 1),
            child: Row(
              children: [
                Container(
                  width: 220,
                  height: double
                      .infinity, // Usando double.infinity para altura infinita
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(0, 19, 150, 1),
                          Color.fromRGBO(52, 141, 107, 1),
                        ],
                      )),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      SizedBox(
                        height: 80,
                        child: Image.asset(
                          'assets/images/navbar_logo.png',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent),
                          width: 188,
                          height: 36,
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(
                                  Icons.home,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Home", // Your text here
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SettingsScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent),
                          width: 188,
                          height: 36,
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const LiveScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(0, 110, 119, 180)),
                          width: 188,
                          height: 36,
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(
                                  Icons.wifi,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Wi-Fi", // Your text here
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await launchUrl(
                              Uri.parse(
                                  'https://drive.google.com/drive/folders/1bhZz_3j1MWmD68m_6fV16VC4WkOj0_Dd?usp=sharing'),
                              webOnlyWindowName: '_blank');
                        },
                        child: SingleChildScrollView(
                            child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent),
                          width: 188,
                          height: 36,
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(
                                  Icons.storage,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Backup", // Your text here
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const TelemetryScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent),
                          width: 188,
                          height: 36,
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(
                                  Icons.radio_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Radio", // Your text here
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    //height: double.infinity,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                _dataCard(
                                  Center(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "Temperaturas", // Your text here
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Roboto',
                                            color: Color.fromRGBO(
                                                130, 130, 130, 1),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              spotIndex = 2;
                                              Navigator.pushNamed(
                                                  context, 'graph');
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 0, 16, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${temperature} °C", // Your text here
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          5, 24, 154, 1),
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Motor", // Your text here
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          130, 130, 130, 1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              spotIndex = 3;
                                              Navigator.pushNamed(
                                                  context, 'graph');
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      40, 0, 16, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${cvt} °C", // Your text here
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          5, 24, 154, 1),
                                                    ),
                                                  ),
                                                  const Text(
                                                    "CVT", // Your text here
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          130, 130, 130, 1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                                  300,
                                  140,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                _dataCard(
                                  Center(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          "Bateria", // Your text here
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Roboto',
                                            color: Color.fromRGBO(
                                                130, 130, 130, 1),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              spotIndex = 4;
                                              Navigator.pushNamed(
                                                  context, 'graph');
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      40, 0, 16, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${soc}%", // Your text here
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          5, 24, 154, 1),
                                                    ),
                                                  ),
                                                  const Text(
                                                    "SoC", // Your text here
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          130, 130, 130, 1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              spotIndex = 5;
                                              Navigator.pushNamed(
                                                  context, 'graph');
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      40, 0, 40, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${roundedValue} V", // Your text here
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          5, 24, 154, 1),
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Tensão", // Your text here
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Roboto',
                                                      color: Color.fromRGBO(
                                                          130, 130, 130, 1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          //InkWell(
                                          //  onTap: () {
                                          //    spotIndex = 6;
                                          //    Navigator.pushNamed(
                                          //        context, 'graph');
                                          //  },
                                          //child: Padding(
                                          //  padding:
                                          //      const EdgeInsets.fromLTRB(
                                          //          16, 0, 16, 0),
                                          //  child: Column(
                                          //    crossAxisAlignment:
                                          //        CrossAxisAlignment.start,
                                          //    children: [
                                          //      Text(
                                          //        "${(curentSpots.last.y * 1000).round()} mA", // Your text here
                                          //        style: const TextStyle(
                                          //          fontSize: 32,
                                          //          fontWeight:
                                          //              FontWeight.w500,
                                          //          fontFamily: 'Roboto',
                                          //          color: Color.fromRGBO(
                                          //              5, 24, 154, 1),
                                          //        ),
                                          //      ),
                                          //      const Text(
                                          //        "Corrente", // Your text here
                                          //        style: TextStyle(
                                          //          fontSize: 16,
                                          //          fontWeight:
                                          //              FontWeight.w500,
                                          //          fontFamily: 'Roboto',
                                          //          color: Color.fromRGBO(
                                          //              130, 130, 130, 1),
                                          //        ),
                                          //      ),
                                          //    ],
                                          //  ),
                                          //),
                                          //),
                                        ],
                                      )
                                    ],
                                  )),
                                  520,
                                  140,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                              child: Center(
                                child: Text(
                                  "Velocidade e Rotação", // Your text here
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                    color: Color.fromRGBO(130, 130, 130, 1),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                _dataCard(
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: LineChart(LineChartData(
                                        lineTouchData: LineTouchData(
                                            touchCallback: (event, response) {
                                              if (event is FlTapUpEvent) {
                                                if (response != null &&
                                                    response.lineBarSpots !=
                                                        null) {
                                                  spotIndex = 0;
                                                  Navigator.pushNamed(
                                                      context, 'graph');
                                                }
                                              }
                                            },
                                            touchTooltipData:
                                                const LineTouchTooltipData(
                                                    tooltipRoundedRadius: 10,
                                                    tooltipBgColor:
                                                        Colors.white)),
                                        titlesData: const FlTitlesData(
                                          show: true,
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 24,
                                              interval: 100,
                                              getTitlesWidget:
                                                  bottomTitleWidgets,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 10,
                                              reservedSize: 32,
                                              getTitlesWidget: leftTitleWidgets,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        minX: speedSpots.first.x,
                                        maxX: speedSpots.last.x,
                                        minY: 0,
                                        maxY: 60,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: speedSpots,
                                            isCurved: true,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromRGBO(0, 106, 213, 1),
                                                Color.fromRGBO(0, 19, 150, 1),
                                              ],
                                            ),
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                            belowBarData: BarAreaData(
                                              show: false,
                                              gradient: LinearGradient(
                                                colors: const [
                                                  Color.fromRGBO(
                                                      90, 106, 213, 1),
                                                  Color.fromRGBO(0, 19, 150, 1),
                                                ]
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                  410,
                                  280,
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                _dataCard(
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: LineChart(LineChartData(
                                        lineTouchData: LineTouchData(
                                            touchCallback: (event, response) {
                                              if (event is FlTapUpEvent) {
                                                if (response != null &&
                                                    response.lineBarSpots !=
                                                        null) {
                                                  spotIndex = 1;
                                                  Navigator.pushNamed(
                                                      context, 'graph');
                                                }
                                              }
                                            },
                                            touchTooltipData:
                                                const LineTouchTooltipData(
                                                    tooltipRoundedRadius: 10,
                                                    tooltipBgColor:
                                                        Colors.white)),
                                        titlesData: const FlTitlesData(
                                          show: true,
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 24,
                                              interval: 100,
                                              getTitlesWidget:
                                                  bottomTitleWidgets,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1000,
                                              reservedSize: 50,
                                              getTitlesWidget: leftTitleWidgets,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        minX: rpmSpots.first.x,
                                        maxX: rpmSpots.last.x,
                                        minY: 0,
                                        maxY: 10000,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: rpmSpots,
                                            isCurved: true,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromRGBO(0, 106, 213, 1),
                                                Color.fromRGBO(0, 19, 150, 1),
                                              ],
                                            ),
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                            belowBarData: BarAreaData(
                                              show: false,
                                              gradient: LinearGradient(
                                                colors: const [
                                                  Color.fromRGBO(
                                                      90, 106, 213, 1),
                                                  Color.fromRGBO(0, 19, 150, 1),
                                                ]
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                  410,
                                  280,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                              child: Center(
                                child: Text(
                                  "Acelerações", // Your text here
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                    color: Color.fromRGBO(130, 130, 130, 1),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                _dataCard(
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: LineChart(LineChartData(
                                        lineTouchData: LineTouchData(
                                            touchCallback: (event, response) {
                                              if (event is FlTapUpEvent) {
                                                if (response != null &&
                                                    response.lineBarSpots !=
                                                        null) {
                                                  spotIndex = 7;
                                                  Navigator.pushNamed(
                                                      context, 'graph');
                                                }
                                              }
                                            },
                                            touchTooltipData:
                                                const LineTouchTooltipData(
                                                    tooltipRoundedRadius: 10,
                                                    tooltipBgColor:
                                                        Colors.white)),
                                        titlesData: const FlTitlesData(
                                          show: true,
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 24,
                                              interval: 100,
                                              getTitlesWidget:
                                                  bottomTitleWidgets,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 0.5,
                                              reservedSize: 32,
                                              getTitlesWidget: leftTitleWidgets,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        minX: accxSpots.first.x,
                                        maxX: accxSpots.last.x,
                                        minY: -2,
                                        maxY: 2,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: accxSpots,
                                            isCurved: true,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromRGBO(0, 106, 213, 1),
                                                Color.fromRGBO(0, 19, 150, 1),
                                              ],
                                            ),
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                            belowBarData: BarAreaData(
                                              show: false,
                                              gradient: LinearGradient(
                                                colors: const [
                                                  Color.fromRGBO(
                                                      90, 106, 213, 1),
                                                  Color.fromRGBO(0, 19, 150, 1),
                                                ]
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                  270,
                                  200,
                                ),
                                const SizedBox(
                                  width: 13,
                                ),
                                _dataCard(
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: LineChart(LineChartData(
                                        lineTouchData: LineTouchData(
                                            touchCallback: (event, response) {
                                              if (event is FlTapUpEvent) {
                                                if (response != null &&
                                                    response.lineBarSpots !=
                                                        null) {
                                                  spotIndex = 8;
                                                  Navigator.pushNamed(
                                                      context, 'graph');
                                                }
                                              }
                                            },
                                            touchTooltipData:
                                                const LineTouchTooltipData(
                                                    tooltipRoundedRadius: 10,
                                                    tooltipBgColor:
                                                        Colors.white)),
                                        titlesData: const FlTitlesData(
                                          show: true,
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 24,
                                              interval: 100,
                                              getTitlesWidget:
                                                  bottomTitleWidgets,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 0.5,
                                              reservedSize: 32,
                                              getTitlesWidget: leftTitleWidgets,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        minX: accySpots.first.x,
                                        maxX: accySpots.last.x,
                                        minY: -2,
                                        maxY: 2,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: accySpots,
                                            isCurved: true,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromRGBO(0, 106, 213, 1),
                                                Color.fromRGBO(0, 19, 150, 1),
                                              ],
                                            ),
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                            belowBarData: BarAreaData(
                                              show: false,
                                              gradient: LinearGradient(
                                                colors: const [
                                                  Color.fromRGBO(
                                                      90, 106, 213, 1),
                                                  Color.fromRGBO(0, 19, 150, 1),
                                                ]
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                  270,
                                  200,
                                ),
                                const SizedBox(
                                  width: 13,
                                ),
                                _dataCard(
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: LineChart(LineChartData(
                                        lineTouchData: LineTouchData(
                                            touchCallback: (event, response) {
                                              if (event is FlTapUpEvent) {
                                                if (response != null &&
                                                    response.lineBarSpots !=
                                                        null) {
                                                  spotIndex = 9;
                                                  Navigator.pushNamed(
                                                      context, 'graph');
                                                }
                                              }
                                            },
                                            touchTooltipData:
                                                const LineTouchTooltipData(
                                                    tooltipRoundedRadius: 10,
                                                    tooltipBgColor:
                                                        Colors.white)),
                                        titlesData: const FlTitlesData(
                                          show: true,
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize: 24,
                                              interval: 100,
                                              getTitlesWidget:
                                                  bottomTitleWidgets,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 0.5,
                                              reservedSize: 32,
                                              getTitlesWidget: leftTitleWidgets,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        minX: acczSpots.first.x,
                                        maxX: acczSpots.last.x,
                                        minY: -2,
                                        maxY: 2,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: acczSpots,
                                            isCurved: true,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color.fromRGBO(0, 106, 213, 1),
                                                Color.fromRGBO(0, 19, 150, 1),
                                              ],
                                            ),
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                            belowBarData: BarAreaData(
                                              show: false,
                                              gradient: LinearGradient(
                                                colors: const [
                                                  Color.fromRGBO(
                                                      90, 106, 213, 1),
                                                  Color.fromRGBO(0, 19, 150, 1),
                                                ]
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                  270,
                                  200,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            _dataCard(
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: GoogleMap(
                                  zoomControlsEnabled: false,
                                  mapType: MapType.hybrid,
                                  initialCameraPosition: _kGooglePlex,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _controller.complete(controller);
                                  },
                                  polylines: {
                                    Polyline(
                                      polylineId: const PolylineId('route'),
                                      points: gpsSpots,
                                      color: Colors.blue,
                                      width: 5,
                                    ),
                                  },
                                ),
                              ),
                              400,
                              400,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            _dataCard(
                              Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      spotIndex = 11;
                                      Navigator.pushNamed(context, 'graph');
                                    },
                                    child: SizedBox(
                                      width: 172,
                                      child: Transform.rotate(
                                        angle: pitchSpots.last.y *
                                            3.14159265358979323 /
                                            180,
                                        child: Image.asset(
                                          'assets/images/baja_side.png',
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 32,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      spotIndex = 10;
                                      Navigator.pushNamed(context, 'graph');
                                    },
                                    child: SizedBox(
                                      width: 129,
                                      child: Transform.rotate(
                                          angle: rollSpots.last.y *
                                              3.14159265358979323 /
                                              180,
                                          child: Image.asset(
                                            'assets/images/baja_front.png',
                                            fit: BoxFit.fitWidth,
                                          )),
                                    ),
                                  ),
                                ],
                              )),
                              400,
                              285,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }

        @override
        void dispose() {
          if (isOpen) {
            port.close();
          }
          super.dispose();
        }

        return Container();
      },
    );
  }
}

Container _dataCard(Widget child, double width, double height) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(154, 170, 207, 0.15),
          blurRadius: 40,
          offset: Offset(0, 16),
        )
      ],
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: child,
  );
}

Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  Text text = Text(value.toString(), style: style, textAlign: TextAlign.left);

  return text;
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontFamily: "Roboto",
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
  Widget text = Text(value.toString(), style: style);

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}
