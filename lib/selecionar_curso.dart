import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selecionar_semestre.dart';

class SelecionarCursoScreen extends StatelessWidget {
  String generateDocumentId(String input) {
    return input.replaceAll(' ', '_').toLowerCase();
  }

  Future<void> _adicionarCurso(BuildContext context) async {
    final TextEditingController _cursoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar Curso'),
        content: TextField(
          controller: _cursoController,
          decoration: InputDecoration(hintText: 'Nome do Curso'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_cursoController.text.isNotEmpty) {
                String docId = generateDocumentId(_cursoController.text);
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(docId)
                    .set({'nome': _cursoController.text});
                Navigator.pop(context);
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editarCurso(BuildContext context, DocumentSnapshot curso) async {
    final TextEditingController _cursoController =
        TextEditingController(text: curso['nome']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Curso'),
        content: TextField(
          controller: _cursoController,
          decoration: InputDecoration(hintText: 'Nome do Curso'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_cursoController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(curso.id)
                    .update({'nome': _cursoController.text});
                Navigator.pop(context);
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirCurso(BuildContext context, DocumentSnapshot curso) async {
    await FirebaseFirestore.instance.collection('cursos').doc(curso.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione seu Curso'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _adicionarCurso(context),
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(230, 231, 232, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cursos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var cursos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              var curso = cursos[index];
              return ListTile(
                title: Text(curso['nome']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editarCurso(context, curso),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _excluirCurso(context, curso),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelecionarSemestreScreen(cursoId: curso.id),
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
