import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selecionar_semestre.dart';

class SelecionarCursoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione seu Curso'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
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
