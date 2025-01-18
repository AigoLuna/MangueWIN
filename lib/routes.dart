// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mangueweb/screens/graph_screen.dart';
import 'package:mangueweb/screens/graph_screen_twodart';
import 'package:mangueweb/screens/telemetry.dart';
import 'package:mangueweb/screens/settings.dart';
import 'package:mangueweb/screens/home_screen.dart';
import 'package:mangueweb/screens/live_screen.dart';



class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'graph':
        return MaterialPageRoute(builder: (_) => const GraphScreen());
      case 'live':
        return MaterialPageRoute(builder: (_) => const LiveScreen());
      case 'telemetry':
        return MaterialPageRoute(builder: (_) =>  const TelemetryScreen());
      case 'settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case 'graphtwo':
        return MaterialPageRoute(builder: (_) => GraphScreenTwo());
      
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}






