import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'selecionar_materia.dart';

class SelecionarSemestreScreen extends StatelessWidget {
  final String cursoId;

  SelecionarSemestreScreen({required this.cursoId});

  String generateDocumentId(String input) {
    return input.replaceAll(' ', '_').toLowerCase();
  }

  Future<void> _adicionarSemestre(BuildContext context) async {
    final TextEditingController _semestreController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Semestre'),
        content: TextField(
          controller: _semestreController,
          decoration: InputDecoration(hintText: 'Nome do Semestre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_semestreController.text.isNotEmpty) {
                String docId = generateDocumentId(_semestreController.text);
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(cursoId)
                    .collection('semestres')
                    .doc(docId)
                    .set({'nome': _semestreController.text});
                Navigator.pop(context);
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editarSemestre(
      BuildContext context, DocumentSnapshot semestre) async {
    final TextEditingController _semestreController =
        TextEditingController(text: semestre['nome']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Semestre'),
        content: TextField(
          controller: _semestreController,
          decoration: InputDecoration(hintText: 'Nome do Semestre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_semestreController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(cursoId)
                    .collection('semestres')
                    .doc(semestre.id)
                    .update({'nome': _semestreController.text});
                Navigator.pop(context);
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirSemestre(
      BuildContext context, DocumentSnapshot semestre) async {
    await FirebaseFirestore.instance
        .collection('cursos')
        .doc(cursoId)
        .collection('semestres')
        .doc(semestre.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione seu Semestre'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              if (userData['tipoUsuario'] == 'Professor') {
                return IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _adicionarSemestre(context),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(230, 231, 232, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cursos')
            .doc(cursoId)
            .collection('semestres')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Sem semestres disponíveis."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var semestre = snapshot.data!.docs[index];
              return ListTile(
                title: Text(semestre.get('nome')),
                trailing: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    if (userData['tipoUsuario'] == 'Professor') {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editarSemestre(context, semestre),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                _excluirSemestre(context, semestre),
                          ),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelecionarMateriaScreen(
                        cursoId: cursoId,
                        semestre: semestre.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
