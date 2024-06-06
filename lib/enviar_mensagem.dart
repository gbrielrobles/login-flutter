import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnviarMensagemScreen extends StatefulWidget {
  @override
  _EnviarMensagemScreenState createState() => _EnviarMensagemScreenState();
}

class _EnviarMensagemScreenState extends State<EnviarMensagemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _titulo = '';
  var _mensagem = '';

  void _enviarMensagem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var user = FirebaseAuth.instance.currentUser;
      var data = {
        'titulo': _titulo,
        'mensagem': _mensagem,
        'autor': user!.uid,
        'data': Timestamp.now(),
      };

      FirebaseFirestore.instance.collection('mensagens').add(data).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Mensagem enviada com sucesso!'),
        ));
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao enviar mensagem: $error'),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar Mensagem'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
                onSaved: (value) {
                  _titulo = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mensagem'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma mensagem';
                  }
                  return null;
                },
                onSaved: (value) {
                  _mensagem = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enviarMensagem,
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
