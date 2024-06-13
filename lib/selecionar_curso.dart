import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'selecionar_semestre.dart';

class SelecionarCursoScreen extends StatelessWidget {
  const SelecionarCursoScreen({Key? key}) : super(key: key);

  String generateDocumentId(String input) {
    return input.replaceAll(' ', '_').toLowerCase();
  }

  Future<void> _adicionarCurso(BuildContext context) async {
    final TextEditingController cursoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Curso'),
        content: TextField(
          controller: cursoController,
          decoration: const InputDecoration(hintText: 'Nome do Curso'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (cursoController.text.isNotEmpty) {
                String docId = generateDocumentId(cursoController.text);
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(docId)
                    .set({'nome': cursoController.text});
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editarCurso(
      BuildContext context, DocumentSnapshot curso) async {
    final TextEditingController cursoController =
        TextEditingController(text: curso['nome']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Curso'),
        content: TextField(
          controller: cursoController,
          decoration: const InputDecoration(hintText: 'Nome do Curso'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (cursoController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(curso.id)
                    .update({'nome': cursoController.text});
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirCurso(
      BuildContext context, DocumentSnapshot curso) async {
    await FirebaseFirestore.instance
        .collection('cursos')
        .doc(curso.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione seu Curso'),
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              if (userData['tipoUsuario'] == 'Professor') {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _adicionarCurso(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(230, 231, 232, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cursos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var cursos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              var curso = cursos[index];
              return ListTile(
                title: Text(curso['nome']),
                trailing: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    if (userData['tipoUsuario'] == 'Professor') {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editarCurso(context, curso),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluirCurso(context, curso),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SelecionarSemestreScreen(cursoId: curso.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: const Color(0xFF3A5C33),
      ),
    );
  }
}
