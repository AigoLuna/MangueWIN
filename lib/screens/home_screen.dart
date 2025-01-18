import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangueweb/cubit/live_cubit.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<LiveCubit>(context).startEmittingFloats();

    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(1, 176, 48, 1),
              Color.fromRGBO(0, 17, 152, 1),
            ],
          ),
        ),
        child: CustomPaint(
          painter: SplineDividerPainter(),
          size: Size.infinite,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(), // Container vazio para ocupar espaço
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset('assets/images/mangue_logo.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, 'live');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(5, 112, 34, 0.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(40),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromRGBO(5, 112, 34, 1),
                                  Color.fromRGBO(57, 180, 90, 1),
                                ],
                              ),
                            ),
                            width: 200,
                            height: 51,
                            child: const Center(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                ),
                                child: Text("Mangue Web"),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () async {
                            await launchUrl(
                              Uri.parse(
                                'https://drive.google.com/drive/folders/1bhZz_3j1MWmD68m_6fV16VC4WkOj0_Dd?usp=sharing',
                              ),
                              webOnlyWindowName: '_blank',
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(5, 112, 34, 0.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(40),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromRGBO(5, 112, 34, 1),
                                  Color.fromRGBO(57, 180, 90, 1),
                                ],
                              ),
                            ),
                            width: 200,
                            height: 51,
                            child: const Center(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                  color: Colors.white,
                                ),
                                child: Text("Backup"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SplineDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var path = Path();

    // Start at the middle of the screen
    path.moveTo(size.width / 2, 0);

    // Define some points for the bezier curve
    // These points can be adjusted to create more complex curves
    var firstControlPoint = Offset(size.width * 0.56, size.height * 0.1);
    var firstEndPoint = Offset(size.width * 0.48, size.height * 0.3);
    var secondControlPoint = Offset(size.width * 0.44, size.height * 0.43);
    var secondEndPoint = Offset(size.width * 0.48, size.height * 0.54);
    var thirdControlPoint = Offset(size.width * 0.53, size.height * 0.67);
    var thirdEndPoint = Offset(size.width * 0.45, size.height * 0.77);
    var fourthControlPoint = Offset(size.width * 0.38, size.height * 0.88);
    var fourthEndPoint = Offset(size.width * 0.47, size.height);

    // Draw the bezier curve
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);
    path.quadraticBezierTo(fourthControlPoint.dx, fourthControlPoint.dy,
        fourthEndPoint.dx, fourthEndPoint.dy);

    // Draw a line to the bottom right corner and then to the top right corner
    // to complete the path for the right side of the screen
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    // Draw the path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
