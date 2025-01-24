import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangueweb/cubit/live_cubit.dart';
import 'package:mangueweb/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LiveCubit(),
          )
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MangueWeb',
          onGenerateRoute: RouteGenerator.generateRoute,
        ));
  }
}
