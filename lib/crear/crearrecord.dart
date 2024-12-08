import 'package:flutter/material.dart';

class CrearRecordForm extends StatefulWidget{
  const CrearRecordForm({super.key});

  @override
  _CrearRecordFormState createState() => _CrearRecordFormState();
}

class _CrearRecordFormState extends State<CrearRecordForm>{
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _fechaconsultaController = TextEditingController();
  final TextEditingController _nombredoctorController = TextEditingController();
  final TextEditingController _horarecordaController = TextEditingController();
  final TextEditingController _hospitalnomController = TextEditingController();
  final TextEditingController _motivochequeoController = TextEditingController();

  void _crearRecordatorio(){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        elevation: 2,
        duration: Duration(seconds: 4),
        content: Text('Se guardo con exito el recordatorio')
      )
    );

    _fechaconsultaController.clear();
    _nombredoctorController.clear();
    _hospitalnomController.clear();
    _motivochequeoController.clear();
    _horarecordaController.clear();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Recordatorio'),
        backgroundColor: Colors.pink[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _motivochequeoController,
                  decoration: const InputDecoration(labelText: 'Nombre del Recordatorio'),
                  maxLines: null,
                  maxLength: 300,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Por favor, ingrese el motivo por el cual debe hacerse le chequeo';
                    }else{
                      return null;
                    }
                  }
                ),
                TextFormField(
                  controller: _fechaconsultaController,
                  decoration: const InputDecoration(labelText: 'Fecha del Recordatorio'),
                  keyboardType: TextInputType.datetime,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Por favor, ingrese la fecha en la cual tendra su siguiente chequeo';
                    }else{
                      return null;
                    }
                  }
                ),
                TextFormField(
                  controller: _nombredoctorController,
                  decoration: const InputDecoration(labelText: 'Nombre del Doctor Encargado (Opcional)'),
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Por favor, ingrese el nombre del doctor que la atendera';
                    }else{
                      return null;
                    }
                  }
                ),
                TextFormField(
                  controller: _horarecordaController,
                  decoration: const InputDecoration(labelText: 'Hora del Recordatorio'),
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Por favor, ingrese el nombre del area medica del chequeo';
                    }else{
                      return null;
                    }
                  }
                ),
                TextFormField(
                  controller: _hospitalnomController,
                  decoration: const InputDecoration(labelText: 'Clinica para Chequeo'),
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Por favor, ingrese el nombre del hospital donde se hara su chequeo';
                    }else{
                      return null;
                    }
                  }
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: (){
                        if(_formkey.currentState!.validate()){
                          _crearRecordatorio();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.black,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                      child: const Text('Guardar Recordatorio')
                    )
                  ),
                  ]
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}