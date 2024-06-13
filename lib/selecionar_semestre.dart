import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'selecionar_materia.dart';

class SelecionarSemestreScreen extends StatelessWidget {
  final String cursoId;

  const SelecionarSemestreScreen({Key? key, required this.cursoId})
      : super(key: key);

  String generateDocumentId(String input) {
    return input.replaceAll(' ', '_').toLowerCase();
  }

  Future<void> _adicionarSemestre(BuildContext context) async {
    final TextEditingController semestreController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Semestre'),
        content: TextField(
          controller: semestreController,
          decoration: const InputDecoration(hintText: 'Nome do Semestre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (semestreController.text.isNotEmpty) {
                String docId = generateDocumentId(semestreController.text);
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(cursoId)
                    .collection('semestres')
                    .doc(docId)
                    .set({'nome': semestreController.text});
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editarSemestre(
      BuildContext context, DocumentSnapshot semestre) async {
    final TextEditingController semestreController =
        TextEditingController(text: semestre['nome']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Semestre'),
        content: TextField(
          controller: semestreController,
          decoration: const InputDecoration(hintText: 'Nome do Semestre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (semestreController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(cursoId)
                    .collection('semestres')
                    .doc(semestre.id)
                    .update({'nome': semestreController.text});
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
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
        title: const Text('Selecione seu Semestre'),
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
                  onPressed: () => _adicionarSemestre(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(230, 231, 232, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cursos')
            .doc(cursoId)
            .collection('semestres')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Sem semestres disponíveis."));
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
                            onPressed: () => _editarSemestre(context, semestre),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _excluirSemestre(context, semestre),
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
      bottomNavigationBar: Container(
        height: 60,
        color: const Color(0xFF3A5C33),
      ),
    );
  }
}
