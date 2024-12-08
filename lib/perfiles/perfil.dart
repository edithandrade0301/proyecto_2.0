import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:proyecto_progra_movil_grupo1/modelos/cardsdurante.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key, required this.durante});

  final Durante durante;

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.durante.titulo),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 170, 216),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 248, 248, 220),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // Desarrollo del bebé
          _buildCardSection(
            titulo: 'DESARROLLO DEL BEBÉ',
            subtitulo: '¿Qué pasa en el ' + (widget.durante.titulo) + ' del embarazo?',
            texto: widget.durante.informacion_bebe,
            imagen: widget.durante.imagen,
            imageAlignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 20),
          // Mamá
          _buildCardSection(
            titulo: 'MAMÁ',
            subtitulo: '¿Qué pasa en el ' + (widget.durante.titulo) + ' del embarazo?',
            texto: widget.durante.informacion_mama,
            imagen: widget.durante.imagen_mama, // Imagen local de la mami
            imageAlignment: Alignment.centerRight,
          ),
          const SizedBox(height: 20),
          // Recomendaciones
          _buildRecommendations(),
        ],
      ),
      floatingActionButton: const MiFAB(),
    );
  }

  Widget _buildCardSection({
    required String titulo,
    required String subtitulo,
    required String texto,
    required String imagen,
    required Alignment imageAlignment,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 238, 56, 156),
              ),
            ),
            const SizedBox(height: 5),
            // Content
            Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 12, 12, 12),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (imageAlignment == Alignment.centerLeft) _buildImageBox(imagen),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      texto,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                if (imageAlignment == Alignment.centerRight) _buildImageBox(imagen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(String imagen) {
    // Verificar si la imagen es local o de la web
    bool isLocalImage = imagen.startsWith('assets/');

    return Container(
      padding: EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Si es una imagen local, usa Image.asset
          isLocalImage
              ? Image.asset(
                  imagen, // Usamos Image.asset para imágenes locales
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  imagen, // Usamos Image.network para imágenes en la web
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
          SizedBox(width: 16),
        ],
      ),
    );
  }



  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECOMENDACIONES',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 238, 56, 156),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildRecommendationCard(1, widget.durante.reco1, widget.durante.imagen1),
              _buildRecommendationCard(2, widget.durante.reco2, widget.durante.imagen2),
              _buildRecommendationCard(3, widget.durante.reco3, widget.durante.imagen3),
              _buildRecommendationCard(4, widget.durante.reco4, widget.durante.imagen4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(int index, String recommendationText, String image) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 150,
        height: 240,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset(
              image,
              height: 100,
              width: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              recommendationText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
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
