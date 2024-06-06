import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Importar a tela inicial ou outra tela de destino
import 'package:firebase_auth/firebase_auth.dart';

class SelecionarMateriaScreen extends StatelessWidget {
  final String cursoId;
  final String semestre;

  SelecionarMateriaScreen({required this.cursoId, required this.semestre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione sua Matéria'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
      ),
      backgroundColor: Color.fromRGBO(230, 231, 232, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('materias').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var materias = snapshot.data!.docs;

          return ListView.builder(
            itemCount: materias.length,
            itemBuilder: (context, index) {
              var materia = materias[index];
              return ListTile(
                title: Text(materia['nome']),
                onTap: () {
                  var user = FirebaseAuth.instance.currentUser;
                  var cursoSemestreMateria = {
                    'curso': cursoId,
                    'semestre': semestre,
                    'materia': materia['nome'],
                  };

                  // Atualize o documento do usuário com o novo atributo
                  FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user!.uid)
                      .update({
                    'cursoSemestreMateria': cursoSemestreMateria,
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Matéria selecionada com sucesso!'),
                    ));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Erro ao selecionar matéria: $error'),
                    ));
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
