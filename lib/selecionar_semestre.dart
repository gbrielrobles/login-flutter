import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selecionar_materia.dart'; // Importar a tela de seleção de matéria

class SelecionarSemestreScreen extends StatelessWidget {
  final String cursoId;

  SelecionarSemestreScreen({required this.cursoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione seu Semestre'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
      ),
      backgroundColor: Color.fromRGBO(230, 231, 232, 1),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('cursos').doc(cursoId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var cursoData = snapshot.data!.data() as Map<String, dynamic>;
          var semestres = cursoData['semestres'] as List<dynamic>;

          return ListView.builder(
            itemCount: semestres.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(semestres[index]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelecionarMateriaScreen(
                        cursoId: cursoId,
                        semestre: semestres[index],
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
