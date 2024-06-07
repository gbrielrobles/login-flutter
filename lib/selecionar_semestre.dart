import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selecionar_materia.dart';

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelecionarMateriaScreen(
                        cursoId: cursoId,
                        semestre: semestre.get('nome'),
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
