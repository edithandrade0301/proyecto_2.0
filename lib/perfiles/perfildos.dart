import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:proyecto_progra_movil_grupo1/modelos/cardsdepues.dart';

class Perfildos extends StatefulWidget {
  const Perfildos({super.key, required this.despues});

  final Despues despues;

  @override
  State<Perfildos> createState() => _PerfildosState();
}

class _PerfildosState extends State<Perfildos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.despues.titulo),
        backgroundColor: const Color.fromARGB(255, 240, 170, 216),
        centerTitle: true,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 248, 248, 220), //fondo
      body: ListView.builder(
        itemCount: (widget.despues.imagenes.length / 2).ceil(), // Divide en pares
        itemBuilder: (context, index) {
          final startIndex = index * 2;
          final endIndex = startIndex + 2;

          return getListElement(
            widget.despues.imagenes.sublist(
                startIndex, endIndex > widget.despues.imagenes.length ? widget.despues.imagenes.length : endIndex),
            widget.despues.subtitulo.sublist(
                startIndex, endIndex > widget.despues.subtitulo.length ? widget.despues.subtitulo.length : endIndex),
            widget.despues.informacion_cards.sublist(
                startIndex, endIndex > widget.despues.informacion_cards.length ? widget.despues.informacion_cards.length : endIndex),
          );
        },
      ),
      floatingActionButton: const MiFAB(),
    );
  }
}

Widget getListElement(List<String> imagenes, List<String> subtitulos, List<String> informaciones) {
  return Padding(
    padding: const EdgeInsets.all(6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(imagenes.length, (index) {
        return Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 150,
                    child: Image.asset(
                      imagenes[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    subtitulos[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 138, 183),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    informaciones[index],
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );
}

class MiFAB extends StatelessWidget {
  const MiFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      buttonSize: const Size(50, 50),
      activeIcon: Icons.close,
      visible: true,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.photo_camera),
          labelWidget: const Text(
            'Chequeo de Estado',
            style: TextStyle(fontSize: 20),
          ),
        ),
        
      
      ],
    );
  }
}


