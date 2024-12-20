import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<void> cargarEventos(Map<DateTime, List<Map<String, dynamic>>> eventos,
    Function setState) async {
  final prefs = await SharedPreferences.getInstance();
  final eventosString = prefs.getString('eventos');
  if (eventosString != null) {
    final eventosMap = Map<String, dynamic>.from(json.decode(eventosString));
    setState(() {
      eventos.addAll(eventosMap.map((key, value) => MapEntry(
            DateTime.parse(key),
            List<Map<String, dynamic>>.from(value.map((evento) {
              return {
                "evento": evento["evento"],
                "categoria": evento["categoria"],
                "color": Color(evento["color"]),
                "desc": evento["desc"],
                "hora": evento["hora"],
                "doc": evento["doc"],
                "lugar": evento["lugar"],
                //nuevo
                "imagen": evento["imagen"],
              };
            })),
          )));
    });
  }
}

void guardarEventos(Map<DateTime, List<Map<String, dynamic>>> eventos) async {
  final prefs = await SharedPreferences.getInstance();
  final eventosMap = eventos.map((key, value) => MapEntry(
        key.toIso8601String(),
        value.map((evento) {
          return {
            "evento": evento["evento"],
            "categoria": evento["categoria"],
            "color": evento["color"].value,
            "desc": evento["desc"],
            "hora": evento["hora"],
            "doc": evento["doc"],
            "lugar": evento["lugar"],
            //nuevo
            "imagen": evento["imagen"],
          };
        }).toList(),
      ));
  await prefs.setString('eventos', json.encode(eventosMap));
}

List<Map<String, dynamic>> obtenerEventosDelDia(
    Map<DateTime, List<Map<String, dynamic>>> eventos, DateTime dia) {
  return eventos[dia] ?? [];
}

Widget buscarEventos(
    Map<DateTime, List<Map<String, dynamic>>> eventos, String filtro) {
  final resultados = eventos.entries
      .expand((entry) => entry.value
          .where((evento) => evento['evento']
              .toString()
              .toLowerCase()
              .contains(filtro.toLowerCase()))
          .map((evento) => {
                ...evento,
                'fecha': entry.key,
              }))
      .toList();

  return resultados.isEmpty
      ? const Center(child: Text("No se encontraron coincidencias."))
      : ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: resultados.length,
          itemBuilder: (context, index) {
            final evento = resultados[index];
            IconData icono = evento['categoria'] == 'Recordatorio'
                ? Icons.note
                : Icons.local_hospital;
            return ListTile(
              title: Text(evento['evento']),
              subtitle: evento.containsKey('fecha')
                  ? Text(
                      "Fecha: ${evento['fecha'].toLocal().toString().split(' ')[0]}")
                  : null,
              leading: Icon(icono, color: evento['color']),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    if (evento['categoria'] == 'Cita médica') {
                      return AlertDialog(
                        title: Text(evento['evento']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Categoría: ${evento['categoria']}"),
                            Text("Hora: ${evento['hora']}"),
                            Text("Doctor/a: ${evento['doc']}"),
                            Text("Lugar: ${evento['lugar']}"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cerrar"),
                          ),
                        ],
                      );
                    } else {
                      return AlertDialog(
                        title: Text(evento['evento']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Categoría: ${evento['categoria']}"),
                            Text("Hora: ${evento['hora']}"),
                            Text("Descripción: ${evento['desc']}"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cerrar"),
                          ),
                        ],
                      );
                    }
                  },
                );
              },
            );
          },
        );
}

void mostrarDialogoAgregarEvento(
  BuildContext context,
  Map<DateTime, List<Map<String, dynamic>>> eventos,
  Function setState,
  DateTime focusedDay,
  DateTime? selectedDay,
) {
  final _formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final horaController = TextEditingController();
  final doctorController = TextEditingController();
  final lugarController = TextEditingController();

  String categoriaSeleccionada = "Recordatorio";
  Color colorSeleccionado = const Color.fromARGB(255, 243, 31, 215);

  File? imagenSeleccionada; // Definir imagenSeleccionada fuera del StatefulBuilder

  Future<void> _seleccionarImagen(StateSetter setStateDialog) async {
  final ImagePicker picker = ImagePicker();

  // Mostrar un diálogo para que el usuario elija entre tomar una foto o seleccionar de la galería
  final imageSource = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Selecciona una opción'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Tomar Foto'),
            onTap: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          ListTile(
            title: const Text('Seleccionar desde Galería'),
            onTap: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
        ],
      ),
    ),
  );

  if (imageSource != null) {
    // Seleccionar imagen de la cámara o galería
    final XFile? imagen = await picker.pickImage(source: imageSource);
    if (imagen != null) {
      setStateDialog(() {
        imagenSeleccionada = File(imagen.path); // Guardar la imagen seleccionada
      });
    }
  }
}

  showDialog(
  context: context,
  builder: (context) {
    return StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        title: const Text("Agregar Evento"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: categoriaSeleccionada,
                  onChanged: (nuevaCategoria) {
                    setStateDialog(() {
                      categoriaSeleccionada = nuevaCategoria!;
                    });
                  },
                  items: ['Recordatorio', 'Cita médica']
                      .map((categoria) => DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          ))
                      .toList(),
                ),
                TextFormField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: "Título del evento"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el título';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: horaController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Hora del evento"),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setStateDialog(() {
                        horaController.text = pickedTime.format(context);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione una hora';
                    }
                    return null;
                  },
                ),
                if (categoriaSeleccionada == 'Recordatorio')
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: "Descripción del evento"),
                  ),
                if (categoriaSeleccionada == 'Cita médica') ...[
                  TextFormField(
                    controller: doctorController,
                    decoration: const InputDecoration(labelText: "Doctor/a"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el nombre del doctor/a';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lugarController,
                    decoration: const InputDecoration(labelText: "Lugar"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el lugar';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Color: "),
                    GestureDetector(
                      onTap: () async {
                        final nuevoColor = await showDialog<Color>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Seleccionar color"),
                            content: BlockPicker(
                              pickerColor: colorSeleccionado,
                              onColorChanged: (color) {
                                setStateDialog(() {
                                  colorSeleccionado = color;
                                });
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, colorSeleccionado);
                                },
                                child: const Text("Aceptar"),
                              ),
                            ],
                          ),
                        );
                        if (nuevoColor != null) {
                          setStateDialog(() {
                            colorSeleccionado = nuevoColor;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: colorSeleccionado,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text("Imagen: "),
    ElevatedButton(
      onPressed: () => _seleccionarImagen(setStateDialog),
      child: const Text("Seleccionar"),
    ),
  ],
),
if (imagenSeleccionada != null)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Image.file(
      imagenSeleccionada!,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
    ),
  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  final diaSeleccionado = selectedDay ?? focusedDay;
                  if (eventos[diaSeleccionado] == null) {
                    eventos[diaSeleccionado] = [];
                  }
                  eventos[diaSeleccionado]?.add({
                    "evento": tituloController.text,
                    "categoria": categoriaSeleccionada,
                    "color": colorSeleccionado,
                    "desc": descripcionController.text,
                    "hora": horaController.text,
                    "doc": doctorController.text,
                    "lugar": lugarController.text,
                    "imagen": imagenSeleccionada?.path,
                  });
                });
                guardarEventos(eventos);
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  },
);

}


Widget eventoWidget(
  BuildContext context,
  Map<String, dynamic> evento,
  Map<DateTime, List<Map<String, dynamic>>> eventos,
  Function setState,
  DateTime focusedDay,
  DateTime? selectedDay,
) {
  return ListTile(
    title: Text(evento['evento']),
    leading: Icon(
      evento['categoria'] == 'Recordatorio' ? Icons.note : Icons.local_hospital,
      color: evento['color'],
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.pink),
          onPressed: () {
            mostrarDialogoEditarEvento(
              context,
              evento,
              eventos,
              setState,
              focusedDay,
              selectedDay,
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.pink),
          onPressed: () {
            // Mostrar mensaje de confirmación antes de borrar
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("¿Estás seguro de borrar este evento?"),
                  content: const Text("Este evento será eliminado."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Cancelar y cerrar el diálogo
                        Navigator.pop(context);
                      },
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Eliminar el evento y guardar cambios
                        setState(() {
                          final diaSeleccionado = selectedDay ?? focusedDay;
                          eventos[diaSeleccionado]?.remove(evento);
                        });
                        guardarEventos(eventos);
                        Navigator.pop(
                            context); // Cerrar el diálogo de confirmación
                      },
                      child: const Text("Aceptar"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    ),
    onTap: () {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(evento['evento']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Categoría: ${evento['categoria']}"),
              Text("Hora: ${evento['hora']}"),


              if (evento['categoria'] == 'Recordatorio')
                Text("Descripción: ${evento['desc']}"),
              if (evento['categoria'] == 'Cita médica') ...[
                Text("Doctor/a: ${evento['doc']}"),
                Text("Lugar: ${evento['lugar']}"),
              ],
              const SizedBox(height: 10),
              if (evento['imagen'] != null && evento['imagen'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Imagen:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Image.file(
                      File(evento['imagen']),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      );
    },
  );
},
);
}

void mostrarDialogoEditarEvento(
  BuildContext context,
  Map<String, dynamic> evento,
  Map<DateTime, List<Map<String, dynamic>>> eventos,
  Function setState,
  DateTime focusedDay,
  DateTime? selectedDay,
) {
  File? imagenSeleccionada = evento['imagen'] != null && evento['imagen'].isNotEmpty
      ? File(evento['imagen'])
      : null;

  Future<void> _seleccionarImagen(StateSetter setStateDialog) async {
    final ImagePicker picker = ImagePicker();

    // Mostrar diálogo para elegir cámara o galería
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona una opción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
            ListTile(
              title: const Text('Seleccionar desde Galería'),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );

    if (imageSource != null) {
      final XFile? imagen = await picker.pickImage(source: imageSource);
      if (imagen != null) {
        setStateDialog(() {
          imagenSeleccionada = File(imagen.path); // Actualizar imagen seleccionada
        });
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController(text: evento['evento']);
  final descripcionController = TextEditingController(text: evento['desc']);
  final horaController = TextEditingController(text: evento['hora']);
  final doctorController = TextEditingController(text: evento['doc']);
  final lugarController = TextEditingController(text: evento['lugar']);

  String categoriaSeleccionada = evento['categoria'];
  Color colorSeleccionado = evento['color'];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Editar Evento"),
      content: Form(
        key: _formKey,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: categoriaSeleccionada,
                    onChanged: (nuevaCategoria) {
                      setStateDialog(() {
                        categoriaSeleccionada = nuevaCategoria!;
                      });
                    },
                    items: ['Recordatorio', 'Cita médica']
                        .map((categoria) => DropdownMenuItem(
                              value: categoria,
                              child: Text(categoria),
                            ))
                        .toList(),
                  ),
                  TextFormField(
                    controller: tituloController,
                    decoration:
                        const InputDecoration(labelText: "Título del evento"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: horaController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: "Hora del evento"),
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        horaController.text = pickedTime.format(context);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, seleccione una hora';
                      }
                      return null;
                    },
                  ),
                  if (categoriaSeleccionada == 'Recordatorio')
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                          labelText: "Descripción del evento"),
                    ),
                  if (categoriaSeleccionada == 'Cita médica') ...[
                    TextFormField(
                      controller: doctorController,
                      decoration: const InputDecoration(labelText: "Doctor/a"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el nombre del doctor/a';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: lugarController,
                      decoration: const InputDecoration(labelText: "Lugar"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el lugar';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Color: "),
                      GestureDetector(
                        onTap: () async {
                          final nuevoColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Seleccionar color"),
                              content: BlockPicker(
                                pickerColor: colorSeleccionado,
                                onColorChanged: (color) {
                                  setStateDialog(() {
                                    colorSeleccionado = color;
                                  });
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, colorSeleccionado);
                                  },
                                  child: const Text("Aceptar"),
                                ),
                              ],
                            ),
                          );
                          if (nuevoColor != null) {
                            setStateDialog(() {
                              colorSeleccionado = nuevoColor;
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: colorSeleccionado,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Imagen: "),
                      ElevatedButton(
                        onPressed: () => _seleccionarImagen(setStateDialog),
                        child: const Text("Seleccionar"),
                      ),
                    ],
                  ),
                  if (imagenSeleccionada != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.file(
                        imagenSeleccionada!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() {
                final diaSeleccionado = selectedDay ?? focusedDay;
                final index = eventos[diaSeleccionado]?.indexOf(evento);
                if (index != null && index >= 0) {
                  eventos[diaSeleccionado]?[index] = {
                    'evento': tituloController.text,
                    'categoria': categoriaSeleccionada,
                    'color': colorSeleccionado,
                    'desc': descripcionController.text,
                    'hora': horaController.text,
                    'doc': doctorController.text,
                    'lugar': lugarController.text,
                    'imagen': imagenSeleccionada?.path ?? evento['imagen'],
                  };
                }
              });
              guardarEventos(eventos);
              Navigator.pop(context);
            }
          },
          child: const Text("Guardar"),
        ),
      ],
    ),
  );
}



