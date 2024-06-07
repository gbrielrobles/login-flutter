import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelecionarMateriaScreen extends StatefulWidget {
  final String cursoId;
  final String semestre;

  SelecionarMateriaScreen({required this.cursoId, required this.semestre});

  @override
  _SelecionarMateriaScreenState createState() =>
      _SelecionarMateriaScreenState();
}

class _SelecionarMateriaScreenState extends State<SelecionarMateriaScreen> {
  Map<String, bool> materiasSelecionadas = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione suas Matérias'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
      ),
      backgroundColor: Color.fromRGBO(230, 231, 232, 1),
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
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text("Nenhuma matéria encontrada para este semestre."));
          }

          var materias = snapshot.data!.docs;
          return ListView.builder(
            itemCount: materias.length,
            itemBuilder: (context, index) {
              var materia = materias[index].data() as Map<String, dynamic>;
              return CheckboxListTile(
                title: Text(materia['nome']),
                value: materiasSelecionadas[materia['nome']] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    materiasSelecionadas[materia['nome']] = value!;
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
              userData['cursoSemestreMateria'] as List<dynamic> ?? [];

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
                SnackBar(content: Text('Matérias selecionadas com sucesso!')));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao selecionar matérias: $error')));
          });
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
