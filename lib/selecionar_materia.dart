import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

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
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: Usuário não está autenticado.')));
            return;
          }

          var cursoSemestreMateria = {
            'curso': widget.cursoId,
            'semestre': widget.semestre,
            'materias': materiasSelecionadas.keys
                .where((k) => materiasSelecionadas[k]!)
                .toList(),
          };

          try {
            var userDoc = await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .get();

            var userData = userDoc.data();
            if (userData == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Erro: Não foi possível obter os dados do usuário.')));
              return;
            }

            List<dynamic> cursoSemestreMateriaArray =
                userData['cursoSemestreMateria'] as List<dynamic>? ?? [];

            int index = cursoSemestreMateriaArray.indexWhere((item) =>
                item['curso'] == widget.cursoId &&
                item['semestre'] == widget.semestre);

            if (index >= 0) {
              cursoSemestreMateriaArray[index] = cursoSemestreMateria;
            } else {
              cursoSemestreMateriaArray.add(cursoSemestreMateria);
            }

            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .update({
              'cursoSemestreMateria': cursoSemestreMateriaArray,
            });

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Matérias selecionadas com sucesso!')));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao selecionar matérias: $e')));
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
