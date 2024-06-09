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
  void initState() {
    super.initState();
    _carregarSelecoesIniciais();
  }

  Future<void> _carregarSelecoesIniciais() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var userData = userDoc.data() as Map<String, dynamic>?;

    if (userData != null && userData['cursoSemestreMateria'] != null) {
      List<dynamic> selecoes = userData['cursoSemestreMateria'];
      var selecaoAtual = selecoes.firstWhere(
          (s) =>
              s['curso'] == widget.cursoId && s['semestre'] == widget.semestre,
          orElse: () => null);

      if (selecaoAtual != null) {
        setState(() {
          materiasSelecionadas = Map.fromIterable(selecaoAtual['materias'],
              key: (e) => e, value: (e) => true);
        });
      }
    }
  }

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
              var materia = materias[index];
              bool isSelected = materiasSelecionadas[materia['nome']] ?? false;

              return CheckboxListTile(
                title: Text(materia['nome']),
                subtitle: Text(materia['descricao']),
                value: isSelected,
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    _updateMateriasSelecionadas(materia['nome'], newValue);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _salvarSelecoes,
        child: Icon(Icons.save),
        backgroundColor: Color.fromRGBO(239, 153, 45, 1),
      ),
    );
  }

  void _updateMateriasSelecionadas(String materiaNome, bool isSelected) {
    setState(() {
      materiasSelecionadas[materiaNome] = isSelected;
    });
  }

  Future<void> _salvarSelecoes() async {
    if (materiasSelecionadas.isEmpty ||
        !materiasSelecionadas.containsValue(true)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor, selecione pelo menos uma matéria.'),
      ));
      return;
    }

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
    var userData = userDoc.data() as Map<String, dynamic>;
    var cursoSemestreMateriaArray =
        userData['cursoSemestreMateria'] as List<dynamic>? ?? [];

    // Encontra o índice do item correspondente ao curso e semestre, se existir
    int index = cursoSemestreMateriaArray.indexWhere((item) =>
        item['curso'] == widget.cursoId && item['semestre'] == widget.semestre);

    if (index >= 0) {
      // Se o item já existir, atualiza-o
      cursoSemestreMateriaArray[index] = cursoSemestreMateria;
    } else {
      // Se o item não existir, adiciona-o
      cursoSemestreMateriaArray.add(cursoSemestreMateria);
    }

    // Atualiza o documento do usuário
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({
      'cursoSemestreMateria': cursoSemestreMateriaArray,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Matérias selecionadas com sucesso!')));
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }
}
