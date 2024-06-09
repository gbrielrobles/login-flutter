// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class SelecionarMateriaScreen extends StatefulWidget {
  final String cursoId;
  final String semestre;

  const SelecionarMateriaScreen({super.key, required this.cursoId, required this.semestre});

  @override
  _SelecionarMateriaScreenState createState() =>
      _SelecionarMateriaScreenState();
}

class _SelecionarMateriaScreenState extends State<SelecionarMateriaScreen> {
  Map<String, bool> materiasSelecionadas = {};
  final TextEditingController _materiaController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String generateDocumentId(String input) {
    return input.replaceAll(' ', '_').toLowerCase();
  }

  @override
  void dispose() {
    _materiaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _adicionarMateria(BuildContext context) async {
    _materiaController.clear();
    _descricaoController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Matéria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _materiaController,
              decoration: const InputDecoration(hintText: 'Nome da Matéria'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(hintText: 'Descrição da Matéria'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_materiaController.text.isNotEmpty &&
                  _descricaoController.text.isNotEmpty) {
                String docId = generateDocumentId(_materiaController.text);
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(widget.cursoId)
                    .collection('semestres')
                    .doc(widget.semestre)
                    .collection('materias')
                    .doc(docId)
                    .set({
                  'nome': _materiaController.text,
                  'descricao': _descricaoController.text,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editarMateria(
      BuildContext context, DocumentSnapshot materia) async {
    _materiaController.text = materia['nome'];
    _descricaoController.text = materia['descricao'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Matéria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _materiaController,
              decoration: const InputDecoration(hintText: 'Nome da Matéria'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(hintText: 'Descrição da Matéria'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_materiaController.text.isNotEmpty &&
                  _descricaoController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('cursos')
                    .doc(widget.cursoId)
                    .collection('semestres')
                    .doc(widget.semestre)
                    .collection('materias')
                    .doc(materia.id)
                    .update({
                  'nome': _materiaController.text,
                  'descricao': _descricaoController.text,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirMateria(
      BuildContext context, DocumentSnapshot materia) async {
    await FirebaseFirestore.instance
        .collection('cursos')
        .doc(widget.cursoId)
        .collection('semestres')
        .doc(widget.semestre)
        .collection('materias')
        .doc(materia.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione suas Matérias'),
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _adicionarMateria(context),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(230, 231, 232, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cursos')
            .doc(widget.cursoId)
            .collection('semestres')
            .doc(widget.semestre)
            .collection('materias')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Nenhuma matéria encontrada para este semestre."));
          }

          var materias = snapshot.data!.docs;
          return ListView.builder(
            itemCount: materias.length,
            itemBuilder: (context, index) {
              var materia = materias[index];
              return ListTile(
                title: Text(materia['nome']),
                subtitle: Text(materia['descricao']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarMateria(context, materia),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _excluirMateria(context, materia),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    materiasSelecionadas[materia['nome']] =
                        !materiasSelecionadas[materia['nome']]!;
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var user = FirebaseAuth.instance.currentUser;
          var cursoSemestreMateria = {
            'curso': widget.cursoId,
            'semestre': widget.semestre,
            'materias': materiasSelecionadas.keys
                .where((k) => materiasSelecionadas[k]!)
                .toList(),
          };

          // Obtém o documento do usuário
          var userDoc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user!.uid)
              .get();

          // Obtém a lista de cursoSemestreMateria
          var userData = userDoc.data() as Map<String, dynamic>;
          var cursoSemestreMateriaArray =
              (userData['cursoSemestreMateria'] as List<dynamic>? ?? []);

          // Encontra o índice do item correspondente ao curso e semestre, se existir
          int index = cursoSemestreMateriaArray.indexWhere((item) =>
              item['curso'] == widget.cursoId &&
              item['semestre'] == widget.semestre);

          if (index >= 0) {
            // Se o item já existir, atualiza-o
            cursoSemestreMateriaArray[index] = cursoSemestreMateria;
          } else {
            // Se o item não existir, adiciona-o
            cursoSemestreMateriaArray.add(cursoSemestreMateria);
          }

          // Atualiza o documento do usuário
          FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .update({
            'cursoSemestreMateria': cursoSemestreMateriaArray,
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Matérias selecionadas com sucesso!')));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao selecionar matérias: $error')));
          });
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
