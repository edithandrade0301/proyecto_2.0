import 'package:flutter/material.dart';

class CrearNotaForm extends StatefulWidget{
  const CrearNotaForm({super.key});

  @override
  _CrearNotaFormState createState() => _CrearNotaFormState();
}

class _CrearNotaFormState extends State<CrearNotaForm>{
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _etiquetaController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();

  void _crearNota(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.pink[200],
        elevation: 2,
        duration: const Duration(seconds: 4),
        content: const Text('Se guardo con exito la nota')
      )
    );

    _etiquetaController.clear();
    _notaController.clear();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nota Nueva'),
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
                  controller: _etiquetaController,
                  decoration: const InputDecoration(labelText: 'Etiqueta de la Nota'),
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Por favor, ingrese la etiqueta con la cual guardara su nota';
                    }else{
                      return null;
                    }
                  }
                ),
                TextFormField(
                  controller: _notaController,
                  decoration: const InputDecoration(labelText: 'Consejo que guardara en su nota'),
                  maxLines: null,
                  maxLength: 300,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Por favor, ingrese el consejo con el cual guardara su nota';
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
                            _crearNota();
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
                      child: const Text('Guardar Nota')
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