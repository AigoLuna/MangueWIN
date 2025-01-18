import 'dart:async';
import 'package:mangueweb/screens/home_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mangueweb/cubit/live_cubit.dart';
import 'package:mangueweb/screens/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mangueweb/screens/telemetry.dart';

int spotIndex = 0;

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 11,
  );

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
                          Color.fromRGBO(100, 118, 235, 1),
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
                              MaterialPageRoute(builder: (context) => const HomeScreen())
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
                              MaterialPageRoute(builder: (context) =>  const SettingsScreen())
                          );
                        },
                        child:
                          Container(
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
                              MaterialPageRoute(builder: (context) => const LiveScreen())
                          );
                        },
                        child:
                          Container(
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

                      InkWell(
                        onTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
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
                    //height: Size.infinite.height,
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
                                                    "${temperatureMotorSpots.last.y} °C", // Your text here
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
                                                    "${temperatureCVTSpots.last.y} °C", // Your text here
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
                                                    "${socSpots.last.y}%", // Your text here
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
                                                    "${voltageSpots.last.y.toStringAsFixed(2)} V", // Your text here
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
                                          InkWell(
                                            onTap: () {
                                              spotIndex = 6;
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
                                                    "${(curentSpots.last.y * 1000).round()} mA", // Your text here
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
                                                    "Corrente", // Your text here
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
                          children:  [
                            const SizedBox(
                              height: 20,
                            ),
                            _dataCard(
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Expanded(
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

