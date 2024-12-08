import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:proyecto_progra_movil_grupo1/metodos_calendario/metodos.dart';
import 'package:proyecto_progra_movil_grupo1/perfiles/perfil.dart';
import 'package:proyecto_progra_movil_grupo1/perfiles/perfildos.dart';
import 'package:proyecto_progra_movil_grupo1/perfiles/perfilplanificacion.dart';
import 'package:proyecto_progra_movil_grupo1/informacion/infodurante.dart';
import 'package:proyecto_progra_movil_grupo1/informacion/infodespues.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarioEventos(),
    );
  }
}

class CalendarioEventos extends StatefulWidget {
  @override
  State<CalendarioEventos> createState() => _CalendarioEventosState();
}

class _CalendarioEventosState extends State<CalendarioEventos>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<DateTime, List<Map<String, dynamic>>> _eventos = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _filtroBusqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 pestañas
    cargarEventos(_eventos, setState);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventosDelDia =
        obtenerEventosDelDia(_eventos, _selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 243, 227),
      appBar: AppBar(
        title: const Text("Materno Infantil"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 170, 216),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 221, 19, 154),
          unselectedLabelColor: const Color.fromARGB(255, 104, 4, 79),
          labelColor: const Color.fromARGB(255, 202, 41, 175),
          tabs: const [
            Tab(text: '    Durante\nel Embarazo'),
            Tab(text: '    Después\ndel Embarazo'),
            Tab(text: 'Calendario'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Fondo pastel rosado
          Container(
            color: const Color(0xFFFFE0E0),
            child: const InfoDuranteTab(),
          ),
          // Fondo pastel azul
          Container(
            color: const Color(0xFFB2EBF2),
            child: const InfoDespuesTab(),
          ),
          
          
          // Pestaña 3: Calendario
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Buscar evento",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (texto) {
                      setState(() {
                        _filtroBusqueda = texto;
                      });
                    },
                  ),
                ),
                if (_filtroBusqueda.isNotEmpty)
                  buscarEventos(_eventos, _filtroBusqueda),
                TableCalendar(
                  firstDay: DateTime(DateTime.now().year, 1, 1),
                  lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: (day) => obtenerEventosDelDia(_eventos, day),
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: Color.fromARGB(255, 245, 201, 232),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.pink[200],
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          right: 1,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.pink,
                            child: Text(
                              events.length.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const SizedBox(height: 16),
                eventosDelDia.isEmpty
                    ? const Center(child: Text("No hay eventos para este día."))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: eventosDelDia.length,
                        itemBuilder: (context, index) {
                          final evento = eventosDelDia[index];
                          return eventoWidget(context, evento, _eventos,
                              setState, _focusedDay, _selectedDay);
                        },
                      ),
              ],
            ),
          ),
        ],
        
      ),

      //dawer 
      drawer: const MiDrawer(),



      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22.0),
        backgroundColor: const Color.fromARGB(255, 241, 145, 221),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.chat),
            label: 'Vithalia Asistente',
            onTap: () {
              // Acción para redirigir al chatbot
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusquedaPage()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.calendar_today),
            label: 'Agregar evento al calendario',
            onTap: () {
              if (_selectedDay != null) {
                // Acción para agregar evento al calendario
                mostrarDialogoAgregarEvento(
                    context, _eventos, setState, _focusedDay, _selectedDay);
              }
            },
          ),
        ],
      ),
    );
  }
}

class InfoDuranteTab extends StatelessWidget {
  const InfoDuranteTab({super.key});

  Widget getInfo(BuildContext context, int index) {
    final durante = Informacion.getItems()[index];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image(
            image: NetworkImage(durante.imagen),
            height: 110,
            width: 70,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  durante.titulo,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  durante.subtiulo,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  durante.informacion_bebe,
                  style: const TextStyle(fontSize: 14),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            child: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Perfil(durante: durante),
                  ));
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final durante = Informacion.getItems();
    return ListView.builder(
      padding: const EdgeInsets.all(1),
      itemCount: durante.length,
      itemBuilder: (BuildContext context, int index) {
        return getInfo(context, index);
      },
    );
  }
}

class InfoDespuesTab extends StatelessWidget {
  const InfoDespuesTab({super.key});

  Widget getInfo(BuildContext context, int index) {
    final despues = Informaciondespues.getItems()[index];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image(
            image: NetworkImage(despues.imagen),
            height: 110,
            width: 70,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  despues.titulo,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  despues.informacion,
                  style: const TextStyle(fontSize: 14),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            child: const Icon(Icons.arrow_forward),
            onTap: () {
              if (despues.titulo == 'Planificación Familiar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Perfilplanificacion(despues: despues),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Perfildos(despues: despues),
                  ),
                );
              }
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final despues = Informaciondespues.getItems();
    return ListView.builder(
      padding: const EdgeInsets.all(1),
      itemCount: despues.length,
      itemBuilder: (BuildContext context, int index) {
        return getInfo(context, index);
      },
    );
  }
}

class BusquedaPage extends StatelessWidget {
  const BusquedaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Eventos')),
      body: const Center(child: Text("Pantalla de búsqueda")),
    );
  }
}




class MiDrawer extends StatelessWidget {
  const MiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      color: const Color.fromARGB(255, 243, 241, 241),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink[50]),
              child: const Text('Opciones',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
          Container(
            color: Colors.yellow[50],
            child: ListTile(
                leading: const Icon(Icons.person_3_sharp),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InfoDespuesTab()));
                }),
          ),

           Container(
            color: const Color.fromARGB(255, 220, 253, 245),
            child: ListTile(
              leading: const Icon(Icons.pending_actions_outlined),
                title: const Text('Historial Medico'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InfoDespuesTab()));
                }),
          ),
          Container(
            color: Colors.green[50],
            child: const ListTile(
              leading: Icon(Icons.chat),
              title: Text('Vithalia Asistente'),
            ),
          ),
          Container(
              color: Colors.red[50],
              child: const ListTile(
                leading: Icon(Icons.meeting_room_sharp),
                title: Text('Cerrar Sesion'),
              ))
        ],
      ),
    ));
  }
}
