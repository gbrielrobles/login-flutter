import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enviar_mensagem.dart'; // Importe a tela de envio de mensagem
import 'selecionar_curso.dart'; // Importe a tela de seleção de curso

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Map<String, dynamic>>> _fetchMensagens() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      var userData = userDoc.data() as Map<String, dynamic>;
      var cursoSemestreMateria =
          userData['cursoSemestreMateria'] as List<dynamic>;

      List<Map<String, dynamic>> mensagens = [];
      for (var item in cursoSemestreMateria) {
        QuerySnapshot mensagensSnapshot = await FirebaseFirestore.instance
            .collection('mensagens')
            .where('curso', isEqualTo: item['curso'])
            .where('semestre', isEqualTo: item['semestre'])
            .where('materias', arrayContainsAny: item['materias'])
            .get();
        mensagens.addAll(mensagensSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
      }
      return mensagens;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SelecionarCursoScreen()),
            );
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMensagens(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma mensagem encontrada.'));
          }

          var mensagens = snapshot.data!;
          return ListView.builder(
            itemCount: mensagens.length,
            itemBuilder: (context, index) {
              var mensagem = mensagens[index];
              return ListTile(
                title: Text(mensagem['titulo']),
                subtitle: Text(mensagem['mensagem']),
                trailing: Text(mensagem['data'].toDate().toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnviarMensagemScreen(
                        mensagemId: mensagem['id'],
                        titulo: mensagem['titulo'],
                        mensagem: mensagem['mensagem'],
                        curso: mensagem['curso'],
                        semestre: mensagem['semestre'],
                        materias: List<String>.from(mensagem['materias']),
                        data: mensagem['data'].toDate(),
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnviarMensagemScreen()),
          ).then((_) {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
      ),
    );
  }
}
