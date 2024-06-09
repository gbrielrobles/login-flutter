import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Importação do pacote intl
import 'enviar_mensagem.dart';
import 'selecionar_curso.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _mensagens = [];
  bool _mostrarNaoLidas = false; // Inicialmente mostrando todas as mensagens
  String _materiaSelecionada = '';
  List<String> _materias = [];

  Future<void> _fetchMensagens() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      var userData = userDoc.data() as Map<String, dynamic>;
      var cursoSemestreMateria =
          userData['cursoSemestreMateria'] as List<dynamic>;
      List<Map<String, dynamic>> mensagens = [];
      _materias = [];

      for (var item in cursoSemestreMateria) {
        _materias.addAll(List<String>.from(item['materias']));
        var mensagensSnapshot = await FirebaseFirestore.instance
            .collection('mensagens')
            .where('curso', isEqualTo: item['curso'])
            .where('semestre', isEqualTo: item['semestre'])
            .get();

        for (var doc in mensagensSnapshot.docs) {
          var msgData = doc.data() as Map<String, dynamic>;
          bool isRead = msgData['visualizadores']?.contains(user.uid) ?? false;
          if ((!_mostrarNaoLidas || !isRead) &&
              (_materiaSelecionada.isEmpty ||
                  msgData['materias'].contains(_materiaSelecionada))) {
            mensagens.add({'id': doc.id, ...msgData});
          }
        }
      }
      setState(() {
        _mensagens = mensagens;
        _materias = _materias.toSet().toList();
      });
    }
  }

  void _markMessageAsRead(Map<String, dynamic> message) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        !(message['visualizadores']?.contains(user.uid) ?? false)) {
      FirebaseFirestore.instance
          .collection('mensagens')
          .doc(message['id'])
          .update({
        'visualizadores': FieldValue.arrayUnion([user.uid])
      });
    }
  }

  Future<bool> isProfessor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      var userData = userDoc.data() as Map<String, dynamic>;
      return userData['tipoUsuario'] == 'Professor';
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _fetchMensagens(); // Chamar ao iniciar para carregar todas as mensagens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SelecionarCursoScreen())),
        ),
      ),
      body: _mensagens.isEmpty
          ? const Center(child: Text('Nenhuma mensagem encontrada.'))
          : ListView.builder(
              itemCount: _mensagens.length,
              itemBuilder: (context, index) {
                var mensagem = _mensagens[index];
                bool isRead = mensagem['visualizadores']
                        ?.contains(FirebaseAuth.instance.currentUser?.uid) ??
                    false;
                return ListTile(
                  title: Text(mensagem['titulo']),
                  subtitle: Text(mensagem['mensagem']),
                  trailing: Text(DateFormat('dd/MM/yyyy HH:mm')
                      .format(mensagem['data'].toDate())),
                  onTap: () {
                    _markMessageAsRead(mensagem);
                    _handleMessageTap(mensagem);
                  },
                  tileColor: isRead
                      ? null
                      : Colors
                          .green[50], // Alterar a cor para mensagens não lidas
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[800], // Definindo a cor verde no BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(),
            ),
            IconButton(
              icon: Icon(Icons.email),
              color: _mostrarNaoLidas ? Colors.blue : Colors.grey,
              onPressed: () {
                setState(() {
                  _mostrarNaoLidas = !_mostrarNaoLidas;
                  _fetchMensagens();
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: isProfessor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(); // Esconder o botão enquanto carrega
          }
          return snapshot.data == true
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnviarMensagemScreen()))
                      .then((_) => _fetchMensagens()),
                  child: Icon(Icons.add),
                  backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
                )
              : Container(); // Esconder o botão se não for professor
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por Matéria'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _materias
                  .map((materia) => CheckboxListTile(
                        title: Text(materia),
                        value: _materiaSelecionada == materia,
                        onChanged: (bool? value) {
                          if (value != null && value) {
                            setState(() {
                              _materiaSelecionada = value ? materia : '';
                              Navigator.pop(context);
                              _fetchMensagens();
                            });
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _handleMessageTap(Map<String, dynamic> mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mensagem['titulo']),
        content: Text(mensagem['mensagem']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
