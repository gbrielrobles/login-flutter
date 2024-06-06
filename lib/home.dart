import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enviar_mensagem.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EnviarMensagemScreen()),
            );
          },
          child: Text('Enviar Mensagem'),
        ),
      ),
    );
  }
}

class SelecionarSemestreScreen extends StatelessWidget {
  final String cursoId;

  SelecionarSemestreScreen({required this.cursoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione seu semestre'),
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
                  var user = FirebaseAuth.instance.currentUser;
                  var cursoSemestre = {
                    'curso': cursoData['nome'],
                    'semestre': semestres[index],
                  };

                  // Atualize o documento do usuário com o novo atributo
                  FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user!.uid)
                      .update({
                    'cursoSemestre': cursoSemestre,
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Curso e semestre selecionados com sucesso!'),
                    ));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Erro ao selecionar curso e semestre: $error'),
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
