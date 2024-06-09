import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class EnviarMensagemScreen extends StatefulWidget {
  final String? mensagemId;
  final String? titulo;
  final String? mensagem;
  final String? curso;
  final String? semestre;
  final List<String>? materias;
  final DateTime? data;

  EnviarMensagemScreen({
    this.mensagemId,
    this.titulo,
    this.mensagem,
    this.curso,
    this.semestre,
    this.materias,
    this.data,
  });

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
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;

  List<String> cursos = [];
  List<String> semestres = [];
  List<String> materias = [];

  @override
  void initState() {
    super.initState();
    _fetchCursos();
    if (widget.titulo != null) {
      _titulo = widget.titulo!;
      _mensagem = widget.mensagem!;
      _cursoSelecionado = widget.curso;
      _semestreSelecionado = widget.semestre;
      _materiasSelecionadas = widget.materias ?? [];
      _dataSelecionada = widget.data;
      _horaSelecionada = TimeOfDay.fromDateTime(widget.data!);
    }
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

      if (_cursoSelecionado == null ||
          _semestreSelecionado == null ||
          _materiasSelecionadas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Por favor, selecione o curso, semestre e pelo menos uma matéria.'),
        ));
        return;
      }

      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          var userDoc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .get();
          var userData = userDoc.data() as Map<String, dynamic>;
          var data = {
            'titulo': _titulo,
            'mensagem': _mensagem,
            'autor': user.uid,
            'nomeUsuario': userData['nomeUsuario'],
            'curso': _cursoSelecionado ?? 'Não especificado',
            'semestre': _semestreSelecionado ?? 'Não especificado',
            'materias': _materiasSelecionadas,
            'data': _dataSelecionada != null
                ? Timestamp.fromDate(
                    DateTime(
                      _dataSelecionada!.year,
                      _dataSelecionada!.month,
                      _dataSelecionada!.day,
                      _horaSelecionada?.hour ?? 0,
                      _horaSelecionada?.minute ?? 0,
                    ),
                  )
                : Timestamp.now(),
          };

          if (widget.mensagemId == null) {
            await FirebaseFirestore.instance.collection('mensagens').add(data);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Mensagem enviada com sucesso!'),
            ));
          } else {
            await FirebaseFirestore.instance
                .collection('mensagens')
                .doc(widget.mensagemId)
                .update(data);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Mensagem atualizada com sucesso!'),
            ));
          }

          Navigator.pop(context, true); // Indica que uma atualização ocorreu
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

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dataSelecionada)
      setState(() {
        _dataSelecionada = picked;
      });
  }

  Future<void> _selecionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _horaSelecionada)
      setState(() {
        _horaSelecionada = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.mensagemId == null ? 'Enviar Mensagem' : 'Editar Mensagem'),
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
                initialValue: _titulo,
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
                initialValue: _mensagem,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um curso';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um semestre';
                  }
                  return null;
                },
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selecionarData(context),
                      child: Text(_dataSelecionada == null
                          ? 'Selecionar Data'
                          : 'Data: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selecionarHora(context),
                      child: Text(_horaSelecionada == null
                          ? 'Selecionar Hora'
                          : 'Hora: ${_horaSelecionada!.format(context)}'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enviarMensagem,
                child: Text(widget.mensagemId == null ? 'Enviar' : 'Atualizar',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
