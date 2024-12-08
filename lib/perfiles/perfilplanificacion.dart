import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:proyecto_progra_movil_grupo1/modelos/cardsdepues.dart';

class Perfilplanificacion extends StatefulWidget {
  const Perfilplanificacion({super.key, required this.despues});

  final Despues despues;

  @override
  State<Perfilplanificacion> createState() => _PerfilplanificacionState();
}

class _PerfilplanificacionState extends State<Perfilplanificacion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 220), //fondo
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
      body: Column( // Usamos un Column para agregar el texto y las tarjetas
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card( // Agregamos el texto dentro de una Card
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "La planificación familiar es clave para prevenir embarazos no deseados y cuidar la salud de la madre y el bebé. Los métodos anticonceptivos ayudan a controlar el tiempo y la cantidad de los embarazos.",
                  style: TextStyle(fontSize: 16, height: 1.5), // Estilo del texto introductorio
                  textAlign: TextAlign.center, // Centrar el texto dentro de la card
                ),
              ),
            ),
          ),
          Expanded( // Contenedor para las cards
            child: CardListView(despues: widget.despues), // Pasar los datos aquí
          ),
        ],
      ),
      floatingActionButton: const MiFAB(),
    );
  }
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

class CardListView extends StatelessWidget {
  final Despues despues; // Recibir el objeto Despues

  const CardListView({super.key, required this.despues});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: despues.subtitulo.length, // Usamos el tamaño de la lista 'subtitulo'
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ExpansionCard(
            title: despues.subtitulo[index], // Usamos los subtítulos de 'despues'
            mainImageUrl: despues.imagenes[index], // Usamos las imágenes de 'despues'
            extraText: despues.informacion_cards[index], // Usamos la información de las tarjetas
          ),
        );
      },
    );
  }
}

class ExpansionCard extends StatefulWidget {
  final String title;
  final String mainImageUrl;
  final String extraText;

  const ExpansionCard({
    required this.title,
    required this.mainImageUrl,
    required this.extraText,
  });

  @override
  State<ExpansionCard> createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center( // Centra la tarjeta en el contenedor
      child: Container(
        width: MediaQuery.of(context).size.width * 0.70, // ancho de la tarjeta
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // texto centrado
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  widget.mainImageUrl, // Cargar imagenes desde assets
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.extraText,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center, // Centrar el texto 
                  ),
                ),
              IconButton(
                icon: Icon(_isExpanded ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: _toggleExpand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

