// ignore_for_file: library_private_types_in_public_api, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enviar_mensagem.dart'; // Importe a tela de envio de mensagem
import 'selecionar_curso.dart'; // Importe a tela de seleção de curso

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _filteredMessages = [];
  bool _materiaFilter = false;
  bool _lidoFilter = false;
  List<String> _materiasUsuario = []; // Lista de matérias do usuário

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

      // Lista de matérias do usuário
      _materiasUsuario = [];
      for (var item in cursoSemestreMateria) {
        _materiasUsuario.addAll(item['materias'].cast<String>());
      }

      return mensagens;
    }
    return [];
  }

  void filterMateria(List<Map<String, dynamic>> mensagens, String materia) {
    setState(() {
      _filteredMessages = mensagens.where((mensagem) {
        List materias = mensagem['materias'];
        return materias.contains(materia);
      }).toList();
      _materiaFilter = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma mensagem encontrada.'));
          }

          var mensagens = _materiaFilter ? _filteredMessages : snapshot.data!;
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
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF3A5C33),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              //Botão de ver lista de matérias para filtrar
              IconButton(
                tooltip: 'Filtrar Por Matéria',
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                },
              ),

              //Botão de filtrar lidas e não lidas 
              IconButton(
                tooltip: 'Filtrar Não Lidas',
                icon: Icon(_lidoFilter
                    ? Icons.mark_email_unread
                    : Icons.mark_email_unread_outlined),
                onPressed: () {
                  setState(() {
                    _lidoFilter = !_lidoFilter;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
