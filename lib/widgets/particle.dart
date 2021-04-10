import 'package:flutter/cupertino.dart';
import 'package:flutter_particles/particles.dart';

Widget particle(context) {
  return Container(
    height: MediaQuery.of(context).size.height,
    child: new Particles(
      20, // Number of Particles
      Color(0xff61e88a), // Color of Particles
    ),
  );
}
