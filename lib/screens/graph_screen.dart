import 'dart:convert';
import 'dart:ui';
import 'package:universal_html/html.dart' as html;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mangueweb/cubit/live_cubit.dart';
import 'package:mangueweb/screens/live_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String dropdownValue = 'Tipo de teste';
  TextEditingController rangeStart = TextEditingController();
  TextEditingController rangeEnd = TextEditingController();
  TextEditingController plotName = TextEditingController();
  TextEditingController plotDescription = TextEditingController();
  GlobalKey globalKey = GlobalKey();

  List<String> dropdownItems = ['Tipo de teste', 'AV', 'Freio', 'Suspensão'];
  bool paused = false;

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveCubit, LiveState>(
      builder: (context, state) {
        if (state is DataState) {
          if (!paused) {
            speedSpots = [];
            rpmSpots = [];
            temperatureMotorSpots = [];
            temperatureCVTSpots = [];
            socSpots = [];
            voltageSpots = [];
            curentSpots = [];
            gpsSpots = [];
            accxSpots = [];
            accySpots = [];
            acczSpots = [];
            rollSpots = [];
            pitchSpots = [];

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
          }
          List<List<FlSpot>> allSpots = [
            speedSpots,
            rpmSpots,
            temperatureMotorSpots,
            temperatureCVTSpots,
            socSpots,
            voltageSpots,
            curentSpots,
            accxSpots,
            accySpots,
            acczSpots,
            rollSpots,
            pitchSpots
          ];

          List<FlSpot> selectedSpots = allSpots[spotIndex];
          double selectedSpotsMin = 0;
          double selectedSpotsMax = 100;
          double selectedSpotsDiv = 10;
          String selectedSpotsName = "Waiting";

          switch (spotIndex) {
            case 0:
              selectedSpotsMin = 0;
              selectedSpotsMax = 60;
              selectedSpotsDiv = 10;
              selectedSpotsName = "Velocidade";
            case 1:
              selectedSpotsMin = 0;
              selectedSpotsMax = 10000;
              selectedSpotsDiv = 1000;
              selectedSpotsName = "Rotação";
            case 2:
              selectedSpotsMin = 0;
              selectedSpotsMax = 100;
              selectedSpotsDiv = 10;
              selectedSpotsName = "Temperatura do motor";
            case 3:
              selectedSpotsMin = 0;
              selectedSpotsMax = 150;
              selectedSpotsDiv = 20;
              selectedSpotsName = "Temperatura da CVT";
            case 4:
              selectedSpotsMin = 0;
              selectedSpotsMax = 100;
              selectedSpotsDiv = 10;
              selectedSpotsName = "State of Charge";
            case 5:
              selectedSpotsMin = 0;
              selectedSpotsMax = 15;
              selectedSpotsDiv = 2;
              selectedSpotsName = "Tensão";
            case 6:
              selectedSpotsMin = 0;
              selectedSpotsMax = 4;
              selectedSpotsDiv = 1;
              selectedSpotsName = "Corrente";
            case 7:
              selectedSpotsMin = -4;
              selectedSpotsMax = 4;
              selectedSpotsDiv = 0.5;
              selectedSpotsName = "Aceleração X";
            case 8:
              selectedSpotsMin = -4;
              selectedSpotsMax = 4;
              selectedSpotsDiv = 0.5;
              selectedSpotsName = "Aceleração Y";
            case 9:
              selectedSpotsMin = -4;
              selectedSpotsMax = 4;
              selectedSpotsDiv = 0.5;
              selectedSpotsName = "Aceleração Z";
            case 10:
              selectedSpotsMin = -180;
              selectedSpotsMax = 180;
              selectedSpotsDiv = 45;
              selectedSpotsName = "Roll";
            case 11:
              selectedSpotsMin = -180;
              selectedSpotsMax = 180;
              selectedSpotsDiv = 45;
              selectedSpotsName = "Pitch";
            default:
              selectedSpotsMin = 0;
              selectedSpotsMax = 100;
              selectedSpotsName = "Waiting";
          }

          return Material(
            color: const Color.fromRGBO(251, 251, 251, 1),
            child: Row(
              children: [
                Container(
                  width: 220,
                  height: Size.infinite.height,
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
                          Color.fromRGBO(90, 106, 213, 1),
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
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
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
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromRGBO(110, 119, 180, 1)),
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
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          await launchUrl(
                              Uri.parse(
                                  'https://drive.google.com/drive/folders/1bhZz_3j1MWmD68m_6fV16VC4WkOj0_Dd?usp=sharing'),
                              webOnlyWindowName: '_blank');
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
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                   
                    width: double.infinity,
                    
                   child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                    child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        RepaintBoundary(
                          key: globalKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  selectedSpotsName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                    color: Color.fromRGBO(130, 130, 130, 1),
                                  ),
                                ),
                                const SizedBox(
                                  height: 64,
                                ),
                                SizedBox(
                                  width: 920,
                                  height: 500,
                                  child: LineChart(LineChartData(
                                    lineTouchData: const LineTouchData(
                                        touchTooltipData: LineTouchTooltipData(
                                            tooltipRoundedRadius: 10,
                                            tooltipBgColor: Colors.white)),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 24,
                                          interval: 50,
                                          getTitlesWidget: bottomTitleWidgets,
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: selectedSpotsDiv,
                                          reservedSize: 50,
                                          getTitlesWidget: leftTitleWidgets,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    minX: selectedSpots.first.x,
                                    maxX: selectedSpots.last.x,
                                    minY: selectedSpotsMin,
                                    maxY: selectedSpotsMax,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: selectedSpots,
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
                                              Color.fromRGBO(90, 106, 213, 1),
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
                                )
                              ]),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        _dataCard(
                            Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      paused = !paused;
                                    });
                                  },
                                  child: Icon(
                                    paused
                                        ? Icons.play_circle_outline
                                        : Icons
                                            .pause_circle_outline, // Example icon
                                    size: 150,
                                    color: paused
                                        ? const Color.fromRGBO(1, 173, 50, 1)
                                        : const Color.fromRGBO(0, 19, 150, 1),
                                    shadows: [
                                      paused
                                          ? const Shadow(
                                              color: Color.fromRGBO(
                                                  1, 173, 50, 0.15),
                                              offset: Offset(0, 16),
                                              blurRadius: 40)
                                          : const Shadow(
                                              color: Color.fromRGBO(
                                                  0, 19, 150, 0.15),
                                              offset: Offset(0, 16),
                                              blurRadius: 40)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40), // Spacing
                                Container(
                                  width: 300,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(
                                          234, 234, 234, 1), // Border color
                                      width: 1, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromRGBO(238, 242, 255, 1),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: dropdownValue,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            dropdownValue = newValue!;
                                          });
                                        },
                                        items: dropdownItems
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: 'Roboto',
                                                  color: Color.fromRGBO(
                                                      130, 130, 130, 1),
                                                )),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24), // Spacing
                                const Text(
                                  'Selecione o intervalo de tempo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                    color: Color.fromRGBO(130, 130, 130, 1),
                                  ),
                                ),
                                const SizedBox(height: 16), // Spacing
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 62,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              234, 234, 234, 1), // Border color
                                          width: 1, // Border width
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromRGBO(
                                            238, 242, 255, 1),
                                      ),
                                      child: TextField(
                                        controller: rangeStart,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '0',
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^[0-3]?[0-9]?[0-9]?$')),
                                        ],
                                      ),
                                    ),
                                    const Text(
                                      '   --------   ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Roboto',
                                        color: Color.fromRGBO(130, 130, 130, 1),
                                      ),
                                    ),
                                    Container(
                                      width: 62,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              234, 234, 234, 1), // Border color
                                          width: 1, // Border width
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromRGBO(
                                            238, 242, 255, 1),
                                      ),
                                      child: TextField(
                                        controller: rangeEnd,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '399',
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^[0-3]?[0-9]?[0-9]?$')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24), // Spacing
                                Container(
                                  width: 300,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(
                                          234, 234, 234, 1), // Border color
                                      width: 1, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromRGBO(238, 242, 255, 1),
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 10),
                                  child: TextField(
                                    controller: plotName,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Nome do gráfico',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                      color: Color.fromRGBO(130, 130, 130, 1),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Container(
                                  width: 300,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromRGBO(
                                          234, 234, 234, 1), // Border color
                                      width: 1, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromRGBO(238, 242, 255, 1),
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 10),
                                  child: TextField(
                                    controller: plotDescription,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Descrição',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                      color: Color.fromRGBO(130, 130, 130, 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                InkWell(
                                  onTap: () async {
                                    RenderRepaintBoundary boundary = globalKey
                                            .currentContext!
                                            .findRenderObject()!
                                        as RenderRepaintBoundary;
                                    //captures qr image
                                    var image = await boundary.toImage();

                                    ByteData? byteData = await image.toByteData(
                                        format: ImageByteFormat.png);
                                    Uint8List pngBytes =
                                        byteData!.buffer.asUint8List();
                                    final base64 = base64Encode(pngBytes);
                                    final anchor = html.AnchorElement(
                                        href:
                                            'data:application/octet-stream;base64,$base64')
                                      ..download =
                                          "${dropdownValue}_${plotName.text}.png"
                                      ..target = 'blank';

                                    html.document.body!.append(anchor);
                                    anchor.click();

                                    downloadCSV(
                                        plotDescription.text,
                                        selectedSpotsName,
                                        selectedSpots.sublist(
                                            int.parse(rangeStart.text),
                                            int.parse(rangeEnd.text)),
                                        '${dropdownValue}_${plotName.text}');

                                    anchor.remove();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Salvar   ", // Your text here
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Roboto',
                                          color: Color.fromRGBO(1, 173, 50, 1),
                                        ),
                                      ),
                                      Icon(
                                        Icons.download,
                                        size: 20,
                                        color: Color.fromRGBO(1, 173, 50, 1),
                                      ),
                                      SizedBox(width: 32),
                                    ],
                                  ),
                                )
                              ],
                            )),
                            350,
                            Size.infinite.height)
                      ],
                    ),
                  ),
                )
                )
              ],
            ),
          );
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

void downloadCSV(
    String description, String value, List<FlSpot> data, String fileName) {
  // Combine headers and data into a CSV string
  final csvContent = StringBuffer();
  csvContent.writeln(description); // Add headers
  csvContent.writeln('id,$value'); // Add headers

  for (final row in data) {
    csvContent.writeln('${row.x},${row.y}'); // Add each row of data
  }

  // Convert the CSV string to a blob and create an Object URL for it
  final bytes = utf8.encode(csvContent.toString());
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Use an anchor element for the download
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "$fileName.csv");

  html.document.body!.append(anchor);
  anchor.click();
}
