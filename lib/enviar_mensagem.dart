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
  String? _cursoSelecionado;
  String? _semestreSelecionado;
  List<String> _materiasSelecionadas = [];

  List<String> cursos = [];
  List<String> semestres = [];
  List<String> materias = [];

  @override
  void initState() {
    super.initState();
    _fetchCursos();
  }

  void _fetchCursos() async {
    var snapshot = await FirebaseFirestore.instance.collection('cursos').get();
    setState(() {
      cursos = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _fetchSemestres() async {
    if (_cursoSelecionado == null) return;
    var snapshot = await FirebaseFirestore.instance
        .collection('cursos')
        .doc(_cursoSelecionado)
        .collection('semestres')
        .get();
    setState(() {
      semestres = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _fetchMaterias() async {
    if (_cursoSelecionado == null || _semestreSelecionado == null) return;
    var snapshot = await FirebaseFirestore.instance
        .collection('cursos')
        .doc(_cursoSelecionado)
        .collection('semestres')
        .doc(_semestreSelecionado)
        .collection('materias')
        .get();
    setState(() {
      materias = snapshot.docs.map((doc) => doc['nome'] as String).toList();
    });
  }

  void _enviarMensagem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          var data = {
            'titulo': _titulo,
            'mensagem': _mensagem,
            'autor': user.uid,
            'curso': _cursoSelecionado ?? 'Não especificado',
            'semestre': _semestreSelecionado ?? 'Não especificado',
            'materias': _materiasSelecionadas,
            'data': Timestamp.now(),
          };

          await FirebaseFirestore.instance.collection('mensagens').add(data);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Mensagem enviada com sucesso!'),
          ));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao enviar mensagem: $e'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro: Usuário não está autenticado.'),
        ));
      }
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Curso'),
                items: cursos
                    .map((curso) => DropdownMenuItem(
                          value: curso,
                          child: Text(curso),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _cursoSelecionado = value;
                    _semestreSelecionado = null;
                    _materiasSelecionadas = [];
                    _fetchSemestres();
                  });
                },
                value: _cursoSelecionado,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Semestre'),
                items: semestres
                    .map((semestre) => DropdownMenuItem(
                          value: semestre,
                          child: Text(semestre),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _semestreSelecionado = value;
                    _materiasSelecionadas = [];
                    _fetchMaterias();
                  });
                },
                value: _semestreSelecionado,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: materias.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(materias[index]),
                      value: _materiasSelecionadas.contains(materias[index]),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _materiasSelecionadas.add(materias[index]);
                          } else {
                            _materiasSelecionadas.remove(materias[index]);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _enviarMensagem,
                child: Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
